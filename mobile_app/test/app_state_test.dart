import 'package:flutter_test/flutter_test.dart';

import 'package:vibe_deck_mobile/src/app_state.dart';
import 'package:vibe_deck_mobile/src/data/discovery_service.dart';
import 'package:vibe_deck_mobile/src/data/ws_client.dart';
import 'package:vibe_deck_mobile/src/models/deck_models.dart';

void main() {
  test('applyDeckStatePayload updates profile only for newer version', () {
    final state = MobileAppState(
      discoveryService: DiscoveryService(),
      wsClient: WsClient(),
    );

    final newest = DeckProfile.defaultProfile().copyWith(
      rows: 4,
      orientation: DeckOrientation.landscape,
    );
    state.applyDeckStatePayload(<String, dynamic>{
      'version': 3,
      'profile': newest.toJson(),
    });

    expect(state.deckStateVersion, 3);
    expect(state.profile.rows, 4);
    expect(state.profile.orientation, DeckOrientation.landscape);

    final stale = DeckProfile.defaultProfile().copyWith(rows: 2);
    state.applyDeckStatePayload(<String, dynamic>{
      'version': 2,
      'profile': stale.toJson(),
    });

    expect(state.deckStateVersion, 3);
    expect(state.profile.rows, 4);
  });
}
