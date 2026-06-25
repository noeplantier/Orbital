import Foundation

@MainActor
final class CallViewModel: ObservableObject {
    @Published var rooms: [CallRoom] = []
    @Published var callState: CallState = .idle
    @Published var newRoomName: String = ""
    @Published var presentedSnackbar: SnackbarMessage?
    @Published var isLoadingRooms = false

    private let callService: CallService
    private let joinCallUseCase: JoinCallUseCase

    init(callService: CallService, joinCallUseCase: JoinCallUseCase) {
        self.callService = callService
        self.joinCallUseCase = joinCallUseCase
        observeCallState()
    }

    /// Subscribes once for the lifetime of this ViewModel — the long-lived `callStateStream` is the
    /// single source of truth for call state, so the UI and the (eventual) real SDK never disagree.
    private func observeCallState() {
        Task { [weak self] in
            guard let self else { return }
            for await state in self.callService.callStateStream {
                self.callState = state
                if case .failed(let error) = state {
                    self.presentedSnackbar = SnackbarMessage(text: error.localizedDescription, style: .error)
                }
            }
        }
    }

    func loadRooms() async {
        isLoadingRooms = true
        defer { isLoadingRooms = false }
        do {
            rooms = try await callService.fetchAvailableRooms()
        } catch {
            presentedSnackbar = SnackbarMessage(text: "Couldn't load rooms.", style: .error)
        }
    }

    func createAndJoinRoom() async {
        let name = newRoomName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        do {
            let room = try await callService.createRoom(named: name)
            newRoomName = ""
            await join(roomID: room.id)
        } catch {
            presentedSnackbar = SnackbarMessage(text: "Couldn't create the room.", style: .error)
        }
    }

    func join(roomID: String) async {
        do {
            try await joinCallUseCase.execute(roomID: roomID, currentState: callState)
        } catch let error as CallError {
            presentedSnackbar = SnackbarMessage(text: error.errorDescription ?? "Couldn't join the call.", style: .error)
        } catch {
            presentedSnackbar = SnackbarMessage(text: "Couldn't join the call.", style: .error)
        }
    }

    func leaveCall() async {
        await callService.leaveCurrentRoom()
    }

    /// Applied optimistically to the local participant for instant UI feedback, then forwarded to
    /// the service. A real SDK would also broadcast this change to remote participants.
    func toggleMicrophone() async {
        guard case .connected(let room, var participants) = callState,
              let localIndex = participants.firstIndex(where: { $0.isLocal }) else { return }
        participants[localIndex].isMicrophoneMuted.toggle()
        callState = .connected(room: room, participants: participants)
        await callService.setMicrophoneEnabled(!participants[localIndex].isMicrophoneMuted)
    }

    func toggleCamera() async {
        guard case .connected(let room, var participants) = callState,
              let localIndex = participants.firstIndex(where: { $0.isLocal }) else { return }
        participants[localIndex].isCameraEnabled.toggle()
        callState = .connected(room: room, participants: participants)
        await callService.setCameraEnabled(participants[localIndex].isCameraEnabled)
    }
}
