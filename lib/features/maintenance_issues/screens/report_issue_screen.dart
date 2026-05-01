import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_tokens.dart';
import '../../../core/services/toast_service.dart';
import '../../../core/utils/app_bar_helper.dart';
import '../../../widgets/ui/app_button.dart';
import '../../../widgets/ui/app_text_field.dart';
import '../../../widgets/ui/screen_background.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../providers/maintenance_provider.dart';

class ReportIssueScreen extends ConsumerStatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  ConsumerState<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends ConsumerState<ReportIssueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _costController = TextEditingController();

  String _category = 'maintenance';
  String _scope = 'flat';
  String? _selectedFlatId;
  final List<XFile> _images = [];
  bool _isSaving = false;
  String? _sizeError;
  int _totalImageSizeBytes = 0;

  static const int maxTotalSizeMb = 5;
  static const int maxTotalSizeBytes = maxTotalSizeMb * 1024 * 1024;

  final List<Map<String, String>> _categories = [
    {'value': 'plumbing', 'label': 'Plumbing'},
    {'value': 'electrical', 'label': 'Electrical'},
    {'value': 'structural', 'label': 'Structural'},
    {'value': 'appliance', 'label': 'Appliance'},
    {'value': 'cleaning', 'label': 'Cleaning'},
    {'value': 'maintenance', 'label': 'General Maintenance'},
    {'value': 'other', 'label': 'Other'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isEmpty) return;

    setState(() => _sizeError = null);

    // Calculate new total size with picked files
    int newFilesSize = 0;
    final fileSizes = <int>[];
    for (final file in pickedFiles) {
      final fileSize = await file.length();
      newFilesSize += fileSize;
      fileSizes.add(fileSize);
    }

    final newTotalSize = _totalImageSizeBytes + newFilesSize;

    if (newTotalSize > maxTotalSizeBytes) {
      final remainingMB = ((maxTotalSizeBytes - _totalImageSizeBytes) / (1024 * 1024)).toStringAsFixed(2);
      setState(() {
        _sizeError = 'Cannot add these images. Total size would exceed ${maxTotalSizeMb}MB. You can add ${remainingMB}MB more.';
      });
      return;
    }

    setState(() {
      if (_images.length + pickedFiles.length > 5) {
        ToastService.showError('Maximum 5 images allowed');
        final filesToAdd = pickedFiles.take(5 - _images.length).toList();
        final sizesToAdd = fileSizes.take(5 - _images.length).toList();
        _images.addAll(filesToAdd);
        for (final size in sizesToAdd) {
          _totalImageSizeBytes += size;
        }
      } else {
        _images.addAll(pickedFiles);
        _totalImageSizeBytes = newTotalSize;
      }
    });
  }

  void _removeImage(int index) async {
    final removedFile = _images[index];
    final removedSize = await removedFile.length();
    setState(() {
      _images.removeAt(index);
      _totalImageSizeBytes -= removedSize.toInt();
      _sizeError = null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFlatId == null) {
      ToastService.showError('Please select a unit');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final asyncDashboard = ref.read(activeDashboardProvider);
      final dashboardData = asyncDashboard.value;
      if (dashboardData == null) throw Exception('Dashboard data not loaded');

      final flat = dashboardData.availableFlats
          .firstWhere((f) => f.id == _selectedFlatId);

      final repository = ref.read(maintenanceRepositoryProvider);
      final result = await repository.createIssue(
        apartmentId: flat.apartmentId,
        flatId: _selectedFlatId!,
        scope: _scope,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _category,
        tenantRepairCost: num.tryParse(_costController.text),
        imagePaths: _images.map((e) => e.path).toList(),
      );

      if (result.isSuccess) {
        ToastService.showSuccess('Issue reported successfully');
        if (mounted) {
          ref.invalidate(maintenanceIssuesProvider);
          context.pop();
        }
      } else {
        ToastService.showError(result.error ?? 'Failed to report issue');
      }
    } catch (e) {
      ToastService.showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncDashboard = ref.watch(activeDashboardProvider);

    return Scaffold(
      appBar: buildPremiumAppBar(title: 'Report Issue'),
      body: ScreenBackground(
        child: asyncDashboard.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
          data: (dashboardData) {
            final defaultFlatId = _selectedFlatId ?? dashboardData.availableFlats.firstOrNull?.id ?? '';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Describe the maintenance issue you are facing.',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Unit Selector
                    const Text('Unit',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSpacing.xs),
                    DropdownButtonFormField<String>(
                      initialValue: defaultFlatId.isNotEmpty ? defaultFlatId : null,
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      items: dashboardData.availableFlats.map((f) {
                        return DropdownMenuItem(
                            value: f.id, child: Text(f.label));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedFlatId = val),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Scope Toggle
                    const Text('Issue Scope',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('My Unit Only')),
                            selected: _scope == 'flat',
                            onSelected: (val) =>
                                setState(() => _scope = 'flat'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Apartment-wide')),
                            selected: _scope == 'apartment',
                            onSelected: (val) =>
                                setState(() => _scope = 'apartment'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Category
                    const Text('Category',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSpacing.xs),
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      items: _categories.map((c) {
                        return DropdownMenuItem(
                            value: c['value'], child: Text(c['label']!));
                      }).toList(),
                      onChanged: (val) => setState(() => _category = val!),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Title
                    AppTextField(
                      label: 'Title',
                      placeholder: 'e.g. Leaking kitchen tap',
                      controller: _titleController,
                      validator: (val) =>
                          (val?.length ?? 0) < 5 ? 'Too short' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Description
                    AppTextField(
                      label: 'Description',
                      placeholder: 'Describe the issue in detail...',
                      controller: _descriptionController,
                      maxLines: 4,
                      validator: (val) => (val?.length ?? 0) < 10
                          ? 'Please provide more details'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Cost
                    AppTextField(
                      label: 'Already paid for repair? (Optional)',
                      placeholder: 'Enter amount for reimbursement',
                      controller: _costController,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.currency_rupee,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Images
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Photos (Max 5)',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          '${(_totalImageSizeBytes / (1024 * 1024)).toStringAsFixed(2)}MB / ${maxTotalSizeMb}MB',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (_sizeError != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _sizeError!,
                          style: const TextStyle(
                            color: Color(0xFFDC2626),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ..._images.asMap().entries.map((entry) {
                            return Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                      image: FileImage(File(entry.value.path)),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 12,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(entry.key),
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close,
                                          size: 16, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                          if (_images.length < 5)
                            GestureDetector(
                              onTap: _pickImages,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.grey.shade300,
                                      style: BorderStyle.solid),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo_outlined,
                                        color: AppColors.textSecondary),
                                    Text('Add Photo',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),
                    AppButton(
                      label: 'Submit Report',
                      onPressed: _submit,
                      isLoading: _isSaving,
                      fullWidth: true,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
