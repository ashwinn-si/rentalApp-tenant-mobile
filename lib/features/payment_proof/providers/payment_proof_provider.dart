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

// Payment proofs params
class PaymentProofsParams {
  const PaymentProofsParams({
    this.flatId,
    this.status,
    this.page = 1,
    this.limit = 10,
  });

  final String? flatId;
  final String? status;
  final int page;
  final int limit;

  @override
  bool operator ==(Object other) {
    return other is PaymentProofsParams &&
        other.flatId == flatId &&
        other.status == status &&
        other.page == page &&
        other.limit == limit;
  }

  @override
  int get hashCode => Object.hash(flatId, status, page, limit);
}

// Payment proofs response model
class PaymentProofsResponse {
  const PaymentProofsResponse({required this.items, required this.pagination});

  final List<PaymentProof> items;
  final PaginationData pagination;
}

class PaginationData {
  const PaginationData({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final int page;
  final int limit;
  final int total;
  final int totalPages;
}

// Payment proofs list provider
final paymentProofsProvider = FutureProvider.family<PaymentProofsResponse, PaymentProofsParams>(
  (ref, params) async {
    developer.log('[PaymentProofsProvider] Loading proofs - flatId=${params.flatId}, status=${params.status}, page=${params.page}');

    try {
      final repository = ref.watch(paymentProofRepositoryProvider);
      final response = await repository.getMyProofsWithPagination(
        flatId: params.flatId,
        status: params.status,
        page: params.page,
        limit: params.limit,
      );

      developer.log('[PaymentProofsProvider] Success! Got ${response.items.length} proofs');
      return response;
    } catch (e, stack) {
      developer.log('[PaymentProofsProvider] ERROR: $e');
      developer.log('[PaymentProofsProvider] Stack: $stack');
      rethrow;
    }
  },
);

// Invalidation trigger for refreshing proofs
final refreshProofsProvider = Provider<Future<void> Function(String?)>((ref) {
  return (flatId) async {
    ref.invalidate(paymentProofsProvider(flatId));
    await ref.watch(paymentProofsProvider(flatId).future);
  };
});
