import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/models/payment_proof.dart';
import '../data/models/rent_record.dart';
import '../data/payment_proof_repository.dart';

// Repository provider
final paymentProofRepositoryProvider = Provider<PaymentProofRepository>((ref) {
  return PaymentProofRepository();
});

// Rent by month/year provider
class RentParams {
  const RentParams({required this.month, required this.year, this.flatId});

  final int month;
  final int year;
  final String? flatId;

  @override
  bool operator ==(Object other) {
    return other is RentParams &&
        other.month == month &&
        other.year == year &&
        other.flatId == flatId;
  }

  @override
  int get hashCode => Object.hash(month, year, flatId);
}

final rentByMonthYearProvider =
    FutureProvider.family<RentRecord?, RentParams>((ref, params) async {
  developer.log('[RentByMonthYearProvider] Loading rent for month=${params.month}, year=${params.year}, flatId=${params.flatId}');

  try {
    final repository = ref.watch(paymentProofRepositoryProvider);
    final rent = await repository.getRentByMonthYear(
      month: params.month,
      year: params.year,
      flatId: params.flatId,
    );

    developer.log('[RentByMonthYearProvider] Got rent: $rent');
    return rent;
  } catch (e, stack) {
    developer.log('[RentByMonthYearProvider] Error: $e\n$stack');
    rethrow;
  }
});

// Active rent provider (watches active flat)
final activeRentProvider =
    FutureProvider.family<RentRecord?, RentParams>((ref, params) {
  final flatId = ref.watch(authProvider.select((state) => state.activeFlatId));
  return ref.watch(
    rentByMonthYearProvider(
      RentParams(month: params.month, year: params.year, flatId: flatId),
    ).future,
  );
});

// Payment proofs list provider
final paymentProofsProvider = FutureProvider<List<PaymentProof>>((ref) async {
  developer.log('[PaymentProofsProvider] Loading proofs - starting');

  try {
    developer.log('[PaymentProofsProvider] Getting repository');
    final repository = ref.watch(paymentProofRepositoryProvider);

    developer.log('[PaymentProofsProvider] Calling getMyProofs()');
    final proofs = await repository.getMyProofs();

    developer.log('[PaymentProofsProvider] Success! Got ${proofs.length} proofs');
    return proofs;
  } catch (e, stack) {
    developer.log('[PaymentProofsProvider] ERROR: $e');
    developer.log('[PaymentProofsProvider] Stack: $stack');
    rethrow;
  }
});

// Invalidation trigger for refreshing proofs
final refreshProofsProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    ref.invalidate(paymentProofsProvider);
    await ref.watch(paymentProofsProvider.future);
  };
});
