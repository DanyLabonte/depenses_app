// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:depenses_app/l10n/s.dart';
import 'package:depenses_app/l10n/locale_controller.dart';
import 'package:depenses_app/theme/theme_controller.dart';
import 'package:depenses_app/screens/app_shell.dart';
import 'package:depenses_app/screens/sign_in_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocaleController.instance.init();
  await ThemeController.instance.init();
  runApp(const DepensesApp());
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.unknown,
  };
}

class DepensesApp extends StatelessWidget {
  const DepensesApp({super.key});

  @override
  Widget build(BuildContext context) {
    const double kTopBannerHeight = 96; // ≈ 1 pouces
    const Color kTopBannerColor = Color(0xFF04834A);

    return AnimatedBuilder(
      animation: Listenable.merge([
        LocaleController.instance,
        ThemeController.instance,
      ]),
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          scrollBehavior: AppScrollBehavior(),
          onGenerateTitle: (ctx) => S.of(ctx).appTitle,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1565C0),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: ThemeController.instance.mode,
          locale: LocaleController.instance.locale,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.supportedLocales,

          // Bande verte
          builder: (context, child) {
            return Column(
              children: [
                Container(
                  height: kTopBannerHeight,
                  width: double.infinity,
                  color: kTopBannerColor,
                ),
                Expanded(child: child ?? const SizedBox.shrink()),
              ],
            );
          },

          home: const SignInScreen(),
          onUnknownRoute: (settings) => MaterialPageRoute(
            builder: (_) => const _UnknownRoute(),
            settings: settings,
          ),
        );
      },
    );
  }
}

class _UnknownRoute extends StatelessWidget {
  const _UnknownRoute();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.routeNotFound)),
      body: Center(
        child: FilledButton.icon(
          icon: const Icon(Icons.home_rounded),
          label: Text(s.goHome),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AppShell(currentUserEmail: '')),
          ),
        ),
      ),
    );
  }
}
