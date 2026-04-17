import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_tokens.dart';
import 'core/router/app_router.dart';
import 'widgets/ui/internet_check_dialog.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Tenant Portal',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: router,
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            const InternetCheckDialog(),
          ],
        );
      },
    );
  }
}
