import 'dart:convert';

enum ActionType { insertText, runAction, hotkey }

ActionType actionTypeFromWire(String value) {
  switch (value) {
    case 'insert_text':
      return ActionType.insertText;
    case 'run_action':
      return ActionType.runAction;
    case 'hotkey':
      return ActionType.hotkey;
    default:
      return ActionType.insertText;
  }
}

String actionTypeToWire(ActionType value) {
  switch (value) {
    case ActionType.insertText:
      return 'insert_text';
    case ActionType.runAction:
      return 'run_action';
    case ActionType.hotkey:
      return 'hotkey';
  }
}

class ProtocolMessage {
  ProtocolMessage({required this.type, required this.payload});

  final String type;
  final Map<String, dynamic> payload;

  factory ProtocolMessage.fromRaw(String raw) {
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return ProtocolMessage(
      type: (decoded['type'] ?? '').toString(),
      payload:
          (decoded['payload'] ?? <String, dynamic>{}) as Map<String, dynamic>,
    );
  }

  String toRaw() {
    return jsonEncode({'type': type, 'payload': payload});
  }
}

class DesktopAction {
  DesktopAction({
    required this.id,
    required this.name,
    required this.command,
    required this.args,
    required this.enabled,
    required this.runInShell,
  });

  final String id;
  final String name;
  final String command;
  final List<String> args;
  final bool enabled;
  final bool runInShell;

  DesktopAction copyWith({
    String? id,
    String? name,
    String? command,
    List<String>? args,
    bool? enabled,
    bool? runInShell,
  }) {
    return DesktopAction(
      id: id ?? this.id,
      name: name ?? this.name,
      command: command ?? this.command,
      args: args ?? this.args,
      enabled: enabled ?? this.enabled,
      runInShell: runInShell ?? this.runInShell,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'command': command,
    'args': args,
    'enabled': enabled,
    'runInShell': runInShell,
  };

  factory DesktopAction.fromJson(Map<String, dynamic> json) {
    return DesktopAction(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      command: (json['command'] ?? '').toString(),
      args: ((json['args'] ?? <dynamic>[]) as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      enabled: (json['enabled'] ?? false) as bool,
      runInShell: (json['runInShell'] ?? false) as bool,
    );
  }
}

class DesktopSettings {
  DesktopSettings({
    required this.allowTextInsert,
    required this.allowHotkeys,
    required this.allowActions,
    required this.allowShellCommands,
  });

  final bool allowTextInsert;
  final bool allowHotkeys;
  final bool allowActions;
  final bool allowShellCommands;

  DesktopSettings copyWith({
    bool? allowTextInsert,
    bool? allowHotkeys,
    bool? allowActions,
    bool? allowShellCommands,
  }) {
    return DesktopSettings(
      allowTextInsert: allowTextInsert ?? this.allowTextInsert,
      allowHotkeys: allowHotkeys ?? this.allowHotkeys,
      allowActions: allowActions ?? this.allowActions,
      allowShellCommands: allowShellCommands ?? this.allowShellCommands,
    );
  }

  Map<String, dynamic> toJson() => {
    'allowTextInsert': allowTextInsert,
    'allowHotkeys': allowHotkeys,
    'allowActions': allowActions,
    'allowShellCommands': allowShellCommands,
  };

  factory DesktopSettings.fromJson(Map<String, dynamic> json) {
    return DesktopSettings(
      allowTextInsert: (json['allowTextInsert'] ?? true) as bool,
      allowHotkeys: (json['allowHotkeys'] ?? true) as bool,
      allowActions: (json['allowActions'] ?? true) as bool,
      allowShellCommands: (json['allowShellCommands'] ?? false) as bool,
    );
  }

  factory DesktopSettings.defaults() {
    return DesktopSettings(
      allowTextInsert: true,
      allowHotkeys: true,
      allowActions: true,
      allowShellCommands: false,
    );
  }
}
