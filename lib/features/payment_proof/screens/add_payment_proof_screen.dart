import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_tokens.dart';
import '../../../core/services/toast_service.dart';
import '../../../core/utils/app_bar_helper.dart';
import '../../../widgets/ui/screen_background.dart';
import '../data/models/payment_proof.dart';
import '../providers/payment_proof_provider.dart'
    show
        paymentProofRepositoryProvider,
        paymentProofsProvider,
        activeRentProvider,
        RentParams;

class AddPaymentProofScreen extends ConsumerStatefulWidget {
  final String? rentRecordId;

  const AddPaymentProofScreen({this.rentRecordId, super.key});

  @override
  ConsumerState<AddPaymentProofScreen> createState() =>
      _AddPaymentProofScreenState();
}

class _AddPaymentProofScreenState extends ConsumerState<AddPaymentProofScreen> {
  late DateTime now;
  late int selectedMonth;
  late int selectedYear;

  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  final List<Map<String, String>> paymentMethods = [
    {'label': 'Cash', 'value': 'cash'},
    {'label': 'Bank Transfer', 'value': 'bank_transfer'},
    {'label': 'Cheque', 'value': 'cheque'},
    {'label': 'UPI', 'value': 'upi'},
    {'label': 'NEFT', 'value': 'neft'},
  ];

  late Set<String> selectedMethods;
  late Map<String, TextEditingController> amountControllers;
  late TextEditingController paidToController;
  late List<File> selectedImages;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    now = DateTime.now();
    selectedMonth = now.month;
    selectedYear = now.year;
    selectedMethods = {'cash'};
    amountControllers = {'cash': TextEditingController()};
    paidToController = TextEditingController();
    selectedImages = [];
  }

  @override
  void dispose() {
    paidToController.dispose();
    for (var controller in amountControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String formatINR(double value) {
    return '₹${value.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final rentAsync = ref.watch(
      activeRentProvider(
        RentParams(month: selectedMonth, year: selectedYear),
      ),
    );

    return Scaffold(
      appBar: buildPremiumAppBar(title: 'Submit Payment Proof'),
      body: ScreenBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month & Year Selector
                _buildMonthYearSelector(),
                const SizedBox(height: AppSpacing.lg),

                // Rent Details
                rentAsync.when(
                  loading: () => Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: const SizedBox(
                      height: 150,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.violet,
                        ),
                      ),
                    ),
                  ),
                  error: (_, __) => Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(
                      'Failed to load rent details',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  data: (rent) {
                    if (rent == null) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Text(
                          'No rent record for ${months[selectedMonth - 1]} $selectedYear',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      );
                    }
                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.violet.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Balance Due',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              formatINR(rent.totalDue),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.violet,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.05),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                              child: Column(
                                children: [
                                  _buildRentBreakdownRow(
                                      'Base Rent', rent.baseRent),
                                  const Divider(height: 12),
                                  _buildRentBreakdownRow(
                                      'Electricity', rent.electricityBill),
                                  const Divider(height: 12),
                                  _buildRentBreakdownRow(
                                      'Maintenance', rent.maintenanceShare),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Payment Methods
                _buildPaymentMethodsSelector(),
                const SizedBox(height: AppSpacing.lg),

                // Amount Inputs
                _buildAmountInputs(),
                const SizedBox(height: AppSpacing.lg),

                // Paid To Name
                _buildPaidToInput(),
                const SizedBox(height: AppSpacing.lg),

                // Image Upload
                _buildImageUploader(),
                const SizedBox(height: AppSpacing.lg),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : rentAsync.maybeWhen(
                            data: (rent) => rent != null ? _submitProof : null,
                            orElse: () => null,
                          ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      backgroundColor: AppColors.violet,
                      disabledBackgroundColor: AppColors.violet.withOpacity(
                        0.35,
                      ),
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white70,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      elevation: 0,
                    ),
                    child: isSubmitting
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                'Submitting...',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(color: Colors.white),
                              ),
                            ],
                          )
                        : Text(
                            'Submit Proof',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthYearSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.violet.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Month & Year',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: selectedMonth,
                      underline: const SizedBox(),
                      items: List.generate(
                        12,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text(months[index]),
                        ),
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedMonth = value);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: selectedYear,
                      underline: const SizedBox(),
                      items: [now.year - 1, now.year, now.year + 1]
                          .map(
                            (year) => DropdownMenuItem(
                              value: year,
                              child: Text(year.toString()),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedYear = value);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRentBreakdownRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        Text(
          formatINR(amount),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
        ),
      ],
    );
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method) {
      case 'cash':
        return Icons.money;
      case 'bank_transfer':
        return Icons.account_balance;
      case 'cheque':
        return Icons.receipt;
      case 'upi':
        return Icons.mobile_screen_share;
      case 'neft':
        return Icons.transit_enterexit;
      default:
        return Icons.payment;
    }
  }

  Widget _buildPaymentMethodsSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.violet.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Methods',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: paymentMethods.map((method) {
                final isSelected = selectedMethods.contains(method['value']);
                return FilterChip(
                  avatar: Icon(
                    _getPaymentMethodIcon(method['value']!),
                    size: 16,
                  ),
                  label: Text(method['label']!),
                  selected: isSelected,
                  backgroundColor: Colors.white,
                  selectedColor: AppColors.violet.withOpacity(0.15),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.violet
                        : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.5 : 1,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedMethods.add(method['value']!);
                        if (!amountControllers
                            .containsKey(method['value']!)) {
                          amountControllers[method['value']!] =
                              TextEditingController();
                        }
                      } else {
                        selectedMethods.remove(method['value']!);
                        amountControllers[method['value']!]?.dispose();
                        amountControllers.remove(method['value']!);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInputs() {
    final total = _calculateTotal();
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.violet.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Amount Breakdown',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.violet.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    'Total: ${formatINR(total)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.violet,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ...selectedMethods.map((method) {
              final label = paymentMethods
                  .firstWhere((m) => m['value'] == method)['label']!;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: TextFormField(
                  controller: amountControllers[method]!,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '$label Amount',
                    hintText: '0.00',
                    prefixText: '₹ ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(
                        color: Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(
                        color: Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(
                        color: AppColors.violet,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaidToInput() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.violet.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: TextFormField(
          controller: paidToController,
          decoration: InputDecoration(
            labelText: 'Paid To (Name)',
            hintText: 'e.g., Landlord Name',
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(
                color: AppColors.violet,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploader() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.violet.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Proof Images',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.violet.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    '${selectedImages.length}/5',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.violet,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Optional',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (selectedImages.isNotEmpty)
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                children: [
                  ...selectedImages.map((file) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: Image.file(
                            file,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: -8,
                          right: -8,
                          child: GestureDetector(
                            onTap: () {
                              setState(() => selectedImages.remove(file));
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: AppColors.red,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  if (selectedImages.length < 5) _buildAddImageButton(),
                ],
              )
            else
              _buildAddImageButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: selectedImages.length < 5 ? _pickImage : null,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedImages.length < 5
                ? AppColors.violet.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.2),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
          color: selectedImages.length < 5
              ? AppColors.violet.withValues(alpha: 0.03)
              : Colors.grey.withValues(alpha: 0.02),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate,
                size: 32,
                color: selectedImages.length < 5
                    ? AppColors.violet
                    : Colors.grey,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Add Image',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: selectedImages.length < 5
                          ? AppColors.violet
                          : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateTotal() {
    double total = 0;
    for (var method in selectedMethods) {
      final amount =
          double.tryParse(amountControllers[method]?.text ?? '0') ?? 0;
      total += amount;
    }
    return total;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => selectedImages.add(File(image.path)));
    }
  }

  bool _validateForm() {
    if (selectedMethods.isEmpty) {
      ToastService.showError('Select at least one payment method');
      return false;
    }

    final total = _calculateTotal();
    if (total <= 0) {
      ToastService.showError('Enter valid amounts');
      return false;
    }

    if (paidToController.text.isEmpty) {
      ToastService.showError('Enter who you paid to');
      return false;
    }

    return true;
  }

  Future<void> _submitProof() async {
    if (!_validateForm()) return;

    setState(() => isSubmitting = true);
    try {
      final repository = ref.read(paymentProofRepositoryProvider);

      // Get the active rent to get its ID
      final rentAsync = ref.read(
        activeRentProvider(
          RentParams(month: selectedMonth, year: selectedYear),
        ).future,
      );

      final rent = await rentAsync;
      if (rent == null) {
        ToastService.showError('No rent record for this month');
        setState(() => isSubmitting = false);
        return;
      }

      // Build payment methods list
      final paymentMethodsList = <PaymentMethod>[];
      for (var method in selectedMethods) {
        final amount =
            double.tryParse(amountControllers[method]?.text ?? '0') ?? 0;
        if (amount > 0) {
          paymentMethodsList.add(
            PaymentMethod(method: method, amount: amount),
          );
        }
      }

      // Read file bytes if any
      final fileBytes = <List<int>>[];
      final fileNames = <String>[];
      for (var imageFile in selectedImages) {
        fileBytes.add(await imageFile.readAsBytes());
        fileNames.add(
            '${DateTime.now().millisecondsSinceEpoch}-${imageFile.path.split('/').last}');
      }

      // Submit proof with files (unified endpoint)
      if (fileBytes.isNotEmpty) {
        await repository.submitProofWithFiles(
          rentRecordId: rent.id,
          paidToName: paidToController.text,
          paymentMethods: paymentMethodsList,
          fileBytes: fileBytes,
          fileNames: fileNames,
        );
      } else {
        // Fallback to legacy endpoint if no files
        await repository.submitProof(
          rentRecordId: rent.id,
          paidToName: paidToController.text,
          paymentMethods: paymentMethodsList,
        );
      }

      if (mounted) {
        ToastService.showSuccess('Proof submitted successfully');
        ref.invalidate(paymentProofsProvider);
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError('Failed to submit: $e');
      }
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }
}
