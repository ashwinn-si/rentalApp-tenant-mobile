import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_tokens.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/utils/app_bar_helper.dart';
import '../../../widgets/ui/premium_card.dart';
import '../../../widgets/ui/screen_background.dart';
import '../../app_version/providers/app_version_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final Future<PackageInfo> _packageInfoFuture;

  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform();
  }

  Future<void> _openStore() async {
    final raw = appStoreUrl.trim();
    if (raw.isEmpty) {
      return;
    }

    final candidate = Uri.tryParse(raw);
    final uri = (candidate != null && candidate.hasScheme)
        ? candidate
        : Uri.tryParse('https://$raw');

    if (uri == null) {
      return;
    }

    final openedInBrowserView = await launchUrl(
      uri,
      mode: LaunchMode.inAppBrowserView,
    );

    if (!openedInBrowserView) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headingColor =
        isDark ? const Color(0xFFF9FAFB) : AppColors.textPrimary;
    final bodyColor =
        isDark ? const Color(0xFFE5E7EB) : AppColors.textSecondary;
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final remoteVersionAsync = ref.watch(currentAppVersionProvider);

    return Scaffold(
      appBar: buildPremiumAppBar(title: 'Settings'),
      body: ScreenBackground(
        child: FutureBuilder<PackageInfo>(
          future: _packageInfoFuture,
          builder: (context, snapshot) {
            final packageInfo = snapshot.data;
            final currentVersion = packageInfo?.version ?? appVersion;
            final currentBuild =
                int.tryParse(packageInfo?.buildNumber ?? '') ?? appBuildNumber;

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: <Widget>[
                PremiumCard(
                  child: SwitchListTile.adaptive(
                    value: isDarkMode,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Dark mode',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: headingColor,
                      ),
                    ),
                    subtitle: Text(
                      isDarkMode
                          ? 'Using dark appearance'
                          : 'Using light appearance',
                      style: TextStyle(
                        color: bodyColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    activeThumbColor: AppColors.violet,
                    activeTrackColor: AppColors.violet.withValues(alpha: 0.35),
                    inactiveThumbColor: isDark
                        ? const Color(0xFFD1D5DB)
                        : const Color(0xFF6B7280),
                    inactiveTrackColor: isDark
                        ? const Color(0xFF3A3458)
                        : const Color(0xFFD1D5DB),
                    onChanged: (value) =>
                        ref.read(themeModeProvider.notifier).setDarkMode(value),
                  ),
                ),
                PremiumCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'App Info',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: headingColor,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _InfoRow(label: 'Version', value: currentVersion),
                      _InfoRow(label: 'Build Number', value: '$currentBuild'),
                    ],
                  ),
                ),
                PremiumCard(
                  child: remoteVersionAsync.when(
                    loading: () => const _UpdateStatusView(
                      title: 'Checking for updates...',
                      subtitle: 'Please wait',
                      icon: Icons.sync,
                    ),
                    error: (_, __) => const _UpdateStatusView(
                      title: 'Update check unavailable',
                      subtitle: 'Could not fetch latest app version.',
                      icon: Icons.cloud_off_outlined,
                    ),
                    data: (remoteVersion) {
                      if (remoteVersion == null) {
                        return const _UpdateStatusView(
                          title: 'Update check unavailable',
                          subtitle: 'No remote version data returned.',
                          icon: Icons.info_outline,
                        );
                      }

                      final latestBuild = remoteVersion.buildNumber ?? 0;
                      final updateAvailable = currentBuild < latestBuild;

                      if (!updateAvailable) {
                        return _UpdateStatusView(
                          title: 'App is up to date',
                          subtitle:
                              'Version ${remoteVersion.versionNumber} (build $latestBuild)',
                          icon: Icons.verified_rounded,
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _UpdateStatusView(
                            title: remoteVersion.forceUpdate
                                ? 'Update required'
                                : 'Update available',
                            subtitle:
                                'Latest version ${remoteVersion.versionNumber} (build $latestBuild)',
                            icon: remoteVersion.forceUpdate
                                ? Icons.system_update_alt_rounded
                                : Icons.new_releases_outlined,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _openStore,
                              icon: const Icon(Icons.open_in_new),
                              label: const Text('Update App'),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor =
        isDark ? const Color(0xFFB8BED3) : AppColors.textSecondary;
    final valueColor = isDark ? const Color(0xFFF8FAFC) : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _UpdateStatusView extends StatelessWidget {
  const _UpdateStatusView({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? const Color(0xFFF8FAFC) : AppColors.textPrimary;
    final subtitleColor =
        isDark ? const Color(0xFFCBD5E1) : AppColors.textSecondary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF2C2550)
                : AppColors.violet.withValues(alpha: 0.12),
            border: Border.all(
              color: isDark ? const Color(0xFF3B3267) : Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(
            icon,
            color: AppColors.violet,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
