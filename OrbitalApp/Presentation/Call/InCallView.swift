import SwiftUI

struct InCallView: View {
    @ObservedObject var viewModel: CallViewModel

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            remoteVideoArea

            VStack {
                HStack {
                    statusBadge
                    Spacer()
                }
                .padding()

                Spacer()

                HStack {
                    Spacer()
                    localVideoPreview
                        .padding()
                }

                controlBar
            }
        }
    }

    @ViewBuilder
    private var remoteVideoArea: some View {
        if case .connected(_, let participants) = viewModel.callState {
            let remoteParticipants = participants.filter { !$0.isLocal }
            if let remote = remoteParticipants.first {
                VideoPlaceholderView(participant: remote, isProminent: true)
            } else {
                waitingForOthersView
            }
        } else if case .connecting = viewModel.callState {
            VStack(spacing: 12) {
                ProgressView().tint(.white)
                Text("Connecting…").foregroundStyle(.white)
            }
        }
    }

    private var waitingForOthersView: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.wave.2.fill")
                .font(.system(size: 40))
                .foregroundStyle(.white.opacity(0.7))
            Text("Waiting for others to join…")
                .foregroundStyle(.white.opacity(0.7))
        }
    }

    @ViewBuilder
    private var localVideoPreview: some View {
        if case .connected(_, let participants) = viewModel.callState, let local = participants.first(where: \.isLocal) {
            VideoPlaceholderView(participant: local, isProminent: false)
                .frame(width: 100, height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(.white.opacity(0.3), lineWidth: 1))
        }
    }

    @ViewBuilder
    private var statusBadge: some View {
        if case .connected(let room, _) = viewModel.callState {
            Text(room.name)
                .font(.orbitalCaption)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Capsule().fill(.black.opacity(0.4)))
                .foregroundStyle(.white)
        }
    }

    private var controlBar: some View {
        HStack(spacing: 28) {
            CallControlButton(
                systemImage: isMicrophoneMuted ? "mic.slash.fill" : "mic.fill",
                isActive: !isMicrophoneMuted
            ) {
                Task { await viewModel.toggleMicrophone() }
            }

            CallControlButton(
                systemImage: isCameraEnabled ? "video.fill" : "video.slash.fill",
                isActive: isCameraEnabled
            ) {
                Task { await viewModel.toggleCamera() }
            }

            CallControlButton(systemImage: "phone.down.fill", tint: .orbitalDanger) {
                Task { await viewModel.leaveCall() }
            }
        }
        .padding(.vertical, 24)
    }

    private var isMicrophoneMuted: Bool {
        guard case .connected(_, let participants) = viewModel.callState else { return false }
        return participants.first(where: \.isLocal)?.isMicrophoneMuted ?? false
    }

    private var isCameraEnabled: Bool {
        guard case .connected(_, let participants) = viewModel.callState else { return true }
        return participants.first(where: \.isLocal)?.isCameraEnabled ?? true
    }
}

/// Stand-in for a real video frame. In production this is where you'd mount Twilio's `VideoView`,
/// Agora's `AgoraRtcVideoCanvas`, or a WebRTC `RTCMTLVideoView` via `UIViewRepresentable` — see the
/// architecture notes for how `CallService` makes that swap contained to the Data layer.
private struct VideoPlaceholderView: View {
    let participant: CallParticipant
    let isProminent: Bool

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.orbitalPrimary.opacity(0.6), .black], startPoint: .top, endPoint: .bottom)

            if participant.isCameraEnabled {
                VStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: isProminent ? 70 : 36))
                        .foregroundStyle(.white.opacity(0.9))
                    if isProminent {
                        Text(participant.displayName)
                            .font(.orbitalBody)
                            .foregroundStyle(.white)
                    }
                }
            } else {
                Image(systemName: "video.slash.fill")
                    .font(.system(size: isProminent ? 40 : 22))
                    .foregroundStyle(.white.opacity(0.6))
            }

            if participant.isMicrophoneMuted {
                VStack {
                    Spacer()
                    HStack {
                        Image(systemName: "mic.slash.fill")
                            .font(.caption)
                            .padding(6)
                            .background(Circle().fill(.black.opacity(0.5)))
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    .padding(8)
                }
            }
        }
    }
}

private struct CallControlButton: View {
    let systemImage: String
    var isActive: Bool = true
    var tint: Color = .white
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(backgroundFill == .white ? Color.black : Color.white)
                .frame(width: 60, height: 60)
                .background(Circle().fill(backgroundFill))
        }
    }

    private var backgroundFill: Color {
        if tint == .orbitalDanger { return .orbitalDanger }
        return isActive ? Color.white.opacity(0.25) : .white
    }
}

#Preview {
    let service = MockCallService()
    InCallView(viewModel: CallViewModel(callService: service, joinCallUseCase: JoinCallUseCase(callService: service)))
}
