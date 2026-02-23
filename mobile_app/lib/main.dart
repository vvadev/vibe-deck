import 'package:flutter/widgets.dart';

import 'src/app/mobile_app.dart';
import 'src/bootstrap/dependencies.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final deps = buildMobileDependencies();
  await deps.state.init();
  await deps.state.scanHosts();
  await deps.localeController.loadLocale();
  runApp(VibeDeckMobileApp(deps: deps));
}
