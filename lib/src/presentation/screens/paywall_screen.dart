import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  static const _offers = [
    _Offer(
      id: 'weekly_premium',
      title: 'Weekly',
      subtitle: 'Best for short trips',
      price: '\$3.99/week',
      badge: 'Popular',
    ),
    _Offer(
      id: 'yearly_premium',
      title: 'Yearly',
      subtitle: 'Two months free, billed annually',
      price: '\$79.99/year',
      badge: 'Best Value',
    ),
  ];

  void _onContinueWithoutSubscription(BuildContext context) {
    context.pop();
  }

  void _onPurchaseOffer(BuildContext context, _Offer offer) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Purchase flow for ${offer.title} coming soon.')),
    );
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
          onPressed: () => context.pop(),
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
          const SizedBox(height: 12),
          ..._offers.map(
            (offer) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _OfferTile(
                offer: offer,
                onTap: () => _onPurchaseOffer(context, offer),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => _onPurchaseOffer(context, _offers.first),
            child: const Text('Unlock Premium'),
          ),
          const SizedBox(height: 8),
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

class _OfferTile extends StatelessWidget {
  const _OfferTile({required this.offer, required this.onTap});

  final _Offer offer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textStyles = context.appTextStyles;

    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Icon(Icons.shield_rounded, color: scheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          offer.title,
                          style: textStyles.sectionTitle.copyWith(
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (offer.badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              offer.badge!,
                              style: textStyles.badge.copyWith(
                                color: scheme.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      offer.subtitle,
                      style: textStyles.supporting.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                offer.price,
                style: textStyles.sectionTitle.copyWith(
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Offer {
  const _Offer({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    this.badge,
  });

  final String id;
  final String title;
  final String subtitle;
  final String price;
  final String? badge;
}
