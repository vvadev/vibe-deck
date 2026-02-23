import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../bootstrap/dependencies.dart';
import '../design/app_theme.dart';
import '../app_state.dart';
import 'desktop_notifications_listener.dart';
import 'desktop_shell.dart';
import 'locale_controller.dart';

class VibeDeckDesktopApp extends StatefulWidget {
  const VibeDeckDesktopApp({super.key, required this.deps});

  final DesktopDependencies deps;

  @override
  State<VibeDeckDesktopApp> createState() => _VibeDeckDesktopAppState();
}

class _VibeDeckDesktopAppState extends State<VibeDeckDesktopApp> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DesktopAppState>.value(
          value: widget.deps.appState,
        ),
        ChangeNotifierProvider<LocaleController>.value(
          value: widget.deps.localeController,
        ),
      ],
      child: Consumer<LocaleController>(
        builder: (context, localeController, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            scaffoldMessengerKey: _scaffoldMessengerKey,
            title: 'Vibe Deck',
            locale: localeController.locale,
            supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
            localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            home: DesktopNotificationsListener(
              scaffoldMessengerKey: _scaffoldMessengerKey,
              child: const DesktopShell(),
            ),
          );
        },
      ),
    );
  }
}
