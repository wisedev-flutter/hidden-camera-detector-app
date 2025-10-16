import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../core/exceptions/failure.dart';
import '../../domain/entities/detected_device.dart';
import '../../domain/entities/device_risk_level.dart';
import '../../domain/entities/scan_source.dart';
import '../../domain/repositories/device_scan_repository.dart';
import '../../pigeon/scanner_api.g.dart';

class PigeonDeviceScanRepository extends DeviceScanRepository
    implements ScannerStreamApi {
  PigeonDeviceScanRepository({
    ScannerHostApi? hostApi,
    BinaryMessenger? binaryMessenger,
    DateTime Function()? now,
  })  : _hostApi = hostApi ?? ScannerHostApi(binaryMessenger: binaryMessenger),
        _now = now ?? DateTime.now {
    ScannerStreamApi.setUp(this, binaryMessenger: binaryMessenger);
  }

  final ScannerHostApi _hostApi;
  final DateTime Function() _now;

  final _wifiDevices = <String, DetectedDevice>{};
  final _bluetoothDevices = <String, DetectedDevice>{};

  late final StreamController<Either<Failure, List<DetectedDevice>>> _wifiController =
      StreamController<Either<Failure, List<DetectedDevice>>>.broadcast(
    onListen: _handleWifiListen,
    onCancel: _handleWifiCancel,
  );

  late final StreamController<Either<Failure, List<DetectedDevice>>> _bluetoothController =
      StreamController<Either<Failure, List<DetectedDevice>>>.broadcast(
    onListen: _handleBluetoothListen,
    onCancel: _handleBluetoothCancel,
  );

  StreamSubscription<void>? _wifiTimeoutSubscription;
  StreamSubscription<void>? _bluetoothTimeoutSubscription;

  @override
  Stream<Either<Failure, List<DetectedDevice>>> watchNetworkDevices() {
    return _wifiController.stream;
  }

  @override
  Stream<Either<Failure, List<DetectedDevice>>> watchBluetoothDevices() {
    return _bluetoothController.stream;
  }

  @override
  void onDeviceEvent(DeviceEventDto event) {
    final repositorySource = _mapSource(event.source);
    final device = _mapDeviceDto(event.device, repositorySource);

    final cache = event.source == ScanSourceDto.wifi ? _wifiDevices : _bluetoothDevices;
    cache[device.id] = device;

    final controller = event.source == ScanSourceDto.wifi ? _wifiController : _bluetoothController;
    controller.add(Right(cache.values.toList()));
  }

  Future<void> _handleWifiListen() async {
    _wifiDevices.clear();
    _wifiController.add(Right(_wifiDevices.values.toList()));

    try {
      await _hostApi.startWifiScan();
      _scheduleWifiTimeout();
    } on PlatformException catch (error) {
      _wifiController.add(Left(_mapPlatformError(error, ScanSource.wifi())));
    }
  }

  Future<void> _handleWifiCancel() async {
    _wifiTimeoutSubscription?.cancel();
    _wifiTimeoutSubscription = null;
    try {
      await _hostApi.stopWifiScan();
    } on PlatformException catch (error) {
      _wifiController.add(Left(_mapPlatformError(error, ScanSource.wifi())));
    }
  }

  Future<void> _handleBluetoothListen() async {
    _bluetoothDevices.clear();
    _bluetoothController.add(Right(_bluetoothDevices.values.toList()));

    try {
      await _hostApi.startBluetoothScan();
      _scheduleBluetoothTimeout();
    } on PlatformException catch (error) {
      _bluetoothController.add(Left(_mapPlatformError(error, ScanSource.bluetooth())));
    }
  }

  Future<void> _handleBluetoothCancel() async {
    _bluetoothTimeoutSubscription?.cancel();
    _bluetoothTimeoutSubscription = null;
    try {
      await _hostApi.stopBluetoothScan();
    } on PlatformException catch (error) {
      _bluetoothController.add(Left(_mapPlatformError(error, ScanSource.bluetooth())));
    }
  }

  void _scheduleWifiTimeout() {
    _wifiTimeoutSubscription?.cancel();
    _wifiTimeoutSubscription = Stream<void>.periodic(const Duration(seconds: 60)).take(1).listen(
      (_) async {
        _wifiController.add(
          Left(Failure.network(message: 'Wi-Fi scan timed out after 60 seconds.')),
        );
        try {
          await _hostApi.stopWifiScan();
        } on PlatformException catch (error) {
          _wifiController.add(Left(_mapPlatformError(error, const ScanSource.wifi())));
        }
      },
    );
  }

  void _scheduleBluetoothTimeout() {
    _bluetoothTimeoutSubscription?.cancel();
    _bluetoothTimeoutSubscription =
        Stream<void>.periodic(const Duration(seconds: 60)).take(1).listen(
      (_) async {
        _bluetoothController.add(
          Left(Failure.bluetooth(message: 'Bluetooth scan timed out after 60 seconds.')),
        );
        try {
          await _hostApi.stopBluetoothScan();
        } on PlatformException catch (error) {
          _bluetoothController.add(Left(_mapPlatformError(error, const ScanSource.bluetooth())));
        }
      },
    );
  }

  Failure _mapPlatformError(PlatformException error, ScanSource source) {
    final message = error.message ?? error.details?.toString();
    switch (error.code) {
      case 'PERMISSION_DENIED':
      case 'PERMISSION_NOT_DETERMINED':
        return source.maybeWhen(
          wifi: () => Failure.network(message: message),
          bluetooth: () => Failure.bluetooth(message: message),
          orElse: () => Failure.unexpected(message: message),
        );
      case 'SCAN_FAILED':
        return source.maybeWhen(
          wifi: () => Failure.network(message: message ?? 'Unable to complete Wi-Fi scan.'),
          bluetooth: () =>
              Failure.bluetooth(message: message ?? 'Unable to complete Bluetooth scan.'),
          orElse: () => Failure.unexpected(message: message),
        );
      default:
        return Failure.unexpected(message: message ?? 'Unknown scanner error: ${error.code}.');
    }
  }

  DetectedDevice _mapDeviceDto(DeviceDto dto, ScanSource source) {
    return DetectedDevice(
      id: dto.id,
      name: dto.name,
      manufacturer: dto.manufacturer ?? 'Unknown Manufacturer',
      riskLevel: _mapRiskLevel(dto.riskLevel),
      source: source,
      ipAddress: dto.ipAddress,
      rssi: dto.rssi,
      isTrusted: dto.isTrusted,
      lastSeen: _now(),
    );
  }

  DeviceRiskLevel _mapRiskLevel(DeviceRiskLevelDto? level) {
    switch (level) {
      case DeviceRiskLevelDto.low:
        return const DeviceRiskLevel.low();
      case DeviceRiskLevelDto.medium:
        return const DeviceRiskLevel.medium();
      case DeviceRiskLevelDto.high:
        return const DeviceRiskLevel.high();
      case DeviceRiskLevelDto.unknown:
      case null:
        return const DeviceRiskLevel.unknown();
    }
  }

  ScanSource _mapSource(ScanSourceDto source) {
    switch (source) {
      case ScanSourceDto.wifi:
        return const ScanSource.wifi();
      case ScanSourceDto.bluetooth:
        return const ScanSource.bluetooth();
    }
  }

  @visibleForTesting
  void dispose() {
    _wifiTimeoutSubscription?.cancel();
    _bluetoothTimeoutSubscription?.cancel();
    _wifiController.close();
    _bluetoothController.close();
    ScannerStreamApi.setUp(null);
  }
}
