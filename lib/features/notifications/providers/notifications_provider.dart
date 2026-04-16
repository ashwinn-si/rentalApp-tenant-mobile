import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/models/notification_model.dart';
import '../data/notifications_repository.dart';

final notificationsProvider =
    FutureProvider<List<TenantNotification>>((ref) async {
  final flatId = ref.watch(authProvider.select((state) => state.activeFlatId));
  final repository = NotificationsRepository();
  final result = await repository.getNotifications(flatId: flatId);
  if (!result.isSuccess || result.data == null) {
    throw Exception(result.error ?? 'Unable to load notifications');
  }
  return result.data!;
});
