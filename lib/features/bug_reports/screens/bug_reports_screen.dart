import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_tokens.dart';
import '../../../core/providers/error_handler_provider.dart';
import '../../../core/utils/app_bar_helper.dart';
import '../../../widgets/ui/app_button.dart';
import '../../../widgets/ui/app_loader.dart';
import '../../../widgets/ui/premium_card.dart';
import '../../../widgets/ui/screen_background.dart';
import '../../../widgets/ui/empty_state_card.dart';
import '../data/models/bug_reports_model.dart';
import '../providers/bug_reports_provider.dart';

class BugReportsScreen extends ConsumerWidget {
  const BugReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bugReportsAsync = ref.watch(bugReportsListProvider);

    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: buildPremiumAppBar(
          title: 'Bug Reports',
          actions: [
            IconButton(
              onPressed: () {
                debugPrint('[BugReportsScreen] Refresh clicked');
                ref.invalidate(bugReportsListProvider);
              },
              icon: const Icon(Icons.refresh_outlined),
              tooltip: 'Refresh',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showReportDialog(context, ref),
          label: const Text('Report Bug'),
          icon: const Icon(Icons.bug_report),
        ),
        body: bugReportsAsync.when(
          loading: () => const Center(child: AppLoader()),
          error: (error, stack) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ApiErrorHandler.handleAccessDenied(error, ref);
            });
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: EmptyStateCard(
                  type: EmptyStateType.generic,
                  title: 'Unable to Load',
                  message: 'Failed to load bug reports. Please try again.',
                ),
              ),
            );
          },
          data: (bugReports) {
            if (bugReports.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: EmptyStateCard(
                    type: EmptyStateType.generic,
                    title: 'No bug reports yet',
                    message: 'Help us improve the app',
                    actionLabel: 'Report Your First Bug',
                    onActionPressed: () => _showReportDialog(context, ref),
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                debugPrint('[BugReportsScreen] Pull-to-refresh triggered');
                ref.invalidate(bugReportsListProvider);
                await ref.watch(bugReportsListProvider.future);
              },
              child: ListView.builder(
                padding: const EdgeInsets.only(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  top: AppSpacing.md,
                  bottom: AppSpacing.xl,
                ),
                itemCount: bugReports.length,
                itemBuilder: (context, index) => _BugReportCard(
                  bugReport: bugReports[index],
                  onTap: () => _showDetailDialog(context, ref, bugReports[index].id),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ReportBugSheet(ref: ref),
    );
  }

  void _showDetailDialog(BuildContext context, WidgetRef ref, String bugReportId) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _BugReportDetailSheet(bugReportId: bugReportId),
    );
  }
}

class _BugReportCard extends StatelessWidget {
  const _BugReportCard({
    required this.bugReport,
    required this.onTap,
  });

  final BugReport bugReport;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: PremiumCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.violet.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    bugReport.bugId,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.violet,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _StatusBadge(status: bugReport.status),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              bugReport.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              bugReport.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.screenBg,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    bugReport.type.label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                        ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(bugReport.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final BugStatus status;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case BugStatus.open:
        bgColor = AppColors.red.withValues(alpha: 0.1);
        textColor = AppColors.red;
      case BugStatus.inProgress:
        bgColor = AppColors.orange.withValues(alpha: 0.1);
        textColor = AppColors.orange;
      case BugStatus.resolved:
        bgColor = AppColors.emerald.withValues(alpha: 0.1);
        textColor = AppColors.emerald;
      case BugStatus.closed:
        bgColor = AppColors.textSecondary.withValues(alpha: 0.1);
        textColor = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
      ),
    );
  }
}

class _ReportBugSheet extends ConsumerStatefulWidget {
  const _ReportBugSheet({required this.ref});

  final WidgetRef ref;

  @override
  ConsumerState<_ReportBugSheet> createState() => _ReportBugSheetState();
}

class _ReportBugSheetState extends ConsumerState<_ReportBugSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  BugType _selectedType = BugType.uiBug;
  List<File> _selectedImages = [];
  bool _isSubmitting = false;
  int _totalImageSizeBytes = 0;

  static const int _maxTotalSizeMb = 15;
  static const int _maxTotalSizeBytes = _maxTotalSizeMb * 1024 * 1024;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          top: AppSpacing.md,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Report a Bug',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildTypeDropdown(),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(
              controller: _titleController,
              label: 'Bug Title',
              hint: 'Brief description of the bug',
              maxLength: 200,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Describe the bug in detail',
              maxLength: 2000,
              maxLines: 5,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildImagePicker(),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: AppSpacing.sm),
                AppButton(
                  label: 'Submit',
                  isLoading: _isSubmitting,
                  onPressed: _isSubmitting ? null : _submitBugReport,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bug Type',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<BugType>(
          initialValue: _selectedType,
          items: BugType.values
              .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type.label),
                  ))
              .toList(),
          onChanged: (type) => setState(() => _selectedType = type!),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLength = 200,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          maxLength: maxLength,
          maxLines: maxLines,
          enabled: !_isSubmitting,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            contentPadding: const EdgeInsets.all(AppSpacing.md),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Screenshots (Optional)',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: 'Pick Images',
          isLoading: false,
          onPressed: _isSubmitting || _selectedImages.length >= 5
              ? null
              : _pickImages,
        ),
        if (_selectedImages.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _selectedImages
                .asMap()
                .entries
                .map((e) => _ImagePreview(
                  image: e.value,
                  onRemove: () async {
                    final size = await e.value.length();
                    setState(() {
                      _selectedImages.removeAt(e.key);
                      _totalImageSizeBytes -= size;
                    });
                  },
                ))
                .toList(),
          ),
        ],
      ],
    );
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.isEmpty) return;

    final remaining = 5 - _selectedImages.length;
    for (final img in images.take(remaining)) {
      final file = File(img.path);
      final size = await file.length();
      if (_totalImageSizeBytes + size > _maxTotalSizeBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Total image size exceeds ${_maxTotalSizeMb}MB limit')),
          );
        }
        break;
      }
      setState(() {
        _selectedImages.add(file);
        _totalImageSizeBytes += size;
      });
    }
  }

  Future<void> _submitBugReport() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      _showSnackbar('Title is required');
      return;
    }

    if (title.length < 3) {
      _showSnackbar('Title must be at least 3 characters');
      return;
    }

    if (description.isEmpty) {
      _showSnackbar('Description is required');
      return;
    }

    if (description.length < 10) {
      _showSnackbar('Description must be at least 10 characters');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref.read(bugReportSubmitProvider(BugReportPayload(
        title: title,
        description: description,
        type: _selectedType.apiValue,
        images: _selectedImages,
      )).future);

      if (mounted) {
        _showSnackbar('Bug report submitted successfully');
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackbar(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _BugReportDetailSheet extends ConsumerWidget {
  const _BugReportDetailSheet({required this.bugReportId});

  final String bugReportId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bugReportAsync = ref.watch(bugReportDetailProvider(bugReportId));

    return bugReportAsync.when(
      loading: () => const Center(child: AppLoader()),
      error: (error, stack) => Center(
        child: EmptyStateCard(
          type: EmptyStateType.generic,
          title: 'Unable to Load',
          message: 'Failed to load bug report. Please try again.',
        ),
      ),
      data: (bugReport) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bugReport.bugId,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          bugReport.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  _StatusBadge(status: bugReport.status),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.screenBg,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      bugReport.type.label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                bugReport.description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (bugReport.images.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Images',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: bugReport.images
                      .map((img) => _ImageThumbnail(imageUrl: img.url))
                      .toList(),
                ),
              ],
              if (bugReport.status == BugStatus.resolved) ...[
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: AppColors.emerald.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppColors.emerald,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Resolved',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppColors.emerald,
                                ),
                          ),
                        ],
                      ),
                      if (bugReport.resolvedAt != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Resolved on ${_formatDate(bugReport.resolvedAt!)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      if (bugReport.resolutionNotes != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Notes',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          bugReport.resolutionNotes!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Reported on ${_formatDate(bugReport.createdAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({
    required this.image,
    required this.onRemove,
  });

  final File image;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            image: DecorationImage(
              image: FileImage(image),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: -8,
          right: -8,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(
                Icons.close,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ImageThumbnail extends StatelessWidget {
  const _ImageThumbnail({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          color: AppColors.screenBg,
        ),
        child: const Icon(Icons.image_not_supported),
      );
    }

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        image: DecorationImage(
          image: NetworkImage(imageUrl!),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
