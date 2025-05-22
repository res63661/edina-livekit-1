
import KeychainAccess
import LiveKit
import Logging
import SwiftUI

@MainActor let sync = ValueStore<Preferences>(store: Keychain(service: "io.livekit.example.SwiftSDK.1"),
                                              key: "preferences",
                                              default: Preferences())

@main
struct LiveKitExample: App {
    @StateObject var appCtx = AppContext(store: sync)

    #if os(visionOS)
    @Environment(\.openWindow) var openWindow
    #endif

    var body: some Scene {
        WindowGroup {
            RoomContextView()
                .environmentObject(appCtx)
        }
        #if !os(tvOS)
        .handlesExternalEvents(matching: Set(arrayLiteral: "*"))
        #endif
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unifiedCompact)
        #endif

        #if os(visionOS)
        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
        .immersionStyle(selection: .constant(.full), in: .full)
        #endif
    }

    init() {
        LoggingSystem.bootstrap {
            var logHandler = StreamLogHandler.standardOutput(label: $0)
            logHandler.logLevel = .debug
            return logHandler
        }
    }
}
