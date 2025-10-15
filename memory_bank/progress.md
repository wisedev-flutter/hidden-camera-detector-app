## 2025-10-14 — Step 1 (Project Setup)
- Refactored `lib/main.dart` to bootstrap the new `HiddenCameraDetectorApp` and created the presentation scaffold at `lib/src/presentation/app/app.dart`.
- Established Clean Architecture directories with placeholders (`lib/src/presentation`, `lib/src/domain`, `lib/src/data`, `lib/core`).
- Added flavor-specific entrypoints and dart-define configs (`lib/main_development.dart`, `lib/main_staging.dart`, `lib/main_production.dart`, `dart_defines/*.json`).
- Configured iOS build flavors, bundle IDs, and shared schemes via new xcconfig files and `Runner.xcodeproj` updates.
- Introduced launcher/splash tooling in `pubspec.yaml`, created placeholder branding assets, and generated iOS icons and native splash resources.

## 2025-10-14 — Flavor Clean-Up
- Removed custom iOS flavor xcconfigs, build configurations, and auxiliary schemes to return Xcode to the standard Debug/Profile/Release setup.
- Deleted flavor-specific Flutter entrypoints and `dart_defines` files; simplified VS Code launch config to run `lib/main.dart` directly.

## 2025-10-14 — Step 2.1 (Navigation Setup)
- Added `go_router` dependency and wired a central `AppRouter` (`lib/src/presentation/navigation/app_router.dart`) with route enum `AppRoute`.
- Stubbed all planned screens with placeholders under `lib/src/presentation/screens/` and shared scaffold widget for temporary UI.
- Switched `HiddenCameraDetectorApp` to use `MaterialApp.router`, enabling premium-route guard hook and initial route configuration.

## 2025-10-14 — Step 2.2 (Onboarding Flow)
- Introduced `permission_handler` and `shared_preferences` dependencies.
- Implemented a fully interactive onboarding experience (`lib/src/presentation/screens/onboarding_screen.dart`) with animated hero, permission requests, and completion persistence.
- Added `OnboardingStorage` helper plus router integration to skip onboarding once completed (`lib/src/presentation/app/app.dart`, `lib/src/presentation/navigation/app_router.dart`, `lib/main.dart`).

## 2025-10-14 — Step 2.3 (Core UI Components)
- Added reusable `ScanButton` widget with icons, descriptions, and premium/loader states (`lib/src/presentation/widgets/scan_button.dart`).
- Implemented `DeviceResultCard` plus supporting enums/data to visualise scan outcomes and premium gating (`lib/src/presentation/widgets/device_result_card.dart`).
- Created `ProximityIndicator` to translate RSSI values into user-friendly signal strength feedback (`lib/src/presentation/widgets/proximity_indicator.dart`).

## 2025-10-14 — Step 2.4 (Theme System)
- Introduced centralized theming (`lib/src/presentation/theme/app_theme.dart`) with light/dark variants and custom extensions (`AppColors`, `AppTextStyles`).
- Updated `HiddenCameraDetectorApp` to consume the new theme and expose `ThemeMode.system`.
- Refreshed widgets to leverage theme extensions for typography and status colors (`scan_button.dart`, `device_result_card.dart`, `proximity_indicator.dart`, onboarding permission copy).

## 2025-10-14 — Step 2.5 (Dashboard)
- Replaced the placeholder dashboard with a tabbed experience covering Wi-Fi, Infrared, and Bluetooth scans (`lib/src/presentation/screens/dashboard_screen.dart`).
- Implemented freemium behaviour: Wi-Fi results limited to a single device for free users, Bluetooth tab previews locked results, and upgrade banners route to the paywall.
- Wired scan buttons to their respective routes while preserving premium gating via `AppRouter`.
- Refactored the dashboard to use a bottom navigation bar for tab switching, removing the app-bar TabBar while retaining the existing tab content.

## 2025-10-14 — Step 2.6 (Paywall Screen)
- Implemented a dedicated paywall screen with blurred scan results preview and subscription copy (`lib/src/presentation/screens/paywall_screen.dart`).
- Added stubbed RevenueCat offerings (weekly/yearly) with call-to-action buttons and legal links.
- Included “Continue without subscribing” path and placeholder purchase handlers to be replaced with real RevenueCat integration later.

## 2025-10-14 — Step 2.7 (Settings Screen)
- Replaced the placeholder settings view with sections for subscription status, restore purchases, data/privacy links, and app metadata (`lib/src/presentation/screens/settings_screen.dart`).
- Restore purchases now toggles premium access in-app via shared state; clear data wipes stored preferences, resets onboarding, and routes back to the onboarding flow.
- Added `package_info_plus` and `url_launcher` dependencies to support version display and external privacy/terms links; updated routing/app state to respond to premium/onboarding changes dynamically.

## 2025-10-14 — Step 3.1 (Domain Entities)
- Added `freezed_annotation`/`freezed` + `build_runner` tooling and generated immutable domain models.
- Defined `DeviceRiskLevel`, `ScanSource`, and `DetectedDevice` entities using Freezed unions (`lib/src/domain/entities/*.dart`).
- Generated supporting `*.freezed.dart` artifacts via `flutter pub run build_runner build --delete-conflicting-outputs` to ensure future domain logic can rely on copyWith/equality helpers.

## 2025-10-14 — Step 3.2 (Use Cases & Repositories)
- Added domain repository abstractions for device scans and subscription workflows (`lib/src/domain/repositories/`).
- Implemented use case classes for network scans, Bluetooth scans, subscription status, purchases, and restores (`lib/src/domain/usecases/`).
- These use cases encapsulate repository calls, priming the domain layer for Riverpod providers and future data integrations.

## 2025-10-14 — Step 3.3 (Failure Modeling)
- Introduced a shared `Failure` sealed class (Freezed union) under `lib/core/exceptions/` with convenience messaging.
- Updated domain repositories/use cases to return `Either<Failure, …>` results using `dartz`, enabling consistent error propagation throughout the clean architecture layers.

## 2025-10-14 — Step 4.1 (Pigeon Setup)
- Added `pigeon` dev dependency and created `pigeons/scanner_api.dart` describing host/flutter APIs for scan management.
- Refined the API to expose explicit `start/stop` methods per scan type plus a `ScannerStreamApi` Flutter channel that streams `DeviceEventDto` payloads including incremental totals and risk metadata.
- Generated Dart bindings (`lib/src/pigeon/scanner_api.g.dart`) and iOS Obj-C stubs (`ios/Runner/Pigeons/ScannerApi.g.{h,m}`) via `flutter pub run pigeon --input pigeons/scanner_api.dart`.
- Documented DTO field mapping and aligned enums (`PigeonDeviceRiskLevel`, `PigeonScanSource`) to the domain layer for consistent serialization ahead of native integration.
- Added a Flutter unit test (`test/pigeon/scanner_api_test.dart`) that mocks the host channels and simulates stream events to verify the Pigeon interface wiring end-to-end.

## 2025-10-14 — Step 4.2 (Native iOS Implementation)
- Registered a dedicated `ScannerPlugin` inside `AppDelegate.swift` that wires the generated `HCDScannerHostApi` to mock native scanners and shares a single `HCDScannerStreamApi` back to Flutter.
- Implemented `MdnsScanner.swift` and `BluetoothScanner.swift` facades: they guard against missing permissions, emit incremental mock devices via timers, and send terminal events when scans complete or are stopped.
- Added Info.plist usage descriptions for Local Network and Bluetooth access to satisfy App Store review and runtime permission prompts.
- Validated the wiring with `flutter analyze` and the targeted `scanner_api_test.dart` to ensure the host/stream channels remain functional after the native integration.

## 2025-10-14 — Step 4.2.1 (Error Propagation Bridge)
- Reworked the domain repository contracts to stream `Either<Failure, List<DetectedDevice>>` results, aligning with the streaming scanner architecture.
- Added `PigeonDeviceScanRepository` to translate Pigeon `DeviceEventDto` payloads into domain entities, accumulate per-source device lists, and map `PlatformException` codes into the appropriate `Failure` variants.
- Introduced targeted unit tests (`test/data/pigeon_device_scan_repository_test.dart`) that mock the Pigeon channels to verify permission errors surface as `NetworkFailure` and that Wi-Fi events hydrate the repository stream correctly.

## 2025-10-14 — Step 4.4.1 (RevenueCat Prereqs & Paywall Strategy)
- Enabled the iOS **In-App Purchase** capability in `Runner.xcodeproj` so sandbox builds can load RevenueCat paywalls.
- Added `purchases_flutter`/`purchases_ui_flutter` dependencies and refactored `PaywallScreen` to launch the native RevenueCat paywall via `RevenueCatUI.presentPaywall`, replacing the bespoke offer tiles.
- Updated the paywall UI copy to highlight RevenueCat-managed plans while keeping “continue without subscribing” and legal links intact for later integration.

## 2025-10-14 — Step 4.3 (Permissions)
- Created a `PermissionCoordinator` that triggers the native Wi-Fi scan to surface the Local Network dialog, requests Bluetooth access on-demand, and routes permanently denied states to the iOS Settings screen.
- Updated `OnboardingScreen` to rely on the new coordinator, limiting onboarding to the Local Network prompt and providing actionable snackbars (with “Open Settings” when required).
- Routed premium Bluetooth scans through the coordinator in the dashboard so on-demand requests show user-friendly messaging before navigation.
- Added widget coverage (`test/presentation/onboarding/onboarding_screen_test.dart`) verifying denied and permanently denied flows display the correct guidance and settings shortcut.
