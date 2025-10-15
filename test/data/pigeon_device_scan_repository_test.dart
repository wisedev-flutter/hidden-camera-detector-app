import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hidden_camera_detector/src/data/repositories/pigeon_device_scan_repository.dart';
import 'package:hidden_camera_detector/src/pigeon/scanner_api.g.dart';
import 'package:hidden_camera_detector/core/exceptions/failure.dart';
import 'package:hidden_camera_detector/src/domain/entities/device_risk_level.dart';
import 'package:hidden_camera_detector/src/domain/entities/scan_source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const wifiStartChannel =
      'dev.flutter.pigeon.hidden_camera_detector.ScannerHostApi.startWifiScan';
  const wifiStopChannel =
      'dev.flutter.pigeon.hidden_camera_detector.ScannerHostApi.stopWifiScan';
  const bluetoothStartChannel =
      'dev.flutter.pigeon.hidden_camera_detector.ScannerHostApi.startBluetoothScan';
  const bluetoothStopChannel =
      'dev.flutter.pigeon.hidden_camera_detector.ScannerHostApi.stopBluetoothScan';
  const streamChannel =
      'dev.flutter.pigeon.hidden_camera_detector.ScannerStreamApi.onDeviceEvent';

  final codec = const StandardMessageCodec();
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMessageHandler(wifiStartChannel, null);
    messenger.setMockMessageHandler(wifiStopChannel, null);
    messenger.setMockMessageHandler(bluetoothStartChannel, null);
    messenger.setMockMessageHandler(bluetoothStopChannel, null);
    messenger.setMockMessageHandler(streamChannel, null);
  });

  group('PigeonDeviceScanRepository', () {
    test('emits network failure when native wifi scan returns permission error', () async {
      messenger
        ..setMockMessageHandler(wifiStartChannel, (ByteData? _) async {
          return codec.encodeMessage(
            <Object?>['PERMISSION_DENIED', 'Local network disabled', null],
          );
        })
        ..setMockMessageHandler(wifiStopChannel, (ByteData? _) async {
          return codec.encodeMessage(<Object?>[]);
        });

      final repository = PigeonDeviceScanRepository(now: () => DateTime(2024, 1, 1));

      final results = await repository.watchNetworkDevices().take(2).toList();
      repository.dispose();

      expect(results[0].isRight(), isTrue);
      expect(results[1].isLeft(), isTrue);
      results[1].fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Expected a failure result'),
      );
    });

    test('streams mapped devices for Wi-Fi events', () async {
      messenger.setMockMessageHandler(wifiStartChannel, (ByteData? _) async {
        return codec.encodeMessage(<Object?>[]);
      });
      messenger.setMockMessageHandler(wifiStopChannel, (ByteData? _) async {
        return codec.encodeMessage(<Object?>[]);
      });

      final repository = PigeonDeviceScanRepository(now: () => DateTime(2024, 1, 1));

      final eventsFuture = repository.watchNetworkDevices().take(2).toList();

      final deviceDto = DeviceDto(
        id: 'AA:BB:CC:11:22:33',
        name: 'Nest Cam',
        source: PigeonScanSource.wifi,
        manufacturer: 'Google',
        ipAddress: '192.168.1.24',
        rssi: -42,
        isTrusted: false,
        riskLevel: PigeonDeviceRiskLevel.high,
      );

      final event = DeviceEventDto(
        source: PigeonScanSource.wifi,
        device: deviceDto,
        eventId: 1,
        totalDiscovered: 1,
        isFinal: false,
      );

      final encoded = ScannerStreamApi.codec.encodeMessage(<Object?>[event]);
      final completer = Completer<ByteData?>();
      messenger.handlePlatformMessage(streamChannel, encoded, completer.complete);
      await completer.future;

      final events = await eventsFuture;
      repository.dispose();

      expect(events[0].isRight(), isTrue);
      expect(events[1].isRight(), isTrue);
      final devices = events[1].getOrElse(() => []);
      expect(devices, hasLength(1));
      final device = devices.single;
      expect(device.id, deviceDto.id);
      expect(device.name, deviceDto.name);
      expect(device.manufacturer, deviceDto.manufacturer);
      expect(device.riskLevel, const DeviceRiskLevel.high());
      expect(device.source, const ScanSource.wifi());
    });
  });
}
