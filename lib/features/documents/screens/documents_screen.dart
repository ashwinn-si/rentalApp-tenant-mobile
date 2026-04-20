import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../core/constants/app_tokens.dart';
import '../../../core/services/toast_service.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/animations.dart';
import '../../../core/utils/app_bar_helper.dart';
import '../../../widgets/domain/flat_selector.dart';
import '../../../widgets/ui/app_loader.dart';
import '../../../widgets/ui/premium_card.dart';
import '../../../widgets/ui/screen_background.dart';
import '../../../widgets/ui/state_card.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../providers/documents_provider.dart';

class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key});

  Future<void> _openDocument(String url) async {
    final raw = url.trim();
    if (raw.isEmpty) {
      ToastService.showError('Document URL is invalid');
      return;
    }

    final normalized = raw.startsWith('http://') || raw.startsWith('https://')
        ? raw
        : 'https://$raw';

    if (Uri.tryParse(normalized) == null) {
      ToastService.showError('Document URL is invalid');
      return;
    }

    try {
      // Keep pre-signed S3 URL query string untouched to avoid signature mismatch.
      final openedInBrowserView = await launchUrlString(
        normalized,
        mode: LaunchMode.inAppBrowserView,
      );

      if (openedInBrowserView) {
        return;
      }

      final openedExternally = await launchUrlString(
        normalized,
        mode: LaunchMode.externalApplication,
      );

      if (!openedExternally) {
        ToastService.showError('Cannot open document');
      }
    } catch (_) {
      ToastService.showError('Cannot open document');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText =
        isDark ? const Color(0xFFF8FAFC) : AppColors.textPrimary;
    final secondaryText =
        isDark ? const Color(0xFFCBD5E1) : AppColors.textSecondary;
    final iconTileBg =
        isDark ? const Color(0xFF2C2550) : AppColors.violet.withOpacity(0.1);
    final actionBg =
        isDark ? const Color(0xFF322A58) : AppColors.violet.withOpacity(0.1);

    final asyncDocuments = ref.watch(documentsProvider);
    final asyncDashboard = ref.watch(activeDashboardProvider);

    return Scaffold(
      appBar: buildPremiumAppBar(title: 'Documents'),
      body: ScreenBackground(
        child: asyncDashboard.when(
          loading: () => const AppLoader(),
          error: (_, __) => const AppLoader(),
          data: (dashboardData) {
            final flatItems = dashboardData.availableFlats
                .map((flat) => FlatModel(id: flat.id, label: flat.label))
                .toList();

            return asyncDocuments.when(
              loading: () => const AppLoader(),
              error: (_, __) => const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: StateCard(
                    message: 'Unable to load documents',
                    variant: StateCardVariant.error),
              ),
              data: (documents) {
                if (documents.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: <Widget>[
                        if (flatItems.isNotEmpty)
                          FadeSlideTransition(
                            child: FlatSelector(flats: flatItems),
                          ),
                        if (flatItems.isNotEmpty)
                          const SizedBox(height: AppSpacing.md),
                        const Expanded(
                          child: StateCard(message: 'No documents available'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    StaggeredListView(
                      children: [
                        if (flatItems.isNotEmpty)
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.md),
                            child: FlatSelector(flats: flatItems),
                          ),
                        ...documents.map((doc) {
                          final hasUrl = doc.url.trim().isNotEmpty;

                          return PremiumCard(
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: iconTileBg,
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF433975)
                                        : Colors.transparent,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md),
                                ),
                                child: const Icon(
                                  Icons.description_outlined,
                                  color: AppColors.violet,
                                  size: 24,
                                ),
                              ),
                              title: Text(
                                doc.fileName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: primaryText,
                                ),
                              ),
                              subtitle: Text(
                                'Uploaded: ${formatDate(doc.uploadedAt)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: secondaryText.withValues(alpha: 0.9),
                                ),
                              ),
                              trailing: TextButton(
                                onPressed: hasUrl
                                    ? () => _openDocument(doc.url)
                                    : null,
                                style: TextButton.styleFrom(
                                  backgroundColor: actionBg,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.md),
                                  ),
                                ),
                                child: Text(
                                  hasUrl ? 'View' : 'Unavailable',
                                  style: const TextStyle(
                                    color: AppColors.violet,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
