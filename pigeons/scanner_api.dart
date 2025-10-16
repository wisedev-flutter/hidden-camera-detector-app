// ignore_for_file: unused_element

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeon/scanner_api.g.dart',
    dartOptions: DartOptions(),
    objcHeaderOut: 'ios/Runner/Pigeons/ScannerApi.g.h',
    objcSourceOut: 'ios/Runner/Pigeons/ScannerApi.g.m',
    objcOptions: ObjcOptions(prefix: 'HCD'),
  ),
)
class _PigeonConfig {}

enum ScanSourceDto {
  wifi,
  bluetooth,
}

enum DeviceRiskLevelDto {
  low,
  medium,
  high,
  unknown,
}

enum PermissionStatusDto {
  granted,
  denied,
  permanentlyDenied,
}

/// Mirrors the Flutter `DetectedDevice` entity. Field documentation ensures a
/// predictable conversion between native JSON/dictionary payloads and the Dart
/// domain model:
/// - `id`: MAC address or UUID string.
/// - `name`: Human-readable device name (default to "Unknown Device").
/// - `source`: Originating scan type; used to route updates in Dart.
/// - `manufacturer`: Optional manufacturer string.
/// - `ipAddress`: Optional IPv4/IPv6 string for Wi-Fi devices.
/// - `rssi`: Received signal strength in dBm (Bluetooth only).
/// - `isTrusted`: Whether the device is user-whitelisted.
/// - `riskLevel`: Maps to `DeviceRiskLevel` enum.
class DeviceDto {
  DeviceDto({
    required this.id,
    required this.name,
    required this.source,
    this.manufacturer,
    this.ipAddress,
    this.rssi,
    this.isTrusted = false,
    this.riskLevel,
  });

  String id;
  String name;
  ScanSourceDto source;
  String? manufacturer;
  String? ipAddress;
  int? rssi;
  bool isTrusted;
  DeviceRiskLevelDto? riskLevel;
}

/// Streaming payload delivered from native scanners. Every event represents a
/// single discovery update so the Dart layer can surface incremental results.
/// `eventId` is a monotonically increasing identifier per scan to help debounce
/// duplicates; `totalDiscovered` tracks the best-effort count emitted so far.
class DeviceEventDto {
  DeviceEventDto({
    required this.source,
    required this.device,
    required this.eventId,
    this.totalDiscovered,
    this.isFinal = false,
  });

  ScanSourceDto source;
  DeviceDto device;
  int eventId;
  int? totalDiscovered;
  bool isFinal;
}

@HostApi()
abstract class ScannerHostApi {
  @async
  PermissionStatusDto requestLocalNetworkAuthorization();

  @async
  void startWifiScan();

  @async
  void stopWifiScan();

  @async
  void startBluetoothScan();

  @async
  void stopBluetoothScan();
}

@FlutterApi()
abstract class ScannerStreamApi {
  void onDeviceEvent(DeviceEventDto event);
}
