import 'package:flutter/foundation.dart';

const String _defaultApiPort = '8080';

String get baseURL {
  // Android emulators cannot reach host services via localhost.
  // 10.0.2.2 maps to the host machine from Android emulator.
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:$_defaultApiPort/api';
  }

  return 'http://localhost:$_defaultApiPort/api';
}
