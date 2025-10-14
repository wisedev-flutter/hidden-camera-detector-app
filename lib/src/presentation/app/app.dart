import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../navigation/app_router.dart';
import '../onboarding/onboarding_storage.dart';
import '../theme/app_theme.dart';

class HiddenCameraDetectorApp extends StatefulWidget {
  const HiddenCameraDetectorApp({super.key, required this.onboardingCompleted});

  final bool onboardingCompleted;

  @override
  State<HiddenCameraDetectorApp> createState() =>
      _HiddenCameraDetectorAppState();
}

class _HiddenCameraDetectorAppState extends State<HiddenCameraDetectorApp> {
  late final ValueNotifier<bool> _onboardingCompletedNotifier;
  late final ValueNotifier<bool> _premiumNotifier;
  late final AppRouter _appRouter;
  final OnboardingStorage _onboardingStorage = const OnboardingStorage();

  @override
  void initState() {
    super.initState();
    _onboardingCompletedNotifier = ValueNotifier<bool>(
      widget.onboardingCompleted,
    );
    _premiumNotifier = ValueNotifier<bool>(false);

    _appRouter = AppRouter(
      premiumAccessResolver: () => _premiumNotifier.value,
      onboardingCompletionResolver: () => _onboardingCompletedNotifier.value,
      onboardingCompletionUpdater: () {
        if (!_onboardingCompletedNotifier.value) {
          _onboardingCompletedNotifier.value = true;
        }
      },
      restorePurchasesHandler: () async {
        if (!_premiumNotifier.value) {
          _premiumNotifier.value = true;
        }
        return true;
      },
      clearAllDataHandler: () async {
        await _onboardingStorage.clear();
        _premiumNotifier.value = false;
        _onboardingCompletedNotifier.value = false;
      },
      refreshListenables: [_premiumNotifier, _onboardingCompletedNotifier],
    );

    _premiumNotifier.addListener(_handleStateChange);
    _onboardingCompletedNotifier.addListener(_handleStateChange);
  }

  void _handleStateChange() {
    _appRouter.refresh();
  }

  @override
  void dispose() {
    _premiumNotifier.removeListener(_handleStateChange);
    _onboardingCompletedNotifier.removeListener(_handleStateChange);
    _premiumNotifier.dispose();
    _onboardingCompletedNotifier.dispose();
    super.dispose();
  }

  GoRouter get _router => _appRouter.router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Hidden Camera Detector',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
