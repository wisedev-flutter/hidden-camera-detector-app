import 'package:flutter/material.dart';

import '../theme/theme_extensions.dart';

class ProximityIndicator extends StatelessWidget {
  const ProximityIndicator({super.key, required this.rssi});

  final int? rssi;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyles = context.appTextStyles;

    if (rssi == null) {
      return _Chip(
        label: 'Signal: Unknown',
        color: theme.colorScheme.outlineVariant,
        textStyle: textStyles.badge,
      );
    }

    final (label, value, color) = _mapRssiToStrength(rssi!, theme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: textStyles.badge.copyWith(color: color)),
          const SizedBox(width: 8),
          SizedBox(
            width: 72,
            height: 6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: color.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
        ],
      ),
    );
  }

  (String, double, Color) _mapRssiToStrength(int rssi, ThemeData theme) {
    // RSSI values are negative; closer to zero means stronger signal.
    if (rssi >= -45) {
      return ('Signal: Very Strong', 1, theme.colorScheme.primary);
    } else if (rssi >= -60) {
      return ('Signal: Strong', 0.75, theme.colorScheme.primary);
    } else if (rssi >= -75) {
      return ('Signal: Medium', 0.5, theme.colorScheme.tertiary);
    } else {
      return ('Signal: Weak', 0.25, theme.colorScheme.error);
    }
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.color,
    required this.textStyle,
  });

  final String label;
  final Color color;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: textStyle.copyWith(color: color)),
    );
  }
}
