import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/maintenance_repository.dart';
import '../data/models/maintenance_issue.dart';

final maintenanceRepositoryProvider = Provider((ref) => MaintenanceRepository());

class MaintenanceIssuesParams {
  const MaintenanceIssuesParams({
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
    return other is MaintenanceIssuesParams &&
        other.flatId == flatId &&
        other.status == status &&
        other.page == page &&
        other.limit == limit;
  }

  @override
  int get hashCode => Object.hash(flatId, status, page, limit);
}

final maintenanceIssuesProvider = FutureProvider.family<MaintenanceIssuesResponse, MaintenanceIssuesParams>((ref, params) async {
  final repository = ref.watch(maintenanceRepositoryProvider);
  final result = await repository.getIssues(
    page: params.page,
    limit: params.limit,
    flatId: params.flatId,
    status: params.status,
  );
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
