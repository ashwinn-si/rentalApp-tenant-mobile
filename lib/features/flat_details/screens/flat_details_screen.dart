import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_tokens.dart';
import '../../../core/providers/error_handler_provider.dart';
import '../../../core/utils/app_bar_helper.dart';
import '../../../core/utils/animations.dart';
import '../../../widgets/domain/flat_selector.dart';
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
                    FadeSlideTransition(
                      duration: AppAnimations.normal,
                      child: FlatSelector(
                        flats: response.availableFlats
                            .map((flat) => FlatModel(id: flat.flatId, label: flat.label))
                            .toList(),
                      ),
                    ),
                  if (response.availableFlats.isNotEmpty)
                    const SizedBox(height: AppSpacing.lg),
                  FadeSlideTransition(
                    duration: AppAnimations.normal,
                    child: _FlatInfoCard(details: details),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FadeSlideTransition(
                    duration: AppAnimations.normal,
                    child: _ApartmentCard(apartment: details.apartment),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FadeSlideTransition(
                    duration: AppAnimations.normal,
                    child: _TenancyCard(details: details),
                  ),
                  if (details.isOnLease) ...[
                    const SizedBox(height: AppSpacing.lg),
                    FadeSlideTransition(
                      duration: AppAnimations.normal,
                      child: _LeaseCard(leaseAmount: details.leaseAmount),
                    ),
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

class _FlatInfoCard extends StatelessWidget {
  const _FlatInfoCard({required this.details});

  final dynamic details;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.violet.withOpacity(0.08),
            AppColors.violet.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.violet.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.violet.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.violet.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.home,
                  color: AppColors.violet,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Flat Information',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      details.flatNumber,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _StatsGrid(
            stats: [
              _Stat(
                label: 'Type',
                value: details.type,
                icon: Icons.apartment,
              ),
              _Stat(
                label: 'Floor',
                value: details.floor,
                icon: Icons.layers,
              ),
              _Stat(
                label: 'Base Rent',
                value: '₹${details.baseRent.toStringAsFixed(0)}',
                icon: Icons.currency_rupee,
              ),
            ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.violet.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.location_on,
                  color: AppColors.violet,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Location',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : AppColors.violet.withOpacity(0.02),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: AppColors.violet.withOpacity(0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  apartment.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  apartment.address,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _LocationTile(
                      label: 'City',
                      value: apartment.city,
                      icon: Icons.location_city,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _LocationTile(
                      label: 'State',
                      value: apartment.state,
                      icon: Icons.map,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _LocationTile(
                label: 'Pincode',
                value: apartment.pincode,
                icon: Icons.pin,
                fullWidth: true,
              ),
            ],
          ),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.violet.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.event,
                  color: AppColors.violet,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Tenancy Details',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _TenancyTile(
            label: 'Move-In Date',
            value: moveInDate,
            icon: Icons.calendar_today,
          ),
          const SizedBox(height: AppSpacing.md),
          _TenancyTile(
            label: 'Advance Paid',
            value: '₹${details.advancePaid.toStringAsFixed(0)}',
            icon: Icons.savings,
            valueColor: AppColors.paid,
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
    final bgColor = isDark
        ? const Color(0xFF2D2A3D).withOpacity(0.6)
        : const Color(0xFFFEF3C7).withOpacity(0.4);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bgColor,
            bgColor.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.pending.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.pending.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.pending.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              Icons.lock,
              color: AppColors.pending,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Leasing',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.pending,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '₹${leaseAmount.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.pending,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat {
  final String label;
  final String value;
  final IconData icon;

  _Stat({
    required this.label,
    required this.value,
    required this.icon,
  });
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final List<_Stat> stats;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (int i = 0; i < stats.length; i++) {
      children.add(
        Expanded(
          child: _StatTile(stat: stats[i]),
        ),
      );
      if (i < stats.length - 1) {
        children.add(const SizedBox(width: AppSpacing.md));
      }
    }

    return Row(children: children);
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.stat});

  final _Stat stat;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : AppColors.violet.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.violet.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(stat.icon, size: 20, color: AppColors.violet),
          const SizedBox(height: AppSpacing.sm),
          Text(
            stat.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            stat.value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LocationTile extends StatelessWidget {
  const _LocationTile({
    required this.label,
    required this.value,
    required this.icon,
    this.fullWidth = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.03)
            : AppColors.violet.withOpacity(0.02),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.violet.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.violet),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TenancyTile extends StatelessWidget {
  const _TenancyTile({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.03)
            : AppColors.violet.withOpacity(0.02),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.violet.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.violet),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: valueColor,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
