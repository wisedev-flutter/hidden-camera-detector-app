import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../navigation/app_route.dart';
import '../theme/theme_extensions.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.isPremium,
    required this.onRestorePurchases,
    required this.onClearAllData,
  });

  final bool isPremium;
  final Future<bool> Function() onRestorePurchases;
  final Future<void> Function() onClearAllData;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final Future<PackageInfo> _packageInfoFuture;

  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform();
  }

  Future<void> _handleRestorePurchases() async {
    final success = await widget.onRestorePurchases();
    if (!mounted) return;
    final message = success
        ? 'Premium restored. All features unlocked.'
        : 'No purchases found to restore.';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleClearAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all data?'),
        content: const Text(
          'This will reset onboarding and clear locally stored preferences.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await widget.onClearAllData();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data cleared. Restarting onboarding...')),
    );
    context.go(AppRoute.onboarding.path);
  }

  Future<void> _launchLink(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open link.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textStyles = context.appTextStyles;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _SectionHeader(
            title: 'Subscription',
            subtitle: widget.isPremium
                ? 'Premium active — thank you for supporting privacy.'
                : 'You are using the free tier. Upgrade to unlock Bluetooth scans.',
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    widget.isPremium
                        ? Icons.verified_rounded
                        : Icons.lock_open_rounded,
                    color: scheme.primary,
                  ),
                  title: Text(
                    widget.isPremium ? 'Premium active' : 'Free tier',
                    style: textStyles.sectionTitle.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    widget.isPremium
                        ? 'Bluetooth scanning and full results unlocked.'
                        : 'Limited Wi-Fi results. Upgrade to unlock more.',
                    style: textStyles.supporting.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: Icon(Icons.history_rounded, color: scheme.primary),
                  title: const Text('Restore Purchases'),
                  subtitle: const Text('Reinstate your premium entitlement'),
                  onTap: _handleRestorePurchases,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(
            title: 'Data & Privacy',
            subtitle: 'Manage stored data and review legal documents.',
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.delete_outline_rounded,
                    color: scheme.error,
                  ),
                  title: const Text('Clear All Data'),
                  subtitle: const Text('Resets onboarding and local settings'),
                  onTap: _handleClearAllData,
                ),
                const Divider(height: 0),
                ListTile(
                  leading: Icon(
                    Icons.privacy_tip_rounded,
                    color: scheme.onSurfaceVariant,
                  ),
                  title: const Text('Privacy Policy'),
                  onTap: () =>
                      _launchLink('https://example.com/privacy-policy'),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: Icon(
                    Icons.article_rounded,
                    color: scheme.onSurfaceVariant,
                  ),
                  title: const Text('Terms of Use'),
                  onTap: () => _launchLink('https://example.com/terms'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FutureBuilder<PackageInfo>(
            future: _packageInfoFuture,
            builder: (context, snapshot) {
              final info = snapshot.data;
              final version = info == null
                  ? 'Loading…'
                  : '${info.version} (${info.buildNumber})';
              return Text(
                'App version $version',
                textAlign: TextAlign.center,
                style: textStyles.supporting.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textStyles = context.appTextStyles;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textStyles.sectionTitle.copyWith(color: scheme.onSurface),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: textStyles.supporting.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
