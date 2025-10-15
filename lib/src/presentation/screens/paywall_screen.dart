import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import 'package:hidden_camera_detector/core/config/paywall_mode.dart';
import '../navigation/app_route.dart';
import '../subscription/subscription_controller.dart';
import '../theme/theme_extensions.dart';
import '../widgets/device_result_card.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key, required this.paywallMode});

  final PaywallMode paywallMode;

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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _presentRevenueCatPaywall(BuildContext context) async {
    try {
      final result = await RevenueCatUI.presentPaywall(
        displayCloseButton: true,
      );
      if (!context.mounted) return;
      await SubscriptionControllerProvider.of(
        context,
      ).handlePaywallResult(result);
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
        _showSnackBar(context, 'Thanks! Your premium access is now unlocked.');
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

  Future<void> _simulatePurchase(BuildContext context, String planLabel) async {
    final controller = SubscriptionControllerProvider.of(context);
    controller.activateMockPremium();
    if (!context.mounted) return;
    _showSnackBar(context, 'Premium unlocked (mock $planLabel plan).');
    _onContinueWithoutSubscription(context);
  }

  Future<void> _simulateRestore(BuildContext context) async {
    final controller = SubscriptionControllerProvider.of(context);
    controller.activateMockPremium();
    if (!context.mounted) return;
    _showSnackBar(context, 'Mock restore completed. Premium re-enabled.');
    _onContinueWithoutSubscription(context);
  }

  @override
  Widget build(BuildContext context) {
    final textStyles = context.appTextStyles;
    final scheme = Theme.of(context).colorScheme;
    final isCustom = paywallMode.isCustom;
    final planHighlights = isCustom
        ? const [
            _PlanHighlightData(
              icon: Icons.developer_mode_rounded,
              title: 'Development build paywall',
              subtitle:
                  'Plans below simulate purchases locally so you can test premium flows without RevenueCat.',
            ),
            _PlanHighlightData(
              icon: Icons.auto_awesome_rounded,
              title: 'No real charges will occur',
              subtitle:
                  'Use this mode only in development. Remember to switch back before releasing.',
            ),
          ]
        : const [
            _PlanHighlightData(
              icon: Icons.local_offer_rounded,
              title: 'Live offers from RevenueCat',
              subtitle:
                  'Weekly and yearly plans load directly from the dashboard once configured.',
            ),
            _PlanHighlightData(
              icon: Icons.autorenew_rounded,
              title: 'Manage subscriptions easily',
              subtitle:
                  'Users can upgrade, downgrade, or cancel via the App Store at any time.',
            ),
          ];

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
          if (isCustom) ...[const _DevModeBanner(), const SizedBox(height: 16)],
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
              children: [
                for (var i = 0; i < planHighlights.length; i++) ...[
                  _PlanHighlight(
                    icon: planHighlights[i].icon,
                    title: planHighlights[i].title,
                    subtitle: planHighlights[i].subtitle,
                  ),
                  if (i != planHighlights.length - 1)
                    const SizedBox(height: 12),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (isCustom) ...[
            _MockPaywallOptions(
              onSelectPlan: (plan) => _simulatePurchase(context, plan),
              onRestore: () => _simulateRestore(context),
            ),
            const SizedBox(height: 12),
          ] else ...[
            FilledButton.icon(
              onPressed: () => _presentRevenueCatPaywall(context),
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text('See premium plans'),
            ),
            const SizedBox(height: 12),
          ],
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

class _DevModeBanner extends StatelessWidget {
  const _DevModeBanner();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_rounded, color: scheme.onTertiaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Development mode: mock paywall enabled. No real purchases occur.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onTertiaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MockPaywallOptions extends StatelessWidget {
  const _MockPaywallOptions({
    required this.onSelectPlan,
    required this.onRestore,
  });

  final ValueChanged<String> onSelectPlan;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _MockPlanCard(
                  key: const ValueKey('mock-plan-weekly'),
                  title: 'Weekly Access',
                  price: '\$4.99 / week',
                  description: 'Unlimited scanning for 7 days.',
                  onPressed: () => onSelectPlan('weekly'),
                  accentColor: scheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MockPlanCard(
                  key: const ValueKey('mock-plan-monthly'),
                  title: 'Monthly Access',
                  price: '\$12.99 / month',
                  description:
                      'Best for ongoing protection with monthly billing.',
                  onPressed: () => onSelectPlan('monthly'),
                  accentColor: scheme.secondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onRestore,
          icon: const Icon(Icons.restore_rounded),
          label: const Text('Simulate restore purchases'),
        ),
      ],
    );
  }
}

class _MockPlanCard extends StatelessWidget {
  const _MockPlanCard({
    super.key,
    required this.title,
    required this.price,
    required this.description,
    required this.onPressed,
    required this.accentColor,
  });

  final String title;
  final String price;
  final String description;
  final VoidCallback onPressed;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.appTextStyles;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(title, style: textStyles.sectionTitle),
            const SizedBox(height: 4),
            Text(
              price,
              style: textStyles.sectionTitle.copyWith(color: accentColor),
            ),
            const SizedBox(height: 8),
            Text(description, style: textStyles.supporting),
            const Spacer(),
            FilledButton(onPressed: onPressed, child: const Text('Subscribe')),
          ],
        ),
      ),
    );
  }
}

class _PlanHighlightData {
  const _PlanHighlightData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
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
