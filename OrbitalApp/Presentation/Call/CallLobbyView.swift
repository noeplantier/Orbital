import SwiftUI

struct CallLobbyView: View {
    @ObservedObject var viewModel: CallViewModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                    newRoomRow
                } header: {
                    SectionHeader(title: "Start a new call")
                }
                .textCase(nil)
                .listRowBackground(Color.orbitalSurface)

                Section {
                    roomsContent
                } header: {
                    SectionHeader(title: "Join a room")
                }
                .textCase(nil)
                .listRowBackground(Color.orbitalSurface)
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.orbitalBackground)
            .navigationTitle("Calls")
            .task { await viewModel.loadRooms() }
            .refreshable { await viewModel.loadRooms() }
            .snackbar($viewModel.presentedSnackbar)
            .fullScreenCover(isPresented: isInCallBinding) {
                InCallView(viewModel: viewModel)
            }
        }
    }

    private var newRoomRow: some View {
        HStack(spacing: Spacing.sm) {
            TextField("New room name", text: $viewModel.newRoomName)
                .font(.orbitalBody)
            Button("Start") {
                Task { await viewModel.createAndJoinRoom() }
            }
            .font(.orbitalHeadline)
            .foregroundStyle(Color.orbitalPrimary)
            .frame(minHeight: 44)
            .disabled(viewModel.newRoomName.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.vertical, Spacing.xs)
    }

    @ViewBuilder
    private var roomsContent: some View {
        if viewModel.isLoadingRooms {
            LoadingStateView()
                .frame(height: 120)
                .listRowInsets(EdgeInsets())
        } else if viewModel.rooms.isEmpty {
            EmptyStateView(
                systemImage: "phone.down.circle",
                title: "No rooms yet",
                message: "Start a call above to create the first room."
            )
            .listRowInsets(EdgeInsets())
        } else {
            ForEach(viewModel.rooms) { room in
                RoomRow(room: room) {
                    Task { await viewModel.join(roomID: room.id) }
                }
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
        HStack(spacing: Spacing.md) {
            Avatar(name: room.name, size: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(room.name)
                    .font(.orbitalHeadline)
                    .foregroundStyle(Color.orbitalTextPrimary)
                Text(room.participantCount == 0 ? "Empty" : "\(room.participantCount) already in the room")
                    .font(.orbitalCaption)
                    .foregroundStyle(Color.orbitalTextSecondary)
            }

            Spacer()

            Button("Join", action: onJoin)
                .font(.orbitalSubheadline)
                .foregroundStyle(Color.orbitalPrimary)
                .frame(minWidth: 44, minHeight: 44)
        }
        .padding(.vertical, Spacing.xs)
    }
}

#Preview {
    let service = MockCallService()
    CallLobbyView(viewModel: CallViewModel(callService: service, joinCallUseCase: JoinCallUseCase(callService: service)))
}
