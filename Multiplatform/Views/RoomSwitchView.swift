

import LiveKit
import SwiftUI

struct RoomSwitchView: View {
    @EnvironmentObject var appCtx: AppContext
    @EnvironmentObject var roomCtx: RoomContext
    @EnvironmentObject var room: Room

    #if os(visionOS)
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    #endif

    var shouldShowRoomView: Bool {
        room.connectionState == .connected || room.connectionState == .reconnecting
    }

    private var navigatonTitle: String {
        guard shouldShowRoomView else { return "LiveKit" }
        return [
            room.name,
            room.localParticipant.name,
            room.localParticipant.identity.map(\.stringValue),
        ]
        .compactMap { $0 }
        .joined(separator: " ")
    }

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            if shouldShowRoomView {
                RoomView()
            } else {
                ConnectView()
            }
        }
        .preferredColorScheme(.dark)
        .navigationTitle(navigatonTitle)
        .onChange(of: shouldShowRoomView) { newValue in
            #if os(visionOS)
            Task {
                if newValue {
                    await openImmersiveSpace(id: "ImmersiveSpace")
                } else {
                    await dismissImmersiveSpace()
                }
            }
            #endif
        }
    }
}
