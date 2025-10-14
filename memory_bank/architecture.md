# Hidden Camera Detector App — Architecture Notes

## Top-Level Entrypoints
- `lib/main.dart`: Sole executable that boots the shared presentation layer (`HiddenCameraDetectorApp`).

## Presentation Layer
- `lib/src/presentation/app/app.dart`: Hosts `HiddenCameraDetectorApp`, now using `MaterialApp.router` with the shared `GoRouter` config and onboarding completion notifier.
- `lib/src/presentation/navigation/app_route.dart`: Enum of route identifiers and paths.
- `lib/src/presentation/navigation/app_router.dart`: Builds the `GoRouter` instance, handles onboarding skip + premium redirection hooks.
- `lib/src/presentation/screens/`: Onboarding is fully implemented (animated hero, permission flow, persistence hook); other screens currently use placeholder scaffolds.
- `lib/src/presentation/widgets/placeholder_scaffold.dart`: Reusable temporary UI scaffold leveraged by the placeholder screens (still used by unimplemented routes).
- `lib/src/presentation/widgets/scan_button.dart`: Parameterised CTA widget that surfaces scan type labels, icons, and premium/loader states.
- `lib/src/presentation/widgets/device_result_card.dart`: Displays device metadata, risk status, premium gating overlay, and integrates the proximity indicator.
- `lib/src/presentation/widgets/proximity_indicator.dart`: Converts RSSI readings into user-friendly signal strength feedback for Bluetooth results.
- `lib/src/presentation/onboarding/onboarding_storage.dart`: SharedPreferences wrapper storing onboarding completion.
- `lib/src/presentation/screens/dashboard_screen.dart`: Bottom-navigation dashboard that centralises Wi-Fi results, IR guidance, and premium-gated Bluetooth scanning.
- `lib/src/presentation/screens/paywall_screen.dart`: Paywall experience with blurred scan preview, mock offerings, and unlock/continue actions.
- `lib/src/presentation/screens/settings_screen.dart`: Settings hub exposing restore purchases, clear data, legal links, and app version metadata.
- `lib/src/presentation/theme/app_theme.dart`: Centralized light/dark `ThemeData` definitions applied app-wide.
- `lib/src/presentation/theme/theme_extensions.dart`: Custom theme extensions (`AppColors`, `AppTextStyles`) plus convenience getters for use throughout the UI.

## Domain Layer
- `lib/src/domain/`: Placeholder for entities, repositories, and use cases defined in the implementation plan; currently contains a `.gitkeep` so structure exists before code generation.

## Data Layer
- `lib/src/data/`: Planned home for repositories, data sources, and Pigeon integrations referencing Swift native code.

## Shared Utilities
- `lib/core/`: Intended for shared utilities (constants, error models, logging adapters). A `.gitkeep` maintains the folder until populated.

## Environment & Configuration
- `pubspec.yaml`: Includes `flutter_launcher_icons`, `flutter_native_splash`, plus runtime deps `go_router`, `permission_handler`, and `shared_preferences`.
- `assets/branding/app_icon.png`, `splash_icon.png`: Temporary solid-color assets consumed by icon/splash generators.

## iOS Project Configuration
- `ios/Runner.xcodeproj/project.pbxproj`: Uses Flutter’s default Debug/Profile/Release build configurations (iOS 14.0 min target) without flavor-specific overrides.
- `ios/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme`: Single shared scheme aligned with the standard configurations.
- Generated icon/splash assets reside under `ios/Runner/Assets.xcassets` (automatically updated by tooling).
