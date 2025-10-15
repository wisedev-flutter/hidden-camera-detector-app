import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_risk_level.freezed.dart';

@freezed
class DeviceRiskLevel with _$DeviceRiskLevel {
  const DeviceRiskLevel._();

  const factory DeviceRiskLevel.low() = _Low;
  const factory DeviceRiskLevel.medium() = _Medium;
  const factory DeviceRiskLevel.high() = _High;
  const factory DeviceRiskLevel.unknown() = _Unknown;

  String get label => when(
        low: () => 'Low',
        medium: () => 'Medium',
        high: () => 'High',
        unknown: () => 'Unknown',
      );

  int get priority => when(low: () => 0, medium: () => 1, high: () => 2, unknown: () => -1);
}
