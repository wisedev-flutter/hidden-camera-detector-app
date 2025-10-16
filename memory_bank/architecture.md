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
- `lib/src/presentation/permissions/permission_coordinator.dart`: Centralises Local Network/Bluetooth permission requests, surfacing SnackBar guidance and deep links back to iOS settings when access is denied.
- `lib/src/presentation/screens/dashboard_screen.dart`: Bottom-navigation dashboard that centralises Wi-Fi results, IR guidance, and premium-gated Bluetooth scanning.
- `lib/src/presentation/screens/paywall_screen.dart`: Dual-mode paywall that shows a development-only mock purchase flow (flagged via `PaywallMode`) or routes to RevenueCat’s modal in production, while consistently highlighting locked results.
- `lib/src/presentation/screens/infrared_scan_screen.dart`: Lifecycle-aware camera preview with a high-contrast grayscale filter, permission recovery prompts, and settings deep link for permanently denied access.
- `lib/src/presentation/screens/settings_screen.dart`: Settings hub exposing restore purchases, clear data, legal links, and app version metadata.
- `lib/src/presentation/theme/app_theme.dart`: Centralized light/dark `ThemeData` definitions applied app-wide.
- `lib/src/presentation/theme/theme_extensions.dart`: Custom theme extensions (`AppColors`, `AppTextStyles`) plus convenience getters for use throughout the UI.

## Domain Layer
- `lib/src/domain/entities/device_risk_level.dart`: Freezed union modeling Low/Medium/High/Unknown device risk with helper labels/priorities.
- `lib/src/domain/entities/scan_source.dart`: Freezed union defining Wi-Fi/Bluetooth scan sources.
- `lib/src/domain/entities/detected_device.dart`: Core immutable entity capturing device metadata, manufacturer info, risk level, source, and trust flags.
- `lib/src/domain/repositories/`: Abstractions for device scanning and subscription management to keep use cases UI/data agnostic.
- `lib/src/domain/usecases/`: Application-specific actions (get network devices, get Bluetooth devices, get subscription status, purchase subscription, restore purchases) that orchestrate repository calls.

## Data Layer
- `lib/src/data/`: Planned home for repositories, data sources, and Pigeon integrations referencing Swift native code.
- `pigeons/scanner_api.dart`: Defines lifecycle methods (`start/stop` per scan type) and the `ScannerStreamApi` channel that pushes `DeviceEventDto` updates into Flutter; generates bindings at `lib/src/pigeon/scanner_api.g.dart` and `ios/Runner/Pigeons/ScannerApi.g.{h,m}`.
- `ios/Runner/ScannerPlugin.swift`, `MdnsScanner.swift`, `BluetoothScanner.swift`: Native facade + mock scanners that enforce permission checks, stream incremental results, and provide a drop-in bridge for future mDNS/CoreBluetooth implementations.
- `lib/src/data/repositories/pigeon_device_scan_repository.dart`: Flutter-side repository that listens to the Pigeon stream, accumulates devices per source, and maps `PlatformException` codes to domain `Failure` types for the use cases.

## Shared Utilities
- `lib/core/`: Shared utilities including the sanitized logger, configuration helpers, and error models.
- `lib/core/exceptions/failure.dart`: Freezed union encapsulating domain-level failure types with default messaging.
- `lib/core/logging/app_logger.dart`: Centralised logger enforcing the “no PII” policy and silencing release builds.
- `lib/core/config/paywall_mode.dart`: Parses the `PAYWALL_MODE` flag and exposes helpers that toggle between RevenueCat and custom paywall implementations.

## Environment & Configuration
- `pubspec.yaml`: Includes `flutter_launcher_icons`, `flutter_native_splash`, and runtime deps `go_router`, `permission_handler`, `shared_preferences`, `package_info_plus`, `url_launcher`, along with codegen tooling (`freezed_annotation`, `freezed`, `build_runner`).
- `pubspec.yaml`: Includes monetization dependencies `purchases_flutter` and `purchases_ui_flutter` ready for the RevenueCat data layer.
- `assets/branding/app_icon.png`, `splash_icon.png`: Temporary solid-color assets consumed by icon/splash generators.

## iOS Project Configuration
- `ios/Runner.xcodeproj/project.pbxproj`: Uses Flutter’s default Debug/Profile/Release build configurations (iOS 14.0 min target) without flavor-specific overrides.
- `ios/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme`: Single shared scheme aligned with the standard configurations.
- `ios/Runner/Info.plist`: Includes Local Network and Bluetooth usage descriptions required for scanner permissions.
- `ios/Runner.xcodeproj/project.pbxproj`: Enables the In-App Purchase capability so RevenueCat paywalls can transact in sandbox and production.
- Generated icon/splash assets reside under `ios/Runner/Assets.xcassets` (automatically updated by tooling).
