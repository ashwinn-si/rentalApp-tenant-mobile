import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/bug_reports_repository.dart';
import '../data/models/bug_reports_model.dart';

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
