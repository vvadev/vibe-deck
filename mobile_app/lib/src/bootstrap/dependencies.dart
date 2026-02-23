import '../app/locale_controller.dart';
import '../app_state.dart';
import '../data/discovery_service.dart';
import '../data/ws_client.dart';

class MobileDependencies {
  const MobileDependencies({
    required this.state,
    required this.localeController,
  });

  final MobileAppState state;
  final LocaleController localeController;
}

MobileDependencies buildMobileDependencies() {
  final state = MobileAppState(
    discoveryService: DiscoveryService(),
    wsClient: WsClient(),
  );
  return MobileDependencies(state: state, localeController: LocaleController());
}
