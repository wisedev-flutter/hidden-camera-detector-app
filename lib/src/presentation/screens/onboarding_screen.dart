import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../navigation/app_route.dart';
import '../onboarding/onboarding_storage.dart';
import '../theme/theme_extensions.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    this.onCompleted,
    this.storage = const OnboardingStorage(),
  });

  final VoidCallback? onCompleted;
  final OnboardingStorage storage;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  late final Animation<double> _pulseAnimation =
      Tween<double>(begin: 0.96, end: 1.08).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );

  bool _isRequestingPermissions = false;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _onGetStarted() async {
    if (_isRequestingPermissions) {
      return;
    }
    setState(() => _isRequestingPermissions = true);
    try {
      final allGranted = await _requestRequiredPermissions();
      if (!allGranted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'We need Bluetooth and Local Network access to scan for devices. '
              'Please enable permissions in Settings.',
            ),
          ),
        );
        return;
      }

      await widget.storage.setCompleted();
      widget.onCompleted?.call();

      if (!mounted) return;
      context.go(AppRoute.dashboard.path);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Something went wrong: $error')));
    } finally {
      if (mounted) {
        setState(() => _isRequestingPermissions = false);
      }
    }
  }

  Future<bool> _requestRequiredPermissions() async {
    final permissions = <Permission>[
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse, // Used for SSID display + local network.
    ];

    final deniedPermissions = <Permission>[];

    for (final permission in permissions) {
      final status = await permission.request();
      if (!status.isGranted && !status.isLimited) {
        deniedPermissions.add(permission);
      }
    }

    // Local Network permission requires additional iOS configuration and will
    // prompt automatically once networking APIs are invoked. We surface a
    // reminder to the user below.
    return deniedPermissions.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.shield_rounded,
                          size: 96,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Protect your privacy',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Hidden Camera Detector helps you find suspicious devices '
                      'on your network using safe, on-device scans.',
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _PermissionInfo(theme: theme),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isRequestingPermissions ? null : _onGetStarted,
                  child: _isRequestingPermissions
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Start Scan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionInfo extends StatelessWidget {
  const _PermissionInfo({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final entries = [
      (
        icon: Icons.wifi_tethering,
        title: 'Local Network',
        message:
            'Required to discover devices connected to your Wi‑Fi network.',
      ),
      (
        icon: Icons.bluetooth,
        title: 'Bluetooth',
        message:
            'Needed to detect nearby devices broadcasting suspicious signals.',
      ),
      (
        icon: Icons.lock,
        title: 'Privacy first',
        message: 'Scanning happens entirely on your device. Nothing is stored.',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Permissions we need',
          style: context.appTextStyles.sectionTitle.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ...entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(entry.icon, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        style: context.appTextStyles.sectionTitle.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        entry.message,
                        style: context.appTextStyles.supporting.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'You can manage permissions anytime from Settings.',
          style: context.appTextStyles.supporting.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
