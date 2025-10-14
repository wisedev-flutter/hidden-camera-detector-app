# Hidden Camera Detector App — Architecture Notes

## Top-Level Entrypoints
- `lib/main.dart`: Sole executable that boots the shared presentation layer (`HiddenCameraDetectorApp`).

## Presentation Layer
- `lib/src/presentation/app/app.dart`: Declares the root MaterialApp, seed theme, and a temporary scaffold pending feature implementation.
- `lib/src/presentation/`: Reserved for UI widgets, screens, navigation, and Riverpod providers (directory scaffolded).

## Domain Layer
- `lib/src/domain/`: Placeholder for entities, repositories, and use cases defined in the implementation plan; currently contains a `.gitkeep` so structure exists before code generation.

## Data Layer
- `lib/src/data/`: Planned home for repositories, data sources, and Pigeon integrations referencing Swift native code.

## Shared Utilities
- `lib/core/`: Intended for shared utilities (constants, error models, logging adapters). A `.gitkeep` maintains the folder until populated.

## Environment & Configuration
- `pubspec.yaml`: Includes `flutter_launcher_icons` and `flutter_native_splash` dev tools and references placeholder branding assets.
- `assets/branding/app_icon.png`, `splash_icon.png`: Temporary solid-color assets consumed by icon/splash generators.

## iOS Project Configuration
- `ios/Runner.xcodeproj/project.pbxproj`: Uses Flutter’s default Debug/Profile/Release build configurations (iOS 14.0 min target) without flavor-specific overrides.
- `ios/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme`: Single shared scheme aligned with the standard configurations.
- Generated icon/splash assets reside under `ios/Runner/Assets.xcassets` (automatically updated by tooling).
