import 'package:freezed_annotation/freezed_annotation.dart';

import 'device_risk_level.dart';
import 'scan_source.dart';

part 'detected_device.freezed.dart';

@freezed
class DetectedDevice with _$DetectedDevice {
  const factory DetectedDevice({
    required String id,
    required String name,
    @Default('Unknown Manufacturer') String manufacturer,
    required DeviceRiskLevel riskLevel,
    required ScanSource source,
    String? ipAddress,
    int? rssi,
    @Default(false) bool isTrusted,
    DateTime? lastSeen,
  }) = _DetectedDevice;
}
