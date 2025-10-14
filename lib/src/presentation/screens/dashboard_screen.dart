import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../navigation/app_route.dart';
import '../theme/theme_extensions.dart';
import '../widgets/device_result_card.dart';
import '../widgets/scan_button.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.isPremium});

  final bool isPremium;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _WifiTab(isPremium: widget.isPremium),
      const _InfraredTab(),
      _BluetoothTab(isPremium: widget.isPremium),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          TextButton(
            onPressed: () => context.go(AppRoute.settings.path),
            child: const Text('Settings'),
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.wifi_rounded), label: 'Wi-Fi'),
          NavigationDestination(
            icon: Icon(Icons.camera_alt_rounded),
            label: 'Infrared',
          ),
          NavigationDestination(
            icon: Icon(Icons.bluetooth_rounded),
            label: 'Bluetooth',
          ),
        ],
      ),
    );
  }
}

class _WifiTab extends StatelessWidget {
  const _WifiTab({required this.isPremium});

  final bool isPremium;

  static const _devices = [
    DeviceResultDisplayData(
      id: 'AA:BB:CC:11:22:33',
      name: 'Nest Cam',
      manufacturer: 'Google',
      riskLevel: DeviceRiskLevel.high,
      source: ScanSource.wifi,
      ipAddress: '192.168.0.24',
      rssi: -42,
    ),
    DeviceResultDisplayData(
      id: '88:55:33:44:22:11',
      name: 'Unknown Device',
      manufacturer: 'Unknown Manufacturer',
      riskLevel: DeviceRiskLevel.medium,
      source: ScanSource.wifi,
      ipAddress: '192.168.0.31',
      rssi: -61,
    ),
    DeviceResultDisplayData(
      id: '44:99:22:77:AA:33',
      name: 'Smart Speaker',
      manufacturer: 'Amazon',
      riskLevel: DeviceRiskLevel.low,
      source: ScanSource.wifi,
      ipAddress: '192.168.0.18',
      rssi: -58,
      isTrusted: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textStyles = context.appTextStyles;
    final visibleDevices = isPremium ? _devices : _devices.take(1).toList();
    final lockedCount = isPremium ? 0 : _devices.length - visibleDevices.length;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        ScanButton(
          type: ScanType.wifi,
          onPressed: () => context.go(AppRoute.scanWifi.path),
        ),
        const SizedBox(height: 24),
        Text(
          'Recent devices',
          style: textStyles.sectionTitle.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ...visibleDevices.map(
          (device) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DeviceResultCard(device: device),
          ),
        ),
        if (lockedCount > 0) ...[
          const SizedBox(height: 8),
          _UpgradeBanner(
            lockedCount: lockedCount,
            description:
                'Unlock to view $lockedCount more devices from your scan.',
          ),
        ],
      ],
    );
  }
}

class _InfraredTab extends StatelessWidget {
  const _InfraredTab();

  @override
  Widget build(BuildContext context) {
    final textStyles = context.appTextStyles;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        ScanButton(
          type: ScanType.infrared,
          onPressed: () => context.go(AppRoute.scanIr.path),
        ),
        const SizedBox(height: 24),
        Text(
          'How it works',
          style: textStyles.sectionTitle.copyWith(color: scheme.onSurface),
        ),
        const SizedBox(height: 8),
        Text(
          'Point your camera at suspicious areas. Hidden cameras emit infrared '
          'light that appears as bright white spots on screen.',
          style: textStyles.supporting.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tips',
                style: textStyles.sectionTitle.copyWith(
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              _TipItem(
                icon: Icons.flashlight_on_rounded,
                text: 'Turn off the room lights for easier detection.',
              ),
              _TipItem(
                icon: Icons.cached_rounded,
                text:
                    'Move slowly and scan vents, smoke detectors, and mirrors.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BluetoothTab extends StatelessWidget {
  const _BluetoothTab({required this.isPremium});

  final bool isPremium;

  static const _bluetoothDevices = [
    DeviceResultDisplayData(
      id: 'BB:CC:DD:EE:FF:00',
      name: 'Tile Tracker',
      manufacturer: 'Tile',
      riskLevel: DeviceRiskLevel.medium,
      source: ScanSource.bluetooth,
      rssi: -55,
    ),
    DeviceResultDisplayData(
      id: '11:22:33:44:55:66',
      name: 'AirPods Pro',
      manufacturer: 'Apple',
      riskLevel: DeviceRiskLevel.low,
      source: ScanSource.bluetooth,
      rssi: -63,
      isTrusted: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textStyles = context.appTextStyles;

    final devices = isPremium
        ? _bluetoothDevices
        : _bluetoothDevices
              .map((device) => device.copyWith(isPremiumLocked: true))
              .toList();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        ScanButton(
          type: ScanType.bluetooth,
          isLocked: !isPremium,
          onPressed: isPremium
              ? () => context.go(AppRoute.scanBluetooth.path)
              : () => context.go(AppRoute.paywall.path),
        ),
        const SizedBox(height: 24),
        if (!isPremium) ...[
          _UpgradeBanner(
            lockedCount: devices.length,
            description:
                'Unlock Bluetooth scanning to detect trackers near you.',
          ),
          const SizedBox(height: 16),
          Text(
            'Preview',
            style: textStyles.sectionTitle.copyWith(color: scheme.onSurface),
          ),
        ] else ...[
          Text(
            'Nearby devices',
            style: textStyles.sectionTitle.copyWith(color: scheme.onSurface),
          ),
        ],
        const SizedBox(height: 12),
        ...devices.map(
          (device) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DeviceResultCard(device: device),
          ),
        ),
      ],
    );
  }
}

class _UpgradeBanner extends StatelessWidget {
  const _UpgradeBanner({required this.lockedCount, required this.description});

  final int lockedCount;
  final String description;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textStyles = context.appTextStyles;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock_rounded, color: scheme.primary),
              const SizedBox(width: 8),
              Text(
                '$lockedCount result${lockedCount > 1 ? 's' : ''} locked',
                style: textStyles.sectionTitle.copyWith(
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: textStyles.supporting.copyWith(
              color: scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => context.go(AppRoute.paywall.path),
            child: const Text('Unlock Premium'),
          ),
        ],
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  const _TipItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textStyles = context.appTextStyles;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: textStyles.supporting.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
