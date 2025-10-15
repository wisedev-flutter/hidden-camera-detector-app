import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../navigation/app_route.dart';
import '../subscription/subscription_controller.dart';
import '../theme/theme_extensions.dart';
import '../widgets/device_result_card.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  static const _mockDevices = [
    DeviceResultDisplayData(
      id: 'AA:BB:CC:11:22:33',
      name: 'Nest Cam',
      manufacturer: 'Google',
      riskLevel: DeviceRiskLevel.high,
      source: ScanSource.wifi,
      ipAddress: '192.168.0.24',
      rssi: -42,
      isPremiumLocked: true,
    ),
    DeviceResultDisplayData(
      id: '88:55:33:44:22:11',
      name: 'Unknown Device',
      manufacturer: 'Unknown Manufacturer',
      riskLevel: DeviceRiskLevel.medium,
      source: ScanSource.wifi,
      ipAddress: '192.168.0.31',
      rssi: -61,
      isPremiumLocked: true,
    ),
  ];

  void _onContinueWithoutSubscription(BuildContext context) {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
    } else {
      context.go(AppRoute.dashboard.path);
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _presentRevenueCatPaywall(BuildContext context) async {
    try {
      final result = await RevenueCatUI.presentPaywall(
        displayCloseButton: true,
      );
      if (!context.mounted) return;
      await SubscriptionControllerProvider.of(context)
          .handlePaywallResult(result);
      if (!context.mounted) return;
      _handlePaywallFeedback(context, result);
    } on PlatformException catch (error) {
      if (!context.mounted) return;
      _showSnackBar(
        context,
        'RevenueCat is not configured. Supply REVENUECAT_API_KEY before building. (${error.message})',
      );
    }
  }

  void _handlePaywallFeedback(BuildContext context, PaywallResult result) {
    switch (result) {
      case PaywallResult.purchased:
      case PaywallResult.restored:
        _showSnackBar(
          context,
          'Thanks! Your premium access is now unlocked.',
        );
        break;
      case PaywallResult.cancelled:
        _showSnackBar(context, 'Purchase cancelled.');
        break;
      case PaywallResult.notPresented:
        _showSnackBar(context, 'Paywall was not presented.');
        break;
      case PaywallResult.error:
        _showSnackBar(
          context,
          'Something went wrong while presenting the paywall.',
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyles = context.appTextStyles;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unlock Premium'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => _onContinueWithoutSubscription(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Access the full scan report',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Upgrade to see every device on your network and enable Bluetooth tracker detection.',
            style: textStyles.supporting.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          _BlurredResults(devices: _mockDevices),
          const SizedBox(height: 24),
          Text(
            'Choose your plan',
            style: textStyles.sectionTitle.copyWith(color: scheme.onSurface),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: const [
                _PlanHighlight(
                  icon: Icons.local_offer_rounded,
                  title: 'Live offers from RevenueCat',
                  subtitle:
                      'Weekly and yearly plans load directly from the dashboard once configured.',
                ),
                SizedBox(height: 12),
                _PlanHighlight(
                  icon: Icons.autorenew_rounded,
                  title: 'Manage subscriptions easily',
                  subtitle:
                      'Users can upgrade, downgrade, or cancel via the App Store at any time.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _presentRevenueCatPaywall(context),
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Text('See premium plans'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => _onContinueWithoutSubscription(context),
            child: const Text('Continue without subscribing'),
          ),
          const SizedBox(height: 16),
          Text(
            'Your subscription will auto-renew. Cancel anytime in Settings. '
            'Prices may vary by region.',
            style: textStyles.supporting.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton(onPressed: () {}, child: const Text('Privacy Policy')),
              const SizedBox(width: 12),
              TextButton(onPressed: () {}, child: const Text('Terms of Use')),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanHighlight extends StatelessWidget {
  const _PlanHighlight({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textStyles = context.appTextStyles;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: scheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textStyles.sectionTitle.copyWith(
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: textStyles.supporting.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BlurredResults extends StatelessWidget {
  const _BlurredResults({required this.devices});

  final List<DeviceResultDisplayData> devices;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  scheme.surfaceContainerHighest,
                  scheme.surfaceContainerHighest.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: devices
                  .map(
                    (device) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DeviceResultCard(device: device),
                    ),
                  )
                  .toList(),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Results locked',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Upgrade to see every device detected on your network.',
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
