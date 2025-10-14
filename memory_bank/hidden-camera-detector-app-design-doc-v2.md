# **Hidden Camera Detector App – High-Level Design Document (Updated for MVP Implementation) \- v2**

## **1\. Introduction**

### **1.1 Problem Statement**

With the rise of covert surveillance devices in private environments, users need reliable tools to ensure privacy.  
 The **Hidden Camera Detector App** provides a transparent, legal, and entirely offline way to identify suspicious devices — restoring confidence in personal spaces.

### **1.2 App Concept**

The app helps users detect hidden cameras and other surveillance devices using:

* Wi-Fi network device discovery

* Bluetooth proximity scanning *(premium feature)*

* Camera-based infrared (IR) light detection

Core Principles:

* 100% on-device detection

* No data transmission or analytics

* Simple, guided UI compliant with App Store privacy policies

### **1.3 Target Audience**

* Privacy-conscious users

* Travelers (hotels, Airbnbs)

* Professionals securing sensitive spaces

### **1.4 Unique Value Proposition**

* Multi-layered detection (Wi-Fi, Bluetooth, IR)

* Freemium model with optional premium upgrade

* On-device privacy and compliance

* Clean, approachable Flutter UI

---

## **2\. System Architecture**

The system follows **Clean Architecture**, maintaining a clear separation between:

* **Presentation Layer (UI \+ State)**

* **Domain Layer (Logic \+ Use Cases)**

* **Data Layer (Repositories \+ Native Integrations)**

### **2.1 Presentation Layer**

**Framework:** Flutter  
 **State Management:** Riverpod (with riverpod\_generator)  
 **Navigation:** go\_router  
 **Responsibilities:**

* UI composition and state management

* Handling permissions and scan flows

* Managing subscriptions and paywall logic

* Navigation and lifecycle control

**Resilience:**  
 If a feature or permission is unavailable, the UI displays clear guidance or fallback states.

### **2.2 Domain Layer**

**Framework:** Pure Dart  
 **Responsibilities:**  
 Business logic and core use cases independent of UI or data implementations.

**Key Entities:**

* `DetectedDevice`

* `DeviceRiskLevel` (Low, Medium, High, Unknown)

* `ScanSource` (Wi-Fi, Bluetooth)

**Use Cases (Examples):**

* `GetNetworkDevicesUseCase`

* `GetBluetoothDevicesUseCase`

* `GetSubscriptionStatusUseCase`

* `PurchaseSubscriptionUseCase`

* `RestorePurchasesUseCase`

**Error Handling:**  
 All domain errors modeled as `Failure` sealed classes using `freezed`.

### **2.3 Data Layer**

**Framework:** Dart with Pigeon-based iOS integrations  
 **Responsibilities:**

* Accessing native APIs for Wi-Fi and Bluetooth scans

* Communicating with RevenueCat for subscriptions

**Data Sources:**

* **Wi-Fi Discovery:** mDNS via Swift (Bonjour)

* **Bluetooth Scanner:** CoreBluetooth

* **Monetization:** RevenueCat SDK

* **Local Storage:** shared\_preferences

**Note:** Local database for manufacturer lookup is deferred in MVP.

---

## **3\. Core Features Breakdown**

### **3.1 Wi-Fi Device Scan**

* Uses iOS Local Network APIs via mDNS/Bonjour

* Displays discovered devices with manufacturer (if known) and risk level

* Limited device visibility in free mode

### **3.2 Bluetooth Scan *(Premium Feature)***

* Uses CoreBluetooth via native Swift integration

* Displays nearby Bluetooth devices and RSSI-based proximity text (simplified indicator)

* Available only for premium users

### **3.3 IR Light Detection**

* Uses the Flutter `camera` package

* Displays grayscale live preview to help users identify reflective IR lights visually

* No advanced ML detection in MVP

### **3.4 Onboarding & Permissions**

* Guides users through required permissions for Wi-Fi and Bluetooth access

* Uses `permission_handler` package

* Onboarding shown once (persisted in shared\_preferences)

### **3.5 Paywall & Subscription**

* **Monetization Provider:** RevenueCat

* **Entitlement:** "premium" unlocks full device list \+ Bluetooth scan

* **Offerings:** weekly\_premium, yearly\_premium

* Paywall appears after the first scan results

---

## **4\. Monetization Strategy**

**Model:** Freemium  
 **Free Tier:**

* One free Wi-Fi scan

* Partial results (only one device shown)

**Premium Tier:**

* Unlock full Wi-Fi scan results

* Enable Bluetooth scanning

* Prices managed via RevenueCat offerings

---

## **5\. UI/UX Flow**

### **5.1 Core Screens**

* **Onboarding:** Intro \+ permission explanation

* **Dashboard:** Displays scan modes and results summary

* **Scan Screens:** Wi-Fi, Bluetooth, IR

* **Results Screen:** Lists detected devices

* **Paywall Screen:** Subscription options after first scan

* **Settings:** Manage purchases, privacy links, clear data

### **5.2 Navigation**

* Managed by `go_router`

* Core routes:  
   `/onboarding`, `/dashboard`, `/scan/wifi`, `/scan/bluetooth`, `/scan/ir`, `/results`, `/settings`, `/paywall`

### **5.3 Design**

* Centralized `ThemeData` with extensions

* Minimalistic layout, consistent icons and animations

* Supports dark mode

---

## **6\. Technology Stack (MVP)**

| Purpose | Technology |
| ----- | ----- |
| Frontend | Flutter |
| State Management | Riverpod \+ riverpod\_generator |
| Navigation | go\_router |
| Native Channels | Pigeon |
| Wi-Fi / Bluetooth | Swift (mDNS \+ CoreBluetooth) |
| Camera | camera |
| Permissions | permission\_handler |
| Monetization | RevenueCat |
| Storage | shared\_preferences |
| Logging | logger |
| Testing | flutter\_test, mocktail, integration\_test |
| CI/CD | GitHub Actions or Codemagic |

---

## **7\. Privacy & Compliance**

* 100% on-device detection

* No data collection or analytics

* Privacy Manifest included (PrivacyInfo.xcprivacy)

* Compliant with GDPR and CCPA

* Optional ATT prompt if Crashlytics/Sentry added later

---

## **8\. Testing Strategy**

* **Unit Tests:** 100% coverage on Domain layer

* **Widget Tests:** Verify loading/data/error states

* **Integration Tests:** Mocked platform channel interactions

* **CI/CD:** flutter analyze \+ flutter test on every PR

---

## **9\. Known Limitations & Future Work**

* Android support deferred

* Local OUI (manufacturer) database postponed

* Simplified IR detection (no ML)

* No permission priming dialogs in MVP

* Sandbox testing for RevenueCat may be complex

---

## **10\. Future Enhancements**

* Android version

* Local OUI manufacturer lookup

* Graphical proximity indicator

* Enhanced IR visualization (TensorFlow Lite)

* Custom permission priming dialogs

