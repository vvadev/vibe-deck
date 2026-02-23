import 'dart:io';

class InputPermissionOpenResult {
  const InputPermissionOpenResult({
    required this.opened,
    required this.instructionEn,
    required this.instructionRu,
  });

  final bool opened;
  final String instructionEn;
  final String instructionRu;
}

class PlatformPermissions {
  static Future<InputPermissionOpenResult> openInputPermissionSettings() async {
    if (Platform.isMacOS) {
      final opened = await _tryOpenCandidates(
        executable: 'open',
        argsCandidates: const <List<String>>[
          <String>[
            'x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility',
          ],
          <String>['-b', 'com.apple.systempreferences'],
        ],
      );
      return InputPermissionOpenResult(
        opened: opened,
        instructionEn:
            'System Settings -> Privacy & Security -> Accessibility and Automation. Enable Vibe Deck (or Terminal/Runner app used for launch), and allow controlling System Events.',
        instructionRu:
            'System Settings -> Privacy & Security -> Accessibility и Automation. Включите Vibe Deck (или Terminal/Runner, если запускали из него) и разрешите управление System Events.',
      );
    }

    if (Platform.isWindows) {
      final opened = await _tryOpenCandidates(
        executable: 'explorer.exe',
        argsCandidates: const <List<String>>[
          <String>['ms-settings:privacy'],
          <String>['ms-settings:easeofaccess-keyboard'],
        ],
      );
      return InputPermissionOpenResult(
        opened: opened,
        instructionEn:
            'Open Windows Settings. If hotkeys do not reach target app, run Vibe Deck with the same privileges as that app (for example, both non-admin).',
        instructionRu:
            'Откройте Windows Settings. Если хоткеи не доходят до приложения, запустите Vibe Deck с тем же уровнем прав, что и целевое приложение (например, оба без admin).',
      );
    }

    if (Platform.isLinux) {
      final opened = await _tryOpenLinuxSettings();
      return InputPermissionOpenResult(
        opened: opened,
        instructionEn:
            'Linux desktop security may block synthetic input (especially on Wayland). Open your desktop settings/privacy panel and allow accessibility/remote-control input, or run an X11 session.',
        instructionRu:
            'Безопасность Linux (особенно Wayland) может блокировать синтетический ввод. Откройте настройки/приватность вашей среды и разрешите accessibility/remote-control ввод, либо используйте сессию X11.',
      );
    }

    return const InputPermissionOpenResult(
      opened: false,
      instructionEn:
          'This platform is not fully supported for automated permission settings. Configure input permissions manually in system settings.',
      instructionRu:
          'Для этой платформы нет автоматического открытия нужных настроек. Настройте права ввода вручную в системных параметрах.',
    );
  }

  static Future<bool> _tryOpenLinuxSettings() async {
    final xdgOpened = await _tryOpenCandidates(
      executable: 'xdg-open',
      argsCandidates: const <List<String>>[
        <String>['settings://privacy'],
      ],
    );
    if (xdgOpened) {
      return true;
    }

    return _tryStartCandidates(
      executableCandidates: const <String>[
        'gnome-control-center',
        'systemsettings5',
        'systemsettings',
      ],
      argsByExecutable: const <String, List<String>>{
        'gnome-control-center': <String>['privacy'],
        'systemsettings5': <String>[],
        'systemsettings': <String>[],
      },
    );
  }

  static Future<bool> _tryOpenCandidates({
    required String executable,
    required List<List<String>> argsCandidates,
  }) async {
    for (final args in argsCandidates) {
      if (await _tryRun(executable, args)) {
        return true;
      }
    }
    return false;
  }

  static Future<bool> _tryStartCandidates({
    required List<String> executableCandidates,
    required Map<String, List<String>> argsByExecutable,
  }) async {
    for (final executable in executableCandidates) {
      final args = argsByExecutable[executable] ?? const <String>[];
      if (await _tryStart(executable, args)) {
        return true;
      }
    }
    return false;
  }

  static Future<bool> _tryRun(String executable, List<String> args) async {
    try {
      final result = await Process.run(executable, args);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _tryStart(String executable, List<String> args) async {
    try {
      await Process.start(executable, args);
      return true;
    } catch (_) {
      return false;
    }
  }
}
