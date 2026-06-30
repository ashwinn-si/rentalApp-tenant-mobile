import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/constants/app_tokens.dart';
import '../../../core/services/toast_service.dart';
import '../../../core/utils/app_bar_helper.dart';
import '../../../widgets/domain/flat_selector.dart';
import '../../../widgets/ui/screen_background.dart';
import '../../auth/providers/auth_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';
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
  String? selectedFlatId;

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
  String? sizeError;
  int totalImageSizeBytes = 0;

  static const int maxTotalSizeMb = 5;
  static const int maxTotalSizeBytes = maxTotalSizeMb * 1024 * 1024;

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
    _loadActiveMonth();
  }

  Future<void> _loadActiveMonth() async {
    try {
      final repo = ref.read(paymentProofRepositoryProvider);
      final response = await repo.getActiveRentMonth();
      if (mounted) {
        setState(() {
          selectedMonth = response['currentRentMonth'] as int? ?? now.month;
          selectedYear = response['currentRentYear'] as int? ?? now.year;
        });
      }
    } catch (e) {
      developer.log('[AddPaymentProofScreen] Failed to load active month: $e');
    }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF171527) : Colors.white;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0);

    final rentAsync = ref.watch(
      activeRentProvider(
        RentParams(month: selectedMonth, year: selectedYear),
      ),
    );
    final asyncDashboard = ref.watch(activeDashboardProvider);

    return Scaffold(
      appBar: buildPremiumAppBar(title: 'Submit Payment Proof'),
      body: ScreenBackground(
        child: asyncDashboard.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Error loading data')),
          data: (dashboardData) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Flat Selector
                    if (dashboardData.availableFlats.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                        child: FlatSelector(
                          flats: dashboardData.availableFlats
                              .map((flat) => FlatModel(id: flat.id, label: flat.label))
                              .toList(),
                        ),
                      ),
                    // Month & Year Selector
                    _buildMonthYearSelector(),
                    const SizedBox(height: AppSpacing.lg),

                // Rent Details
                rentAsync.when(
                  loading: () => Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: borderColor,
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
                      color: cardBg,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: borderColor,
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
                          color: cardBg,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(
                            color: borderColor,
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

                    final calculatedTotalDue = rent.totalDue;

                    final isPaid = rent.paidAmount >= calculatedTotalDue;
                    final amountDueToPay = isPaid ? 0.0 : (calculatedTotalDue - rent.paidAmount);

                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: borderColor,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.violet.withValues(alpha: 0.04),
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
                            // Total Due
                            Text(
                              'Total Due',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.8,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              formatINR(calculatedTotalDue),
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            // Breakdown
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Base Rent',
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                              color: AppColors.textSecondary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                      Text(
                                        formatINR(rent.baseRent),
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Divider(color: AppColors.textSecondary.withValues(alpha: 0.15)),
                                  const SizedBox(height: AppSpacing.sm),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Electricity',
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                              color: AppColors.textSecondary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                      Text(
                                        formatINR(rent.electricityBill),
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Divider(color: AppColors.textSecondary.withValues(alpha: 0.15)),
                                  const SizedBox(height: AppSpacing.sm),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        rent.maintenanceShare < 0 ? 'Maintenance Credit' : 'Maintenance',
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                              color: AppColors.textSecondary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                      Text(
                                        formatINR(rent.maintenanceShare),
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: rent.maintenanceShare < 0 ? AppColors.paid : AppColors.textPrimary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            // Already Paid
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Already Paid',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: AppColors.paid,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                ),
                                Text(
                                  formatINR(rent.paidAmount),
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.paid,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Divider(
                              height: 1,
                              color: AppColors.textSecondary.withValues(alpha: 0.2),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            // Amount Due to Pay
                            Container(
                              decoration: BoxDecoration(
                                color: isPaid
                                    ? AppColors.paid.withValues(alpha: 0.08)
                                    : AppColors.pending.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Amount Due to Pay',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: isPaid ? AppColors.paid : AppColors.pending,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  Text(
                                    formatINR(amountDueToPay),
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: isPaid ? AppColors.paid : AppColors.pending,
                                        ),
                                  ),
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
                      disabledBackgroundColor: AppColors.violet.withValues(
                        alpha: 0.35,
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildMonthYearSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF171527) : Colors.white;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.violet.withValues(alpha: 0.04),
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
                        color: borderColor,
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
                        color: borderColor,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF171527) : Colors.white;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.violet.withValues(alpha: 0.04),
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
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              children: paymentMethods.map((method) {
                final isSelected = selectedMethods.contains(method['value']);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedMethods.remove(method['value']!);
                        amountControllers[method['value']!]?.dispose();
                        amountControllers.remove(method['value']!);
                      } else {
                        selectedMethods.add(method['value']!);
                        if (!amountControllers.containsKey(method['value']!)) {
                          amountControllers[method['value']!] =
                              TextEditingController();
                        }
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.violet.withValues(alpha: 0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: isSelected ? AppColors.violet : borderColor,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getPaymentMethodIcon(method['value']!),
                          size: 28,
                          color: isSelected ? AppColors.violet : AppColors.textSecondary,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          method['label']!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isSelected ? AppColors.violet : AppColors.textSecondary,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInputs() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF171527) : Colors.white;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0);
    final inputFillColor = isDark ? const Color(0xFF2A2540) : Colors.white;

    final total = _calculateTotal();
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.violet.withValues(alpha: 0.04),
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
                    color: AppColors.violet.withValues(alpha: 0.08),
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
                      borderSide: BorderSide(
                        color: borderColor,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(
                        color: borderColor,
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
                    fillColor: inputFillColor,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPaidToInput() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF171527) : Colors.white;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0);
    final inputFillColor = isDark ? const Color(0xFF2A2540) : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.violet.withValues(alpha: 0.04),
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
              borderSide: BorderSide(
                color: borderColor,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: borderColor,
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
            fillColor: inputFillColor,
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF171527) : Colors.white;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.violet.withValues(alpha: 0.04),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.violet,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(totalImageSizeBytes / (1024 * 1024)).toStringAsFixed(2)}MB / ${maxTotalSizeMb}MB',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
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
            if (sizeError != null)
              Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  sizeError!,
                  style: const TextStyle(
                    color: AppColors.red,
                    fontSize: 12,
                  ),
                ),
              ),
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
                            onTap: () async {
                              final fileSize = await file.length();
                              setState(() {
                                selectedImages.remove(file);
                                totalImageSizeBytes -= fileSize.toInt();
                                sizeError = null;
                              });
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
                  }),
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
      onTap: selectedImages.length < 5 ? _pickFile : null,
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
                Icons.attach_file,
                size: 32,
                color:
                    selectedImages.length < 5 ? AppColors.violet : Colors.grey,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Add File',
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

  Future<void> _pickFile() async {
    final remaining = 5 - selectedImages.length;
    if (remaining <= 0) return;

    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null || result.files.isEmpty) return;

    setState(() => sizeError = null);

    for (final file in result.files.take(remaining)) {
      final filePath = file.path;
      if (filePath == null) continue;

      final fileSize = await File(filePath).length();
      final newTotalSize = totalImageSizeBytes + fileSize;

      if (newTotalSize > maxTotalSizeBytes) {
        final remainingMB = ((maxTotalSizeBytes - totalImageSizeBytes) / (1024 * 1024)).toStringAsFixed(2);
        setState(() {
          sizeError = 'Cannot add more files. Total size exceeds ${maxTotalSizeMb}MB. You can add ${remainingMB}MB more.';
        });
        break;
      }

      setState(() {
        selectedImages.add(File(filePath));
        totalImageSizeBytes = newTotalSize;
      });
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

      final total = _calculateTotal();
      final remainingDue = (rent.totalDue - rent.paidAmount).clamp(0.0, double.infinity);
      if (total > remainingDue) {
        ToastService.showError(
          'Amount cannot exceed remaining rent due of ₹${remainingDue.toStringAsFixed(2)}',
        );
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
