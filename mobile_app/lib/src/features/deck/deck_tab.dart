import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_state.dart';
import '../../design/design_tokens.dart';
import '../../i18n.dart';
import '../../models/deck_models.dart';
import 'widgets/deck_grid.dart';

class DeckTab extends StatelessWidget {
  const DeckTab({super.key, required this.onExitDeckMode});

  final VoidCallback onExitDeckMode;

  @override
  Widget build(BuildContext context) {
    final t = AppI18n.of(context);
    final view = context.select<MobileAppState, _DeckView>(
      (s) => _DeckView(
        profile: s.profile,
        state: s.deckConnectionState,
        reconnectAttempts: s.reconnectAttempts,
      ),
    );
    final blocked = view.state != DeckConnectionState.idle;

    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(AppTokens.spacingMd),
            child: DeckGrid(
              profile: view.profile,
              enabled: !blocked,
              transparentEmptyCells: true,
            ),
          ),
        ),
        Positioned(
          top: AppTokens.spacingMd,
          right: AppTokens.spacingMd,
          child: SafeArea(
            child: IconButton(
              onPressed: onExitDeckMode,
              icon: const Icon(Icons.close),
              tooltip: t.text('Exit deck mode', 'Выйти из режима пульта'),
            ),
          ),
        ),
        if (blocked)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black45,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTokens.spacingMd),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (view.state == DeckConnectionState.reconnecting)
                          const CircularProgressIndicator(),
                        if (view.state == DeckConnectionState.reconnectFailed)
                          const Icon(Icons.wifi_off, size: 36),
                        const SizedBox(height: AppTokens.spacingSm),
                        Text(
                          view.state == DeckConnectionState.reconnecting
                              ? t.text(
                                  'Reconnecting to desktop...',
                                  'Переподключение к ПК...',
                                )
                              : t.text('Connection lost', 'Связь потеряна'),
                        ),
                        if (view.state == DeckConnectionState.reconnecting)
                          Text(
                            '${t.text('Attempt', 'Попытка')} ${view.reconnectAttempts}/3',
                          ),
                        const SizedBox(height: AppTokens.spacingSm),
                        if (view.state == DeckConnectionState.reconnectFailed)
                          FilledButton.icon(
                            onPressed: onExitDeckMode,
                            icon: const Icon(Icons.link),
                            label: Text(
                              t.text(
                                'Open connection screen',
                                'Открыть экран подключения',
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _DeckView {
  const _DeckView({
    required this.profile,
    required this.state,
    required this.reconnectAttempts,
  });

  final DeckProfile profile;
  final DeckConnectionState state;
  final int reconnectAttempts;
}
