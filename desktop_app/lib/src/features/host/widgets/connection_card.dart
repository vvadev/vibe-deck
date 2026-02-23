import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app_state.dart';
import '../../../design/design_tokens.dart';
import '../../../i18n.dart';

class ConnectionCard extends StatelessWidget {
  const ConnectionCard({super.key, required this.onCopyValue});

  final Future<void> Function({required String value, required String message})
  onCopyValue;

  String _endpointIp(String endpoint) {
    final separatorIndex = endpoint.lastIndexOf(':');
    if (separatorIndex <= 0) {
      return endpoint;
    }
    return endpoint.substring(0, separatorIndex);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppI18n.of(context);
    final theme = Theme.of(context);
    return Selector<DesktopAppState, _ConnectionViewData>(
      selector: (_, state) => _ConnectionViewData(
        running: state.running,
        endpoint: state.endpoint,
        wsPort: state.wsPort,
        pairCode: state.pairCode,
        clientCount: state.clientCount,
      ),
      builder: (context, data, _) {
        final ip = _endpointIp(data.endpoint);
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Header
              _ConnectionCardHeader(
                running: data.running,
                clientCount: data.clientCount,
              ),
              Divider(
                color: AppTokens.getBorder(theme.brightness),
                height: 1,
              ),
              Padding(
                padding: const EdgeInsets.all(AppTokens.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Connection Details Section
                    Text(
                      t.text('Connection Details', 'Подключение'),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppTokens.getTextSecondary(theme.brightness),
                      ),
                    ),
                    SizedBox(height: AppTokens.spacingSm),

                    // Connection details card-in-card
                    Container(
                      padding: const EdgeInsets.all(AppTokens.spacingMd),
                      decoration: BoxDecoration(
                        color: AppTokens.getSurfaceVariant(theme.brightness),
                        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                      ),
                      child: Column(
                        children: [
                          _ConnectionCopyRow(
                            label: 'IP',
                            value: ip,
                            icon: Icons.computer_rounded,
                            onCopy: () => onCopyValue(
                              value: ip,
                              message: t.text('IP copied', 'IP скопирован'),
                            ),
                          ),
                          SizedBox(height: AppTokens.spacingSm),
                          _ConnectionCopyRow(
                            label: t.text('Port', 'Порт'),
                            value: data.wsPort.toString(),
                            icon: Icons.cable_rounded,
                            onCopy: () => onCopyValue(
                              value: data.wsPort.toString(),
                              message: t.text('Port copied', 'Порт скопирован'),
                            ),
                          ),
                          SizedBox(height: AppTokens.spacingSm),
                          _ConnectionCopyRow(
                            label: t.text('Pair code', 'Код пары'),
                            value: data.pairCode,
                            icon: Icons.key_rounded,
                            onCopy: () => onCopyValue(
                              value: data.pairCode,
                              message: t.text('Pair code copied', 'Код пары скопирован'),
                            ),
                          ),
                        ],
                      ),
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

/// Card header with title, status badge, and icon
class _ConnectionCardHeader extends StatelessWidget {
  const _ConnectionCardHeader({
    required this.running,
    required this.clientCount,
  });

  final bool running;
  final int clientCount;

  @override
  Widget build(BuildContext context) {
    final t = AppI18n.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppTokens.spacingMd),
      child: Row(
        children: [
          // Icon with background
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: running
                  ? AppTokens.success.withOpacity(0.1)
                  : AppTokens.getTextTertiary(theme.brightness).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            ),
            child: Icon(
              Icons.wifi_rounded,
              size: 18,
              color: running
                  ? AppTokens.success
                  : AppTokens.getTextTertiary(theme.brightness),
            ),
          ),
          SizedBox(width: AppTokens.spacingMd),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.text('Connection', 'Подключение'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppTokens.getTextPrimary(theme.brightness),
                  ),
                ),
                Text(
                  '${t.text('Clients', 'Клиенты')}: $clientCount',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppTokens.getTextSecondary(theme.brightness),
                  ),
                ),
              ],
            ),
          ),

          // Status Badge
          _StatusBadge(running: running),
        ],
      ),
    );
  }
}

/// Status badge showing running or stopped state
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.running});

  final bool running;

  @override
  Widget build(BuildContext context) {
    final t = AppI18n.of(context);
    final theme = Theme.of(context);

    final backgroundColor = running
        ? AppTokens.success.withOpacity(0.1)
        : AppTokens.getTextTertiary(theme.brightness).withOpacity(0.1);
    final textColor = running
        ? AppTokens.success
        : AppTokens.getTextTertiary(theme.brightness);
    final label = running
        ? t.text('Running', 'Запущен')
        : t.text('Stopped', 'Остановлен');

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.spacingSm,
        vertical: AppTokens.spacingXs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppTokens.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: textColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppTokens.spacingXs),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: textColor,
              fontWeight: AppTokens.weightMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// Copy row with icon, label, value, and copy button
class _ConnectionCopyRow extends StatelessWidget {
  const _ConnectionCopyRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.onCopy,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTokens.getTextSecondary(theme.brightness),
        ),
        SizedBox(width: AppTokens.spacingSm),
        Expanded(
          child: Text(
            '$label: ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTokens.getTextSecondary(theme.brightness),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTokens.getTextPrimary(theme.brightness),
              fontFamily: 'monospace',
            ),
          ),
        ),
        SizedBox(width: AppTokens.spacingSm),
        _CopyButton(onCopy: onCopy),
      ],
    );
  }
}

/// Icon-only copy button
class _CopyButton extends StatefulWidget {
  const _CopyButton({required this.onCopy});

  final VoidCallback onCopy;

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _copied = false;

  Future<void> _handleCopy() async {
    widget.onCopy();
    setState(() {
      _copied = true;
    });
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

    return Tooltip(
      message: _copied ? 'Copied!' : 'Copy',
      child: InkWell(
        onTap: _copied ? null : _handleCopy,
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        child: Container(
          padding: const EdgeInsets.all(AppTokens.spacingXs),
          child: Icon(
            _copied ? Icons.check_rounded : Icons.copy_all_rounded,
            size: 18,
            color: _copied
                ? AppTokens.success
                : AppTokens.getTextSecondary(theme.brightness),
          ),
        ),
      ),
    );
  }
}

class _ConnectionViewData {
  const _ConnectionViewData({
    required this.running,
    required this.endpoint,
    required this.wsPort,
    required this.pairCode,
    required this.clientCount,
  });

  final bool running;
  final String endpoint;
  final int wsPort;
  final String pairCode;
  final int clientCount;
}
