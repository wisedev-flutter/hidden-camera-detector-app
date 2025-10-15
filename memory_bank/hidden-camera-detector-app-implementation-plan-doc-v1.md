# Hidden Camera Detector App — Implementation Plan (iOS, Flutter V1)

**Version:** 1.0  
**Target Platform:** iOS 14+  
**Framework:** Flutter 3.x (Stable)  
**Purpose:** This plan provides step-by-step implementation instructions for developers, aligned with the approved Design and Technical Implementation Documents.  
**Note:** Each step includes a validation test to confirm correct implementation.

---

## 🧭 Table of Contents

1. [Project Setup](#1-project-setup)
2. [Presentation Layer (UI)](#2-presentation-layer-ui)
3. [Domain Layer](#3-domain-layer)
4. [Data Layer](#4-data-layer)
5. [IR Light Detection](#5-ir-light-detection)
6. [Monetization Logic](#6-monetization-logic)
7. [App Lifecycle & Resource Management](#7-app-lifecycle--resource-management)
8. [Security & Privacy](#8-security--privacy)
9. [Testing Strategy](#9-testing-strategy)
10. [CI/CD Setup](#10-cicd-setup)
11. [Performance Validation](#11-performance-validation)
12. [Final Verification Checklist](#✅-final-verification-checklist)

---

## 1. Project Setup

### Step 1.1 — Initialize Flutter Environment
- Install latest **Flutter stable 3.x.x** and **Dart 3.x.x**.
- Create new project:
  ```bash
  flutter create hidden_camera_detector
  ```
- Add linting:
  ```bash
  flutter pub add --dev very_good_analysis
  ```
- Enable strict analysis in `analysis_options.yaml`.

✅ **Test:** Run `flutter analyze` — ensure no lint issues.

---

### Step 1.2 — Setup Folder Structure
- Under `lib/src/`, create:
  ```
  presentation/
  domain/
  data/
  ```
- Add `lib/core/` and `lib/main.dart`.
- Verify imports follow clean architecture layers.

✅ **Test:** Run `flutter analyze` and confirm no circular dependencies.

---

### Step 1.3 — Configure Build Flavors
- Define **development**, **staging**, **production** in Xcode.
- Use `--dart-define-from-file` for API/environment variables.

✅ **Test:** Build and run each flavor successfully in simulator.

---

### Step 1.4 — Configure Assets & Branding
- Add and run:
  ```bash
  flutter pub run flutter_launcher_icons
  flutter pub run flutter_native_splash:create
  ```
✅ **Test:** Launch app — verify correct app icon and splash screen.

---

## 2. Presentation Layer (UI)

### Step 2.1 — Setup Navigation
- Add `go_router`.
- Define routes:
  ```
  /onboarding
  /dashboard
  /scan/wifi
  /scan/bluetooth
  /scan/ir
  /results
  /settings
  /paywall
  ```
- Implement route guards for premium routes via subscription status provider.

✅ **Test:**  
- Navigation between routes works.  
- Premium-only routes redirect to `/paywall` when unsubscribed.

---

### Step 2.2 — Onboarding Flow
- Create `OnboardingScreen` with:
  - Welcome animation + “Scan” button.
  - Requests Bluetooth + Local Network permissions.
  - Save onboarding completion flag via `shared_preferences`.

✅ **Test:** Launch fresh → onboarding visible. Relaunch → skipped.

---

### Step 2.3 — Core UI Components
Under `presentation/widgets/`, create:
- `ScanButton(type: ScanType)`
- `DeviceResultCard(device: DetectedDevice)`
- `ProximityIndicator()`

✅ **Test:** Render each widget in isolation and verify with Golden tests.

---

### Step 2.4 — Theme System
- Define centralized `ThemeData` and custom color/text extensions.
- Apply globally.

✅ **Test:** Toggle light/dark mode — verify consistent theming.

---

### Step 2.5 — Dashboard
- Three tabs:
  - **Wi-Fi Scan**
  - **Infrared (Camera)**
  - **Bluetooth (Premium)**
- Implement freemium restriction on Wi-Fi tab (show only 1 device).

✅ **Test:**  
Free user → limited device view.  
Premium user → full list + Bluetooth enabled.

---

### Step 2.6 — Paywall Screen
- Display blurred scan results.
- Show RevenueCat offerings (weekly/yearly).
- Include “Continue without subscribing” option.

✅ **Test:** Offerings load and purchase triggers correct RevenueCat flow.

---

### Step 2.7 — Settings Screen
- Add:
  - Restore Purchases
  - Clear All Data
  - Privacy Policy link
  - App version

✅ **Test:**  
Restore reinstates premium entitlement.  
Data clear resets onboarding.

---

## 3. Domain Layer

### Step 3.1 — Entities
Define immutable models with `freezed`:
- `DetectedDevice`
- `DeviceRiskLevel`
- `ScanSource`

✅ **Test:** Run `flutter pub run build_runner build` — no generation errors.

---

### Step 3.2 — Use Cases
Implement:
- `GetNetworkDevicesUseCase`
- `GetBluetoothDevicesUseCase`
- `GetSubscriptionStatusUseCase`
- `PurchaseSubscriptionUseCase`
- `RestorePurchasesUseCase`

✅ **Test:**  
Mock repositories with `mocktail` — verify success/failure paths.

---

### Step 3.3 — Failure Models
Create `Failure` union types using `freezed` (e.g., `NetworkFailure`, `BluetoothFailure`).

✅ **Test:** Ensure all `when()` and `map()` cases compile and are handled.

---

## 4. Data Layer

### Step 4.1 — Pigeon Channel Setup
- Define `pigeons/scanner_api.dart` with explicit scan lifecycle calls:
  - `startWifiScan()`, `stopWifiScan()`
  - `startBluetoothScan()`, `stopBluetoothScan()`
- Include a Flutter-to-native streaming channel (e.g., `ScannerApiStream`) that emits `DetectedDeviceDto` objects incrementally as native scanners discover them.
- Document the expected JSON schema / field mapping so Dart repositories can translate incoming events into domain entities.
- Run generator:
  ```bash
  flutter pub run pigeon --input pigeons/scanner_api.dart
  ```
- Commit generated files.

✅ **Test:** Build iOS project — ensure compilation success and verify a stub Flutter listener receives streaming events from the generated API.

---

### Step 4.2 — Native iOS Implementation
In `ios/Runner/`:
- Create:
  - `ScannerPlugin.swift`
  - `MdnsScanner.swift`
  - `BluetoothScanner.swift`
- `ScannerPlugin.swift` implements the Pigeon `HostApi` facade, wiring Flutter commands to native scanners and exposing the shared event stream back to Dart.
- `MdnsScanner.swift` and `BluetoothScanner.swift` encapsulate platform APIs (Bonjour/CoreBluetooth). Each class checks its respective authorization status before scanning; on missing permission, immediately surface a descriptive error (see Step 4.2.1).
- Configure permissions in `Info.plist`:
  ```
  NSLocalNetworkUsageDescription
  NSBluetoothAlwaysUsageDescription
  ```
- Run scanning on background threads; dispatch discovered devices to the event stream on the main thread.

✅ **Test:** Run on physical iPhone → invoking `startWifiScan()` streams mocked devices in near real time; stopping the scan halts further events.

---

### Step 4.2.1 — Error Propagation Bridge
- Wrap native failures (e.g., permission denied, hardware unavailable) in `FlutterError` instances with stable error codes (`PERMISSION_DENIED`, `SCAN_FAILED`, etc.).
- Ensure the generated Dart API surfaces these errors so the repository layer can map codes to the appropriate `Failure` union variants.

✅ **Test:** Simulate a denied permission → Dart repository receives `FlutterError` and maps it to the expected `Failure`.

---

### Step 4.3 — RevenueCat Integration
- Add `purchases_flutter` SDK.
- Initialize in app startup.
- Auto-restore subscriptions.

✅ **Test:** Purchase + restore flows work using sandbox test accounts.

---

### Step 4.4 — Permissions
- Use `permission_handler` for all permissions.
- Request on demand during onboarding/scan.

✅ **Test:** Deny → app shows message.  
Grant → scan proceeds.

---

### Step 4.5 — Logging & Diagnostics
- Add `logger` package for dev logging.
- (Optional) Add Crashlytics/Sentry (with ATT prompt if needed).

✅ **Test:** Verify logs only appear in debug builds.

---

## 5. IR Light Detection

### Step 5.1 — Implement IR Camera
- Use `camera` package.
- Apply grayscale filter using `ColorFiltered`.
- Show permission prompt if denied.

✅ **Test:** Open IR tab — grayscale camera view active; permission denial handled cleanly.

---

## 6. Monetization Logic

### Step 6.1 — RevenueCat Entitlement Handling
- Define single “premium” entitlement.
- Provide stream-based `SubscriptionProvider` using Riverpod.

✅ **Test:** Change entitlement → UI updates in real time (premium features unlock).

---

## 7. App Lifecycle & Resource Management

### Step 7.1 — Scan Management
- Automatically cancel scans after **60 seconds**.
- Stop active scans when app backgrounded.

✅ **Test:**  
Scan auto-stops at 60s.  
Backgrounding stops scan.

---

## 8. Security & Privacy

### Step 8.1 — Data Clearing
- Implement `clearAllData()` in settings.
- Wipe shared preferences.

✅ **Test:**  
Clear data → onboarding shown again on next app launch.

---

### Step 8.2 — Privacy Manifest
- Add `PrivacyInfo.xcprivacy`.
- Ensure no PII (MAC/IP) logged.

✅ **Test:**  
Validate build via App Store Connect — no privacy warnings.

---

## 9. Testing Strategy

### Step 9.1 — Unit Tests
- Achieve 100% coverage on domain use cases.
- Use `mocktail` for dependencies.

✅ **Test:**  
Run `flutter test --coverage` → 100% domain coverage.

---

### Step 9.2 — Widget & Golden Tests
- Test AsyncValue states (loading/data/error).
- Add Golden tests for all core widgets.

✅ **Test:**  
Run test suite in CI — no regressions in golden images.

---

### Step 9.3 — Integration Tests
- Mock Pigeon APIs.
- Simulate scan → paywall → purchase → dashboard flow.

✅ **Test:**  
Integration tests complete successfully with no failures.

---

## 10. CI/CD Setup

### Step 10.1 — Continuous Integration
- Add GitHub Actions (or Codemagic) workflow:
  - `flutter analyze`
  - `flutter test`
  - Optional: build & deploy to TestFlight.

✅ **Test:**  
PR with failing lint/test → blocked.  
Fixed → passes CI.

---

## 11. Performance Validation

### Step 11.1 — Verify Performance Targets
- **Cold Start:** < 2.5s  
- **Scan Duration:** ≤ 60s  
- **UI FPS:** ≥ 60fps (frame build time < 16ms)

✅ **Test:**  
Profile using Flutter DevTools — all metrics within limits.

---

## ✅ Final Verification Checklist

- [ ] App launches with onboarding flow.
- [ ] Wi-Fi, Bluetooth, and IR scanning functional.
- [ ] Paywall + RevenueCat flow operational.
- [ ] Permissions handled gracefully.
- [ ] All tests (unit, widget, integration) pass.
- [ ] CI/CD workflow passes successfully.
- [ ] Meets privacy & performance requirements.

---

**Document Maintainer:** Lead iOS Developer  
**Last Updated:** 2025-10-14  
**Approved By:** Project Technical Lead
