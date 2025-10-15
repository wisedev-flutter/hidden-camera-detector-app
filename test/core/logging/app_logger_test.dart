import 'package:flutter_test/flutter_test.dart';

import 'package:hidden_camera_detector/core/logging/app_logger.dart';

void main() {
  group('AppLogger.sanitize', () {
    test('redacts IPv4 and MAC addresses', () {
      const message =
          'Device AA:BB:CC:11:22:33 responded from 192.168.0.10 to user';
      final sanitised = AppLogger.sanitize(message);

      expect(sanitised.contains('192.168.0.10'), isFalse);
      expect(sanitised.contains('AA:BB:CC:11:22:33'), isFalse);
      expect(sanitised, isNot(equals(message)));
    });

    test('redacts IPv6 addresses', () {
      const message = 'Reachable at fe80:0:0:0:abcd:1234:5678:9abc when active';
      final sanitised = AppLogger.sanitize(message);

      expect(sanitised.contains('fe80:0:0:0:abcd:1234:5678:9abc'), isFalse);
      expect(sanitised, isNot(equals(message)));
    });
  });
}
