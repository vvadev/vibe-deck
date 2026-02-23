import 'package:flutter_test/flutter_test.dart';

import 'package:vibe_deck_desktop/src/deck_models.dart';
import 'package:vibe_deck_desktop/src/models.dart';

void main() {
  test('deck profile json roundtrip keeps orientation and enter lock', () {
    final profile = DeckProfile.defaultProfile().copyWith(
      orientation: DeckOrientation.landscape,
      buttons: <DeckButton>[
        DeckButton(
          id: enterButtonId,
          label: 'Enter custom',
          iconKey: 'paste',
          bgStyle: 'red',
          action: ButtonAction(type: ActionType.insertText, data: 'x'),
          cellIndex: 3,
          locked: false,
        ),
        DeckButton(
          id: 'custom',
          label: 'Run',
          iconKey: 'terminal',
          bgStyle: 'night',
          action: ButtonAction(type: ActionType.runAction, data: 'sample-echo'),
          cellIndex: 4,
        ),
      ],
    );

    final decoded = DeckProfile.decode(profile.encode());
    final enter = decoded.buttons.firstWhere((b) => b.id == enterButtonId);
    expect(decoded.orientation, DeckOrientation.landscape);
    expect(enter.locked, true);
    expect(enter.action.type, ActionType.hotkey);
    expect(enter.cellIndex, 3);
  });
}
