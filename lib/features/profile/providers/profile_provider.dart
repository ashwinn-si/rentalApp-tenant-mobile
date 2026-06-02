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

final changePasswordProvider = FutureProvider.family<void, ChangePasswordParams>((ref, params) async {
  final repository = ProfileRepository();
  final result = await repository.changePassword(
    currentPassword: params.currentPassword,
    newPassword: params.newPassword,
  );
  if (!result.isSuccess) {
    throw Exception(result.error ?? 'Failed to change password');
  }
});

class ChangePasswordParams {
  final String currentPassword;
  final String newPassword;

  ChangePasswordParams({
    required this.currentPassword,
    required this.newPassword,
  });
}
