import Foundation

struct CallRoom: Identifiable, Equatable {
    let id: String
    let name: String
    let participantCount: Int
}

struct CallParticipant: Identifiable, Equatable {
    let id: String
    let displayName: String
    let isLocal: Bool
    var isMicrophoneMuted: Bool
    var isCameraEnabled: Bool
}

/// Snapshot of an in-progress call, streamed by `CallService` to anyone observing it.
/// Modeling this as an enum (rather than several optional flags) makes illegal states unrepresentable.
enum CallState: Equatable {
    case idle
    case connecting(roomID: String)
    case connected(room: CallRoom, participants: [CallParticipant])
    case ended
    case failed(CallError)
}
