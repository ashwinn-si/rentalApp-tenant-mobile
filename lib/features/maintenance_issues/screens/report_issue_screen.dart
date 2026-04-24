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
    if (pickedFiles.isNotEmpty) {
      setState(() {
        if (_images.length + pickedFiles.length > 5) {
          ToastService.showError('Maximum 5 images allowed');
          _images.addAll(pickedFiles.take(5 - _images.length));
        } else {
          _images.addAll(pickedFiles);
        }
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
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

      final flat = dashboardData.availableFlats.firstWhere((f) => f.id == _selectedFlatId);

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
            if (_selectedFlatId == null && dashboardData.availableFlats.isNotEmpty) {
              _selectedFlatId = dashboardData.availableFlats.first.id;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Describe the maintenance issue you are facing.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Unit Selector
                    const Text('Unit', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSpacing.xs),
                    DropdownButtonFormField<String>(
                      value: _selectedFlatId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      items: dashboardData.availableFlats.map((f) {
                        return DropdownMenuItem(value: f.id, child: Text(f.label));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedFlatId = val),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Scope Toggle
                    const Text('Issue Scope', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('My Unit Only')),
                            selected: _scope == 'flat',
                            onSelected: (val) => setState(() => _scope = 'flat'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Apartment-wide')),
                            selected: _scope == 'apartment',
                            onSelected: (val) => setState(() => _scope = 'apartment'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Category
                    const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSpacing.xs),
                    DropdownButtonFormField<String>(
                      value: _category,
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      items: _categories.map((c) {
                        return DropdownMenuItem(value: c['value'], child: Text(c['label']!));
                      }).toList(),
                      onChanged: (val) => setState(() => _category = val!),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Title
                    AppTextField(
                      label: 'Title',
                      placeholder: 'e.g. Leaking kitchen tap',
                      controller: _titleController,
                      validator: (val) => (val?.length ?? 0) < 5 ? 'Too short' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Description
                    AppTextField(
                      label: 'Description',
                      placeholder: 'Describe the issue in detail...',
                      controller: _descriptionController,
                      maxLines: 4,
                      validator: (val) =>
                          (val?.length ?? 0) < 10 ? 'Please provide more details' : null,
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
                    const Text('Photos (Max 5)', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSpacing.sm),
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
                                      child: const Icon(Icons.close, size: 16, color: Colors.white),
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
                                  border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo_outlined, color: AppColors.textSecondary),
                                    Text('Add Photo', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
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
