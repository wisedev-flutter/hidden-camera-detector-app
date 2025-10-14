import 'package:flutter/material.dart';

import '../theme/theme_extensions.dart';
import 'proximity_indicator.dart';

enum DeviceRiskLevel {
  low,
  medium,
  high,
  unknown;

  String get label {
    switch (this) {
      case DeviceRiskLevel.low:
        return 'Low';
      case DeviceRiskLevel.medium:
        return 'Medium';
      case DeviceRiskLevel.high:
        return 'High';
      case DeviceRiskLevel.unknown:
        return 'Unknown';
    }
  }

  Color badgeColor(ColorScheme scheme) {
    switch (this) {
      case DeviceRiskLevel.low:
        return scheme.secondary;
      case DeviceRiskLevel.medium:
        return scheme.tertiary;
      case DeviceRiskLevel.high:
        return scheme.error;
      case DeviceRiskLevel.unknown:
        return scheme.outlineVariant;
    }
  }
}

enum ScanSource {
  wifi,
  bluetooth;

  IconData get icon {
    switch (this) {
      case ScanSource.wifi:
        return Icons.wifi_rounded;
      case ScanSource.bluetooth:
        return Icons.bluetooth_rounded;
    }
  }

  String get label {
    switch (this) {
      case ScanSource.wifi:
        return 'Wi-Fi';
      case ScanSource.bluetooth:
        return 'Bluetooth';
    }
  }
}

class DeviceResultDisplayData {
  const DeviceResultDisplayData({
    required this.id,
    required this.name,
    required this.manufacturer,
    required this.riskLevel,
    required this.source,
    this.ipAddress,
    this.rssi,
    this.isTrusted = false,
    this.isPremiumLocked = false,
  });

  final String id;
  final String name;
  final String manufacturer;
  final DeviceRiskLevel riskLevel;
  final ScanSource source;
  final String? ipAddress;
  final int? rssi;
  final bool isTrusted;
  final bool isPremiumLocked;

  DeviceResultDisplayData copyWith({
    String? id,
    String? name,
    String? manufacturer,
    DeviceRiskLevel? riskLevel,
    ScanSource? source,
    String? ipAddress,
    int? rssi,
    bool? isTrusted,
    bool? isPremiumLocked,
  }) {
    return DeviceResultDisplayData(
      id: id ?? this.id,
      name: name ?? this.name,
      manufacturer: manufacturer ?? this.manufacturer,
      riskLevel: riskLevel ?? this.riskLevel,
      source: source ?? this.source,
      ipAddress: ipAddress ?? this.ipAddress,
      rssi: rssi ?? this.rssi,
      isTrusted: isTrusted ?? this.isTrusted,
      isPremiumLocked: isPremiumLocked ?? this.isPremiumLocked,
    );
  }
}

class DeviceResultCard extends StatelessWidget {
  const DeviceResultCard({super.key, required this.device, this.onTap});

  final DeviceResultDisplayData device;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textStyles = context.appTextStyles;

    final cardContent = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SourceIcon(source: device.source),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      device.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (device.isTrusted)
                    Icon(
                      Icons.verified_rounded,
                      size: 18,
                      color: scheme.primary,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                device.manufacturer,
                style: textStyles.supporting.copyWith(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                ),
              ),
              if (device.ipAddress != null) ...[
                const SizedBox(height: 4),
                Text(
                  device.ipAddress!,
                  style: textStyles.supporting.copyWith(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _RiskChip(level: device.riskLevel),
                  if (device.rssi != null)
                    ProximityIndicator(rssi: device.rssi),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    final child = device.isPremiumLocked
        ? Stack(
            children: [
              Opacity(opacity: 0.5, child: cardContent),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: scheme.surface.withValues(alpha: 0.6),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_rounded, color: scheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Unlock to view details',
                          style: textStyles.sectionTitle.copyWith(
                            color: scheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        : cardContent;

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: device.isPremiumLocked ? null : onTap,
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );
  }
}

class _SourceIcon extends StatelessWidget {
  const _SourceIcon({required this.source});

  final ScanSource source;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: scheme.primaryContainer,
      ),
      child: Icon(source.icon, color: scheme.primary),
    );
  }
}

class _RiskChip extends StatelessWidget {
  const _RiskChip({required this.level});

  final DeviceRiskLevel level;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textStyles = context.appTextStyles;
    final bg = level.badgeColor(scheme).withValues(alpha: 0.14);
    final fg = level == DeviceRiskLevel.unknown
        ? scheme.onSurfaceVariant
        : level.badgeColor(scheme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Risk: ${level.label}',
        style: textStyles.badge.copyWith(color: fg),
      ),
    );
  }
}
