import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/bug_reports_repository.dart';
import '../data/models/bug_reports_model.dart';

class BugReportsParams {
  const BugReportsParams({
    this.status,
    this.page = 1,
    this.limit = 10,
  });

  final String? status;
  final int page;
  final int limit;

  @override
  bool operator ==(Object other) {
    return other is BugReportsParams &&
        other.status == status &&
        other.page == page &&
        other.limit == limit;
  }

  @override
  int get hashCode => Object.hash(status, page, limit);
}

class BugReportPayload {
  final String title;
  final String description;
  final String type;
  final List<File> images;

  BugReportPayload({
    required this.title,
    required this.description,
    required this.type,
    required this.images,
  });
}

final bugReportsRepositoryProvider =
    Provider((ref) => BugReportsRepository());

final bugReportsListProvider = FutureProvider<List<BugReport>>((ref) async {
  final repo = ref.watch(bugReportsRepositoryProvider);
  final result = await repo.getBugReports();

  if (!result.isSuccess) {
    throw Exception(result.error ?? 'Failed to load bug reports');
  }

  return result.data ?? [];
});

final bugReportsWithPaginationProvider =
    FutureProvider.family<BugReportsResponseDto, BugReportsParams>(
  (ref, params) async {
    final repo = ref.watch(bugReportsRepositoryProvider);
    final result = await repo.getBugReportsWithPagination(
      status: params.status,
      page: params.page,
      limit: params.limit,
    );

    if (!result.isSuccess) {
      throw Exception(result.error ?? 'Failed to load bug reports');
    }

    return result.data!;
  },
);

final bugReportDetailProvider =
    FutureProvider.family<BugReport, String>((ref, bugReportId) async {
  final repo = ref.watch(bugReportsRepositoryProvider);
  final result = await repo.getBugReport(bugReportId);

  if (!result.isSuccess) {
    throw Exception(result.error ?? 'Failed to load bug report');
  }

  return result.data!;
});

final bugReportSubmitProvider =
    FutureProvider.family<BugReport, BugReportPayload>((ref, payload) async {
  final repo = ref.watch(bugReportsRepositoryProvider);
  final result = await repo.submitBugReport(
    title: payload.title,
    description: payload.description,
    type: payload.type,
    images: payload.images,
  );

  if (!result.isSuccess) {
    throw Exception(result.error ?? 'Failed to submit bug report');
  }

  ref.invalidate(bugReportsListProvider);
  return result.data!;
});
