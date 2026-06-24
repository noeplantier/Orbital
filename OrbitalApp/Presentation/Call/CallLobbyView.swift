import SwiftUI

struct CallLobbyView: View {
    @ObservedObject var viewModel: CallViewModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        TextField("New room name", text: $viewModel.newRoomName)
                        Button("Start") {
                            Task { await viewModel.createAndJoinRoom() }
                        }
                        .disabled(viewModel.newRoomName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                } header: {
                    Text("Start a new call")
                }

                Section {
                    if viewModel.isLoadingRooms {
                        ProgressView().frame(maxWidth: .infinity)
                    } else if viewModel.rooms.isEmpty {
                        Text("No rooms yet — start one above.")
                            .foregroundStyle(Color.orbitalTextSecondary)
                    } else {
                        ForEach(viewModel.rooms) { room in
                            RoomRow(room: room) {
                                Task { await viewModel.join(roomID: room.id) }
                            }
                        }
                    }
                } header: {
                    Text("Join a room")
                }
            }
            .navigationTitle("Calls")
            .task { await viewModel.loadRooms() }
            .refreshable { await viewModel.loadRooms() }
            .snackbar($viewModel.presentedSnackbar)
            .fullScreenCover(isPresented: isInCallBinding) {
                InCallView(viewModel: viewModel)
            }
        }
    }

    /// Drives the in-call presentation purely off `CallState` so there's exactly one source of truth
    /// for "are we in a call" — no separate `@State isShowingCall` flag to fall out of sync.
    private var isInCallBinding: Binding<Bool> {
        Binding(
            get: {
                switch viewModel.callState {
                case .connecting, .connected: return true
                case .idle, .ended, .failed: return false
                }
            },
            set: { isPresented in
                if !isPresented {
                    Task { await viewModel.leaveCall() }
                }
            }
        )
    }
}

private struct RoomRow: View {
    let room: CallRoom
    let onJoin: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(room.name).font(.orbitalHeadline)
                Text("\(room.participantCount) already in the room")
                    .font(.orbitalCaption)
                    .foregroundStyle(Color.orbitalTextSecondary)
            }
            Spacer()
            Button("Join", action: onJoin)
                .buttonStyle(.bordered)
                .tint(Color.orbitalPrimary)
        }
    }
}

#Preview {
    let service = MockCallService()
    CallLobbyView(viewModel: CallViewModel(callService: service, joinCallUseCase: JoinCallUseCase(callService: service)))
}
