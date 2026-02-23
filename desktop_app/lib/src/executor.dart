import 'dart:io';

import 'package:flutter/services.dart';

import 'models.dart';

class ExecutionResult {
  ExecutionResult({required this.ok, required this.message});

  final bool ok;
  final String message;
}

class DesktopExecutor {
  static const MethodChannel _macInputChannel = MethodChannel(
    'vibe_deck/macos_input',
  );

  Future<ExecutionResult> handleInsertText({
    required bool allowed,
    required String text,
  }) async {
    if (!allowed) {
      return ExecutionResult(
        ok: false,
        message: 'insert_text is disabled in desktop settings',
      );
    }
    await Clipboard.setData(ClipboardData(text: text));
    final pasted = await _sendPasteHotkey();
    if (pasted.ok) {
      return ExecutionResult(ok: true, message: 'Text pasted at cursor');
    }
    return ExecutionResult(
      ok: false,
      message:
          pasted.error ??
          'Text copied to clipboard, but paste hotkey could not be sent',
    );
  }

  Future<ExecutionResult> handleHotkey({
    required bool allowed,
    required String chord,
  }) async {
    if (!allowed) {
      return ExecutionResult(
        ok: false,
        message: 'hotkey is disabled in desktop settings',
      );
    }

    final parsed = _parseHotkeyChord(chord);
    if (parsed == null) {
      return ExecutionResult(
        ok: false,
        message: 'Hotkey adapter unsupported for "$chord" on this platform',
      );
    }

    final sent = await _sendPlatformHotkey(parsed);
    if (sent.ok) {
      return ExecutionResult(
        ok: true,
        message: 'Hotkey ${parsed.label()} sent',
      );
    }
    return ExecutionResult(
      ok: false,
      message:
          sent.error ??
          'Hotkey adapter unsupported for "$chord" on this platform',
    );
  }

  Future<ExecutionResult> handleRunAction({
    required bool allowed,
    required bool allowShellCommands,
    required String actionId,
    required List<DesktopAction> actions,
  }) async {
    if (!allowed) {
      return ExecutionResult(
        ok: false,
        message: 'run_action is disabled in desktop settings',
      );
    }

    DesktopAction? action;
    for (final current in actions) {
      if (current.id == actionId) {
        action = current;
        break;
      }
    }
    if (action == null || !action.enabled) {
      return ExecutionResult(
        ok: false,
        message: 'Action "$actionId" not found in allowlist',
      );
    }
    if (action.command.trim().isEmpty) {
      return ExecutionResult(
        ok: false,
        message: 'Action command cannot be empty',
      );
    }
    if (action.runInShell && !allowShellCommands) {
      return ExecutionResult(
        ok: false,
        message: 'Shell execution is disabled in desktop settings',
      );
    }

    try {
      if (action.runInShell) {
        await _runWithShell(action);
      } else {
        await Process.start(action.command, action.args, runInShell: false);
      }
      return ExecutionResult(
        ok: true,
        message: 'Action "${action.name}" launched',
      );
    } catch (e) {
      return ExecutionResult(ok: false, message: 'Action failed: $e');
    }
  }

  Future<void> _runWithShell(DesktopAction action) async {
    if (Platform.isWindows) {
      final command = _buildWindowsCommand(action.command, action.args);
      await Process.start('powershell', <String>[
        '-NoProfile',
        '-NonInteractive',
        '-Command',
        command,
      ], runInShell: false);
      return;
    }

    final command = _buildPosixCommand(action.command, action.args);
    await Process.start('/bin/sh', <String>['-lc', command], runInShell: false);
  }

  String _buildPosixCommand(String command, List<String> args) {
    final escaped = <String>[_escapePosix(command), ...args.map(_escapePosix)];
    return escaped.join(' ');
  }

  String _escapePosix(String value) {
    return "'${value.replaceAll("'", "'\"'\"'")}'";
  }

  String _buildWindowsCommand(String command, List<String> args) {
    final escaped = <String>[
      _escapePowershell(command),
      ...args.map(_escapePowershell),
    ];
    return '& ${escaped.join(' ')}';
  }

  String _escapePowershell(String value) {
    return "'${value.replaceAll("'", "''")}'";
  }

  _ParsedHotkey? _parseHotkeyChord(String raw) {
    final parts = raw
        .split('+')
        .map((part) => part.trim().toUpperCase())
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return null;

    final modifiers = <String>{};
    String? key;
    for (final part in parts) {
      final modifier = _normalizeModifier(part);
      if (modifier != null) {
        modifiers.add(modifier);
        continue;
      }
      if (key != null) {
        return null;
      }
      key = _normalizeKey(part);
    }
    if (key == null) return null;
    return _ParsedHotkey(modifiers: modifiers, key: key);
  }

  String? _normalizeModifier(String value) {
    switch (value) {
      case 'CTRL':
      case 'CONTROL':
      case 'CTL':
        return 'CTRL';
      case 'ALT':
      case 'OPTION':
        return 'ALT';
      case 'SHIFT':
        return 'SHIFT';
      case 'CMD':
      case 'COMMAND':
      case 'META':
      case 'WIN':
      case 'SUPER':
        return 'CMD';
      default:
        return null;
    }
  }

  String? _normalizeKey(String value) {
    if (RegExp(r'^[A-Z]$').hasMatch(value) ||
        RegExp(r'^[0-9]$').hasMatch(value) ||
        RegExp(r'^F([1-9]|1[0-2])$').hasMatch(value)) {
      return value;
    }
    switch (value) {
      case 'RETURN':
      case 'ENTER':
        return 'ENTER';
      case 'TAB':
      case 'SPACE':
      case 'ESC':
      case 'BACKSPACE':
      case 'DELETE':
      case 'UP':
      case 'DOWN':
      case 'LEFT':
      case 'RIGHT':
      case 'HOME':
      case 'END':
      case 'PAGEUP':
      case 'PAGEDOWN':
        return value;
      case 'PGUP':
        return 'PAGEUP';
      case 'PGDOWN':
      case 'PGDN':
        return 'PAGEDOWN';
      default:
        return null;
    }
  }

  Future<_HotkeySendResult> _sendLinuxHotkey(_ParsedHotkey hotkey) async {
    final key = _linuxKeyName(hotkey.key);
    if (key == null) {
      return _HotkeySendResult.fail(
        'Linux hotkey key is not supported: ${hotkey.key}',
      );
    }
    final parts = <String>[
      ...hotkey.modifiers.map(_linuxModifierName).whereType<String>(),
      key,
    ];
    if (parts.length != hotkey.modifiers.length + 1) {
      return _HotkeySendResult.fail(
        'Linux hotkey modifiers are not supported: ${hotkey.label()}',
      );
    }
    final combo = parts.join('+');
    try {
      final result = await Process.run('xdotool', <String>[
        'key',
        '--clearmodifiers',
        combo,
      ]);
      if (result.exitCode == 0) {
        return const _HotkeySendResult.success();
      }
      return _HotkeySendResult.fail(
        'xdotool failed (exit ${result.exitCode}) for "$combo": ${_compactProcessOutput(result.stderr)}',
      );
    } catch (e) {
      return _HotkeySendResult.fail('Failed to run xdotool: $e');
    }
  }

  Future<_HotkeySendResult> _sendPasteHotkey() async {
    final pasteHotkey = Platform.isMacOS
        ? const _ParsedHotkey(modifiers: <String>{'CMD'}, key: 'V')
        : Platform.isLinux || Platform.isWindows
        ? const _ParsedHotkey(modifiers: <String>{'CTRL'}, key: 'V')
        : null;
    if (pasteHotkey == null) {
      return const _HotkeySendResult.fail(
        'Paste hotkey is unsupported on this platform',
      );
    }
    return _sendPlatformHotkey(pasteHotkey);
  }

  Future<_HotkeySendResult> _sendPlatformHotkey(_ParsedHotkey hotkey) async {
    if (Platform.isMacOS) {
      return _sendMacHotkey(hotkey);
    }
    if (Platform.isLinux) {
      return _sendLinuxHotkey(hotkey);
    }
    if (Platform.isWindows) {
      return _sendWindowsHotkey(hotkey);
    }
    return const _HotkeySendResult.fail(
      'Hotkey adapter unsupported on this platform',
    );
  }

  String? _linuxModifierName(String modifier) {
    switch (modifier) {
      case 'CTRL':
        return 'ctrl';
      case 'ALT':
        return 'alt';
      case 'SHIFT':
        return 'shift';
      case 'CMD':
        return 'super';
      default:
        return null;
    }
  }

  String? _linuxKeyName(String key) {
    switch (key) {
      case 'ENTER':
        return 'Return';
      case 'TAB':
        return 'Tab';
      case 'SPACE':
        return 'space';
      case 'ESC':
        return 'Escape';
      case 'BACKSPACE':
        return 'BackSpace';
      case 'DELETE':
        return 'Delete';
      case 'UP':
        return 'Up';
      case 'DOWN':
        return 'Down';
      case 'LEFT':
        return 'Left';
      case 'RIGHT':
        return 'Right';
      case 'HOME':
        return 'Home';
      case 'END':
        return 'End';
      case 'PAGEUP':
        return 'Prior';
      case 'PAGEDOWN':
        return 'Next';
      default:
        return key;
    }
  }

  Future<_HotkeySendResult> _sendWindowsHotkey(_ParsedHotkey hotkey) async {
    if (hotkey.modifiers.contains('CMD')) {
      return const _HotkeySendResult.fail(
        'Windows hotkey does not support CMD modifier',
      );
    }
    final key = _windowsKeyName(hotkey.key);
    if (key == null) {
      return _HotkeySendResult.fail(
        'Windows hotkey key is not supported: ${hotkey.key}',
      );
    }
    final modifiers = StringBuffer();
    if (hotkey.modifiers.contains('CTRL')) modifiers.write('^');
    if (hotkey.modifiers.contains('ALT')) modifiers.write('%');
    if (hotkey.modifiers.contains('SHIFT')) modifiers.write('+');
    final sendKeys = '${modifiers.toString()}$key';
    try {
      final result = await Process.run('powershell', <String>[
        '-Command',
        'Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.SendKeys]::SendWait("${sendKeys.replaceAll('"', '\\"')}")',
      ]);
      if (result.exitCode == 0) {
        return const _HotkeySendResult.success();
      }
      return _HotkeySendResult.fail(
        'powershell SendKeys failed (exit ${result.exitCode}) for "$sendKeys": ${_compactProcessOutput(result.stderr)}',
      );
    } catch (e) {
      return _HotkeySendResult.fail('Failed to run powershell SendKeys: $e');
    }
  }

  String? _windowsKeyName(String key) {
    if (RegExp(r'^[A-Z0-9]$').hasMatch(key)) {
      return key.toLowerCase();
    }
    if (RegExp(r'^F([1-9]|1[0-2])$').hasMatch(key)) {
      return '{$key}';
    }
    switch (key) {
      case 'ENTER':
        return '{ENTER}';
      case 'TAB':
        return '{TAB}';
      case 'SPACE':
        return ' ';
      case 'ESC':
        return '{ESC}';
      case 'BACKSPACE':
        return '{BACKSPACE}';
      case 'DELETE':
        return '{DELETE}';
      case 'UP':
        return '{UP}';
      case 'DOWN':
        return '{DOWN}';
      case 'LEFT':
        return '{LEFT}';
      case 'RIGHT':
        return '{RIGHT}';
      case 'HOME':
        return '{HOME}';
      case 'END':
        return '{END}';
      case 'PAGEUP':
        return '{PGUP}';
      case 'PAGEDOWN':
        return '{PGDN}';
      default:
        return null;
    }
  }

  Future<_HotkeySendResult> _sendMacHotkey(_ParsedHotkey hotkey) async {
    final native = await _sendMacHotkeyViaChannel(hotkey);
    if (native.ok) {
      return native;
    }

    final modifiers = <String>[
      if (hotkey.modifiers.contains('CTRL')) 'control down',
      if (hotkey.modifiers.contains('ALT')) 'option down',
      if (hotkey.modifiers.contains('SHIFT')) 'shift down',
      if (hotkey.modifiers.contains('CMD')) 'command down',
    ];
    final keyCode = _macKeyCode(hotkey.key);
    final action = keyCode != null
        ? 'key code $keyCode'
        : _macKeystroke(hotkey.key) != null
        ? 'keystroke "${_macKeystroke(hotkey.key)}"'
        : null;
    if (action == null) {
      return _HotkeySendResult.fail(
        'macOS hotkey key is not supported: ${hotkey.key}',
      );
    }
    final usingClause = modifiers.isEmpty
        ? ''
        : ' using {${modifiers.join(', ')}}';
    final script = 'tell application "System Events" to $action$usingClause';
    try {
      final result = await Process.run('osascript', <String>['-e', script]);
      if (result.exitCode == 0) {
        return const _HotkeySendResult.success();
      }
      final nativeMessage = native.error == null
          ? ''
          : 'native=${native.error}; ';
      final permissionHint = _macPermissionHintForOutput(result.stderr);
      return _HotkeySendResult.fail(
        '${nativeMessage}osascript failed (exit ${result.exitCode}) for "$script": ${_compactProcessOutput(result.stderr)}$permissionHint',
      );
    } catch (e) {
      final nativeMessage = native.error == null
          ? ''
          : 'native=${native.error}; ';
      return _HotkeySendResult.fail(
        '${nativeMessage}Failed to run osascript: $e',
      );
    }
  }

  Future<_HotkeySendResult> _sendMacHotkeyViaChannel(
    _ParsedHotkey hotkey,
  ) async {
    try {
      final response = await _macInputChannel.invokeMapMethod<String, dynamic>(
        'sendHotkey',
        <String, dynamic>{
          'key': hotkey.key,
          'modifiers': hotkey.modifiers.toList(growable: false),
        },
      );
      if (response == null) {
        return const _HotkeySendResult.fail(
          'macOS input channel returned null',
        );
      }
      final ok = response['ok'] == true;
      if (ok) {
        return const _HotkeySendResult.success();
      }
      final error = (response['error'] ?? '').toString().trim();
      return _HotkeySendResult.fail(
        error.isEmpty ? 'macOS input channel failed' : error,
      );
    } on PlatformException catch (e) {
      return _HotkeySendResult.fail(
        'macOS input channel platform error: ${e.code} ${e.message ?? ''}'
            .trim(),
      );
    } catch (e) {
      return _HotkeySendResult.fail('macOS input channel failed: $e');
    }
  }

  String _compactProcessOutput(Object output) {
    final text = output.toString().trim().replaceAll('\n', ' ');
    if (text.isEmpty) {
      return 'no stderr';
    }
    if (text.length <= 300) {
      return text;
    }
    return '${text.substring(0, 297)}...';
  }

  String _macPermissionHintForOutput(Object output) {
    final text = output.toString().toLowerCase();
    if (!text.contains('-10004') &&
        !text.contains('not authorized') &&
        !text.contains('not permitted') &&
        !text.contains('violation of rights') &&
        !text.contains('нарушение прав')) {
      return '';
    }
    return ' | macOS permissions hint: enable Accessibility and Automation (System Events) for Vibe Deck, or for Terminal/Runner if launched from them.';
  }

  String? _macKeystroke(String key) {
    if (RegExp(r'^[A-Z]$').hasMatch(key)) {
      return key.toLowerCase();
    }
    if (RegExp(r'^[0-9]$').hasMatch(key)) {
      return key;
    }
    if (key == 'SPACE') {
      return ' ';
    }
    return null;
  }

  int? _macKeyCode(String key) {
    switch (key) {
      case 'ENTER':
        return 36;
      case 'TAB':
        return 48;
      case 'BACKSPACE':
        return 51;
      case 'ESC':
        return 53;
      case 'LEFT':
        return 123;
      case 'RIGHT':
        return 124;
      case 'DOWN':
        return 125;
      case 'UP':
        return 126;
      case 'DELETE':
        return 117;
      case 'HOME':
        return 115;
      case 'END':
        return 119;
      case 'PAGEUP':
        return 116;
      case 'PAGEDOWN':
        return 121;
      case 'F1':
        return 122;
      case 'F2':
        return 120;
      case 'F3':
        return 99;
      case 'F4':
        return 118;
      case 'F5':
        return 96;
      case 'F6':
        return 97;
      case 'F7':
        return 98;
      case 'F8':
        return 100;
      case 'F9':
        return 101;
      case 'F10':
        return 109;
      case 'F11':
        return 103;
      case 'F12':
        return 111;
      default:
        return null;
    }
  }
}

class _ParsedHotkey {
  const _ParsedHotkey({required this.modifiers, required this.key});

  final Set<String> modifiers;
  final String key;

  String label() {
    const order = <String>['CTRL', 'ALT', 'SHIFT', 'CMD'];
    final parts = <String>[...order.where(modifiers.contains), key];
    return parts.join('+');
  }
}

class _HotkeySendResult {
  const _HotkeySendResult._({required this.ok, this.error});

  const _HotkeySendResult.success() : this._(ok: true);

  const _HotkeySendResult.fail(String error) : this._(ok: false, error: error);

  final bool ok;
  final String? error;
}
