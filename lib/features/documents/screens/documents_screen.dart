import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_tokens.dart';
import '../../../core/services/toast_service.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/animations.dart';
import '../../../core/utils/app_bar_helper.dart';
import '../../../widgets/domain/flat_selector.dart';
import '../../../widgets/ui/app_loader.dart';
import '../../../widgets/ui/premium_card.dart';
import '../../../widgets/ui/state_card.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../providers/documents_provider.dart';

class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key});

  Future<void> _openDocument(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ToastService.showError('Cannot open document');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDocuments = ref.watch(documentsProvider);
    final asyncDashboard = ref.watch(activeDashboardProvider);

    return Scaffold(
      appBar: buildPremiumAppBar(title: 'Documents'),
      body: asyncDashboard.when(
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
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: FlatSelector(flats: flatItems),
                        ),
                      ...documents.map((doc) {
                        return PremiumCard(
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: AppColors.violet.withOpacity(0.1),
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
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              'Uploaded: ${formatDate(doc.uploadedAt)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary.withOpacity(0.7),
                              ),
                            ),
                            trailing: TextButton(
                              onPressed: () => _openDocument(doc.url),
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    AppColors.violet.withOpacity(0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md),
                                ),
                              ),
                              child: const Text(
                                'View',
                                style: TextStyle(
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
    );
  }
}
