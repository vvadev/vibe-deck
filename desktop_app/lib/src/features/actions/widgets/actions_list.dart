import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app_state.dart';
import '../../../design/design_tokens.dart';
import '../../../i18n.dart';
import '../../../models.dart';
import 'action_tile.dart';

class ActionsList extends StatelessWidget {
  const ActionsList({super.key, required this.confirmDangerousMode});

  final Future<bool> Function({required String title, required String details})
  confirmDangerousMode;

  @override
  Widget build(BuildContext context) {
    final t = AppI18n.of(context);
    return Selector<DesktopAppState, List<DesktopAction>>(
      selector: (_, state) => state.actions,
      builder: (context, actions, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Section Header
            _ActionsSectionHeader(
              actionCount: actions.length,
            ),

            SizedBox(height: AppTokens.spacingMd),

            // Actions List
            ...actions.map(
              (action) => Padding(
                padding: const EdgeInsets.only(bottom: AppTokens.spacingMd),
                child: ActionTile(
                  key: ValueKey<String>(action.id),
                  action: action,
                  i18n: t,
                  onChanged: (value) =>
                      context.read<DesktopAppState>().updateAction(value),
                  onDelete: () =>
                      context.read<DesktopAppState>().removeAction(action.id),
                  confirmDangerous: confirmDangerousMode,
                ),
              ),
            ),

            // Add Action Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.read<DesktopAppState>().addAction(),
                icon: const Icon(Icons.add_rounded),
                label: Text(t.text('Add Action', 'Добавить действие')),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTokens.spacingMd,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Section header for actions list
class _ActionsSectionHeader extends StatelessWidget {
  const _ActionsSectionHeader({required this.actionCount});

  final int actionCount;

  @override
  Widget build(BuildContext context) {
    final t = AppI18n.of(context);
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Row(
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
            Icons.list_rounded,
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
                t.text('Allowlist Actions', 'Действия allowlist'),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppTokens.getTextPrimary(brightness),
                ),
              ),
              Text(
                '$actionCount ${t.text('configured', 'настроено')}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppTokens.getTextSecondary(brightness),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
