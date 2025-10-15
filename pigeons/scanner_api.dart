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

enum PigeonScanSource {
  wifi,
  bluetooth,
}

class DeviceDto {
  DeviceDto({
    required this.id,
    required this.name,
    this.manufacturer,
    required this.source,
    this.ipAddress,
    this.rssi,
    this.isTrusted,
    this.riskLevel,
  });

  String id;
  String name;
  String? manufacturer;
  PigeonScanSource source;
  String? ipAddress;
  int? rssi;
  bool? isTrusted;
  String? riskLevel;
}

class ScanResultDto {
  ScanResultDto({
    required this.source,
    required this.devices,
  });

  PigeonScanSource source;
  List<DeviceDto?> devices;
}

@HostApi()
abstract class ScannerHostApi {
  @async
  List<DeviceDto?> getNetworkDevices();

  @async
  List<DeviceDto?> getBluetoothDevices();

  @async
  void startScan(PigeonScanSource source);

  @async
  void stopScan(PigeonScanSource source);
}

@FlutterApi()
abstract class ScannerFlutterApi {
  void onScanResult(ScanResultDto result);
}
