import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/maintenance_repository.dart';
import '../data/models/maintenance_issue.dart';

final maintenanceRepositoryProvider = Provider((ref) => MaintenanceRepository());

final maintenanceIssuesProvider = FutureProvider.family<MaintenanceIssuesResponse, ({int page, int limit})>((ref, params) async {
  final repository = ref.watch(maintenanceRepositoryProvider);
  final result = await repository.getIssues(page: params.page, limit: params.limit);
  if (!result.isSuccess || result.data == null) {
    throw Exception(result.error ?? 'Unable to load maintenance issues');
  }
  return result.data!;
});

final maintenanceIssueDetailProvider =
    FutureProvider.family<MaintenanceIssue, String>((ref, id) async {
  final repository = ref.watch(maintenanceRepositoryProvider);
  final result = await repository.getIssue(id);
  if (!result.isSuccess || result.data == null) {
    throw Exception(result.error ?? 'Unable to load issue details');
  }
  return result.data!;
});
