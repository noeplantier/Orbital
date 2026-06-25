# Orbital

An iOS app scaffold: SwiftUI + Clean Architecture (Domain / Data / Presentation), with working Auth, Maps (3D camera), a SceneKit 3D preview, and audio/video calling — all running on in-memory mocks. No backend, no API keys, no package manager step.

## Run it

```bash
xcodegen generate   # regenerates OrbitalApp.xcodeproj from project.yml — skip if you just cloned, it's already committed
open OrbitalApp.xcodeproj
```

In Xcode: pick an iOS 17+ simulator → `Cmd R`.

**Login:** `demo@orbital.app` / `password123` (or sign up — nothing is persisted, it all resets on relaunch).

## Requirements

- Xcode 15+ (full app, not just Command Line Tools — see Troubleshooting)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen), only if you change `project.yml` or add/remove files: `brew install xcodegen`

## What you get

| Tab | What it shows |
|---|---|
| **Map** | User location, custom place pins, a route polyline, a 2D/3D camera toggle |
| **3D** | A SceneKit rotating cube (stand-in for a real `.usdz`), with speed/color/camera controls |
| **Calls** | A lobby to start/join mock rooms, then an in-call screen with mute/camera toggles |
| **Profile** | Signed-in user, logout, and a list of "coming soon" extension points |

Everything runs against mocks — [MockAuthRepository](OrbitalApp/Data/Auth/MockAuthRepository.swift), [MockMapRepository](OrbitalApp/Data/Map/MockMapRepository.swift), [MockCallService](OrbitalApp/Data/Call/MockCallService.swift) — and the UI follows a dynamic anthracite-dark / neutral-light design system that adapts to the system appearance.

## Project structure

```
OrbitalApp/
├── App/             DI container, session state, @main entry point
├── Domain/          protocols + entities + use cases — zero framework imports
├── Data/            mock implementations of the Domain protocols
└── Presentation/
    ├── DesignSystem/  colors, typography, spacing, reusable components
    └── Auth/ Map/ Scene3D/ Call/ Settings/ Home/   one folder per feature
```

Dependency rule: `Domain` knows nothing about `Data` or `Presentation`. Swapping a mock for a real backend (Firebase, Twilio/Agora, Mapbox) means adding one new file under `Data/` — nothing else changes.

## Tests

`Cmd U` in Xcode, or:

```bash
xcodebuild test -project OrbitalApp.xcodeproj -scheme OrbitalApp \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

(swap the simulator name for one you actually have: `xcrun simctl list devices available`)

## Troubleshooting

- **Build fails immediately / "No such module 'MapKit'"** — you're on Command Line Tools, not full Xcode: `sudo xcode-select -s /Applications/Xcode.app`.
- **Xcode shows red/missing files** — the file tree and `.xcodeproj` are out of sync; run `xcodegen generate` again.
- **Map centers on the ocean / no pins nearby** — the simulator has no real GPS. Simulator menu → Features → Location → Custom Location (or pick a city).
- **No camera/mic permission prompt in-call** — expected; the simulator has no real camera/mic, so video/audio in [InCallView](OrbitalApp/Presentation/Call/InCallView.swift) are placeholders by design, not a bug.
