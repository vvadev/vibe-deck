import 'dart:math';

class PairAttemptResult {
  PairAttemptResult({
    required this.ok,
    required this.message,
    this.sessionToken,
    this.retryAfter,
  });

  final bool ok;
  final String message;
  final String? sessionToken;
  final Duration? retryAfter;
}

class _SessionBinding {
  _SessionBinding({required this.clientBinding, required this.expiresAt});

  final String clientBinding;
  final DateTime expiresAt;
}

class PairingManager {
  PairingManager();

  static const int maxFailedAttempts = 5;
  static const Duration attemptWindow = Duration(minutes: 1);
  static const Duration lockoutDuration = Duration(minutes: 5);

  String _pairCode = _newPairCode();
  final Map<String, _SessionBinding> _sessions = <String, _SessionBinding>{};
  final Map<String, List<DateTime>> _failedAttemptsByIp =
      <String, List<DateTime>>{};
  final Map<String, DateTime> _lockoutUntilByIp = <String, DateTime>{};

  String get pairCode => _pairCode;

  bool isPairCodeValid(String candidate) {
    return candidate.trim() == _pairCode;
  }

  String createSessionToken({
    required String clientBinding,
    Duration ttl = const Duration(minutes: 30),
  }) {
    final token = _randomToken(32);
    _sessions[token] = _SessionBinding(
      clientBinding: clientBinding,
      expiresAt: DateTime.now().add(ttl),
    );
    return token;
  }

  PairAttemptResult attemptPair({
    required String candidate,
    required String remoteIp,
    required String clientBinding,
    Duration sessionTtl = const Duration(minutes: 30),
  }) {
    _cleanupPairingState();
    final now = DateTime.now();
    final lockoutUntil = _lockoutUntilByIp[remoteIp];
    if (lockoutUntil != null && lockoutUntil.isAfter(now)) {
      return PairAttemptResult(
        ok: false,
        message: 'Too many attempts. Try again later.',
        retryAfter: lockoutUntil.difference(now),
      );
    }

    if (isPairCodeValid(candidate)) {
      _failedAttemptsByIp.remove(remoteIp);
      final token = createSessionToken(
        clientBinding: clientBinding,
        ttl: sessionTtl,
      );
      return PairAttemptResult(
        ok: true,
        message: 'Pairing successful',
        sessionToken: token,
      );
    }

    final attempts =
        (_failedAttemptsByIp[remoteIp] ?? <DateTime>[])
            .where((e) => now.difference(e) <= attemptWindow)
            .toList()
          ..add(now);
    _failedAttemptsByIp[remoteIp] = attempts;

    if (attempts.length >= maxFailedAttempts) {
      final until = now.add(lockoutDuration);
      _lockoutUntilByIp[remoteIp] = until;
      _failedAttemptsByIp.remove(remoteIp);
      return PairAttemptResult(
        ok: false,
        message: 'Too many attempts. Pairing locked temporarily.',
        retryAfter: lockoutDuration,
      );
    }

    final remaining = maxFailedAttempts - attempts.length;
    return PairAttemptResult(
      ok: false,
      message:
          'Invalid pair code. Remaining attempts before lockout: $remaining',
    );
  }

  bool validateSession({required String token, required String clientBinding}) {
    final session = _sessions[token];
    if (session == null) return false;
    if (session.expiresAt.isBefore(DateTime.now())) {
      _sessions.remove(token);
      return false;
    }
    if (session.clientBinding != clientBinding) {
      return false;
    }
    return true;
  }

  void _cleanupPairingState() {
    final now = DateTime.now();
    _lockoutUntilByIp.removeWhere((_, value) => !value.isAfter(now));
    _failedAttemptsByIp.removeWhere((_, attempts) {
      attempts.removeWhere((time) => now.difference(time) > attemptWindow);
      return attempts.isEmpty;
    });
    _sessions.removeWhere((_, session) => session.expiresAt.isBefore(now));
  }

  static String _newPairCode() {
    final rnd = Random.secure();
    final value = rnd.nextInt(900000) + 100000;
    return value.toString();
  }

  static String _randomToken(int length) {
    const alphabet =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random.secure();
    return List<String>.generate(
      length,
      (_) => alphabet[rnd.nextInt(alphabet.length)],
    ).join();
  }
}
