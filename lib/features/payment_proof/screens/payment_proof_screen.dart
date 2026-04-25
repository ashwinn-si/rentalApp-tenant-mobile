import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_tokens.dart';
import '../../../widgets/templates/list_page_template.dart';
import '../../../widgets/ui/pagination_footer.dart';
import '../data/models/payment_proof.dart';
import '../providers/payment_proof_provider.dart';
import 'proof_detail_screen.dart';
import 'add_payment_proof_screen.dart';

class PaymentProofScreen extends ConsumerStatefulWidget {
  const PaymentProofScreen({super.key});

  @override
  ConsumerState<PaymentProofScreen> createState() => _PaymentProofScreenState();
}

class _PaymentProofScreenState extends ConsumerState<PaymentProofScreen> {
  static const int itemsPerPage = 5;
  int currentPage = 0;

  String formatINR(double value) {
    return '₹${value.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final proofsAsync = ref.watch(paymentProofsProvider);

    return proofsAsync.when(
      loading: () => ListPageTemplate(
        title: 'Payment Proofs',
        isLoading: true,
        body: const SizedBox.shrink(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AddPaymentProofScreen(),
              ),
            );
          },
          backgroundColor: AppColors.violet,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      error: (err, __) => ListPageTemplate(
        title: 'Payment Proofs',
        errorMessage: 'Failed to load proofs',
        body: const SizedBox.shrink(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AddPaymentProofScreen(),
              ),
            );
          },
          backgroundColor: AppColors.violet,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      data: (allProofs) {
        final totalPages = (allProofs.length / itemsPerPage).ceil().toInt();

        // Empty state
        if (allProofs.isEmpty) {
          return ListPageTemplate(
            title: 'Payment Proofs',
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'No payment proofs yet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildAddButton(),
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AddPaymentProofScreen(),
                  ),
                );
              },
              backgroundColor: AppColors.violet,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          );
        }

        // Paginate
        final startIdx = currentPage * itemsPerPage;
        final endIdx = (startIdx + itemsPerPage).clamp(0, allProofs.length);
        final pageProofs = allProofs.sublist(startIdx, endIdx);
        final isSingleItem = pageProofs.length == 1 && totalPages == 1;

        return ListPageTemplate(
          title: 'Payment Proofs',
          body: isSingleItem
              ? SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height - 180,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ...pageProofs.map((proof) => _buildProofCard(proof)),
                        ],
                      ),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: AppSpacing.md,
                      right: AppSpacing.md,
                      top: AppSpacing.md,
                      bottom: totalPages > 1 ? 100 : AppSpacing.md,
                    ),
                    child: Column(
                      children: [
                        ...pageProofs.map((proof) => _buildProofCard(proof)),
                        if (totalPages > 1) ...[
                          const SizedBox(height: AppSpacing.md),
                          PaginationFooter(
                            currentPage: currentPage + 1,
                            totalPages: totalPages,
                            onPreviousPressed: currentPage > 0
                                ? () => setState(() => currentPage--)
                                : null,
                            onNextPressed: currentPage < totalPages - 1
                                ? () => setState(() => currentPage++)
                                : null,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AddPaymentProofScreen(),
                ),
              );
            },
            backgroundColor: AppColors.violet,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildProofCard(PaymentProof proof) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProofDetailScreen(proof: proof),
          ),
        );
      },
      child: Container(
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatINR(proof.totalAmount),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          proof.paidToName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _buildStatusBadge(proof.status),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Submitted: ${proof.submittedAt != null ? proof.submittedAt!.toLocal().toString().split('.')[0] : '—'}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              if (proof.paymentMethods.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Methods: ${proof.paymentMethods.map((m) => '${m.method} (${formatINR(m.amount)})').join(', ')}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (proof.proofImages.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    ...proof.proofImages.take(3).map((proofImage) {
                      final imageUrl = proofImage.url ?? '';
                      return Container(
                        margin: const EdgeInsets.only(right: AppSpacing.xs),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.sm - 1),
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: AppColors.violet.withValues(alpha: 0.1),
                                    child: const Icon(Icons.image, size: 20),
                                  ),
                                )
                              : Container(
                                  color: AppColors.violet.withValues(alpha: 0.1),
                                  child: const Icon(Icons.image, size: 20),
                                ),
                        ),
                      );
                    }),
                    if (proof.proofImages.length > 3) ...[
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          color: AppColors.violet.withValues(alpha: 0.1),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '+${proof.proofImages.length - 3}',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: AppColors.violet,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'approved':
        bgColor = const Color(0xFFDCFCE7); // Soft Mint
        textColor = const Color(0xFF166534); // Dark Green
        label = 'APPROVED';
        break;
      case 'rejected':
        bgColor = const Color(0xFFFEE2E2); // Soft Rose
        textColor = const Color(0xFF991B1B); // Dark Red
        label = 'REJECTED';
        break;
      default:
        bgColor = const Color(0xFFFEF3C7); // Soft Gold
        textColor = const Color(0xFF78350F); // Dark Brown
        label = 'PENDING';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: textColor.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
      ),
    );
  }

Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddPaymentProofScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Payment Proof'),
      ),
    );
  }
}
