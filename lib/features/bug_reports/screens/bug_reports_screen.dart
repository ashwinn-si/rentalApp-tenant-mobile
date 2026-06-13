import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_tokens.dart';
import '../../../core/providers/error_handler_provider.dart';
import '../../../widgets/templates/list_page_template.dart';
import '../../../widgets/ui/app_button.dart';
import '../../../widgets/ui/app_loader.dart';
import '../../../widgets/ui/pagination_footer.dart';
import '../../../widgets/ui/premium_card.dart';
import '../../../widgets/ui/empty_state_card.dart';
import '../data/models/bug_reports_model.dart';
import '../providers/bug_reports_provider.dart';

class BugReportsScreen extends ConsumerStatefulWidget {
  const BugReportsScreen({super.key});

  @override
  ConsumerState<BugReportsScreen> createState() => _BugReportsScreenState();
}

class _BugReportsScreenState extends ConsumerState<BugReportsScreen> {
  static const int itemsPerPage = 10;
  int currentPage = 1;
  String? selectedStatus;

  List<Widget> _refreshAction() => [
        IconButton(
          onPressed: () {
            ref.invalidate(
              bugReportsWithPaginationProvider(
                BugReportsParams(
                  status: selectedStatus,
                  page: currentPage,
                  limit: itemsPerPage,
                ),
              ),
            );
          },
          icon: const Icon(Icons.refresh_outlined, color: Colors.white),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final bugReportsAsync = ref.watch(
      bugReportsWithPaginationProvider(
        BugReportsParams(
          status: selectedStatus,
          page: currentPage,
          limit: itemsPerPage,
        ),
      ),
    );

    return bugReportsAsync.when(
      loading: () => ListPageTemplate(
        title: 'Bug Reports',
        isLoading: true,
        actions: _refreshAction(),
        body: const SizedBox.shrink(),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showReportDialog(context, ref),
          backgroundColor: AppColors.violet,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      error: (error, stack) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ApiErrorHandler.handleAccessDenied(error, ref);
        });
        return ListPageTemplate(
          title: 'Bug Reports',
          errorMessage: 'Failed to load bug reports',
          actions: _refreshAction(),
          body: const SizedBox.shrink(),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showReportDialog(context, ref),
            backgroundColor: AppColors.violet,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
      data: (response) {
        final bugReports = response.items;
        final pagination = response.pagination;

        if (bugReports.isEmpty) {
          return ListPageTemplate(
            title: 'Bug Reports',
            actions: _refreshAction(),
            body: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildStatusFilter(),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.15,
                        ),
                        child: EmptyStateCard(
                          type: EmptyStateType.generic,
                          title: 'No bug reports yet',
                          message: 'Help us improve the app',
                          actionLabel: 'Report Your First Bug',
                          onActionPressed: () => _showReportDialog(context, ref),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showReportDialog(context, ref),
              backgroundColor: AppColors.violet,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          );
        }

        return ListPageTemplate(
          title: 'Bug Reports',
          actions: _refreshAction(),
          body: ListView.builder(
            padding: EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.md,
              top: AppSpacing.md,
              bottom: pagination.totalPages > 1 ? 100 : AppSpacing.xl,
            ),
            itemCount: bugReports.length + 1 + (pagination.totalPages > 1 ? 1 : 0),
            itemBuilder: (context, index) {
              // First item is status filter
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _buildStatusFilter(),
                );
              }

              final dataIndex = index - 1;

              // Last item is pagination
              if (pagination.totalPages > 1 && dataIndex == bugReports.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: PaginationFooter(
                    currentPage: pagination.page,
                    totalPages: pagination.totalPages,
                    onPreviousPressed: pagination.page > 1
                        ? () => setState(() => currentPage = pagination.page - 1)
                        : null,
                    onNextPressed: pagination.page < pagination.totalPages
                        ? () => setState(() => currentPage = pagination.page + 1)
                        : null,
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _BugReportCard(
                  bugReport: bugReports[dataIndex],
                  onTap: () => _showDetailDialog(context, ref, bugReports[dataIndex].id),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showReportDialog(context, ref),
            backgroundColor: AppColors.violet,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildStatusFilter() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filterBg = isDark ? const Color(0xFF2C2550) : AppColors.violet.withValues(alpha: 0.08);
    final selectedBg = AppColors.violet;
    final selectedText = Colors.white;
    final unselectedText = isDark ? const Color(0xFFF3F4F6) : AppColors.textPrimary;

    final statuses = [
      {'value': null, 'label': 'All'},
      {'value': 'open', 'label': 'Open'},
      {'value': 'in_progress', 'label': 'In Progress'},
      {'value': 'resolved', 'label': 'Resolved'},
      {'value': 'closed', 'label': 'Closed'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: statuses.map((status) {
          final isSelected = selectedStatus == status['value'];
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: Text(
                status['label'] as String,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? selectedText : unselectedText,
                ),
              ),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  selectedStatus = status['value'] as String?;
                  currentPage = 1;
                });
              },
              backgroundColor: filterBg,
              selectedColor: selectedBg,
              side: BorderSide(
                color: isSelected ? selectedBg : AppColors.violet.withValues(alpha: 0.2),
                width: 1,
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
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

  void _showDetailDialog(
      BuildContext context, WidgetRef ref, String bugReportId) {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typeBadgeBg = isDark
        ? const Color(0xFF2C2550)
        : AppColors.screenBg;

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
                    color: typeBadgeBg,
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
  final List<File> _selectedImages = [];
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
                  onPressed:
                      _isSubmitting ? null : () => Navigator.pop(context),
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
          onPressed:
              _isSubmitting || _selectedImages.length >= 5 ? null : _pickImages,
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
            const SnackBar(
                content: Text(
                    'Total image size exceeds ${_maxTotalSizeMb}MB limit')),
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
      error: (error, stack) => const Center(
        child: EmptyStateCard(
          type: EmptyStateType.generic,
          title: 'Unable to Load',
          message: 'Failed to load bug report. Please try again.',
        ),
      ),
      data: (bugReport) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final typeBadgeBg =
            isDark ? const Color(0xFF2C2550) : AppColors.screenBg;

        return SingleChildScrollView(
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
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
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
                      color: typeBadgeBg,
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
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.emerald,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Resolved',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
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
      );
      },
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (imageUrl == null) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          color: isDark ? const Color(0xFF2C2550) : AppColors.screenBg,
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
