import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../app_state.dart';
import '../../../design/design_tokens.dart';
import '../../../i18n.dart';

class RuntimeLogPanel extends StatelessWidget {
  const RuntimeLogPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Container(
      color: AppTokens.getBackground(brightness),
      child: Selector<DesktopAppState, List<String>>(
        selector: (_, state) => state.logs,
        builder: (context, logs, _) {
          return Card(
            margin: const EdgeInsets.all(AppTokens.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Panel Header
                _LogPanelHeader(logCount: logs.length),

                Divider(
                  color: AppTokens.getBorder(brightness),
                  height: 1,
                ),

                // Log entries
                Expanded(
                  child: logs.isEmpty
                      ? _EmptyLogState()
                      : _LogEntries(
                          logs: logs,
                          brightness: brightness,
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Log panel header with title and action button
class _LogPanelHeader extends StatelessWidget {
  const _LogPanelHeader({required this.logCount});

  final int logCount;

  @override
  Widget build(BuildContext context) {
    final t = AppI18n.of(context);
    final brightness = Theme.of(context).brightness;

    return Padding(
      padding: const EdgeInsets.all(AppTokens.spacingMd),
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
              Icons.terminal_rounded,
              size: 16,
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
                  t.text('Runtime Log', 'Журнал выполнения'),
                  style: TextStyle(
                    fontSize: AppTokens.fontSizeLg,
                    fontWeight: AppTokens.weightSemibold,
                    color: AppTokens.getTextPrimary(brightness),
                  ),
                ),
                Text(
                  '$logCount ${t.text('entries', 'записей')}',
                  style: TextStyle(
                    fontSize: AppTokens.fontSizeXs,
                    fontWeight: AppTokens.weightMedium,
                    color: AppTokens.getTextSecondary(brightness),
                  ),
                ),
              ],
            ),
          ),

          // Copy all button
          if (logCount > 0)
            _CopyAllButton(
              logs: context.read<DesktopAppState>().logs,
            ),
        ],
      ),
    );
  }
}

/// Copy all button
class _CopyAllButton extends StatefulWidget {
  const _CopyAllButton({required this.logs});

  final List<String> logs;

  @override
  State<_CopyAllButton> createState() => _CopyAllButtonState();
}

class _CopyAllButtonState extends State<_CopyAllButton> {
  bool _copied = false;

  Future<void> _handleCopy() async {
    final logsText = widget.logs.join('\n');
    await Clipboard.setData(ClipboardData(text: logsText));
    if (!mounted) return;

    setState(() {
      _copied = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('All logs copied'),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppTokens.spacingMd),
        duration: const Duration(seconds: 1),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() {
        _copied = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Tooltip(
      message: 'Copy all logs',
      child: InkWell(
        onTap: _copied ? null : _handleCopy,
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        child: Container(
          padding: const EdgeInsets.all(AppTokens.spacingSm),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _copied ? Icons.check_rounded : Icons.content_copy_rounded,
                size: 18,
                color: _copied
                    ? AppTokens.success
                    : AppTokens.getTextSecondary(brightness),
              ),
              if (!_copied) ...[
                SizedBox(width: AppTokens.spacingXs),
                Text(
                  'Copy All',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppTokens.getTextSecondary(brightness),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty log state
class _EmptyLogState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = AppI18n.of(context);
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history_rounded,
            size: 48,
            color: AppTokens.getTextTertiary(brightness),
          ),
          SizedBox(height: AppTokens.spacingMd),
          Text(
            t.text('No logs yet', 'Пока нет записей'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTokens.getTextSecondary(brightness),
            ),
          ),
          SizedBox(height: AppTokens.spacingXs),
          Text(
            t.text(
              'Logs will appear here as the app runs',
              'Здесь появится журнал работы приложения',
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTokens.getTextTertiary(brightness),
            ),
          ),
        ],
      ),
    );
  }
}

/// Log entries list
class _LogEntries extends StatelessWidget {
  const _LogEntries({
    required this.logs,
    required this.brightness,
  });

  final List<String> logs;
  final Brightness brightness;

  Color _getLogColor(String logLine) {
    final lowerLine = logLine.toLowerCase();

    // Error logs
    if (lowerLine.contains('error') ||
        lowerLine.contains('exception') ||
        lowerLine.contains('failed')) {
      return AppTokens.danger;
    }

    // Warning logs
    if (lowerLine.contains('warning') ||
        lowerLine.contains('warn') ||
        lowerLine.contains('deprecated')) {
      return AppTokens.warning;
    }

    // Info/success logs
    if (lowerLine.contains('started') ||
        lowerLine.contains('connected') ||
        lowerLine.contains('running') ||
        lowerLine.contains('success')) {
      return brightness == Brightness.dark
          ? const Color(0xFF34D399)
          : AppTokens.success;
    }

    // Default text color
    return AppTokens.getTextSecondary(brightness);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTokens.spacingMd),
      decoration: BoxDecoration(
        color: brightness == Brightness.dark
            ? const Color(0xFF0D0D0D)
            : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppTokens.radiusMd),
          bottomRight: Radius.circular(AppTokens.radiusMd),
        ),
      ),
      child: SelectionArea(
        child: ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: logs.length,
          separatorBuilder: (_, __) =>
              SizedBox(height: AppTokens.spacingXs),
          itemBuilder: (context, index) {
            final logLine = logs[index];
            final logColor = _getLogColor(logLine);

            return SelectableText(
              logLine,
              style: TextStyle(
                fontFamily: 'Monaco, Menlo, Consolas, monospace',
                fontSize: AppTokens.fontSizeSm,
                color: logColor,
                height: 1.4,
              ),
            );
          },
        ),
      ),
    );
  }
}
