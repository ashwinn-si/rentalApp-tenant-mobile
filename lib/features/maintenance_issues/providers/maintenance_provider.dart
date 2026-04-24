import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/maintenance_repository.dart';
import '../data/models/maintenance_issue.dart';

final maintenanceRepositoryProvider = Provider((ref) => MaintenanceRepository());

final maintenanceIssuesProvider = FutureProvider<MaintenanceIssuesResponse>((ref) async {
  final repository = ref.watch(maintenanceRepositoryProvider);
  final result = await repository.getIssues();
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
