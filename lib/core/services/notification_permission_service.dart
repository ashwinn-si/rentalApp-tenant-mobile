import 'package:permission_handler/permission_handler.dart';

class NotificationPermissionService {
  NotificationPermissionService._();

  static Future<bool> isEnabled() async {
    final status = await Permission.notification.status;
    return status.isGranted || status.isLimited;
  }

  static Future<bool> request() async {
    final status = await Permission.notification.request();
    return status.isGranted || status.isLimited;
  }

  static Future<void> openSettings() async {
    await openAppSettings();
  }
}

