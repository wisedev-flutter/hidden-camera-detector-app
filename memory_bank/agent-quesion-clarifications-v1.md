# Hidden Camera Detector App — Agent Clarifications & Responses

**Version:** 1.0  
**Date:** 2025-10-14  
**Author:** Project Technical Lead  
**Purpose:** This document provides authoritative answers to initial developer clarification questions regarding the implementation plan for the Hidden Camera Detector iOS (Flutter) MVP.

---

Step 1.1 assumes we will run flutter create. Because the repo already contains the Flutter scaffold, should we treat that step as verification only so we don’t overwrite the existing project?
Same doc Step 1.3: could you confirm the desired bundle identifiers / Xcode scheme names for the development, staging, and production flavors so we wire up the correct configs?
Step 2.2: when onboarding requests Bluetooth and Local Network access, do we also need to handle Location Services on iOS, and if so what prompt order or primer copy do you want to avoid App Store rejections?
Step 2.5: for the free tier’s “show only one device” rule, which device should we surface (first discovered, highest risk, user-selected), and how should we indicate that additional results exist but are gated?
Step 3.1: can you spell out the required fields for DetectedDevice, DeviceRiskLevel, and ScanSource (e.g., IP, manufacturer, RSSI, risk reasons) so we model the entities correctly?
Step 4.2: should the initial native scanner implementations return actual scan data from mDNS/CoreBluetooth right away, or is a mocked list acceptable for the first milestone? If real data is expected, can we get the response schema and any performance constraints?

## Step 1.1 — Initialize Flutter Environment
Yes, you can assume this step is completed.

## Step 1.3 — Bundle Identifiers & Schemes

| Flavor | Xcode Scheme | Bundle Identifier | Notes |
|---------|---------------|-------------------|--------|
| Development | `HiddenCameraDev` | `com.yourcompany.hiddencameradetector.dev` | Uses RevenueCat sandbox and debug logging |
| Staging | `HiddenCameraStaging` | `com.yourcompany.hiddencameradetector.staging` | TestFlight internal testing |
| Production | `HiddenCameraProd` | `com.yourcompany.hiddencameradetector` | App Store release build |

**Notes**
- Each scheme has its own configuration and provisioning profile.  
- Environment variables and RevenueCat keys will be injected via `--dart-define-from-file` per flavor.

✅ *Confirm these bundle identifiers exist in the Apple Developer Account before CI setup.*

---

## Step 2.2 — Permission Strategy (Bluetooth, Local Network, Location)

**Required (for MVP):**
- `NSBluetoothAlwaysUsageDescription`
- `NSLocalNetworkUsageDescription`

**Optional (if Wi-Fi SSID shown):**
- `NSLocationWhenInUseUsageDescription`

**Recommended MVP Flow:**
1. Request **Local Network** permission first.
2. Then request **Bluetooth** access.
3. Do **not** request Location in V1 unless SSID display is needed.

**Primer screen copy (App Store–safe):**
> “To detect nearby devices, Hidden Camera Detector needs access to your local network and Bluetooth. These permissions stay on-device and are never shared.”

If Location is added later:
> “We use your location only to identify your Wi‑Fi network — never to track you.”

✅ *This order and copy minimize App Store rejection risk and ensure transparent privacy messaging.*

---

## Step 2.5 — Free Tier “Show Only One Device” Rule

- **Visible device:** Highest-risk device (`riskLevel == High`), or first found if none marked high.
- **UI Treatment:**
  - Display one `DeviceResultCard` normally.
  - Beneath, show blurred list or message:
    > “+ X more devices found — unlock to see all results.”
  - Include CTA: **“Unlock All Devices”** → navigates to `/paywall`.

✅ *Clear visual gating increases upgrade conversions and fits freemium UX expectations.*

---

## Step 3.1 — Entity Definitions

### `DetectedDevice`
| Field | Type | Description |
|--------|------|-------------|
| `id` | `String` | MAC or UUID |
| `name` | `String` | Device name (default “Unknown Device”) |
| `ipAddress` | `String?` | Local IP (nullable) |
| `manufacturer` | `String` | Default “Unknown Manufacturer” |
| `riskLevel` | `DeviceRiskLevel` | Enum |
| `source` | `ScanSource` | Enum (`wifi` / `bluetooth`) |
| `rssi` | `int?` | Optional signal strength (dBm) |
| `isTrusted` | `bool` | User-marked trusted device |

### `DeviceRiskLevel`
Enum values: `Low`, `Medium`, `High`, `Unknown`

### `ScanSource`
Enum values: `wifi`, `bluetooth`

✅ *These mirror the entities section from the Technical Implementation Document (Section 4.2).*

---

## Step 4.2 — Native Scanner Implementation Expectations

**Milestone 1: Mocked Data**
- Acceptable for initial development and testing.
- Use Pigeon interface but return fixed list of 3–5 mock devices with varied risk levels.

**Example mock response:**
```json
[
  {
    "id": "AA:BB:CC:11:22:33",
    "name": "Nest Cam",
    "ipAddress": "192.168.1.24",
    "manufacturer": "Google",
    "riskLevel": "High",
    "source": "wifi",
    "rssi": -42,
    "isTrusted": false
  }
]
```

**Later Phase: Real Data Integration**
- Wi‑Fi: use **mDNS (Bonjour)** discovery.  
- Bluetooth: use **CoreBluetooth** peripheral scanning.  
- Dispatch updates on **main thread** via Pigeon stream.

**Performance Constraints**
- Max scan duration: 60 s  
- UI update latency: < 500 ms  
- Avoid blocking main thread during network discovery

✅ *Goal for first milestone: stable mock scanning + correct async UI updates before real scanner integration.*

---

**Maintainer:** Lead iOS Developer  
**Approved By:** Project Technical Lead  
**Last Updated:** 2025‑10‑14
