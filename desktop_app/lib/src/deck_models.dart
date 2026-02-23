import 'dart:convert';

import 'models.dart';

const int maxButtons = 24;
const String enterButtonId = 'enter-default';

enum DeckOrientation { auto, portrait, landscape }

String deckOrientationToWire(DeckOrientation value) {
  switch (value) {
    case DeckOrientation.auto:
      return 'auto';
    case DeckOrientation.portrait:
      return 'portrait';
    case DeckOrientation.landscape:
      return 'landscape';
  }
}

DeckOrientation deckOrientationFromWire(String value) {
  switch (value) {
    case 'portrait':
      return DeckOrientation.portrait;
    case 'landscape':
      return DeckOrientation.landscape;
    default:
      return DeckOrientation.auto;
  }
}

class ButtonAction {
  ButtonAction({required this.type, required this.data});

  final ActionType type;
  final String data;

  Map<String, dynamic> toJson() => {
    'type': actionTypeToWire(type),
    'data': data,
  };

  factory ButtonAction.fromJson(Map<String, dynamic> json) {
    return ButtonAction(
      type: actionTypeFromWire((json['type'] ?? '').toString()),
      data: (json['data'] ?? '').toString(),
    );
  }
}

class DeckButton {
  DeckButton({
    required this.id,
    required this.label,
    required this.iconKey,
    required this.bgStyle,
    required this.action,
    required this.cellIndex,
    this.locked = false,
  });

  final String id;
  final String label;
  final String iconKey;
  final String bgStyle;
  final ButtonAction action;
  final int cellIndex;
  final bool locked;

  DeckButton copyWith({
    String? id,
    String? label,
    String? iconKey,
    String? bgStyle,
    ButtonAction? action,
    int? cellIndex,
    bool? locked,
  }) {
    return DeckButton(
      id: id ?? this.id,
      label: label ?? this.label,
      iconKey: iconKey ?? this.iconKey,
      bgStyle: bgStyle ?? this.bgStyle,
      action: action ?? this.action,
      cellIndex: cellIndex ?? this.cellIndex,
      locked: locked ?? this.locked,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'iconKey': iconKey,
    'bgStyle': bgStyle,
    'action': action.toJson(),
    'cellIndex': cellIndex,
    'locked': locked,
  };

  factory DeckButton.fromJson(Map<String, dynamic> json) {
    return DeckButton(
      id: (json['id'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      iconKey: (json['iconKey'] ?? 'terminal').toString(),
      bgStyle: (json['bgStyle'] ?? 'blue').toString(),
      action: ButtonAction.fromJson(
        (json['action'] ?? <String, dynamic>{}) as Map<String, dynamic>,
      ),
      cellIndex: _intOrDefault(json['cellIndex'], -1),
      locked: (json['locked'] ?? false) as bool,
    );
  }

  static int _intOrDefault(Object? value, int fallback) {
    if (value is num) {
      return value.toInt();
    }
    return fallback;
  }
}

class DeckProfile {
  DeckProfile({
    required this.id,
    required this.name,
    required this.rows,
    required this.cols,
    required this.cellSpacing,
    required this.autoAspectRatio,
    required this.orientation,
    this.buttonAspectRatio,
    required this.buttons,
  });

  final String id;
  final String name;
  final int rows;
  final int cols;
  final double cellSpacing;
  final bool autoAspectRatio;
  final double? buttonAspectRatio;
  final DeckOrientation orientation;
  final List<DeckButton> buttons;

  int get capacity => rows * cols;

  DeckProfile copyWith({
    String? id,
    String? name,
    int? rows,
    int? cols,
    double? cellSpacing,
    bool? autoAspectRatio,
    double? buttonAspectRatio,
    bool clearButtonAspectRatio = false,
    DeckOrientation? orientation,
    List<DeckButton>? buttons,
  }) {
    return DeckProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      rows: rows ?? this.rows,
      cols: cols ?? this.cols,
      cellSpacing: cellSpacing ?? this.cellSpacing,
      autoAspectRatio: autoAspectRatio ?? this.autoAspectRatio,
      buttonAspectRatio: clearButtonAspectRatio
          ? null
          : (buttonAspectRatio ?? this.buttonAspectRatio),
      orientation: orientation ?? this.orientation,
      buttons: buttons ?? this.buttons,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'rows': rows,
    'cols': cols,
    'cellSpacing': cellSpacing,
    'autoAspectRatio': autoAspectRatio,
    'buttonAspectRatio': buttonAspectRatio,
    'orientation': deckOrientationToWire(orientation),
    'buttons': buttons.map((b) => b.toJson()).toList(),
  };

  factory DeckProfile.fromJson(Map<String, dynamic> json) {
    final buttonJson = (json['buttons'] ?? <dynamic>[]) as List<dynamic>;
    final buttons = buttonJson
        .map((e) => DeckButton.fromJson(e as Map<String, dynamic>))
        .toList();

    return DeckProfile(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? 'My Deck').toString(),
      rows: _intOrDefault(json['rows'], 3),
      cols: _intOrDefault(json['cols'], 4),
      cellSpacing: _doubleOrDefault(json['cellSpacing'], 8),
      autoAspectRatio: (json['autoAspectRatio'] ?? true) as bool,
      buttonAspectRatio: _nullableDouble(json['buttonAspectRatio']),
      orientation: deckOrientationFromWire(
        (json['orientation'] ?? 'auto').toString(),
      ),
      buttons: _normalizeButtons(
        buttons,
        (_intOrDefault(json['rows'], 3) * _intOrDefault(json['cols'], 4))
            .clamp(1, maxButtons)
            .toInt(),
      ),
    );
  }

  static DeckProfile defaultProfile() {
    return DeckProfile(
      id: 'default-profile',
      name: 'Vibe Deck',
      rows: 3,
      cols: 4,
      cellSpacing: 8,
      autoAspectRatio: true,
      buttonAspectRatio: null,
      orientation: DeckOrientation.auto,
      buttons: _normalizeButtons(<DeckButton>[], 12),
    );
  }

  DeckProfile normalized() {
    return copyWith(
      rows: rows.clamp(1, maxButtons).toInt(),
      cols: cols.clamp(1, maxButtons).toInt(),
      cellSpacing: cellSpacing.clamp(0.0, 48.0).toDouble(),
      buttonAspectRatio: buttonAspectRatio?.clamp(0.2, 5.0).toDouble(),
      buttons: _normalizeButtons(
        buttons,
        capacity.clamp(1, maxButtons).toInt(),
      ),
    );
  }

  static List<DeckButton> _normalizeButtons(
    List<DeckButton> buttons,
    int capacity,
  ) {
    final safeCapacity = capacity.clamp(1, maxButtons).toInt();
    DeckButton? existingEnter;
    for (final button in buttons) {
      if (button.id == enterButtonId) {
        existingEnter = button;
        break;
      }
    }
    final enterButton = DeckButton(
      id: enterButtonId,
      label: 'Enter',
      iconKey: 'keyboard_return',
      bgStyle: 'green',
      action: ButtonAction(type: ActionType.hotkey, data: 'ENTER'),
      cellIndex: existingEnter?.cellIndex ?? 0,
      locked: true,
    );
    final filtered = buttons
        .where((b) => b.id != enterButtonId)
        .where((b) => b.id.isNotEmpty)
        .toList();
    final uniqueById = <String>{enterButton.id};
    final source = <DeckButton>[
      enterButton,
      ...filtered.where((b) => uniqueById.add(b.id)),
    ];
    final occupied = <int>{};
    int nextFree = 0;

    int claimCell(int preferred) {
      if (preferred >= 0 &&
          preferred < safeCapacity &&
          !occupied.contains(preferred)) {
        occupied.add(preferred);
        return preferred;
      }
      while (nextFree < safeCapacity && occupied.contains(nextFree)) {
        nextFree++;
      }
      if (nextFree >= safeCapacity) {
        return -1;
      }
      occupied.add(nextFree);
      return nextFree++;
    }

    final result = <DeckButton>[];
    for (final button in source) {
      final claimed = claimCell(button.cellIndex);
      if (claimed == -1) break;
      result.add(button.copyWith(cellIndex: claimed));
    }
    return result;
  }

  String encode() => jsonEncode(toJson());

  factory DeckProfile.decode(String input) {
    return DeckProfile.fromJson(jsonDecode(input) as Map<String, dynamic>);
  }

  static int _intOrDefault(Object? value, int fallback) {
    if (value is num) {
      return value.toInt();
    }
    return fallback;
  }

  static double _doubleOrDefault(Object? value, double fallback) {
    if (value is num) {
      return value.toDouble();
    }
    return fallback;
  }

  static double? _nullableDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return null;
  }
}
