import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:hidden_camera_detector/core/config/paywall_mode.dart';
import '../permissions/permission_coordinator.dart';
import '../screens/bluetooth_scan_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/infrared_scan_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/paywall_screen.dart';
import '../screens/results_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/wifi_scan_screen.dart';
import 'app_route.dart';

typedef PremiumAccessResolver = bool Function();
typedef OnboardingCompletionResolver = bool Function();
typedef OnboardingCompletionUpdater = void Function();
typedef RestorePurchasesHandler = Future<bool> Function();
typedef ClearAllDataHandler = Future<void> Function();

/// Centralised app router that wires every navigation destination defined in
/// the implementation plan. Premium-only routes consult the injected resolver
/// so real subscription logic can be connected later.
class AppRouter {
  AppRouter({
    required PremiumAccessResolver premiumAccessResolver,
    required OnboardingCompletionResolver onboardingCompletionResolver,
    required OnboardingCompletionUpdater onboardingCompletionUpdater,
    required RestorePurchasesHandler restorePurchasesHandler,
    required ClearAllDataHandler clearAllDataHandler,
    required PermissionCoordinator permissionCoordinator,
    required PaywallMode paywallMode,
    List<Listenable> refreshListenables = const [],
  }) : _premiumAccessResolver = premiumAccessResolver,
       _onboardingCompletionResolver = onboardingCompletionResolver,
       _onboardingCompletionUpdater = onboardingCompletionUpdater,
       _restorePurchasesHandler = restorePurchasesHandler,
       _clearAllDataHandler = clearAllDataHandler,
       _permissionCoordinator = permissionCoordinator,
       _paywallMode = paywallMode,
       _refreshListenables = refreshListenables;

  final PremiumAccessResolver _premiumAccessResolver;
  final OnboardingCompletionResolver _onboardingCompletionResolver;
  final OnboardingCompletionUpdater _onboardingCompletionUpdater;
  final RestorePurchasesHandler _restorePurchasesHandler;
  final ClearAllDataHandler _clearAllDataHandler;
  final PermissionCoordinator _permissionCoordinator;
  final PaywallMode _paywallMode;
  final List<Listenable> _refreshListenables;

  late final GoRouter router = GoRouter(
    refreshListenable: _refreshListenables.isEmpty
        ? null
        : Listenable.merge(_refreshListenables),
    initialLocation: _onboardingCompletionResolver()
        ? AppRoute.dashboard.path
        : AppRoute.onboarding.path,
    routes: [
      GoRoute(
        path: AppRoute.onboarding.path,
        name: AppRoute.onboarding.name,
        redirect: (context, state) {
          if (_onboardingCompletionResolver()) {
            return AppRoute.dashboard.path;
          }
          return null;
        },
        builder: (context, state) => OnboardingScreen(
          onCompleted: _onboardingCompletionUpdater,
          permissionCoordinator: _permissionCoordinator,
        ),
      ),
      GoRoute(
        path: AppRoute.dashboard.path,
        name: AppRoute.dashboard.name,
        builder: (context, state) => DashboardScreen(
          isPremium: _premiumAccessResolver(),
          permissionCoordinator: _permissionCoordinator,
        ),
      ),
      GoRoute(
        path: AppRoute.scanWifi.path,
        name: AppRoute.scanWifi.name,
        builder: (context, state) => const WifiScanScreen(),
      ),
      GoRoute(
        path: AppRoute.scanBluetooth.path,
        name: AppRoute.scanBluetooth.name,
        redirect: (context, state) {
          final hasPremium = _premiumAccessResolver();
          if (!hasPremium) {
            return AppRoute.paywall.path;
          }
          return null;
        },
        builder: (context, state) => const BluetoothScanScreen(),
      ),
      GoRoute(
        path: AppRoute.scanIr.path,
        name: AppRoute.scanIr.name,
        builder: (context, state) => const InfraredScanScreen(),
      ),
      GoRoute(
        path: AppRoute.results.path,
        name: AppRoute.results.name,
        builder: (context, state) => const ResultsScreen(),
      ),
      GoRoute(
        path: AppRoute.settings.path,
        name: AppRoute.settings.name,
        builder: (context, state) => SettingsScreen(
          isPremium: _premiumAccessResolver(),
          onRestorePurchases: _restorePurchasesHandler,
          onClearAllData: _clearAllDataHandler,
        ),
      ),
      GoRoute(
        path: AppRoute.paywall.path,
        name: AppRoute.paywall.name,
        builder: (context, state) => PaywallScreen(paywallMode: _paywallMode),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.uri.toString()}')),
    ),
  );

  void refresh() {
    router.refresh();
  }
}
