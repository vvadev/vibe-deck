import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../i18n.dart';
import '../models/deck_models.dart';
import 'locale_controller.dart';
import '../features/about/about_tab.dart';
import '../features/connection/connection_tab.dart';
import '../features/connection/dialogs/pair_code_dialog.dart';
import '../features/deck/deck_tab.dart';

class MobileShell extends StatefulWidget {
  const MobileShell({super.key});

  @override
  State<MobileShell> createState() => _MobileShellState();
}

class _MobileShellState extends State<MobileShell> {
  final TextEditingController _hostCtrl = TextEditingController();
  final TextEditingController _portCtrl = TextEditingController(text: '4040');
  final TextEditingController _codeCtrl = TextEditingController();

  int _tabIndex = 0;
  DeckOrientation? _appliedOrientation;

  @override
  void dispose() {
    _hostCtrl.dispose();
    _portCtrl.dispose();
    _codeCtrl.dispose();
    unawaited(_clearDeckPresentation());
    super.dispose();
  }

  Future<void> _connect({
    required String host,
    required int port,
    required String pairCode,
  }) async {
    final t = AppI18n.of(context);
    try {
      await context.read<MobileAppState>().connectAndPair(
        host: host,
        port: port,
        pairCode: pairCode,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.text('Connected', 'Подключено'))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${t.text('Connect error', 'Ошибка подключения')}: $e'),
        ),
      );
    }
  }

  Future<void> _connectWithDialog() async {
    final t = AppI18n.of(context);
    await showPairCodeDialog(
      context: context,
      controller: _codeCtrl,
      onPair: () async {
        await _connect(
          host: _hostCtrl.text.trim(),
          port: int.tryParse(_portCtrl.text.trim()) ?? 4040,
          pairCode: _codeCtrl.text.trim(),
        );
      },
      title: t.text('Pair code', 'Код пары'),
      labelText: t.text(
        'Enter code shown on desktop',
        'Введите код, показанный на ПК',
      ),
      cancelText: t.text('Cancel', 'Отмена'),
      pairText: t.text('Pair', 'Сопрячь'),
    );
  }

  Future<void> _sendHealthPing() async {
    final t = AppI18n.of(context);
    try {
      await context.read<MobileAppState>().sendHealthPing();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t.text('Signal sent to desktop', 'Сигнал отправлен на ПК'),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${t.text('Health check error', 'Ошибка проверки')}: $e',
          ),
        ),
      );
    }
  }

  Future<void> _unpair() async {
    final t = AppI18n.of(context);
    await context.read<MobileAppState>().unpair();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.text('Pairing reset', 'Сопряжение сброшено'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppI18n.of(context);
    final locale = context.select<LocaleController, Locale>((c) => c.locale);
    final orientation = context.select<MobileAppState, DeckOrientation>(
      (s) => s.profile.orientation,
    );
    if (_tabIndex == 1) {
      unawaited(_applyDeckPresentation(orientation));
    } else if (_appliedOrientation != null) {
      unawaited(_clearDeckPresentation());
    }

    return Scaffold(
      appBar: _tabIndex == 1
          ? null
          : AppBar(
              leading: const Padding(
                padding: EdgeInsets.all(10),
                child: Image(
                  image: AssetImage('assets/vibe-deck-logo.png'),
                  fit: BoxFit.contain,
                ),
              ),
              title: const Text('Vibe Deck'),
              actions: <Widget>[
                PopupMenuButton<Locale>(
                  initialValue: locale,
                  tooltip: t.text('Language', 'Язык'),
                  icon: const Icon(Icons.language),
                  onSelected: (value) =>
                      context.read<LocaleController>().setLocale(value),
                  itemBuilder: (context) => const <PopupMenuEntry<Locale>>[
                    PopupMenuItem<Locale>(
                      value: Locale('en'),
                      child: Text('English'),
                    ),
                    PopupMenuItem<Locale>(
                      value: Locale('ru'),
                      child: Text('Русский'),
                    ),
                  ],
                ),
              ],
            ),
      body: switch (_tabIndex) {
        0 => ConnectionTab(
          hostCtrl: _hostCtrl,
          portCtrl: _portCtrl,
          codeCtrl: _codeCtrl,
          onPairFromHost: ({required String host, required int port}) async {
            _hostCtrl.text = host;
            _portCtrl.text = port.toString();
            await _connectWithDialog();
          },
          onConnect: () => _connect(
            host: _hostCtrl.text.trim(),
            port: int.tryParse(_portCtrl.text.trim()) ?? 4040,
            pairCode: _codeCtrl.text.trim(),
          ),
          onHealthPing: _sendHealthPing,
          onUnpair: _unpair,
        ),
        1 => DeckTab(
          onExitDeckMode: () async {
            setState(() => _tabIndex = 0);
            await _clearDeckPresentation();
          },
        ),
        _ => AboutTab(),
      },
      bottomNavigationBar: _tabIndex == 1
          ? null
          : NavigationBar(
              selectedIndex: _tabIndex,
              destinations: <Widget>[
                NavigationDestination(
                  icon: const Icon(Icons.link),
                  label: t.text('Connect', 'Подключение'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.grid_view),
                  label: t.text('Deck', 'Пульт'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.info_outline_rounded),
                  label: t.text('About', 'О приложении'),
                ),
              ],
              onDestinationSelected: (index) {
                setState(() {
                  _tabIndex = index;
                });
              },
            ),
    );
  }

  Future<void> _applyDeckPresentation(DeckOrientation orientation) async {
    if (_appliedOrientation == orientation) {
      return;
    }
    _appliedOrientation = orientation;
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations(_toPreferred(orientation));
  }

  Future<void> _clearDeckPresentation() async {
    _appliedOrientation = null;
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations(<DeviceOrientation>[]);
  }

  List<DeviceOrientation> _toPreferred(DeckOrientation orientation) {
    switch (orientation) {
      case DeckOrientation.portrait:
        return const <DeviceOrientation>[
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ];
      case DeckOrientation.landscape:
        return const <DeviceOrientation>[
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ];
      case DeckOrientation.auto:
        return const <DeviceOrientation>[];
    }
  }
}
