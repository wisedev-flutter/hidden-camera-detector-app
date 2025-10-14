import 'package:flutter/material.dart';

import '../theme/theme_extensions.dart';

enum ScanType {
  wifi,
  bluetooth,
  infrared;

  String get label {
    switch (this) {
      case ScanType.wifi:
        return 'Wi-Fi Scan';
      case ScanType.bluetooth:
        return 'Bluetooth Scan';
      case ScanType.infrared:
        return 'Infrared Scan';
    }
  }

  String get description {
    switch (this) {
      case ScanType.wifi:
        return 'Discover devices on your network';
      case ScanType.bluetooth:
        return 'Find nearby Bluetooth signals';
      case ScanType.infrared:
        return 'Use camera to reveal IR lights';
    }
  }

  IconData get icon {
    switch (this) {
      case ScanType.wifi:
        return Icons.wifi_rounded;
      case ScanType.bluetooth:
        return Icons.bluetooth_rounded;
      case ScanType.infrared:
        return Icons.light_mode_rounded;
    }
  }
}

class ScanButton extends StatelessWidget {
  const ScanButton({
    super.key,
    required this.type,
    this.onPressed,
    this.isLocked = false,
    this.isLoading = false,
  });

  final ScanType type;
  final VoidCallback? onPressed;
  final bool isLocked;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveOnPressed = isLoading ? null : onPressed;
    final scheme = theme.colorScheme;
    final textStyles = context.appTextStyles;
    final cardColor = scheme.surfaceContainerHighest;
    final foreground = scheme.onSurface;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: effectiveOnPressed,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: cardColor,
        ),
        child: Row(
          children: [
            Icon(type.icon, size: 36, color: foreground),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    type.label,
                    style: textStyles.sectionTitle.copyWith(color: foreground),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    type.description,
                    style: textStyles.supporting.copyWith(
                      color: foreground.withValues(alpha: 0.74),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (isLoading)
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            else if (isLocked)
              Icon(Icons.lock_rounded, color: foreground.withValues(alpha: 0.8))
            else
              const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
