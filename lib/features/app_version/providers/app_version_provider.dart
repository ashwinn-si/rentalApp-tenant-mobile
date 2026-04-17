import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/app_version_model.dart';
import '../data/app_version_repository.dart';

final appVersionRepositoryProvider = Provider((ref) {
  return AppVersionRepository();
});

final currentAppVersionProvider = FutureProvider<AppVersionModel?>((ref) async {
  final repo = ref.watch(appVersionRepositoryProvider);
  final response = await repo.getCurrentVersion();

  if (response.isSuccess) {
    return response.data;
  }

  return null;
});
