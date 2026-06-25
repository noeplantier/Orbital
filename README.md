# MetaCity

A digital-twin city app: SwiftUI + Clean Architecture (Core / Models / Repositories / Services / Features / DesignSystem), with working Auth (email/password + a mocked "Continue with Google"), a 3D map, a real ARKit module, audio/video calling, and an Explore tab — running on in-memory mocks where there's no backend yet. No API keys required to build and run today.

## Run it

```bash
xcodegen generate   # regenerates MetaCity.xcodeproj from project.yml — skip if you just cloned, it's already committed
open MetaCity.xcodeproj
```

In Xcode: pick an iOS 17+ simulator → `Cmd R`.

**Login:** `demo@metacity.app` / `password123`, or tap **Continue with Google** (signs in as a mocked identity — no real OAuth wired up yet, see Roadmap). Nothing is persisted; it all resets on relaunch.

## Requirements

- Xcode 15+ (full app, not just Command Line Tools — see Troubleshooting)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen), only if you change `project.yml` or add/remove files: `brew install xcodegen`
- A physical iPhone to actually see the AR tab work (ARKit needs a camera — see below)

## What you get

| Tab | What it shows |
|---|---|
| **Explore** | Greeting, search-filtered nearby landmarks, tap one to open a 3D preview |
| **Map** | User location, custom place pins, a route polyline, a 2D/3D camera toggle |
| **AR** | Real ARKit (`ARSCNView` + world tracking): tap a detected surface to place a 3D marker. Falls back to a clear "needs a real device" message in the Simulator, which has no camera |
| **Calls** | A lobby to start/join mock rooms, then an in-call screen with mute/camera toggles |
| **Profile** | Signed-in user, logout, and a list of "coming soon" extension points |

Everything backend-shaped runs against mocks — [MockAuthRepository](MetaCity/Services/Auth/MockAuthRepository.swift), [MockMapRepository](MetaCity/Services/Map/MockMapRepository.swift), [MockCallService](MetaCity/Services/Call/MockCallService.swift) — behind protocols in [Repositories/](MetaCity/Repositories), so swapping in a real backend never touches a View or ViewModel. The UI follows a dynamic anthracite-dark / neutral-light design system that adapts to the system appearance.

## Project structure

```
MetaCity/
├── Core/            DI container, session state, @main entry point, use cases, error types
├── Models/          plain entities — zero framework imports
├── Repositories/    protocols only (the contracts: AuthRepository, MapRepository, CallService, ...)
├── Services/        concrete implementations of those protocols (mocks today, real backends later)
├── Networking/      reserved for real API/Firebase/WebRTC clients (empty until Phase 2+)
├── DesignSystem/     colors, typography, spacing, reusable components
└── Features/         Explore/ Map/ AR/ Calls/ Profile/ Auth/ Home/ — one folder per screen
```

## Tests

`Cmd U` in Xcode, or:

```bash
xcodebuild test -project MetaCity.xcodeproj -scheme MetaCity \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

(swap the simulator name for one you actually have: `xcrun simctl list devices available`)

## Roadmap (what's real vs. mocked vs. blocked)

This is being built in phases rather than all at once, since some of it genuinely needs infrastructure only you can provide:

1. **Foundation** (done) — rebrand, Core/Models/Repositories/Services/Features structure, 5-tab shell, Explore v1, real ARKit scaffold, Sign in with Apple-ready Auth.
2. **Explore + real-time presence** — nearby users, trending locations, glassmorphism visual pass.
3. **3D depth** — swap the placeholder cube for real USDZ landmark assets.
4. **Calls upgrade** — network quality indicator, messaging.
5. **Real backend** — your existing Firebase project (needs your `GoogleService-Info.plist` and exact bundle ID dropped in) plus a managed calling provider (Agora/Twilio/Stream — needs an API key).

Two things are worth knowing going in: **GLB models aren't natively supported on iOS** (RealityKit/SceneKit only load USDZ natively — GLB needs a third-party parser, not recommended for a flagship app), and **ARKit cannot be verified in the Simulator** (no camera) — the AR tab's code is real and will run on a physical device, but I can only confirm it compiles, not that tracking looks right, without one.

## Troubleshooting

- **Build fails immediately / "No such module 'MapKit'"** — you're on Command Line Tools, not full Xcode: `sudo xcode-select -s /Applications/Xcode.app`.
- **Xcode shows red/missing files** — the file tree and `.xcodeproj` are out of sync; run `xcodegen generate` again.
- **Map centers on the ocean / no pins nearby** — the simulator has no real GPS. Simulator menu → Features → Location → Custom Location (or pick a city).
- **AR tab shows "needs a real device"** — expected in the Simulator; build to a physical iPhone to actually place markers.
- **No camera/mic permission prompt in calls** — expected; the simulator has no real camera/mic, so video/audio in [InCallView](MetaCity/Features/Calls/InCallView.swift) are placeholders by design, not a bug.
