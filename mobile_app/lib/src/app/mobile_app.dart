import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../bootstrap/dependencies.dart';
import '../design/app_theme.dart';
import 'locale_controller.dart';
import 'mobile_shell.dart';

class VibeDeckMobileApp extends StatelessWidget {
  const VibeDeckMobileApp({super.key, required this.deps});

  final MobileDependencies deps;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MobileAppState>.value(value: deps.state),
        ChangeNotifierProvider<LocaleController>.value(
          value: deps.localeController,
        ),
      ],
      child: Consumer<LocaleController>(
        builder: (context, localeController, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
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
            home: const MobileShell(),
          );
        },
      ),
    );
  }
}
