import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/flat_details_repository.dart';
import '../data/models/flat_details_model.dart';

final flatDetailsRepositoryProvider = Provider((ref) => FlatDetailsRepository());

final flatDetailsProvider =
    FutureProvider.family<FlatDetailsResponse, String?>((ref, flatId) async {
  final repo = ref.watch(flatDetailsRepositoryProvider);
  final result = await repo.getFlatDetails(flatId: flatId);

  if (!result.isSuccess) {
    throw Exception(result.error ?? 'Failed to load flat details');
  }

  return result.data!;
});

final activeFlatIdProvider = Provider<String?>((ref) {
  return ref.watch(authProvider.select((state) => state.activeFlatId));
});
