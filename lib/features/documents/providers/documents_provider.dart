import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/documents_repository.dart';
import '../data/models/document_model.dart';

final documentsProvider = FutureProvider<List<TenantDocument>>((ref) async {
  final flatId = ref.watch(authProvider.select((state) => state.activeFlatId));
  final repository = DocumentsRepository();
  final result = await repository.getDocuments(flatId: flatId);
  if (!result.isSuccess || result.data == null) {
    throw Exception(result.error ?? 'Unable to load documents');
  }
  return result.data!;
});
