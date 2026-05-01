import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_tokens.dart';
import '../../features/auth/providers/auth_provider.dart';

class FlatModel {
  const FlatModel({required this.id, required this.label});

  final String id;
  final String label;
}

class FlatSelector extends ConsumerWidget {
  const FlatSelector({required this.flats, super.key});

  final List<FlatModel> flats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText =
        isDark ? const Color(0xFFF3F4F6) : AppColors.textPrimary;
    final fieldFill = isDark ? const Color(0xFF1D1A2B) : Colors.white;

    final activeFlatId =
        ref.watch(authProvider.select((state) => state.activeFlatId));

    // If only one flat, show as text only
    if (flats.length == 1) {
      return Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              fieldFill,
              fieldFill.withValues(alpha: 0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: AppColors.violet.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: AppShadows.card(),
        ),
        child: Row(
          children: [
            Icon(
              Icons.apartment_outlined,
              color: AppColors.violet.withValues(alpha: 0.7),
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                flats[0].label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: primaryText,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    // If multiple flats, show dropdown
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            fieldFill,
            fieldFill.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.violet.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: AppShadows.card(),
      ),
      child: Row(
        children: [
          Icon(
            Icons.home_work_outlined,
            color: AppColors.violet.withValues(alpha: 0.65),
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: DropdownButton<String>(
              value: activeFlatId,
              isExpanded: true,
              underline: const SizedBox(),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.violet.withValues(alpha: 0.7),
              ),
              items: flats
                  .map(
                    (flat) => DropdownMenuItem<String>(
                      value: flat.id,
                      child: Text(
                        flat.label,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: primaryText,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  ref.read(authProvider.notifier).setActiveFlatId(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
