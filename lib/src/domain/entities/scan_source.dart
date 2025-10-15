import 'package:freezed_annotation/freezed_annotation.dart';

part 'scan_source.freezed.dart';

@freezed
class ScanSource with _$ScanSource {
  const ScanSource._();

  const factory ScanSource.wifi() = _Wifi;
  const factory ScanSource.bluetooth() = _Bluetooth;

  String get label => when(wifi: () => 'Wi-Fi', bluetooth: () => 'Bluetooth');
}
