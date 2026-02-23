import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app_state.dart';
import '../../../design/design_tokens.dart';
import '../../../i18n.dart';
import '../../../models.dart';
import '../../../platform_permissions.dart';

class SecurityToggles extends StatelessWidget {
  const SecurityToggles({super.key, required this.confirmDangerousMode});

  final Future<bool> Function({required String title, required String details})
  confirmDangerousMode;

  Future<void> _openInputSettings(BuildContext context) async {
    final t = AppI18n.of(context);
    final result = await PlatformPermissions.openInputPermissionSettings();
    if (!context.mounted) return;

    final instruction = t.text(result.instructionEn, result.instructionRu);
    final title = t.text(
      'Input permissions',
      'Права на ввод',
    );

    if (result.opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t.text(
              'System settings opened. Verify input permissions there.',
              'Системные настройки открыты. Проверьте там права на ввод.',
            ),
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(AppTokens.spacingMd),
        ),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(instruction),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t.text('OK', 'ОК')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppI18n.of(context);
    return Selector<DesktopAppState, DesktopSettings>(
      selector: (_, state) => state.settings,
      builder: (context, settings, _) {
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Header
              _SecurityHeader(),

              Divider(
                color: AppTokens.getBorder(Theme.of(context).brightness),
                height: 1,
              ),

              Padding(
                padding: const EdgeInsets.all(AppTokens.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Regular Security Toggles
                    _SecurityToggleItem(
                      icon: Icons.text_fields_rounded,
                      title: t.text('Allow text insert', 'Разрешить вставку текста'),
                      value: settings.allowTextInsert,
                      onChanged: (value) => context
                          .read<DesktopAppState>()
                          .updateSettings(settings.copyWith(allowTextInsert: value)),
                    ),
                    _SecurityToggleItem(
                      icon: Icons.keyboard_rounded,
                      title: t.text('Allow hotkeys', 'Разрешить хоткеи'),
                      value: settings.allowHotkeys,
                      onChanged: (value) => context
                          .read<DesktopAppState>()
                          .updateSettings(settings.copyWith(allowHotkeys: value)),
                    ),
                    _SecurityToggleItem(
                      icon: Icons.play_circle_rounded,
                      title: t.text(
                        'Allow allowlist actions',
                        'Разрешить действия из allowlist',
                      ),
                      value: settings.allowActions,
                      onChanged: (value) => context
                          .read<DesktopAppState>()
                          .updateSettings(settings.copyWith(allowActions: value)),
                    ),

                    // Input Permissions Section
                    SizedBox(height: AppTokens.spacingSm),
                    _InputPermissionsSection(
                      onPressed: () => _openInputSettings(context),
                    ),

                    // Danger Zone
                    SizedBox(height: AppTokens.spacingMd),
                    _DangerZone(
                      allowShellCommands: settings.allowShellCommands,
                      onChanged: (value) async {
                        if (value && !settings.allowShellCommands) {
                          final confirmed = await confirmDangerousMode(
                            title: t.text(
                              'Enable shell execution?',
                              'Включить выполнение shell-команд?',
                            ),
                            details: t.text(
                              'Shell execution can run arbitrary commands on this machine. Use only for reviewed allowlist actions on trusted networks.',
                              'Shell-режим может выполнять произвольные команды на этом компьютере. Используйте только для проверенных действий в доверенной сети.',
                            ),
                          );
                          if (!confirmed) return;
                        }
                        if (!context.mounted) return;
                        await context.read<DesktopAppState>().updateSettings(
                          settings.copyWith(allowShellCommands: value),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Security card header
class _SecurityHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = AppI18n.of(context);
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Padding(
      padding: const EdgeInsets.all(AppTokens.spacingMd),
      child: Row(
        children: [
          // Icon with background
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTokens.getSurfaceVariant(brightness),
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            ),
            child: Icon(
              Icons.security_rounded,
              size: 18,
              color: AppTokens.getTextSecondary(brightness),
            ),
          ),
          SizedBox(width: AppTokens.spacingMd),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.text('Security Settings', 'Настройки безопасности'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppTokens.getTextPrimary(brightness),
                  ),
                ),
                Text(
                  t.text('Control access to system features', 'Управление доступом к функциям системы'),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppTokens.getTextSecondary(brightness),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual security toggle item
class _SecurityToggleItem extends StatelessWidget {
  const _SecurityToggleItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTokens.spacingXs),
      child: Row(
        children: [
          // Icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTokens.getSurfaceVariant(brightness),
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            ),
            child: Icon(
              icon,
              size: 16,
              color: AppTokens.getTextSecondary(brightness),
            ),
          ),
          SizedBox(width: AppTokens.spacingMd),

          // Title
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTokens.getTextPrimary(brightness),
              ),
            ),
          ),

          // Switch
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

/// Input permissions section
class _InputPermissionsSection extends StatelessWidget {
  const _InputPermissionsSection({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final t = AppI18n.of(context);
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
            Icons.settings_rounded,
            size: 16,
            color: AppTokens.getTextSecondary(brightness),
          ),
          SizedBox(width: AppTokens.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.text(
                    'Open input permission settings',
                    'Открыть настройки прав ввода',
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTokens.getTextPrimary(brightness),
                  ),
                ),
                Text(
                  t.text(
                    'Needed if paste/hotkeys do not reach other apps',
                    'Нужно, если вставка/хоткеи не доходят до других приложений',
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTokens.getTextSecondary(brightness),
                  ),
                ),
              ],
            ),
          ),
          FilledButton.tonal(
            onPressed: onPressed,
            child: Text(t.text('Open', 'Открыть')),
          ),
        ],
      ),
    );
  }
}

/// Danger zone section for shell commands
class _DangerZone extends StatelessWidget {
  const _DangerZone({
    required this.allowShellCommands,
    required this.onChanged,
  });

  final bool allowShellCommands;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = AppI18n.of(context);
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTokens.warning,
            width: 2,
          ),
        ),
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppTokens.spacingMd),
        decoration: BoxDecoration(
          color: brightness == Brightness.dark
              ? AppTokens.warningContainerDark.withOpacity(0.3)
              : AppTokens.warning.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Danger zone header
            Row(
              children: [
                Icon(
                  Icons.warning_rounded,
                  size: 18,
                  color: AppTokens.warning,
                ),
                SizedBox(width: AppTokens.spacingSm),
                Text(
                  t.text('Danger Zone', 'Опасная зона'),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppTokens.warning,
                    fontWeight: AppTokens.weightSemibold,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTokens.spacingSm),

            // Description
            Text(
              t.text(
                'Shell execution can run arbitrary commands on this machine.',
                'Shell-режим может выполнять произвольные команды на этом компьютере.',
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTokens.getTextSecondary(brightness),
              ),
            ),
            SizedBox(height: AppTokens.spacingMd),

            // Toggle
            Row(
              children: [
                Icon(
                  Icons.terminal_rounded,
                  size: 16,
                  color: allowShellCommands
                      ? AppTokens.warning
                      : AppTokens.getTextSecondary(brightness),
                ),
                SizedBox(width: AppTokens.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.text(
                          'Allow shell execution',
                          'Разрешить выполнение shell-команд',
                        ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTokens.getTextPrimary(brightness),
                          fontWeight: AppTokens.weightMedium,
                        ),
                      ),
                      Text(
                        t.text(
                          'Required for actions that must run in a shell/terminal',
                          'Нужно для действий, которым требуется shell/терминал',
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTokens.getTextSecondary(brightness),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: allowShellCommands,
                  onChanged: onChanged,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
