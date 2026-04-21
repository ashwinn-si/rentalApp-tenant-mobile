import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/constants/env_config.dart';
import 'firebase_options.dart';
import 'services/fcm_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  EnvConfig.printEnvInfo();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FcmService.initialize();
  await initializeDateFormatting('en_IN');
  Intl.defaultLocale = 'en_IN';
  runApp(const ProviderScope(child: App()));
}
