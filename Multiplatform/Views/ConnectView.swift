

import Foundation
import LiveKit
import SFSafeSymbols
import SwiftUI

struct ConnectView: View {
    @EnvironmentObject var appCtx: AppContext
    @EnvironmentObject var roomCtx: RoomContext
    @EnvironmentObject var room: Room

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .center, spacing: 40.0) {
                    VStack(spacing: 10) {
                        Image("logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 30)
                            .padding(.bottom, 10)
                        Text("SDK Version \(LiveKitSDK.version)")
                            .opacity(0.5)
                        Text("Example App Version \(Bundle.main.appVersionLong) (\(Bundle.main.appBuild))")
                            .opacity(0.5)
                    }

                    VStack(spacing: 15) {
                        LKTextField(title: "Server URL", text: $roomCtx.url, type: .URL)
                        LKTextField(title: "Token", text: $roomCtx.token, type: .secret)
                        LKTextField(title: "E2EE Key", text: $roomCtx.e2eeKey, type: .secret)

                        HStack {
                            Menu {
                                Toggle("Auto-Subscribe", isOn: $roomCtx.autoSubscribe)
                                Toggle("Enable E2EE", isOn: $roomCtx.isE2eeEnabled)
                            } label: {
                                Image(systemSymbol: .boltFill)
                                    .renderingMode(.original)
                                Text("Connect Options")
                            }
                            #if os(macOS)
                            .menuIndicator(.visible)
                            .menuStyle(BorderlessButtonMenuStyle())
                            #elseif os(iOS)
                            .menuStyle(BorderlessButtonMenuStyle())
                            #endif
                            .fixedSize()

                            Menu {
                                Toggle("Simulcast", isOn: $roomCtx.simulcast)
                                Toggle("AdaptiveStream", isOn: $roomCtx.adaptiveStream)
                                Toggle("Dynacast", isOn: $roomCtx.dynacast)
                                Toggle("Report stats", isOn: $roomCtx.reportStats)
                            } label: {
                                Image(systemSymbol: .gear)
                                    .renderingMode(.original)
                                Text("Room Options")
                            }
                            #if os(macOS)
                            .menuIndicator(.visible)
                            .menuStyle(BorderlessButtonMenuStyle())
                            #elseif os(iOS)
                            .menuStyle(BorderlessButtonMenuStyle())
                            #endif
                            .fixedSize()
                        }
                    }.frame(maxWidth: 350)

                    if case .connecting = room.connectionState {
                        HStack(alignment: .center) {
                            ProgressView()

                            LKButton(title: "Cancel") {
                                roomCtx.cancelConnect()
                            }
                        }
                    } else {
                        HStack(alignment: .center) {
                            Spacer()

                            LKButton(title: "Connect") {
                                Task { @MainActor in
                                    let room = try await roomCtx.connect()
                                    appCtx.connectionHistory.update(room: room, e2ee: roomCtx.isE2eeEnabled, e2eeKey: roomCtx.e2eeKey)
                                }
                            }

                            if !appCtx.connectionHistory.isEmpty {
                                Menu {
                                    ForEach(appCtx.connectionHistory.sortedByUpdated) { entry in
                                        Button {
                                            Task { @MainActor in
                                                let room = try await roomCtx.connect(entry: entry)
                                                appCtx.connectionHistory.update(room: room, e2ee: roomCtx.isE2eeEnabled, e2eeKey: roomCtx.e2eeKey)
                                            }
                                        } label: {
                                            Image(systemSymbol: .boltFill)
                                                .renderingMode(.original)
                                            Text(String(describing: entry))
                                        }
                                    }

                                    Divider()

                                    Button {
                                        appCtx.connectionHistory.removeAll()
                                    } label: {
                                        Image(systemSymbol: .xmarkCircleFill)
                                            .renderingMode(.original)
                                        Text("Clear history")
                                    }

                                } label: {
                                    Image(systemSymbol: .clockFill)
                                        .renderingMode(.original)
                                    Text("Recent")
                                }
                                #if os(macOS)
                                .menuIndicator(.visible)
                                .menuStyle(BorderlessButtonMenuStyle())
                                #elseif os(iOS)
                                .menuStyle(BorderlessButtonMenuStyle())
                                #endif
                                .fixedSize()
                            }

                            Spacer()
                        }
                    }
                }
                .padding()
                .frame(width: geometry.size.width) // Make the scroll view full-width
                .frame(minHeight: geometry.size.height) // Set the content’s min height to the parent
            }
        }
        #if os(macOS)
        .frame(minWidth: 500, minHeight: 500)
        #endif
        .alert(isPresented: $roomCtx.shouldShowDisconnectReason) {
            Alert(title: Text("Disconnected"),
                  message: Text("Reason: " + String(describing: roomCtx.latestError)))
        }
    }
}
