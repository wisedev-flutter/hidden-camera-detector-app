import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hidden_camera_detector/src/pigeon/scanner_api.g.dart';

class _TestStreamApi implements ScannerStreamApi {
  final List<DeviceEventDto> receivedEvents = [];

  @override
  void onDeviceEvent(DeviceEventDto event) {
    receivedEvents.add(event);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ScannerHostApi', () {
    const wifiStartChannel =
        'dev.flutter.pigeon.hidden_camera_detector.ScannerHostApi.startWifiScan';
    const wifiStopChannel =
        'dev.flutter.pigeon.hidden_camera_detector.ScannerHostApi.stopWifiScan';
    const btStartChannel =
        'dev.flutter.pigeon.hidden_camera_detector.ScannerHostApi.startBluetoothScan';
    const btStopChannel =
        'dev.flutter.pigeon.hidden_camera_detector.ScannerHostApi.stopBluetoothScan';

    const codec = StandardMessageCodec();
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

    tearDown(() {
      messenger.setMockMessageHandler(wifiStartChannel, null);
      messenger.setMockMessageHandler(wifiStopChannel, null);
      messenger.setMockMessageHandler(btStartChannel, null);
      messenger.setMockMessageHandler(btStopChannel, null);
    });

    test('invokes start/stop channels', () async {
      final invokedChannels = <String>[];

      void register(String channel) {
        messenger.setMockMessageHandler(channel, (ByteData? message) async {
          expect(message, isNull, reason: '$channel should receive null payload');
          invokedChannels.add(channel);
          return codec.encodeMessage(<Object?>[]);
        });
      }

      register(wifiStartChannel);
      register(wifiStopChannel);
      register(btStartChannel);
      register(btStopChannel);

      final api = ScannerHostApi();

      await api.startWifiScan();
      await api.stopWifiScan();
      await api.startBluetoothScan();
      await api.stopBluetoothScan();

      expect(
        invokedChannels,
        <String>[
          wifiStartChannel,
          wifiStopChannel,
          btStartChannel,
          btStopChannel,
        ],
      );
    });
  });

  group('ScannerStreamApi', () {
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

    tearDown(() {
      ScannerStreamApi.setup(
        null,
        binaryMessenger: messenger,
      );
    });

    test('routes native device events to Dart handler', () async {
      final streamApi = _TestStreamApi();
      ScannerStreamApi.setup(
        streamApi,
        binaryMessenger: messenger,
      );

      const channelName =
          'dev.flutter.pigeon.hidden_camera_detector.ScannerStreamApi.onDeviceEvent';
      final deviceDto = DeviceDto(
        id: 'AA:BB:CC:DD:EE:FF',
        name: 'Mock Camera',
        source: PigeonScanSource.wifi,
        isTrusted: false,
        manufacturer: 'Fabrikam',
        ipAddress: '192.168.1.5',
        rssi: -40,
        riskLevel: PigeonDeviceRiskLevel.high,
      );

      final event = DeviceEventDto(
        source: PigeonScanSource.wifi,
        device: deviceDto,
        eventId: 1,
        totalDiscovered: 3,
        isFinal: false,
      );

      final encoded = ScannerStreamApi.codec.encodeMessage(<Object?>[event]);
      final completer = Completer<ByteData?>();
      messenger.handlePlatformMessage(
        channelName,
        encoded,
        completer.complete,
      );
      final reply = await completer.future;
      expect(ScannerStreamApi.codec.decodeMessage(reply), isEmpty);

      expect(streamApi.receivedEvents, hasLength(1));
      final captured = streamApi.receivedEvents.single;
      expect(captured.source, PigeonScanSource.wifi);
      expect(captured.device.id, deviceDto.id);
      expect(captured.totalDiscovered, 3);
      expect(captured.isFinal, isFalse);
    });
  });
}
