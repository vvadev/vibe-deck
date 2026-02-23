import 'package:flutter/material.dart';

import '../../../design/design_tokens.dart';
import '../../../i18n.dart';
import '../../../models/deck_models.dart';

class ButtonEditorDialog extends StatefulWidget {
  const ButtonEditorDialog({super.key, required this.button});

  final DeckButton button;

  @override
  State<ButtonEditorDialog> createState() => _ButtonEditorDialogState();
}

class _ButtonEditorDialogState extends State<ButtonEditorDialog> {
  static const double _fieldGap = AppTokens.spacingLg;

  static const List<String> _iconOptions = <String>[
    'smart_button',
    'terminal',
    'code',
    'paste',
    'keyboard_return',
    'play_arrow',
    'pause',
    'stop',
    'skip_next',
    'volume_up',
    'mic',
    'camera',
    'flash_on',
    'search',
    'settings',
    'bolt',
    'rocket_launch',
    'home',
    'folder',
    'send',
  ];
  static const List<String> _bgOptions = <String>[
    'blue',
    'sky',
    'green',
    'mint',
    'orange',
    'sunset',
    'red',
    'cherry',
    'purple',
    'violet',
    'pink',
    'night',
  ];
  static const List<String> _hotkeyModifierOrder = <String>[
    'CTRL',
    'ALT',
    'SHIFT',
    'CMD',
  ];
  static final List<String> _hotkeyKeyOptions = <String>[
    'ENTER',
    'TAB',
    'SPACE',
    'ESC',
    'BACKSPACE',
    'DELETE',
    'UP',
    'DOWN',
    'LEFT',
    'RIGHT',
    'HOME',
    'END',
    'PAGEUP',
    'PAGEDOWN',
    ...List<String>.generate(12, (index) => 'F${index + 1}'),
    ...List<String>.generate(26, (index) => String.fromCharCode(65 + index)),
    ...List<String>.generate(10, (index) => '$index'),
  ];
  static const Map<String, String> _hotkeyKeyLabelsRu = <String, String>{
    'ENTER': 'Enter',
    'TAB': 'Tab',
    'SPACE': 'Пробел',
    'ESC': 'Esc',
    'BACKSPACE': 'Backspace',
    'DELETE': 'Delete',
    'UP': 'Стрелка вверх',
    'DOWN': 'Стрелка вниз',
    'LEFT': 'Стрелка влево',
    'RIGHT': 'Стрелка вправо',
    'HOME': 'Home',
    'END': 'End',
    'PAGEUP': 'Page Up',
    'PAGEDOWN': 'Page Down',
  };

  late final TextEditingController _labelCtrl;
  late final TextEditingController _dataCtrl;
  late ActionType _type;
  late String _icon;
  late String _bg;
  late Set<String> _hotkeyModifiers;
  late String _hotkeyKey;

  @override
  void initState() {
    super.initState();
    _labelCtrl = TextEditingController(text: widget.button.label);
    _dataCtrl = TextEditingController(text: widget.button.action.data);
    _type = widget.button.action.type;
    _icon = _normalizeOption(
      widget.button.iconKey,
      _iconOptions,
      'smart_button',
    );
    _bg = _normalizeOption(widget.button.bgStyle, _bgOptions, 'blue');
    final initialHotkey = _parseHotkeyPayload(_dataCtrl.text);
    _hotkeyModifiers = initialHotkey?.modifiers ?? <String>{};
    _hotkeyKey = initialHotkey?.key ?? 'ENTER';
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _dataCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppI18n.of(context);
    final iconValue = _normalizeOption(_icon, _iconOptions, 'smart_button');
    final bgValue = _normalizeOption(_bg, _bgOptions, 'blue');
    return AlertDialog(
      title: Text(
        widget.button.locked
            ? t.text('View Button', 'Просмотр кнопки')
            : t.text('Edit Button', 'Редактировать кнопку'),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _labelCtrl,
              enabled: !widget.button.locked,
              decoration: InputDecoration(
                labelText: t.text('Label', 'Название'),
              ),
            ),
            const SizedBox(height: _fieldGap),
            DropdownButtonFormField<ActionType>(
              initialValue: _type,
              decoration: InputDecoration(
                labelText: t.text('Action type', 'Тип действия'),
              ),
              items: ActionType.values
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(_actionTypeLabel(context, e)),
                    ),
                  )
                  .toList(),
              onChanged: widget.button.locked
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          final previous = _type;
                          _type = value;
                          if (_type == ActionType.hotkey &&
                              previous != ActionType.hotkey) {
                            final parsed = _parseHotkeyPayload(_dataCtrl.text);
                            _hotkeyModifiers = parsed?.modifiers ?? <String>{};
                            _hotkeyKey = parsed?.key ?? 'ENTER';
                            _applyHotkeyBuilderToPayload();
                          }
                        });
                      }
                    },
            ),
            const SizedBox(height: _fieldGap),
            TextField(
              controller: _dataCtrl,
              enabled: !widget.button.locked,
              decoration: InputDecoration(
                labelText: t.text('Action payload', 'Параметры действия'),
              ),
              onChanged: _type == ActionType.hotkey
                  ? (value) => _syncHotkeyBuilderFromPayload(value)
                  : null,
            ),
            if (_type == ActionType.hotkey) ...<Widget>[
              const SizedBox(height: _fieldGap),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  t.text('Hotkey builder', 'Конструктор хоткея'),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const SizedBox(height: _fieldGap),
              Wrap(
                spacing: AppTokens.spacingSm,
                runSpacing: AppTokens.spacingSm,
                children: _hotkeyModifierOrder.map((modifier) {
                  return FilterChip(
                    label: Text(_modifierLabel(modifier)),
                    selected: _hotkeyModifiers.contains(modifier),
                    onSelected: widget.button.locked
                        ? null
                        : (selected) {
                            setState(() {
                              if (selected) {
                                _hotkeyModifiers.add(modifier);
                              } else {
                                _hotkeyModifiers.remove(modifier);
                              }
                              _applyHotkeyBuilderToPayload();
                            });
                          },
                  );
                }).toList(),
              ),
              const SizedBox(height: _fieldGap),
              DropdownButtonFormField<String>(
                initialValue: _normalizeOption(
                  _hotkeyKey,
                  _hotkeyKeyOptions,
                  'ENTER',
                ),
                decoration: InputDecoration(
                  labelText: t.text('Main key', 'Основная клавиша'),
                ),
                items: _hotkeyKeyOptions
                    .map(
                      (key) => DropdownMenuItem<String>(
                        value: key,
                        child: Text(_hotkeyKeyLabel(key)),
                      ),
                    )
                    .toList(),
                onChanged: widget.button.locked
                    ? null
                    : (value) {
                        if (value == null) return;
                        setState(() {
                          _hotkeyKey = value;
                          _applyHotkeyBuilderToPayload();
                        });
                      },
              ),
              const SizedBox(height: _fieldGap),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  t.text('Example: CTRL+SHIFT+K', 'Пример: CTRL+SHIFT+K'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
            const SizedBox(height: _fieldGap),
            DropdownButtonFormField<String>(
              initialValue: iconValue,
              decoration: InputDecoration(labelText: t.text('Icon', 'Иконка')),
              items: _iconOptions
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(_iconLabel(context, value)),
                    ),
                  )
                  .toList(),
              onChanged: widget.button.locked
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          _icon = value;
                        });
                      }
                    },
            ),
            const SizedBox(height: _fieldGap),
            DropdownButtonFormField<String>(
              initialValue: bgValue,
              decoration: InputDecoration(
                labelText: t.text('Background', 'Фон'),
              ),
              items: _bgOptions
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(_bgLabel(context, value)),
                    ),
                  )
                  .toList(),
              onChanged: widget.button.locked
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          _bg = value;
                        });
                      }
                    },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.text('Close', 'Закрыть')),
        ),
        if (!widget.button.locked)
          FilledButton(
            onPressed: () {
              Navigator.pop(
                context,
                widget.button.copyWith(
                  label: _labelCtrl.text.trim(),
                  iconKey: _icon,
                  bgStyle: _bg,
                  action: ButtonAction(
                    type: _type,
                    data: _dataCtrl.text.trim(),
                  ),
                ),
              );
            },
            child: Text(t.text('Save', 'Сохранить')),
          ),
      ],
    );
  }

  String _normalizeOption(String value, List<String> options, String fallback) {
    if (options.contains(value)) {
      return value;
    }
    return options.contains(fallback) ? fallback : options.first;
  }

  String _actionTypeLabel(BuildContext context, ActionType type) {
    final t = AppI18n.of(context);
    switch (type) {
      case ActionType.insertText:
        return t.text('Insert text', 'Вставить текст');
      case ActionType.runAction:
        return t.text('Run action', 'Запустить действие');
      case ActionType.hotkey:
        return t.text('Hotkey', 'Хоткей');
    }
  }

  void _applyHotkeyBuilderToPayload() {
    final orderedModifiers = _hotkeyModifierOrder
        .where(_hotkeyModifiers.contains)
        .toList();
    final payload = <String>[...orderedModifiers, _hotkeyKey].join('+');
    if (_dataCtrl.text == payload) {
      return;
    }
    _dataCtrl.value = _dataCtrl.value.copyWith(
      text: payload,
      selection: TextSelection.collapsed(offset: payload.length),
      composing: TextRange.empty,
    );
  }

  void _syncHotkeyBuilderFromPayload(String payload) {
    final parsed = _parseHotkeyPayload(payload);
    if (parsed == null) {
      return;
    }
    final sameModifiers =
        _hotkeyModifiers.length == parsed.modifiers.length &&
        _hotkeyModifiers.containsAll(parsed.modifiers);
    if (sameModifiers && _hotkeyKey == parsed.key) {
      return;
    }
    setState(() {
      _hotkeyModifiers = parsed.modifiers;
      _hotkeyKey = parsed.key;
    });
  }

  _ParsedHotkey? _parseHotkeyPayload(String payload) {
    final parts = payload
        .split('+')
        .map((part) => part.trim().toUpperCase())
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return null;
    }

    final modifiers = <String>{};
    String? key;
    for (final part in parts) {
      final normalizedModifier = _normalizeModifier(part);
      if (normalizedModifier != null) {
        modifiers.add(normalizedModifier);
        continue;
      }
      key = _normalizeHotkeyKey(part);
    }
    if (key == null) {
      return null;
    }
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

  String _normalizeHotkeyKey(String value) {
    final upper = value.toUpperCase();
    if (_hotkeyKeyOptions.contains(upper)) {
      return upper;
    }
    if (upper == 'RETURN') {
      return 'ENTER';
    }
    if (upper == 'PGUP') {
      return 'PAGEUP';
    }
    if (upper == 'PGDOWN' || upper == 'PGDN') {
      return 'PAGEDOWN';
    }
    return 'ENTER';
  }

  String _modifierLabel(String modifier) {
    final language = Localizations.localeOf(context).languageCode;
    switch (modifier) {
      case 'CTRL':
        return language == 'ru' ? 'Ctrl' : 'Ctrl';
      case 'ALT':
        return language == 'ru' ? 'Alt' : 'Alt';
      case 'SHIFT':
        return language == 'ru' ? 'Shift' : 'Shift';
      case 'CMD':
        return language == 'ru' ? 'Cmd' : 'Cmd';
      default:
        return modifier;
    }
  }

  String _hotkeyKeyLabel(String key) {
    if (Localizations.localeOf(context).languageCode == 'ru') {
      return _hotkeyKeyLabelsRu[key] ?? key;
    }
    return key;
  }

  String _iconLabel(BuildContext context, String key) {
    final t = AppI18n.of(context);
    switch (key) {
      case 'terminal':
        return t.text('Terminal', 'Терминал');
      case 'code':
        return t.text('Code', 'Код');
      case 'paste':
        return t.text('Paste', 'Вставить');
      case 'keyboard_return':
        return t.text('Enter', 'Enter');
      case 'play_arrow':
        return t.text('Play', 'Старт');
      case 'pause':
        return t.text('Pause', 'Пауза');
      case 'stop':
        return t.text('Stop', 'Стоп');
      case 'skip_next':
        return t.text('Next', 'Далее');
      case 'volume_up':
        return t.text('Volume', 'Громкость');
      case 'mic':
        return t.text('Mic', 'Микрофон');
      case 'camera':
        return t.text('Camera', 'Камера');
      case 'flash_on':
        return t.text('Flash', 'Вспышка');
      case 'search':
        return t.text('Search', 'Поиск');
      case 'settings':
        return t.text('Settings', 'Настройки');
      case 'bolt':
        return t.text('Bolt', 'Молния');
      case 'rocket_launch':
        return t.text('Rocket', 'Ракета');
      case 'home':
        return t.text('Home', 'Домой');
      case 'folder':
        return t.text('Folder', 'Папка');
      case 'send':
        return t.text('Send', 'Отправить');
      default:
        return t.text('Button', 'Кнопка');
    }
  }

  String _bgLabel(BuildContext context, String key) {
    final t = AppI18n.of(context);
    switch (key) {
      case 'sky':
        return t.text('Sky', 'Небесный');
      case 'green':
        return t.text('Green', 'Зеленый');
      case 'mint':
        return t.text('Mint', 'Мятный');
      case 'orange':
        return t.text('Orange', 'Оранжевый');
      case 'sunset':
        return t.text('Sunset', 'Закат');
      case 'red':
        return t.text('Red', 'Красный');
      case 'cherry':
        return t.text('Cherry', 'Вишневый');
      case 'purple':
        return t.text('Purple', 'Фиолетовый');
      case 'violet':
        return t.text('Violet', 'Лиловый');
      case 'pink':
        return t.text('Pink', 'Розовый');
      case 'night':
        return t.text('Night', 'Ночной');
      default:
        return t.text('Blue', 'Синий');
    }
  }
}

class _ParsedHotkey {
  const _ParsedHotkey({required this.modifiers, required this.key});

  final Set<String> modifiers;
  final String key;
}
