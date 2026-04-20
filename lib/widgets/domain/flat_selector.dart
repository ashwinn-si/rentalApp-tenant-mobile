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
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: AppColors.violet.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: AppShadows.card(),
        ),
        child: Row(
          children: [
            Icon(
              Icons.apartment_outlined,
              color: AppColors.violet.withOpacity(0.7),
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                flats[0].label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
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
      decoration: BoxDecoration(
        boxShadow: AppShadows.card(),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: activeFlatId,
        decoration: InputDecoration(
          labelText: 'Select Unit',
          labelStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide(
              color: AppColors.violet.withOpacity(0.2),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide(
              color: AppColors.violet.withOpacity(0.2),
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
        icon: Icon(
          Icons.apartment_outlined,
          color: AppColors.violet.withOpacity(0.7),
        ),
        items: flats
            .map(
              (flat) => DropdownMenuItem<String>(
                value: flat.id,
                child: Text(
                  flat.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
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
    );
  }
}
