import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../app_state.dart';
import '../../design/design_tokens.dart';
import '../../i18n.dart';
import '../../models/protocol_models.dart';

class ConnectionTab extends StatelessWidget {
  const ConnectionTab({
    super.key,
    required this.hostCtrl,
    required this.portCtrl,
    required this.codeCtrl,
    required this.onPairFromHost,
    required this.onConnect,
    required this.onHealthPing,
    required this.onUnpair,
  });

  final TextEditingController hostCtrl;
  final TextEditingController portCtrl;
  final TextEditingController codeCtrl;
  final Future<void> Function({required String host, required int port})
  onPairFromHost;
  final Future<void> Function() onConnect;
  final Future<void> Function() onHealthPing;
  final Future<void> Function() onUnpair;

  @override
  Widget build(BuildContext context) {
    final t = AppI18n.of(context);
    return Selector<MobileAppState, _ConnectionViewData>(
      selector: (_, state) => _ConnectionViewData(
        status: state.status,
        loading: state.loading,
        connectedEndpoint: state.connectedEndpoint,
        hosts: state.hosts,
        isHostLinkConnected: state.isHostLinkConnected,
      ),
      builder: (context, view, _) {
        return ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(AppTokens.spacingMd),
          children: <Widget>[
            Text('${t.text('Status', 'Статус')}: ${view.status}'),
            if (view.connectedEndpoint != null) ...<Widget>[
              const SizedBox(height: AppTokens.spacingXs),
              _ConnectionStatusBadge(connected: view.isHostLinkConnected),
            ],
            if (view.connectedEndpoint != null)
              Text(
                '${t.text('Connected to', 'Подключено к')}: ${view.connectedEndpoint}',
              ),
            const SizedBox(height: AppTokens.spacingSm + AppTokens.spacingXs),
            FilledButton.icon(
              onPressed: view.loading
                  ? null
                  : () => context.read<MobileAppState>().scanHosts(),
              icon: const Icon(Icons.radar),
              label: Text(
                view.loading
                    ? t.text('Scanning...', 'Сканирование...')
                    : t.text('Scan LAN', 'Сканировать LAN'),
              ),
            ),
            const SizedBox(height: AppTokens.spacingSm + AppTokens.spacingXs),
            Text(t.text('Discovered hosts', 'Найденные хосты')),
            const SizedBox(height: AppTokens.spacingSm),
            ...view.hosts.map(
              (h) => Card(
                child: ListTile(
                  title: Text(h.name),
                  subtitle: Text(h.endpoint),
                  trailing: FilledButton(
                    onPressed: () async =>
                        onPairFromHost(host: h.address, port: h.wsPort),
                    child: Text(t.text('Pair', 'Сопрячь')),
                  ),
                ),
              ),
            ),
            const Divider(),
            Text(t.text('Manual connection', 'Ручное подключение')),
            const SizedBox(height: AppTokens.spacingSm),
            TextField(
              controller: hostCtrl,
              textInputAction: TextInputAction.next,
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              decoration: InputDecoration(
                labelText: t.text('Host / IP', 'Хост / IP'),
              ),
            ),
            const SizedBox(height: AppTokens.spacingSm),
            TextField(
              controller: portCtrl,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              decoration: InputDecoration(labelText: t.text('Port', 'Порт')),
            ),
            const SizedBox(height: AppTokens.spacingSm),
            TextField(
              controller: codeCtrl,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              decoration: InputDecoration(
                labelText: t.text('Pair code', 'Код пары'),
              ),
            ),
            const SizedBox(height: AppTokens.spacingSm),
            FilledButton(
              onPressed: onConnect,
              child: Text(t.text('Connect & Pair', 'Подключить и сопрячь')),
            ),
            const SizedBox(height: AppTokens.spacingSm),
            OutlinedButton.icon(
              onPressed: view.connectedEndpoint == null ? null : onHealthPing,
              icon: const Icon(Icons.check_circle_outline),
              label: Text(t.text('Health check', 'Проверить связь')),
            ),
            const SizedBox(height: AppTokens.spacingSm),
            OutlinedButton.icon(
              onPressed: view.connectedEndpoint == null ? null : onUnpair,
              icon: const Icon(Icons.link_off),
              label: Text(t.text('Unpair', 'Разорвать пару')),
            ),
          ],
        );
      },
    );
  }
}

class _ConnectionViewData {
  const _ConnectionViewData({
    required this.status,
    required this.loading,
    required this.connectedEndpoint,
    required this.hosts,
    required this.isHostLinkConnected,
  });

  final String status;
  final bool loading;
  final String? connectedEndpoint;
  final List<DiscoveredHost> hosts;
  final bool isHostLinkConnected;
}

class _ConnectionStatusBadge extends StatelessWidget {
  const _ConnectionStatusBadge({required this.connected});

  final bool connected;

  @override
  Widget build(BuildContext context) {
    final t = AppI18n.of(context);
    final colors = Theme.of(context).colorScheme;
    final background = connected
        ? colors.primaryContainer
        : colors.errorContainer;
    final foreground = connected
        ? colors.onPrimaryContainer
        : colors.onErrorContainer;
    final icon = connected ? Icons.wifi : Icons.wifi_off;
    final label = connected
        ? t.text('Connected', 'Подключено')
        : t.text('Connection lost', 'Соединение пропало');

    return Align(
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppTokens.radiusFull),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.spacingSm,
            vertical: AppTokens.spacingXs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 16, color: foreground),
              const SizedBox(width: AppTokens.spacingXs),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
