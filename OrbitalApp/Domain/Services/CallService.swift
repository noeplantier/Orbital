import Foundation

/// Abstraction over a calling backend (WebRTC/Twilio/Agora/...). `MockCallService` simulates it
/// in-memory so the UI is fully functional before a real SDK is wired in — see Data/Call.
protocol CallService: AnyObject {
    /// Long-lived stream of call state changes. ViewModels subscribe once (in `init`) and react to every update.
    var callStateStream: AsyncStream<CallState> { get }

    func fetchAvailableRooms() async throws -> [CallRoom]
    func createRoom(named name: String) async throws -> CallRoom
    func join(roomID: String) async throws
    func leaveCurrentRoom() async
    func setMicrophoneEnabled(_ isEnabled: Bool) async
    func setCameraEnabled(_ isEnabled: Bool) async
}
