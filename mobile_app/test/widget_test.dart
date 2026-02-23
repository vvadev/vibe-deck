import 'package:flutter_test/flutter_test.dart';

import 'package:vibe_deck_mobile/src/models/deck_models.dart';

void main() {
  test('default profile always has Enter button', () {
    final profile = DeckProfile.defaultProfile();
    final enter = profile.buttons.where((b) => b.id == enterButtonId).toList();
    expect(enter.length, 1);
    expect(enter.single.locked, true);
    expect(enter.single.action.type, ActionType.hotkey);
  });

  test('profile encode/decode keeps enter button', () {
    final profile = DeckProfile.defaultProfile().copyWith(
      buttons: <DeckButton>[
        DeckButton(
          id: 'custom',
          label: 'Paste',
          iconKey: 'paste',
          bgStyle: 'blue',
          action: ButtonAction(type: ActionType.insertText, data: 'hello'),
          cellIndex: 5,
        ),
      ],
    );
    final decoded = DeckProfile.decode(profile.encode());
    expect(decoded.buttons.where((b) => b.id == enterButtonId).length, 1);
  });

  test('profile decode restores button positions', () {
    final profile = DeckProfile.defaultProfile().copyWith(
      buttons: <DeckButton>[
        DeckButton(
          id: enterButtonId,
          label: 'Wrong Enter',
          iconKey: 'paste',
          bgStyle: 'red',
          action: ButtonAction(type: ActionType.insertText, data: 'x'),
          cellIndex: 7,
          locked: false,
        ),
        DeckButton(
          id: 'custom',
          label: 'Paste',
          iconKey: 'paste',
          bgStyle: 'blue',
          action: ButtonAction(type: ActionType.insertText, data: 'hello'),
          cellIndex: 10,
        ),
      ],
    );

    final decoded = DeckProfile.decode(profile.encode());
    final enter = decoded.buttons.firstWhere((b) => b.id == enterButtonId);
    final custom = decoded.buttons.firstWhere((b) => b.id == 'custom');

    expect(enter.locked, true);
    expect(enter.cellIndex, 7);
    expect(custom.cellIndex, 10);
  });
}
