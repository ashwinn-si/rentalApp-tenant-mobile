import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../core/constants/app_tokens.dart';
import '../../../core/services/toast_service.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/animations.dart';
import '../../../widgets/domain/flat_selector.dart';
import '../../../widgets/templates/list_page_template.dart';
import '../../../widgets/ui/app_loader.dart';
import '../../../widgets/ui/premium_card.dart';
import '../../../widgets/ui/empty_state_card.dart';
import '../../auth/providers/auth_provider.dart';
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

  List<Widget> _refreshAction(WidgetRef ref) => [
        IconButton(
          onPressed: () => ref.invalidate(documentsProvider),
          icon: const Icon(Icons.refresh_outlined, color: Colors.white),
        ),
      ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText =
        isDark ? const Color(0xFFF8FAFC) : AppColors.textPrimary;
    final secondaryText =
        isDark ? const Color(0xFFCBD5E1) : AppColors.textSecondary;
    final iconTileBg = isDark
        ? const Color(0xFF2C2550)
        : AppColors.violet.withValues(alpha: 0.1);
    final actionBg = isDark
        ? const Color(0xFF322A58)
        : AppColors.violet.withValues(alpha: 0.1);

    final asyncDocuments = ref.watch(documentsProvider);
    final asyncDashboard = ref.watch(activeDashboardProvider);

    return asyncDashboard.when(
      loading: () => ListPageTemplate(
        title: 'Documents',
        isLoading: true,
        actions: _refreshAction(ref),
        body: const SizedBox.shrink(),
      ),
      error: (_, __) => ListPageTemplate(
        title: 'Documents',
        errorMessage: 'Error loading flats',
        actions: _refreshAction(ref),
        body: const SizedBox.shrink(),
      ),
      data: (dashboardData) {
        final flatItems = dashboardData.availableFlats
            .map((flat) => FlatModel(id: flat.id, label: flat.label))
            .toList();

        return asyncDocuments.when(
          loading: () => ListPageTemplate(
            title: 'Documents',
            isLoading: true,
            actions: _refreshAction(ref),
            body: const SizedBox.shrink(),
          ),
          error: (_, __) => ListPageTemplate(
            title: 'Documents',
            actions: _refreshAction(ref),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    if (flatItems.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: FlatSelector(flats: flatItems),
                      ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.15,
                        ),
                        child: EmptyStateCard(
                          type: EmptyStateType.documents,
                          title: 'Unable to Load',
                          message: 'Failed to load documents. Please try again.',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          data: (documents) {
            if (documents.isEmpty) {
              return ListPageTemplate(
                title: 'Documents',
                actions: _refreshAction(ref),
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        if (flatItems.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: FlatSelector(flats: flatItems),
                          ),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: MediaQuery.of(context).size.height * 0.15,
                            ),
                            child: const EmptyStateCard(
                              type: EmptyStateType.documents,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return ListPageTemplate(
              title: 'Documents',
              actions: _refreshAction(ref),
              body: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  StaggeredListView(
                    children: [
                      if (flatItems.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: FlatSelector(flats: flatItems),
                        ),
                      ...documents.map((doc) {
                        final hasUrl = doc.url.trim().isNotEmpty;
                        final activeFlatId = ref.watch(authProvider
                            .select((state) => state.activeFlatId));
                        final currentFlat = dashboardData.availableFlats
                            .where((f) => f.id == activeFlatId)
                            .firstOrNull;
                        final flatLabel = currentFlat?.label ?? 'Unit';
                        final apartmentName =
                            currentFlat?.apartmentName ?? '';

                        return PremiumCard(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.all(AppSpacing.xs),
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
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        doc.fileName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: primaryText,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          if (apartmentName.isNotEmpty) ...[
                                            Expanded(
                                              child: Text(
                                                apartmentName,
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: secondaryText
                                                      .withValues(alpha: 0.8),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              ' • ',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: secondaryText
                                                    .withValues(alpha: 0.6),
                                              ),
                                            ),
                                          ],
                                          Expanded(
                                            child: Text(
                                              flatLabel,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: secondaryText
                                                    .withValues(alpha: 0.8),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        formatDate(doc.uploadedAt),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: secondaryText.withValues(
                                              alpha: 0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                TextButton(
                                  onPressed: hasUrl
                                      ? () => _openDocument(doc.url)
                                      : null,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: 4,
                                    ),
                                    backgroundColor: actionBg,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.sm),
                                    ),
                                  ),
                                  child: Text(
                                    hasUrl ? 'View' : 'N/A',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.violet,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
