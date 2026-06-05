import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_tokens.dart';
import '../../../core/providers/error_handler_provider.dart';
import '../../../core/utils/app_bar_helper.dart';
import '../../../widgets/ui/app_loader.dart';
import '../../../widgets/ui/premium_card.dart';
import '../../../widgets/ui/screen_background.dart';
import '../../../widgets/ui/state_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/flat_details_provider.dart';

class FlatDetailsScreen extends ConsumerWidget {
  const FlatDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    developer.log('[FlatDetailsScreen] Auth state: ${authState.toString()}');
    developer.log('[FlatDetailsScreen] Token: ${authState.token}');
    developer.log('[FlatDetailsScreen] UserId: ${authState.userId}');
    developer.log('[FlatDetailsScreen] TenantKey: ${authState.tenantKey}');

    final activeFlatId = ref.watch(activeFlatIdProvider);
    final flatDetailsAsync = ref.watch(flatDetailsProvider(activeFlatId));

    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: buildPremiumAppBar(
          title: 'Flat Details',
          actions: [
            IconButton(
              onPressed: () {
                developer.log('[FlatDetailsScreen] Refresh clicked, activeFlatId=$activeFlatId');
                ref.invalidate(flatDetailsProvider(activeFlatId));
              },
              icon: const Icon(Icons.refresh_outlined),
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: flatDetailsAsync.when(
          loading: () => const Center(child: AppLoader()),
          error: (error, stack) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ApiErrorHandler.handleAccessDenied(error, ref);
            });
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: StateCard(
                message: 'Failed to load flat details',
                variant: StateCardVariant.error,
              ),
            );
          },
          data: (response) {
            if (response.details == null) {
              return const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: StateCard(message: 'No flat details available'),
              );
            }

            final details = response.details!;

            return RefreshIndicator(
              onRefresh: () async {
                developer.log('[FlatDetailsScreen] Pull-to-refresh triggered');
                ref.invalidate(flatDetailsProvider(activeFlatId));
                await ref.watch(flatDetailsProvider(activeFlatId).future);
              },
              child: ListView(
                padding: const EdgeInsets.only(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  top: AppSpacing.md,
                  bottom: AppSpacing.xl,
                ),
                children: [
                  if (response.availableFlats.isNotEmpty)
                    _FlatSelector(
                      flats: response.availableFlats,
                      selectedFlatId: activeFlatId ?? response.activeFlatId,
                      onChanged: (flatId) => ref
                          .read(activeFlatIdProvider.notifier)
                          .state = flatId,
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  _FlatInfoCard(details: details),
                  const SizedBox(height: AppSpacing.lg),
                  _ApartmentCard(apartment: details.apartment),
                  const SizedBox(height: AppSpacing.lg),
                  _TenancyCard(details: details),
                  if (details.isOnLease) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _LeaseCard(leaseAmount: details.leaseAmount),
                  ]
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FlatSelector extends StatelessWidget {
  const _FlatSelector({
    required this.flats,
    required this.selectedFlatId,
    required this.onChanged,
  });

  final List<dynamic> flats;
  final String? selectedFlatId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Flat', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          DropdownButton<String>(
            value: selectedFlatId,
            isExpanded: true,
            items: flats
                .map(
                  (flat) => DropdownMenuItem<String>(
                    value: flat.flatId,
                    child: Text(flat.label),
                  ),
                )
                .toList(),
            onChanged: (flatId) {
              if (flatId != null) onChanged(flatId);
            },
          ),
        ],
      ),
    );
  }
}

class _FlatInfoCard extends StatelessWidget {
  const _FlatInfoCard({required this.details});

  final dynamic details;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Flat Information',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoRow(
            label: 'Flat Number',
            value: details.flatNumber,
            icon: Icons.home,
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoRow(
            label: 'Type',
            value: details.type,
            icon: Icons.apartment,
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoRow(
            label: 'Floor',
            value: details.floor,
            icon: Icons.layers,
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoRow(
            label: 'Base Rent',
            value: '₹${details.baseRent.toStringAsFixed(0)}',
            icon: Icons.currency_rupee,
          ),
        ],
      ),
    );
  }
}

class _ApartmentCard extends StatelessWidget {
  const _ApartmentCard({required this.apartment});

  final dynamic apartment;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Apartment Location',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoBlock(label: 'Name', value: apartment.name),
          const SizedBox(height: AppSpacing.md),
          _InfoBlock(label: 'Address', value: apartment.address),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _InfoBlock(label: 'City', value: apartment.city),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _InfoBlock(label: 'State', value: apartment.state),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoBlock(label: 'Pincode', value: apartment.pincode),
        ],
      ),
    );
  }
}

class _TenancyCard extends StatelessWidget {
  const _TenancyCard({required this.details});

  final dynamic details;

  @override
  Widget build(BuildContext context) {
    final moveInDate = _formatDate(details.moveInDate);
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tenancy Information',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoRow(
            label: 'Move-In Date',
            value: moveInDate,
            icon: Icons.calendar_today,
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoRow(
            label: 'Advance Paid',
            value: '₹${details.advancePaid.toStringAsFixed(0)}',
            icon: Icons.savings,
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateString;
    }
  }
}

class _LeaseCard extends StatelessWidget {
  const _LeaseCard({required this.leaseAmount});

  final double leaseAmount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? const Color(0xFF2D2A3D) : const Color(0xFFFEF3C7);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.pending.withValues(alpha: 0.3),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Security Deposit (Lease)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.pending,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '₹${leaseAmount.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.pending,
                ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.violet),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
