
import Combine
import KeychainAccess
import LiveKit
import SwiftUI

struct Preferences: Codable, Equatable {
    var url = ""
    var token = ""
    var e2eeKey = ""
    var isE2eeEnabled = false

    // Connect options
    var autoSubscribe = true

    // Room options
    var simulcast = true
    var adaptiveStream = true
    var dynacast = true
    var reportStats = true

    // Settings
    var videoViewVisible = true
    var showInformationOverlay = false
    var preferSampleBufferRendering = false
    var videoViewMode: VideoView.LayoutMode = .fit
    var videoViewMirrored = false

    var connectionHistory = Set<ConnectionHistory>()
}

let encoder = JSONEncoder()
let decoder = JSONDecoder()

@MainActor
final class ValueStore<T: Codable & Equatable> {
    private let store: Keychain
    private let key: String
    private let message = ""
    private var syncTask: Task<Void, Never>?

    public var value: T {
        didSet {
            guard oldValue != value else { return }
            lazySync()
        }
    }

    private var storeWithOptions: Keychain {
        store
            .accessibility(.whenUnlocked)
            .synchronizable(true)
    }

    public init(store: Keychain, key: String, default: T) {
        self.store = store
        self.key = key
        value = `default`

        if let data = try? storeWithOptions.getData(key),
           let result = try? decoder.decode(T.self, from: data)
        {
            value = result
        }
    }

    deinit {
        syncTask?.cancel()
    }

    public func lazySync() {
        syncTask?.cancel()
        syncTask = Task {
            try? await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)
            guard !Task.isCancelled else { return }
            sync()
        }
    }

    public func sync() {
        do {
            let data = try encoder.encode(value)
            try storeWithOptions.set(data, key: key)
        } catch {
            print("Failed to write in Keychain, error: \(error)")
        }
    }
}
