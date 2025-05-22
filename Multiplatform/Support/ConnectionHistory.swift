
import LiveKit
import SwiftUI

struct ConnectionHistory: Codable {
    let updated: Date
    let url: String
    let token: String
    let e2ee: Bool
    let e2eeKey: String
    let roomSid: Room.Sid?
    let roomName: String?
    let participantSid: Participant.Sid?
    let participantIdentity: Participant.Identity?
    let participantName: String?
}

extension ConnectionHistory: CustomStringConvertible {
    var description: String {
        var segments: [String] = []
        if let roomName {
            segments.append(String(describing: roomName))
        }
        if let participantIdentity {
            segments.append(String(describing: participantIdentity))
        }
        segments.append(url)
        return segments.joined(separator: " ")
    }
}

extension ConnectionHistory: Identifiable {
    var id: Int {
        hashValue
    }
}

extension ConnectionHistory: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
        hasher.combine(token)
    }

    static func == (lhs: ConnectionHistory, rhs: ConnectionHistory) -> Bool {
        lhs.url == rhs.url && lhs.token == rhs.token
    }
}

extension Sequence<ConnectionHistory> {
    var sortedByUpdated: [ConnectionHistory] {
        Array(self).sorted { $0.updated > $1.updated }
    }
}

extension Set<ConnectionHistory> {
    mutating func update(room: Room, e2ee: Bool, e2eeKey: String) {
        guard let url = room.url,
              let token = room.token else { return }

        let element = ConnectionHistory(
            updated: Date(),
            url: url,
            token: token,
            e2ee: e2ee,
            e2eeKey: e2eeKey,
            roomSid: room.sid,
            roomName: room.name,
            participantSid: room.localParticipant.sid,
            participantIdentity: room.localParticipant.identity,
            participantName: room.localParticipant.name
        )

        update(with: element)
    }
}
