import Foundation

/// Simulates a WebRTC/Twilio/Agora-style backend entirely in memory. Replace with a real adapter
/// (e.g. `TwilioCallService`, `AgoraCallService`) later — every screen in Presentation/Call only
/// ever talks to the `CallService` protocol, so the swap is contained to this one file.
final class MockCallService: CallService {
    let callStateStream: AsyncStream<CallState>
    private let continuation: AsyncStream<CallState>.Continuation

    private var rooms: [CallRoom]
    private var isMicrophoneEnabled = true
    private var isCameraEnabled = true

    init() {
        let (stream, continuation) = AsyncStream.makeStream(of: CallState.self)
        self.callStateStream = stream
        self.continuation = continuation
        self.rooms = [
            CallRoom(id: "room-design", name: "Design Sync", participantCount: 2),
            CallRoom(id: "room-standup", name: "Daily Standup", participantCount: 4),
            CallRoom(id: "room-investor", name: "Investor Update", participantCount: 1)
        ]
        continuation.yield(.idle)
    }

    func fetchAvailableRooms() async throws -> [CallRoom] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return rooms
    }

    func createRoom(named name: String) async throws -> CallRoom {
        try await Task.sleep(nanoseconds: 250_000_000)
        let room = CallRoom(id: UUID().uuidString, name: name, participantCount: 0)
        rooms.append(room)
        return room
    }

    func join(roomID: String) async throws {
        guard let room = rooms.first(where: { $0.id == roomID }) else {
            continuation.yield(.failed(.roomNotFound))
            throw CallError.roomNotFound
        }
        continuation.yield(.connecting(roomID: roomID))
        try await Task.sleep(nanoseconds: 800_000_000) // simulated signaling/ICE negotiation delay

        let localParticipant = CallParticipant(
            id: "local",
            displayName: "You",
            isLocal: true,
            isMicrophoneMuted: !isMicrophoneEnabled,
            isCameraEnabled: isCameraEnabled
        )
        let remoteParticipants = (0..<room.participantCount).map { index in
            CallParticipant(
                id: "remote-\(index)",
                displayName: "Teammate \(index + 1)",
                isLocal: false,
                isMicrophoneMuted: false,
                isCameraEnabled: true
            )
        }
        continuation.yield(.connected(room: room, participants: [localParticipant] + remoteParticipants))
    }

    func leaveCurrentRoom() async {
        continuation.yield(.ended)
        try? await Task.sleep(nanoseconds: 150_000_000)
        continuation.yield(.idle)
    }

    func setMicrophoneEnabled(_ isEnabled: Bool) async {
        isMicrophoneEnabled = isEnabled
    }

    func setCameraEnabled(_ isEnabled: Bool) async {
        isCameraEnabled = isEnabled
    }
}
