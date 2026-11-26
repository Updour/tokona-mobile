import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tokona/core/services/local_push_notification_service.dart';
import 'package:tokona/core/theme/app_theme.dart';
import 'package:tokona/features/auth/presentation/screens/splash_screen.dart';
import 'package:tokona/features/settings/presentation/controllers/app_appearance_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await LocalPushNotificationService.instance.init();
  runApp(const ProviderScope(child: TokonaApp()));
}

class TokonaApp extends ConsumerWidget {
  const TokonaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearance = ref.watch(appAppearanceProvider);

    return MaterialApp(
      title: 'Tokona POS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildLightTheme(appearance),
      darkTheme: AppTheme.buildDarkTheme(appearance),
      themeMode: appearance.flutterThemeMode,
      scrollBehavior: const _SmoothScrollBehavior(),
      home: const SplashScreen(),
    );
  }
}

class _SmoothScrollBehavior extends MaterialScrollBehavior {
  const _SmoothScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}
