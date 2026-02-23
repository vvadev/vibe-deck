import 'package:flutter/material.dart';

import '../../../design/design_tokens.dart';
import '../../../i18n.dart';
import '../../../models.dart';

class ActionTile extends StatefulWidget {
  const ActionTile({
    super.key,
    required this.action,
    required this.i18n,
    required this.onChanged,
    required this.onDelete,
    required this.confirmDangerous,
  });

  final DesktopAction action;
  final AppI18n i18n;
  final Future<void> Function(DesktopAction action) onChanged;
  final VoidCallback onDelete;
  final Future<bool> Function({required String title, required String details})
  confirmDangerous;

  @override
  State<ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<ActionTile> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _commandCtrl;
  late final TextEditingController _argsCtrl;
  late bool _enabled;
  late bool _runInShell;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.action.name);
    _commandCtrl = TextEditingController(text: widget.action.command);
    _argsCtrl = TextEditingController(text: widget.action.args.join(' '));
    _enabled = widget.action.enabled;
    _runInShell = widget.action.runInShell;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _commandCtrl.dispose();
    _argsCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final args = _argsCtrl.text
        .split(' ')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    await widget.onChanged(
      widget.action.copyWith(
        name: _nameCtrl.text.trim(),
        command: _commandCtrl.text.trim(),
        args: args,
        enabled: _enabled,
        runInShell: _runInShell,
      ),
    );
    setState(() {
      _isExpanded = false;
    });
  }

  Future<void> _toggleShellMode(bool value) async {
    if (value && !_runInShell) {
      final confirmed = await widget.confirmDangerous(
        title: widget.i18n.text(
          'Enable shell mode for action?',
          'Включить shell-режим для действия?',
        ),
        details: widget.i18n.text(
          'This action will execute through a shell. Keep this off unless you explicitly need shell behavior.',
          'Это действие будет выполняться через shell. Оставляйте выключенным, если shell-поведение не требуется.',
        ),
      );
      if (!confirmed) return;
    }
    setState(() {
      _runInShell = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.i18n;
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Card(
      child: Column(
        children: [
          // Card Header (always visible)
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppTokens.radiusMd),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppTokens.spacingMd),
              child: Row(
                children: [
                  // Enable/Disable icon
                  _EnabledIndicator(enabled: _enabled),
                  SizedBox(width: AppTokens.spacingMd),

                  // Action info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _nameCtrl.text.isEmpty
                                  ? widget.action.id
                                  : _nameCtrl.text,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppTokens.getTextPrimary(brightness),
                              ),
                            ),
                            SizedBox(width: AppTokens.spacingSm),
                            // Action ID badge
                            _ActionIdBadge(id: widget.action.id),
                          ],
                        ),
                        SizedBox(height: AppTokens.spacingXs),
                        Row(
                          children: [
                            // Shell mode badge
                            if (_runInShell) _ShellModeBadge(),
                            // Command preview
                            Expanded(
                              child: Text(
                                _commandCtrl.text.isEmpty
                                    ? t.text('No command', 'Нет команды')
                                    : _commandCtrl.text,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTokens.getTextSecondary(brightness),
                                  fontFamily: 'monospace',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Expand/collapse icon
                  Icon(
                    _isExpanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: AppTokens.getTextSecondary(brightness),
                  ),
                  SizedBox(width: AppTokens.spacingSm),

                  // Delete button
                  _DeleteButton(onDelete: widget.onDelete),
                ],
              ),
            ),
          ),

          // Form fields (expanded)
          if (_isExpanded) ...[
            Divider(
              color: AppTokens.getBorder(brightness),
              height: 1,
            ),
            Padding(
              padding: const EdgeInsets.all(AppTokens.spacingMd),
              child: Column(
                children: [
                  // Name field
                  TextField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      labelText: t.text('Name', 'Название'),
                    ),
                  ),
                  SizedBox(height: AppTokens.spacingSm),

                  // Command field
                  TextField(
                    controller: _commandCtrl,
                    decoration: InputDecoration(
                      labelText: t.text('Command', 'Команда'),
                    ),
                  ),
                  SizedBox(height: AppTokens.spacingSm),

                  // Args field
                  TextField(
                    controller: _argsCtrl,
                    decoration: InputDecoration(
                      labelText: t.text(
                        'Args (space-separated)',
                        'Аргументы (через пробел)',
                      ),
                    ),
                  ),
                  SizedBox(height: AppTokens.spacingMd),

                  // Enabled toggle
                  _ToggleRow(
                    icon: Icons.play_circle_rounded,
                    title: t.text('Enabled', 'Включено'),
                    value: _enabled,
                    onChanged: (value) {
                      setState(() {
                        _enabled = value;
                      });
                    },
                  ),
                  SizedBox(height: AppTokens.spacingSm),

                  // Shell mode toggle
                  _ToggleRow(
                    icon: Icons.terminal_rounded,
                    title: t.text(
                      'Run in shell (dangerous)',
                      'Запускать в shell (опасно)',
                    ),
                    subtitle: t.text(
                      'Enable shell/terminal semantics for this action',
                      'Включить shell/terminal-режим для этого действия',
                    ),
                    value: _runInShell,
                    onChanged: _toggleShellMode,
                    isDangerous: true,
                  ),
                  SizedBox(height: AppTokens.spacingMd),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _handleSave,
                      icon: const Icon(Icons.save_rounded),
                      label: Text(t.text('Save', 'Сохранить')),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Enable/disable indicator
class _EnabledIndicator extends StatelessWidget {
  const _EnabledIndicator({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: enabled
            ? AppTokens.success.withOpacity(0.1)
            : AppTokens.getSurfaceVariant(brightness),
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      ),
      child: Icon(
        enabled
            ? Icons.play_arrow_rounded
            : Icons.pause_rounded,
        size: 18,
        color: enabled
            ? AppTokens.success
            : AppTokens.getTextSecondary(brightness),
      ),
    );
  }
}

/// Action ID badge
class _ActionIdBadge extends StatelessWidget {
  const _ActionIdBadge({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.spacingSm,
        vertical: AppTokens.spacingXs,
      ),
      decoration: BoxDecoration(
        color: AppTokens.getSurfaceVariant(brightness),
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      ),
      child: Text(
        id,
        style: theme.textTheme.labelSmall?.copyWith(
          color: AppTokens.getTextSecondary(brightness),
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

/// Shell mode badge
class _ShellModeBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = AppI18n.of(context);
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.spacingSm,
        vertical: AppTokens.spacingXs,
      ),
      decoration: BoxDecoration(
        color: brightness == Brightness.dark
            ? AppTokens.warningContainerDark.withOpacity(0.3)
            : AppTokens.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_rounded,
            size: 12,
            color: AppTokens.warning,
          ),
          SizedBox(width: AppTokens.spacingXs),
          Text(
            t.text('SHELL', 'SHELL'),
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppTokens.warning,
              fontWeight: AppTokens.weightMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// Delete button with confirmation
class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.onDelete});

  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Tooltip(
      message: 'Delete action',
      child: InkWell(
        onTap: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (_) => _DeleteConfirmDialog(),
          );
          if (confirmed == true) {
            onDelete();
          }
        },
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        child: Container(
          padding: const EdgeInsets.all(AppTokens.spacingXs),
          child: Icon(
            Icons.delete_rounded,
            size: 18,
            color: AppTokens.getTextSecondary(brightness),
          ),
        ),
      ),
    );
  }
}

/// Delete confirmation dialog
class _DeleteConfirmDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = AppI18n.of(context);

    return AlertDialog(
      icon: Icon(
        Icons.delete_rounded,
        color: AppTokens.danger,
        size: 32,
      ),
      title: Text(t.text('Delete Action?', 'Удалить действие?')),
      content: Text(
        t.text(
          'This action will be permanently deleted.',
          'Это действие будет безвозвратно удалено.',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(t.text('Cancel', 'Отмена')),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(
            backgroundColor: AppTokens.danger,
          ),
          child: Text(t.text('Delete', 'Удалить')),
        ),
      ],
    );
  }
}

/// Toggle row component
class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.isDangerous = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDangerous;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Container(
      padding: const EdgeInsets.all(AppTokens.spacingMd),
      decoration: BoxDecoration(
        color: AppTokens.getSurfaceVariant(brightness),
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isDangerous && value
                ? AppTokens.warning
                : AppTokens.getTextSecondary(brightness),
          ),
          SizedBox(width: AppTokens.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTokens.getTextPrimary(brightness),
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: AppTokens.spacingXs),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTokens.getTextSecondary(brightness),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
