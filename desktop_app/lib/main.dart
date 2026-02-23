import 'package:flutter/widgets.dart';

import 'src/app/desktop_app.dart';
import 'src/bootstrap/dependencies.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final deps = buildDesktopDependencies();
  await deps.appState.init();
  try {
    await deps.localeController.loadLocale();
  } catch (_) {}
  runApp(VibeDeckDesktopApp(deps: deps));
}
