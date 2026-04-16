import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/profile_model.dart';
import '../data/profile_repository.dart';

final profileProvider = FutureProvider<TenantProfile>((ref) async {
  final repository = ProfileRepository();
  final result = await repository.getProfile();
  if (!result.isSuccess || result.data == null) {
    throw Exception(result.error ?? 'Unable to load profile');
  }
  return result.data!;
});
