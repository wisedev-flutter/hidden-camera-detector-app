## 2025-10-14 — Step 1 (Project Setup)
- Refactored `lib/main.dart` to bootstrap the new `HiddenCameraDetectorApp` and created the presentation scaffold at `lib/src/presentation/app/app.dart`.
- Established Clean Architecture directories with placeholders (`lib/src/presentation`, `lib/src/domain`, `lib/src/data`, `lib/core`).
- Added flavor-specific entrypoints and dart-define configs (`lib/main_development.dart`, `lib/main_staging.dart`, `lib/main_production.dart`, `dart_defines/*.json`).
- Configured iOS build flavors, bundle IDs, and shared schemes via new xcconfig files and `Runner.xcodeproj` updates.
- Introduced launcher/splash tooling in `pubspec.yaml`, created placeholder branding assets, and generated iOS icons and native splash resources.

## 2025-10-14 — Flavor Clean-Up
- Removed custom iOS flavor xcconfigs, build configurations, and auxiliary schemes to return Xcode to the standard Debug/Profile/Release setup.
- Deleted flavor-specific Flutter entrypoints and `dart_defines` files; simplified VS Code launch config to run `lib/main.dart` directly.
