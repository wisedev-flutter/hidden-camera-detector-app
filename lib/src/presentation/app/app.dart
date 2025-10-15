import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:hidden_camera_detector/core/config/paywall_mode.dart';
import '../navigation/app_router.dart';
import '../onboarding/onboarding_storage.dart';
import '../permissions/permission_coordinator.dart';
import '../subscription/subscription_controller.dart';
import '../theme/app_theme.dart';

class HiddenCameraDetectorApp extends StatefulWidget {
  const HiddenCameraDetectorApp({
    super.key,
    required this.onboardingCompleted,
    required this.subscriptionController,
    required this.paywallMode,
  });

  final bool onboardingCompleted;
  final SubscriptionController subscriptionController;
  final PaywallMode paywallMode;

  @override
  State<HiddenCameraDetectorApp> createState() =>
      _HiddenCameraDetectorAppState();
}

class _HiddenCameraDetectorAppState extends State<HiddenCameraDetectorApp> {
  late final ValueNotifier<bool> _onboardingCompletedNotifier;
  late final AppRouter _appRouter;
  final OnboardingStorage _onboardingStorage = const OnboardingStorage();
  final PermissionCoordinator _permissionCoordinator =
      const PermissionCoordinator();

  @override
  void initState() {
    super.initState();
    _onboardingCompletedNotifier = ValueNotifier<bool>(
      widget.onboardingCompleted,
    );

    _appRouter = AppRouter(
      premiumAccessResolver: () => widget.subscriptionController.isPremium,
      onboardingCompletionResolver: () => _onboardingCompletedNotifier.value,
      onboardingCompletionUpdater: () {
        if (!_onboardingCompletedNotifier.value) {
          _onboardingCompletedNotifier.value = true;
        }
      },
      restorePurchasesHandler: () async {
        return widget.subscriptionController.restorePurchases();
      },
      clearAllDataHandler: () async {
        await _onboardingStorage.clear();
        widget.subscriptionController.reset();
        _onboardingCompletedNotifier.value = false;
      },
      permissionCoordinator: _permissionCoordinator,
      paywallMode: widget.paywallMode,
      refreshListenables: [
        widget.subscriptionController,
        _onboardingCompletedNotifier,
      ],
    );

    widget.subscriptionController.addListener(_handleStateChange);
    _onboardingCompletedNotifier.addListener(_handleStateChange);
  }

  void _handleStateChange() {
    _appRouter.refresh();
  }

  @override
  void dispose() {
    widget.subscriptionController.removeListener(_handleStateChange);
    _onboardingCompletedNotifier.removeListener(_handleStateChange);
    _onboardingCompletedNotifier.dispose();
    widget.subscriptionController.dispose();
    super.dispose();
  }

  GoRouter get _router => _appRouter.router;

  @override
  Widget build(BuildContext context) {
    return SubscriptionControllerProvider(
      controller: widget.subscriptionController,
      child: MaterialApp.router(
        title: 'Hidden Camera Detector',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        routerConfig: _router,
      ),
    );
  }
}
