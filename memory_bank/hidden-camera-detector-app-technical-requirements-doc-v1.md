# **Technical Implementation Document: Hidden Camera Detector App**

**(V1 MVP Revision)**

## **1\. Purpose**

This document provides a detailed technical blueprint for the development of the Hidden Camera Detector App. It is based on the approved High-Level Design Document and is intended for the engineering team, specifying project structure, component responsibilities, API contracts, and implementation guidelines. **The V1 MVP exclusively targets the iOS platform, with Android support deferred to a later phase.**

## **2\. Project Setup & Conventions**

### **2.1 Environment**

* **Flutter Version:** Latest stable release (e.g., 3.x.x)  
* **Dart Version:** Latest stable release (e.g., 3.x.x)  
* **Linting:** Use very\_good\_analysis for a strict, modern set of linting rules.  
* **CI/CD:** Use GitHub Actions or Codemagic to run flutter analyze and flutter test on every pull request.

### **2.2 Directory Structure**

lib/  
 └── src/  
     ├── presentation/       \# UI Layer (Widgets, Screens, Providers)  
     ├── domain/             \# Domain Layer (Entities, UseCases, Repositories)  
     ├── data/               \# Data Layer (Repositories, DataSources, Models)  
 └── core/                   \# Shared utilities, constants, error models  
 └── main.dart               \# App entry point

### **2.3 Build & Configuration**

* **Build Flavors:** The project will be configured with build flavors (development, staging, production) to manage different environments. This will be used for separate API keys (e.g., RevenueCat sandbox vs. production) and configurations.  
* **App Assets:** Initial app icons and splash screens will be managed using the flutter\_launcher\_icons and flutter\_native\_splash packages.

### **2.4 Platform Target**

* **Minimum iOS Version:** The app will target **iOS 14.0** and newer. This is the minimum version required for the native APIs that handle Local Network privacy permissions.

## **3\. Presentation Layer (UI)**

### **3.1 Directory Structure**

presentation/  
 ├── providers/              \# Riverpod providers  
 ├── screens/                \# Top-level screen widgets  
 │    └── paywall/           \# Paywall-specific UI and state  
 ├── widgets/                \# Reusable UI components  
 └── navigation/             \# Routing logic

### **3.2 State Management (Riverpod)**

* **Providers:** Use riverpod\_generator to reduce boilerplate.  
* **State Management Patterns:** Use AsyncNotifierProvider and NotifierProvider for complex state.  
* **Resource Management:** Use the .autoDispose modifier for providers scoped to a specific screen's lifecycle.  
* **Async Handling:** UI must handle AsyncValue (data, loading, error).

### **3.3 Navigation**

* **Router:** Implement go\_router for type-safe, URL-based navigation.  
* **Routes:** /onboarding, /dashboard, /scan/wifi, /scan/bluetooth, /scan/ir, /results, /settings, /paywall.  
* **Route Guards:** Routes requiring a premium entitlement will be protected by navigation guards that check the user's subscription status.

### **3.4 Key UI Components**

* **ScanButton(type: ScanType):** Reusable button for initiating scans.  
* **DeviceResultCard(device: DetectedDevice):** Displays device information, including an icon, name, and risk level.  
* **ProximityIndicator():** (V1 Simplification) A simple text-based widget that displays proximity (e.g., "Signal: Very Strong", "Signal: Weak") based on the RSSI signal strength of a Bluetooth device.  
* **OnboardingScreen:** Provides a brief welcome and serves as the entry point for requesting initial Bluetooth and Local Network permissions. **State will be persisted using shared\_preferences to ensure the onboarding flow is only shown once.**  
* **SettingsScreen:** Contains essential user options, including a "Restore Purchases" button, the "Clear All Data" option, a link to the app's Privacy Policy, and the app version number.

### **3.5 Theme & Design System**

* **Theme:** The app will use a centralized ThemeData object for consistent styling. Custom colors and text styles will be defined as ThemeData extensions to ensure they are accessible throughout the widget tree and easy to maintain.

### **3.6 Core User Flow & Monetization Strategy**

* **Initial Onboarding Flow:**  
  1. **Welcome Screen (/onboarding):** When a user first opens the app, they are presented with a welcome screen featuring a prominent "Scan" button and an animation demonstrating the app's functionality (e.g., showing suspicious devices).  
  2. **Permission Priming & Request:** Upon tapping "Scan", the user is taken to a screen explaining the need for Location Services to detect Wi-Fi networks. Tapping "Continue" triggers the native iOS permission dialog for Local Network access.  
  3. **Pre-Scan Dashboard:** After granting permission, the user lands on a page displaying their current Wi-Fi network name (SSID) and IP address, with another large "Scan" button.  
  4. **Scan Completion & Paywall Trigger:** After the scan completes, a screen confirms success ("Network scan finished successfully") and prompts the user to "See the devices". Tapping this leads directly to the paywall.  
* **Monetization and Main App Flow:**  
  1. **Paywall Screen (/paywall):** This screen informs the user "X devices found" but obscures the details. It presents subscription options (e.g., yearly, weekly). An exit button allows the user to proceed to the main app without subscribing.  
  2. **Main Dashboard Screen (/dashboard):** The main interface features a bottom navigation bar with three tabs:  
     * **Scan (Wi-Fi):** The primary Wi-Fi scanning feature.  
     * **Infrared:** The camera-based IR light detector.  
     * **Bluetooth:** A premium-only Bluetooth device scanner.  
  3. **Freemium Model Logic:** If a user has not subscribed, the "Scan" tab's functionality is limited. It will perform a scan but only display 1 of the found devices. A call-to-action ("Unlock All Devices") will be present to guide them back to the paywall.  
  4. **Premium Features:** A premium subscription unlocks the full list of devices from the Wi-Fi scan and enables the Bluetooth scanner tab.

## **4\. Domain Layer**

### **4.1 Directory Structure**

domain/  
 ├── entities/  
 ├── usecases/  
 ├── repositories/  
 └── failures/

### **4.2 Entities & Data Models (freezed)**

* **Tool:** The freezed package will be used for code generation of all entities and data models.  
* **Implementation:** The DetectedDevice entity and other models will be defined as immutable classes. freezed will auto-generate constructors, copyWith, toString, \==, and hashCode methods, eliminating boilerplate and preventing mutation-related bugs.  
* **DetectedDevice**  
  * String id (MAC or UUID)  
  * String name  
  * String? ipAddress  
  * String manufacturer  
  * DeviceRiskLevel riskLevel (enum: Low, Medium, High, Unknown)  
  * ScanSource source (enum: wifi, bluetooth)  
  * bool isTrusted

### **4.3 Use Cases**

* Each use case exposes a single call() method returning a Future\<Either\<Failure, SuccessType\>\>.  
* **GetNetworkDevicesUseCase:** Returns a Stream\<List\<DetectedDevice\>\>.  
* **GetBluetoothDevicesUseCase:** Returns a Stream\<List\<DetectedDevice\>\>.  
* **GetSubscriptionStatusUseCase:** Returns a Stream\<bool\>.  
* **PurchaseSubscriptionUseCase:** Initiates a purchase flow.  
* **RestorePurchasesUseCase:** **Restores a user's active subscriptions.**

### **4.4 Repositories**

* **DeviceRepository (abstract)**  
  * Stream\<Either\<Failure, List\<DetectedDevice\>\>\> watchNetworkDevices()  
  * Stream\<Either\<Failure, List\<DetectedDevice\>\>\> watchBluetoothDevices()  
* **SubscriptionRepository (abstract)**  
  * Stream\<bool\> watchSubscriptionStatus()  
  * Future\<Either\<Failure, List\<SubscriptionProduct\>\>\> getProducts()  
  * Future\<Either\<Failure, void\>\> purchaseProduct(SubscriptionProduct product)  
  * **Future\<Either\<Failure, void\>\> restorePurchases()**

### **4.5 Failure & Error Model (freezed)**

* **Implementation:** The standardized Failure hierarchy will be implemented as a sealed class (union type) using freezed.  
* **Benefit:** This enables exhaustive error handling (e.g., using when or map in the UI), forcing the developer to handle every possible failure type at compile time and leading to a more robust V1 application.

## **5\. Data Layer**

### **5.1 Directory Structure**

data/  
 ├── repositories/  
 ├── datasources/  
 │    ├── remote/  
 │    └── native/  
 └── models/

### **5.2 Platform Channels (using pigeon)**

* **Tool:** The pigeon package will be used to create type-safe communication channels.  
* **Workflow:**  
  1. An abstract API for native scanning functionality will be defined in a Dart file (e.g., pigeons/scanner\_api.dart).  
  2. The pigeon generator will be run manually after any changes to the API definition. The generated files will be committed to version control.  
  3. The app will use the generated, type-safe Dart API to call native functions.  
* **Error Propagation:** Native Swift errors will be caught and mapped to corresponding Failure types to be passed back through the pigeon channel.

### **5.3 Native iOS Implementation (Swift)**

* **Location:** ios/Runner/  
* **Classes:** ScannerPlugin.swift, MdnsScanner.swift, BluetoothScanner.swift.  
* **Native Dependencies & Configuration:** The Info.plist file must be configured with usage descriptions for the following permissions:  
  * NSLocalNetworkUsageDescription: For Wi-Fi scanning.  
  * NSBluetoothAlwaysUsageDescription: For Bluetooth scanning.  
* **Thread Safety:** Native scanning must run on background threads; event updates must be dispatched back to the main thread.

### **5.4 Local Data Source (Deferred for V1)**

* **V1 Simplification:** The local database for OUI (manufacturer) lookups is deferred.  
* **Strategy:** The manufacturer field will default to "Unknown Manufacturer".

### **5.5 Monetization DataSource (datasources/remote/)**

* **Provider:** RevenueCat will serve as the remote data source.  
* **Package:** The purchases-flutter SDK will be integrated.

## **6\. Technical Feature Requirements**

### **6.1 IR Light Detection**

* **Goal:** Help the user visually identify IR lights.  
* **Implementation:** Use the camera package and apply a ColorFiltered widget with a grayscale matrix to the preview.  
* **Error Handling:** If camera access is denied, the UI will display a message prompting the user to enable permission in the device settings.

## **7\. Monetization Implementation**

### **7.1 Provider & Entitlements**

* **Provider:** RevenueCat.  
* **Entitlement:** A single "premium" entitlement will unlock all paid features.  
* **Offering Identifiers:** The following identifiers will be used to map to products in the RevenueCat dashboard: weekly\_premium, yearly\_premium.

### **7.2 Implementation Flow**

* The purchases-flutter SDK will be initialized at app startup.  
* **Auto-Restore:** The app will automatically attempt to restore purchases upon launch to ensure a seamless experience for existing subscribers.  
* **Error Handling:** The UI must provide graceful error handling for failed purchases (e.g., network issues, user cancellation) with clear feedback and a retry option.

## **8\. Cross-Cutting Concerns**

### **8.1 Resource Management & Cancellation**

* All scans must be cancellable.  
* **Scan Timeout:** Scans will automatically stop after 60 seconds to prevent indefinite running and battery drain.  
* **App Lifecycle:** Active scans will be stopped when the app is backgrounded. Upon resuming, any in-progress scan must be manually restarted by the user.

### **8.2 Security**

* **Data Clearing:** A "Clear All Data" option in settings must delete all user preferences.  
* **No Hardcoded Secrets:** Use compile-time variables via \--dart-define-from-file.

### **8.3 Permissions & Edge-Case Handling (permission\_handler)**

* **Tool:** The permission\_handler package is the definitive tool for all permission requests.  
* **V1 Simplification:** Custom permission "primer" dialogs are deferred.

### **8.4 Logging & Diagnostics**

* Use the logger package for development logging. Logs will be suppressed in production builds.  
* Optionally integrate Sentry or Firebase Crashlytics. **If enabled, user consent must be obtained via the App Tracking Transparency (ATT) framework.**  
* **PII such as IPs or MAC addresses must never be logged.**

## **9\. Testing Strategy**

### **9.1 Test Frameworks & Boundaries**

* **Frameworks:** Testing will use flutter\_test for unit and widget tests, and the integration\_test package for end-to-end tests.  
* **Unit Test Boundaries:** Domain layer use cases will be unit tested by providing mock implementations of their repository dependencies using mocktail.

### **9.2 Unit & Widget Tests**

* Domain layer logic must have 100% test coverage.  
* Widget tests will verify UI states (loading, data, error) and include Golden tests.

### **9.3 Integration Tests**

* Test full scan flows using mocked data streams and mocked platform channel handlers.  
* **Pigeon Mocking:** The generated pigeon Dart API classes will be mocked using mocktail to test platform channel interactions without requiring a native implementation.

## **10\. Compliance & Privacy Summary**

* 100% on-device detection; no data transmission.  
* No persistent history of scans.  
* Fully GDPR & CCPA compliant.  
* **Privacy Manifest:** A PrivacyInfo.xcprivacy manifest will be included in the iOS project, detailing the data collected and the reasons for using required reason APIs, as mandated by Apple.  
* **App Tracking Transparency (ATT):** If analytics or other SDKs are used that fall under Apple's definition of "tracking", the ATT framework will be implemented to request user consent.

## **11\. Known Technical Risks**

* **iOS Local Network Permission:** User acceptance can be inconsistent. The initial scan flow is highly dependent on this permission being granted.  
* **IR Detection Limitations:** The effectiveness of IR light detection is limited by the hardware IR filters on different iPhone models.  
* **RevenueCat Sandbox Complexity:** Setting up and testing with sandbox accounts can be complex and time-consuming.

## **12\. Performance Budget**

* **Cold Start Time:** App should be interactive in \< 2.5 seconds.  
* **Scan Duration:** Max network scan duration is capped at 60 seconds.  
* **UI Performance:** All animations and transitions must maintain 60 FPS (frame build time \< 16ms).

## **13\. Post-V1 Extension Roadmap**

* **Android Support:** A full implementation for the Android platform.  
* **Local OUI Database:** Integration of an on-device database for manufacturer identification.  
* **Enhanced Visualizations:** A graphical proximity indicator and more detailed device result screens.  
* **Custom Permission Priming:** User-friendly dialogs to explain permission needs before the native prompt.