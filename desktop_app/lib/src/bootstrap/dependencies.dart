import '../app/locale_controller.dart';
import '../app_state.dart';
import '../executor.dart';
import '../security.dart';
import '../server.dart';
import '../storage.dart';

class DesktopDependencies {
  const DesktopDependencies({
    required this.appState,
    required this.localeController,
  });

  final DesktopAppState appState;
  final LocaleController localeController;
}

DesktopDependencies buildDesktopDependencies() {
  final state = DesktopAppState(
    storage: DesktopStorage(),
    pairingManager: PairingManager(),
    executor: DesktopExecutor(),
    hostServer: HostServer(port: 4040),
  );
  return DesktopDependencies(
    appState: state,
    localeController: LocaleController(),
  );
}
