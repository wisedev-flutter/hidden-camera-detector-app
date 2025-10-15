import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import 'package:hidden_camera_detector/src/presentation/onboarding/onboarding_storage.dart';
import 'package:hidden_camera_detector/src/presentation/screens/onboarding_screen.dart';
import 'package:hidden_camera_detector/src/presentation/permissions/permission_coordinator.dart';

void main() {
  group('OnboardingScreen permissions', () {
    testWidgets('shows denial message when local network permission is denied', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final storage = _FakeOnboardingStorage();
      final coordinator = PermissionCoordinator(
        localNetworkRequester: () async => ph.PermissionStatus.denied,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingScreen(
            storage: storage,
            permissionCoordinator: coordinator,
          ),
        ),
      );

      await tester.tap(find.text('Start Scan'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.text('Local Network access is required to discover devices on your Wi‑Fi network.'),
        findsOneWidget,
      );
      expect(storage.completed, isFalse);
    });

    testWidgets('offers settings shortcut when local network permission is permanently denied',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final storage = _FakeOnboardingStorage();
      var openedSettings = false;
      final coordinator = PermissionCoordinator(
        localNetworkRequester: () async => ph.PermissionStatus.permanentlyDenied,
        openSettingsCallback: () async {
          openedSettings = true;
          return true;
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingScreen(
            storage: storage,
            permissionCoordinator: coordinator,
          ),
        ),
      );

      await tester.tap(find.text('Start Scan'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.text('Local Network access has been disabled. Enable it in Settings to continue scanning.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Open Settings'));
      await tester.pump();
      expect(openedSettings, isTrue);
      expect(storage.completed, isFalse);
    });
  });
}

class _FakeOnboardingStorage extends OnboardingStorage {
  bool completed = false;

  @override
  Future<void> setCompleted() async {
    completed = true;
  }
}
