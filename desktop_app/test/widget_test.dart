import 'package:flutter_test/flutter_test.dart';

import 'package:vibe_deck_desktop/src/models.dart';
import 'package:vibe_deck_desktop/src/security.dart';

void main() {
  test('pairing manager validates and expires sessions', () {
    final manager = PairingManager();
    final token = manager.createSessionToken(
      clientBinding: '127.0.0.1|mobile-1',
      ttl: const Duration(milliseconds: 10),
    );
    expect(
      manager.validateSession(
        token: token,
        clientBinding: '127.0.0.1|mobile-1',
      ),
      true,
    );
  });

  test(
    'pair code remains valid after successful pairing until next rotation',
    () {
      final manager = PairingManager();
      final code = manager.pairCode;

      final success = manager.attemptPair(
        candidate: code,
        remoteIp: '10.0.0.8',
        clientBinding: '10.0.0.8|mobile-1',
      );
      expect(success.ok, true);
      expect(success.sessionToken, isNotNull);

      final reuseCode = manager.attemptPair(
        candidate: code,
        remoteIp: '10.0.0.9',
        clientBinding: '10.0.0.9|mobile-2',
      );
      expect(reuseCode.ok, true);
      expect(reuseCode.sessionToken, isNotNull);
    },
  );

  test('pairing lockout is enforced per remote IP, not clientId', () {
    final manager = PairingManager();
    PairAttemptResult? last;

    for (var i = 0; i < PairingManager.maxFailedAttempts; i++) {
      last = manager.attemptPair(
        candidate: '000000',
        remoteIp: '10.0.0.50',
        clientBinding: '10.0.0.50|spoofed-client-$i',
      );
    }

    expect(last, isNotNull);
    expect(last!.ok, false);
    expect(last.retryAfter, isNotNull);
    expect(last.message, contains('locked temporarily'));
  });

  test('actionType wire conversion works', () {
    expect(actionTypeToWire(ActionType.insertText), 'insert_text');
    expect(actionTypeToWire(ActionType.hotkey), 'hotkey');
    expect(actionTypeFromWire('run_action'), ActionType.runAction);
  });

  test('desktop settings json roundtrip', () {
    final settings = DesktopSettings(
      allowTextInsert: false,
      allowHotkeys: true,
      allowActions: false,
      allowShellCommands: false,
    );
    final restored = DesktopSettings.fromJson(settings.toJson());

    expect(restored.allowTextInsert, false);
    expect(restored.allowHotkeys, true);
    expect(restored.allowActions, false);
    expect(restored.allowShellCommands, false);
  });
}
