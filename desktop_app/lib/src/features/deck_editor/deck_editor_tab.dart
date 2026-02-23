import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../app_state.dart';
import '../../deck_models.dart';
import '../../design/design_tokens.dart';
import '../../i18n.dart';
import '../../models.dart';

class DeckEditorTab extends StatefulWidget {
  const DeckEditorTab({super.key});

  @override
  State<DeckEditorTab> createState() => _DeckEditorTabState();
}

class _DeckEditorTabState extends State<DeckEditorTab> {
  String? _selectedButtonId;
  final TextEditingController _rowsCtrl = TextEditingController();
  final TextEditingController _colsCtrl = TextEditingController();
  final TextEditingController _spacingCtrl = TextEditingController();
  final TextEditingController _aspectCtrl = TextEditingController();

  @override
  void dispose() {
    _rowsCtrl.dispose();
    _colsCtrl.dispose();
    _spacingCtrl.dispose();
    _aspectCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<DesktopAppState, _DeckEditorVm>(
      selector: (_, s) => _DeckEditorVm(
        profile: s.deckProfile,
        actions: s.actions.where((a) => a.enabled).toList(),
      ),
      builder: (context, vm, _) {
        final selected = vm.profile.buttons
            .where((b) => b.id == _selectedButtonId)
            .firstOrNull;
        _syncLayoutControllers(vm.profile);

        return Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  _DeckToolbar(
                    profile: vm.profile,
                    rowsCtrl: _rowsCtrl,
                    colsCtrl: _colsCtrl,
                    spacingCtrl: _spacingCtrl,
                    aspectCtrl: _aspectCtrl,
                  ),
                  const SizedBox(height: AppTokens.spacingMd),
                  Expanded(
                    child: _DeckGridEditor(
                      profile: vm.profile,
                      selectedButtonId: _selectedButtonId,
                      onSelected: (id) => setState(() => _selectedButtonId = id),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppTokens.spacingMd),
            Expanded(
              flex: 2,
              child: _ButtonEditorPanel(
                selected: selected,
                actions: vm.actions,
                onRemove: () async {
                  if (selected == null) return;
                  await context.read<DesktopAppState>().removeDeckButton(
                    selected.id,
                  );
                  if (!mounted) return;
                  setState(() => _selectedButtonId = null);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _syncLayoutControllers(DeckProfile profile) {
    if (_rowsCtrl.text != profile.rows.toString()) {
      _rowsCtrl.text = profile.rows.toString();
    }
    if (_colsCtrl.text != profile.cols.toString()) {
      _colsCtrl.text = profile.cols.toString();
    }
    final spacing = profile.cellSpacing.toStringAsFixed(1);
    if (_spacingCtrl.text != spacing) {
      _spacingCtrl.text = spacing;
    }
    final aspect = (profile.buttonAspectRatio ?? 1.0).toStringAsFixed(2);
    if (_aspectCtrl.text != aspect) {
      _aspectCtrl.text = aspect;
    }
  }
}

class _DeckEditorVm {
  const _DeckEditorVm({required this.profile, required this.actions});

  final DeckProfile profile;
  final List<DesktopAction> actions;
}

class _DeckToolbar extends StatelessWidget {
  const _DeckToolbar({
    required this.profile,
    required this.rowsCtrl,
    required this.colsCtrl,
    required this.spacingCtrl,
    required this.aspectCtrl,
  });

  final DeckProfile profile;
  final TextEditingController rowsCtrl;
  final TextEditingController colsCtrl;
  final TextEditingController spacingCtrl;
  final TextEditingController aspectCtrl;

  @override
  Widget build(BuildContext context) {
    final t = AppI18n.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spacingMd),
        child: Wrap(
          spacing: AppTokens.spacingSm,
          runSpacing: AppTokens.spacingSm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: () => context.read<DesktopAppState>().addDeckButton(),
              icon: const Icon(Icons.add),
              label: Text(t.text('Add button', 'Добавить кнопку')),
            ),
            SizedBox(
              width: 72,
              child: TextField(
                controller: rowsCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: t.text('Rows', 'Ряды'),
                  isDense: true,
                ),
              ),
            ),
            SizedBox(
              width: 72,
              child: TextField(
                controller: colsCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: t.text('Cols', 'Колонки'),
                  isDense: true,
                ),
              ),
            ),
            SizedBox(
              width: 92,
              child: TextField(
                controller: spacingCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: t.text('Gap', 'Отступ'),
                  isDense: true,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(t.text('Auto ratio', 'Авто пропорция')),
                const SizedBox(width: AppTokens.spacingXs),
                Switch(
                  value: profile.autoAspectRatio,
                  onChanged: (value) {
                    context.read<DesktopAppState>().updateDeckLayout(
                      rows: profile.rows,
                      cols: profile.cols,
                      cellSpacing: profile.cellSpacing,
                      autoAspectRatio: value,
                      buttonAspectRatio: profile.buttonAspectRatio ?? 1.0,
                    );
                  },
                ),
              ],
            ),
            if (!profile.autoAspectRatio)
              SizedBox(
                width: 92,
                child: TextField(
                  controller: aspectCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: t.text('Aspect', 'Пропорция'),
                    isDense: true,
                  ),
                ),
              ),
            DropdownButton<DeckOrientation>(
              value: profile.orientation,
              items: [
                DropdownMenuItem(
                  value: DeckOrientation.auto,
                  child: Text(t.text('Auto', 'Авто')),
                ),
                DropdownMenuItem(
                  value: DeckOrientation.portrait,
                  child: Text(t.text('Portrait', 'Портрет')),
                ),
                DropdownMenuItem(
                  value: DeckOrientation.landscape,
                  child: Text(t.text('Landscape', 'Ландшафт')),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                context.read<DesktopAppState>().updateDeckOrientation(value);
              },
            ),
            OutlinedButton.icon(
              onPressed: () {
                final rows = int.tryParse(rowsCtrl.text.trim()) ?? profile.rows;
                final cols = int.tryParse(colsCtrl.text.trim()) ?? profile.cols;
                final gap =
                    double.tryParse(spacingCtrl.text.trim()) ??
                    profile.cellSpacing;
                final ratio =
                    double.tryParse(aspectCtrl.text.trim()) ??
                    (profile.buttonAspectRatio ?? 1.0);
                context.read<DesktopAppState>().updateDeckLayout(
                  rows: rows,
                  cols: cols,
                  cellSpacing: gap,
                  autoAspectRatio: profile.autoAspectRatio,
                  buttonAspectRatio: ratio,
                );
              },
              icon: const Icon(Icons.save),
              label: Text(t.text('Apply grid', 'Применить сетку')),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeckGridEditor extends StatelessWidget {
  const _DeckGridEditor({
    required this.profile,
    required this.selectedButtonId,
    required this.onSelected,
  });

  final DeckProfile profile;
  final String? selectedButtonId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = profile.cols;
        final rows = profile.rows;
        final spacing = profile.cellSpacing;
        final safeWidth = max(1.0, constraints.maxWidth - spacing * (cols - 1));
        final safeHeight = max(
          1.0,
          constraints.maxHeight - spacing * (rows - 1),
        );
        final autoAspect = (safeWidth / cols) / (safeHeight / rows);
        final ratio = profile.autoAspectRatio
            ? autoAspect
            : (profile.buttonAspectRatio ?? autoAspect);
        final buttonsByCell = <int, DeckButton>{
          for (final button in profile.buttons)
            if (button.cellIndex >= 0 && button.cellIndex < profile.capacity)
              button.cellIndex: button,
        };

        return GridView.builder(
          itemCount: profile.capacity,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: ratio,
          ),
          itemBuilder: (context, index) {
            final button = buttonsByCell[index];
            return DragTarget<DeckButton>(
              onWillAcceptWithDetails: (d) => d.data.cellIndex != index,
              onAcceptWithDetails: (d) {
                context.read<DesktopAppState>().moveDeckButtonToCell(
                  buttonId: d.data.id,
                  targetCell: index,
                );
              },
              builder: (context, candidateData, rejectedData) {
                final highlighted = candidateData.isNotEmpty;
                if (button == null) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                      border: Border.all(
                        color: highlighted
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                                context,
                              ).colorScheme.outline.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Center(child: Text('Empty')),
                  );
                }
                final selected = selectedButtonId == button.id;
                return LongPressDraggable<DeckButton>(
                  data: button,
                  feedback: SizedBox(
                    width: safeWidth / cols,
                    height: safeHeight / rows,
                    child: _DeckButtonCell(button: button, selected: true),
                  ),
                  childWhenDragging: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                      color: Colors.black12,
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () => onSelected(button.id),
                    child: _DeckButtonCell(
                      button: button,
                      selected: selected || highlighted,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _DeckButtonCell extends StatelessWidget {
  const _DeckButtonCell({required this.button, required this.selected});

  final DeckButton button;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final border = selected
        ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
        : Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.25),
          );
    final icon = _iconFor(button.iconKey);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: _gradientFor(button.bgStyle),
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        border: border,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spacingSm),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 88;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: compact ? 18 : 22, color: Colors.white),
                const SizedBox(height: AppTokens.spacingXs),
                Text(
                  button.label,
                  textAlign: TextAlign.center,
                  maxLines: compact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ButtonEditorPanel extends StatefulWidget {
  const _ButtonEditorPanel({
    required this.selected,
    required this.actions,
    required this.onRemove,
  });

  final DeckButton? selected;
  final List<DesktopAction> actions;
  final Future<void> Function() onRemove;

  @override
  State<_ButtonEditorPanel> createState() => _ButtonEditorPanelState();
}

class _ButtonEditorPanelState extends State<_ButtonEditorPanel> {
  final _labelCtrl = TextEditingController();
  final _dataCtrl = TextEditingController();
  ActionType _type = ActionType.insertText;
  String _iconKey = 'smart_button';
  String _bgStyle = 'blue';

  @override
  void dispose() {
    _labelCtrl.dispose();
    _dataCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppI18n.of(context);
    final selected = widget.selected;
    if (selected == null) {
      return const Card(child: Center(child: Text('Select a button')));
    }
    _sync(selected);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spacingMd),
        child: ListView(
          children: [
            Text(
              t.text('Button editor', 'Редактор кнопки'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTokens.spacingSm),
            TextField(
              controller: _labelCtrl,
              decoration: InputDecoration(labelText: t.text('Label', 'Название')),
              enabled: !selected.locked,
            ),
            const SizedBox(height: AppTokens.spacingSm),
            DropdownButtonFormField<String>(
              value: _iconKey,
              decoration: InputDecoration(labelText: t.text('Icon', 'Иконка')),
              items: _iconOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: selected.locked
                  ? null
                  : (value) => setState(() => _iconKey = value ?? _iconKey),
            ),
            const SizedBox(height: AppTokens.spacingSm),
            DropdownButtonFormField<String>(
              value: _bgStyle,
              decoration: InputDecoration(
                labelText: t.text('Background', 'Фон'),
              ),
              items: _bgOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: selected.locked
                  ? null
                  : (value) => setState(() => _bgStyle = value ?? _bgStyle),
            ),
            const SizedBox(height: AppTokens.spacingSm),
            DropdownButtonFormField<ActionType>(
              value: _type,
              decoration: InputDecoration(labelText: t.text('Type', 'Тип')),
              items: [
                DropdownMenuItem(
                  value: ActionType.insertText,
                  child: Text(t.text('Insert text', 'Вставка текста')),
                ),
                DropdownMenuItem(
                  value: ActionType.hotkey,
                  child: Text(t.text('Hotkey', 'Хоткей')),
                ),
                DropdownMenuItem(
                  value: ActionType.runAction,
                  child: Text(t.text('Run action', 'Запуск действия')),
                ),
              ],
              onChanged: selected.locked
                  ? null
                  : (value) => setState(() => _type = value ?? _type),
            ),
            const SizedBox(height: AppTokens.spacingSm),
            if (_type == ActionType.runAction)
              DropdownButtonFormField<String>(
                value: widget.actions.any((a) => a.id == _dataCtrl.text)
                    ? _dataCtrl.text
                    : null,
                decoration: InputDecoration(
                  labelText: t.text('Action', 'Действие'),
                ),
                items: widget.actions
                    .map(
                      (a) => DropdownMenuItem(
                        value: a.id,
                        child: Text('${a.name} (${a.id})'),
                      ),
                    )
                    .toList(),
                onChanged: selected.locked
                    ? null
                    : (value) => setState(() => _dataCtrl.text = value ?? ''),
              )
            else ...[
              TextField(
                controller: _dataCtrl,
                enabled: !selected.locked,
                decoration: InputDecoration(
                  labelText: _type == ActionType.hotkey
                      ? t.text('Hotkey', 'Хоткей')
                      : t.text('Payload', 'Данные'),
                ),
              ),
              if (_type == ActionType.hotkey)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: selected.locked
                        ? null
                        : () async {
                            final captured = await showDialog<String>(
                              context: context,
                              builder: (_) => const _HotkeyCaptureDialog(),
                            );
                            if (captured != null) {
                              setState(() => _dataCtrl.text = captured);
                            }
                          },
                    icon: const Icon(Icons.keyboard),
                    label: Text(t.text('Capture hotkey', 'Захватить хоткей')),
                  ),
                ),
            ],
            const SizedBox(height: AppTokens.spacingMd),
            FilledButton.icon(
              onPressed: selected.locked
                  ? null
                  : () async {
                      final payload = _dataCtrl.text.trim();
                      if (_type == ActionType.hotkey &&
                          !_isSupportedHotkey(payload)) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              t.text(
                                'Unsupported hotkey format',
                                'Неподдерживаемый формат хоткея',
                              ),
                            ),
                          ),
                        );
                        return;
                      }
                      await context.read<DesktopAppState>().updateDeckButton(
                        selected.copyWith(
                          label: _labelCtrl.text.trim(),
                          iconKey: _iconKey,
                          bgStyle: _bgStyle,
                          action: ButtonAction(type: _type, data: payload),
                        ),
                      );
                    },
              icon: const Icon(Icons.save),
              label: Text(t.text('Save', 'Сохранить')),
            ),
            const SizedBox(height: AppTokens.spacingSm),
            OutlinedButton.icon(
              onPressed: selected.locked ? null : widget.onRemove,
              icon: const Icon(Icons.delete),
              label: Text(t.text('Delete', 'Удалить')),
            ),
          ],
        ),
      ),
    );
  }

  void _sync(DeckButton selected) {
    if (_labelCtrl.text != selected.label) {
      _labelCtrl.text = selected.label;
    }
    if (_dataCtrl.text != selected.action.data) {
      _dataCtrl.text = selected.action.data;
    }
    _type = selected.action.type;
    _iconKey = _iconOptions.contains(selected.iconKey)
        ? selected.iconKey
        : 'smart_button';
    _bgStyle = _bgOptions.contains(selected.bgStyle) ? selected.bgStyle : 'blue';
  }
}

class _HotkeyCaptureDialog extends StatefulWidget {
  const _HotkeyCaptureDialog();

  @override
  State<_HotkeyCaptureDialog> createState() => _HotkeyCaptureDialogState();
}

class _HotkeyCaptureDialogState extends State<_HotkeyCaptureDialog> {
  final FocusNode _focusNode = FocusNode();
  String? _value;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Capture hotkey'),
      content: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: (event) {
          if (event is! KeyDownEvent) {
            return;
          }
          final captured = _normalizeFromEvent(event);
          setState(() {
            _value = captured.value;
            _error = captured.error;
          });
        },
        child: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Press combination and press Save'),
              const SizedBox(height: AppTokens.spacingSm),
              SelectableText(_value ?? '-'),
              if (_error != null) ...[
                const SizedBox(height: AppTokens.spacingXs),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _value != null && _error == null
              ? () => Navigator.of(context).pop(_value)
              : null,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _CapturedHotkey {
  const _CapturedHotkey({this.value, this.error});

  final String? value;
  final String? error;
}

_CapturedHotkey _normalizeFromEvent(KeyDownEvent event) {
  final key = event.logicalKey;
  final normalizedKey = _logicalToKeyName(key);
  if (normalizedKey == null) {
    return _CapturedHotkey(error: 'Unsupported key');
  }
  final modifiers = <String>[];
  if (HardwareKeyboard.instance.isControlPressed) modifiers.add('CTRL');
  if (HardwareKeyboard.instance.isAltPressed) modifiers.add('ALT');
  if (HardwareKeyboard.instance.isShiftPressed) modifiers.add('SHIFT');
  if (HardwareKeyboard.instance.isMetaPressed) modifiers.add('CMD');
  final value = [...modifiers, normalizedKey].join('+');
  return _CapturedHotkey(value: value);
}

String? _logicalToKeyName(LogicalKeyboardKey key) {
  final label = key.keyLabel.toUpperCase();
  if (RegExp(r'^[A-Z0-9]$').hasMatch(label)) {
    return label;
  }
  final map = <LogicalKeyboardKey, String>{
    LogicalKeyboardKey.enter: 'ENTER',
    LogicalKeyboardKey.numpadEnter: 'ENTER',
    LogicalKeyboardKey.tab: 'TAB',
    LogicalKeyboardKey.space: 'SPACE',
    LogicalKeyboardKey.escape: 'ESC',
    LogicalKeyboardKey.backspace: 'BACKSPACE',
    LogicalKeyboardKey.delete: 'DELETE',
    LogicalKeyboardKey.arrowUp: 'UP',
    LogicalKeyboardKey.arrowDown: 'DOWN',
    LogicalKeyboardKey.arrowLeft: 'LEFT',
    LogicalKeyboardKey.arrowRight: 'RIGHT',
    LogicalKeyboardKey.home: 'HOME',
    LogicalKeyboardKey.end: 'END',
    LogicalKeyboardKey.pageUp: 'PAGEUP',
    LogicalKeyboardKey.pageDown: 'PAGEDOWN',
    LogicalKeyboardKey.f1: 'F1',
    LogicalKeyboardKey.f2: 'F2',
    LogicalKeyboardKey.f3: 'F3',
    LogicalKeyboardKey.f4: 'F4',
    LogicalKeyboardKey.f5: 'F5',
    LogicalKeyboardKey.f6: 'F6',
    LogicalKeyboardKey.f7: 'F7',
    LogicalKeyboardKey.f8: 'F8',
    LogicalKeyboardKey.f9: 'F9',
    LogicalKeyboardKey.f10: 'F10',
    LogicalKeyboardKey.f11: 'F11',
    LogicalKeyboardKey.f12: 'F12',
  };
  return map[key];
}

bool _isSupportedHotkey(String raw) {
  final parts = raw
      .split('+')
      .map((e) => e.trim().toUpperCase())
      .where((e) => e.isNotEmpty)
      .toList();
  if (parts.isEmpty) {
    return false;
  }
  final key = parts.last;
  if (RegExp(r'^[A-Z0-9]$').hasMatch(key)) {
    return true;
  }
  return const <String>{
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
    'F1',
    'F2',
    'F3',
    'F4',
    'F5',
    'F6',
    'F7',
    'F8',
    'F9',
    'F10',
    'F11',
    'F12',
  }.contains(key);
}

const List<String> _iconOptions = <String>[
  'smart_button',
  'terminal',
  'keyboard_return',
  'code',
  'paste',
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

const List<String> _bgOptions = <String>[
  'blue',
  'sky',
  'green',
  'mint',
  'red',
  'cherry',
  'orange',
  'sunset',
  'purple',
  'violet',
  'pink',
  'night',
];

LinearGradient _gradientFor(String key) {
  switch (key) {
    case 'sky':
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF00C6FB), Color(0xFF005BEA)],
      );
    case 'green':
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF11998E), Color(0xFF38EF7D)],
      );
    case 'mint':
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF43E97B), Color(0xFF38F9D7)],
      );
    case 'red':
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFFCB2D3E), Color(0xFFEF473A)],
      );
    case 'cherry':
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFFEB3349), Color(0xFFF45C43)],
      );
    case 'orange':
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFFF7971E), Color(0xFFFFD200)],
      );
    case 'sunset':
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFFFC4A1A), Color(0xFFF7B733)],
      );
    case 'purple':
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF7F00FF), Color(0xFFE100FF)],
      );
    case 'violet':
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF4776E6), Color(0xFF8E54E9)],
      );
    case 'pink':
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFFFF512F), Color(0xFFDD2476)],
      );
    case 'night':
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF232526), Color(0xFF414345)],
      );
    default:
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF396AFC), Color(0xFF2948FF)],
      );
  }
}

IconData _iconFor(String key) {
  switch (key) {
    case 'terminal':
      return Icons.terminal;
    case 'keyboard_return':
      return Icons.keyboard_return;
    case 'code':
      return Icons.code;
    case 'paste':
      return Icons.content_paste;
    case 'play_arrow':
      return Icons.play_arrow;
    case 'pause':
      return Icons.pause;
    case 'stop':
      return Icons.stop;
    case 'skip_next':
      return Icons.skip_next;
    case 'volume_up':
      return Icons.volume_up;
    case 'mic':
      return Icons.mic;
    case 'camera':
      return Icons.camera_alt;
    case 'flash_on':
      return Icons.flash_on;
    case 'search':
      return Icons.search;
    case 'settings':
      return Icons.settings;
    case 'bolt':
      return Icons.bolt;
    case 'rocket_launch':
      return Icons.rocket_launch;
    case 'home':
      return Icons.home;
    case 'folder':
      return Icons.folder;
    case 'send':
      return Icons.send;
    default:
      return Icons.smart_button;
  }
}

extension<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
