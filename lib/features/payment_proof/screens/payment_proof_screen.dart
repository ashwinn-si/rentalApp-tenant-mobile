import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_tokens.dart';
import '../../../core/services/toast_service.dart';
import '../../../core/utils/animations.dart';
import '../../../core/utils/app_bar_helper.dart';
import '../../../widgets/ui/app_loader.dart';
import '../../../widgets/ui/premium_card.dart';
import '../../../widgets/ui/screen_background.dart';
import '../../../widgets/ui/state_card.dart';
import '../providers/payment_proof_provider.dart';

class PaymentProofScreen extends ConsumerStatefulWidget {
  const PaymentProofScreen({super.key});

  @override
  ConsumerState<PaymentProofScreen> createState() =>
      _PaymentProofScreenState();
}

class _PaymentProofScreenState extends ConsumerState<PaymentProofScreen> {
  late DateTime now;
  late int selectedMonth;
  late int selectedYear;

  final List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  final paymentMethods = [
    {'label': 'Cash', 'value': 'cash'},
    {'label': 'Bank Transfer', 'value': 'bank_transfer'},
    {'label': 'Cheque', 'value': 'cheque'},
    {'label': 'UPI', 'value': 'upi'},
    {'label': 'NEFT', 'value': 'neft'},
  ];

  late Set<String> selectedMethods;
  late Map<String, double> amounts;
  late TextEditingController paidToController;

  @override
  void initState() {
    super.initState();
    now = DateTime.now();
    selectedMonth = now.month;
    selectedYear = now.year;
    selectedMethods = {'cash'};
    amounts = {'cash': 0.0};
    paidToController = TextEditingController();
  }

  @override
  void dispose() {
    paidToController.dispose();
    super.dispose();
  }

  List<int> getYearOptions() {
    return [now.year - 1, now.year, now.year + 1];
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
    final proofsAsync = ref.watch(paymentProofsProvider);

    return Scaffold(
      appBar: buildPremiumAppBar(title: 'Payment Proof'),
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

                // Rent Record Display
                rentAsync.when(
                  loading: () => _buildLoadingCard(),
                  error: (_, __) => _buildErrorCard('Failed to load rent'),
                  data: (rent) => _buildRentCard(rent),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Proof History Section
                _buildProofHistorySection(proofsAsync),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthYearSelector() {
    return PremiumCard(
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
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: selectedMonth,
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
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: selectedYear,
                  items: getYearOptions()
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return PremiumCard(
      child: SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.violet,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return PremiumCard(
      child: StateCard(
        message: message,
        variant: StateCardVariant.error,
      ),
    );
  }

  Widget _buildRentCard(dynamic rent) {
    if (rent == null) {
      return PremiumCard(
        child: StateCard(
          message:
              'No rent record available for ${months[selectedMonth - 1]} $selectedYear',
          variant: StateCardVariant.warning,
        ),
      );
    }

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rent Due',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                formatINR(rent.totalDue),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildBreakdownRow('Base Rent', rent.baseRent),
          _buildBreakdownRow('Electricity', rent.electricityBill),
          _buildBreakdownRow('Maintenance', rent.maintenanceShare),
          _buildBreakdownRow('Already Paid', rent.paidAmount,
              color: AppColors.green),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String label, double amount, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
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
                  color: color ?? AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildProofHistorySection(AsyncValue<List<dynamic>> proofsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Proof History',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            proofsAsync.when(
              loading: () => SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.violet,
                ),
              ),
              error: (_, __) => IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  ref.invalidate(paymentProofsProvider);
                },
              ),
              data: (_) => IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  ref.invalidate(paymentProofsProvider);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        proofsAsync.when(
          loading: () => const AppLoader(),
          error: (err, __) => StateCard(
            message: 'Unable to load proofs',
            variant: StateCardVariant.error,
          ),
          data: (proofs) {
            if (proofs.isEmpty) {
              return StateCard(
                message: 'No submissions yet',
                variant: StateCardVariant.info,
              );
            }

            return Column(
              children: proofs
                  .map(
                    (proof) => PremiumCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                formatINR(proof.totalAmount),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              _buildStatusBadge(proof.status),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Submitted: ${proof.submittedAt != null ? proof.submittedAt.toLocal() : '—'}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                          if (proof.status == 'rejected' &&
                              proof.rejectionReason != null) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Reason: ${proof.rejectionReason}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.red,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'approved':
        bgColor = AppColors.green.withOpacity(0.1);
        textColor = AppColors.green;
        break;
      case 'rejected':
        bgColor = AppColors.red.withOpacity(0.1);
        textColor = AppColors.red;
        break;
      default:
        bgColor = AppColors.orange.withOpacity(0.1);
        textColor = AppColors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        status.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
