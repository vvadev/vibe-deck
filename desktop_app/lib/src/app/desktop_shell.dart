import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../design/design_tokens.dart';
import '../i18n.dart';
import 'locale_controller.dart';
import '../features/actions/widgets/actions_list.dart';
import '../features/about/about_tab.dart';
import '../features/deck_editor/deck_editor_tab.dart';
import '../features/dialogs/dangerous_confirm_dialog.dart';
import '../features/host/widgets/connection_card.dart';
import '../features/logs/widgets/runtime_log_panel.dart';
import '../features/settings/widgets/security_toggles.dart';

class DesktopShell extends StatefulWidget {
  const DesktopShell({super.key});

  @override
  State<DesktopShell> createState() => _DesktopShellState();
}

class _DesktopShellState extends State<DesktopShell> {
  int _tabIndex = 0;

  @override
  void dispose() {
    context.read<DesktopAppState>().stop();
    super.dispose();
  }

  Future<void> _copyValue({
    required String value,
    required String message,
  }) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppTokens.spacingMd),
      ),
    );
  }

  Future<bool> _confirmDangerousMode({
    required String title,
    required String details,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DangerousConfirmDialog(title: title, details: details),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.select<LocaleController, Locale>((c) => c.locale);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTokens.getBackground(theme.brightness),
      body: Column(
        children: [
          _CustomAppBar(
            isDark: isDark,
            locale: locale,
            tabIndex: _tabIndex,
            onTabChanged: (index) => setState(() => _tabIndex = index),
          ),
          Expanded(
            child: switch (_tabIndex) {
              0 => Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: ListView(
                      padding: const EdgeInsets.all(AppTokens.spacingLg),
                      children: <Widget>[
                        ConnectionCard(onCopyValue: _copyValue),
                        SizedBox(height: AppTokens.spacingMd),
                        SecurityToggles(
                          confirmDangerousMode: _confirmDangerousMode,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppTokens.spacingMd,
                          ),
                          child: Divider(
                            color: AppTokens.getBorder(theme.brightness),
                            height: 1,
                          ),
                        ),
                        ActionsList(
                          confirmDangerousMode: _confirmDangerousMode,
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: RuntimeLogPanel()),
                ],
              ),
              1 => Padding(
                padding: const EdgeInsets.all(AppTokens.spacingLg),
                child: DeckEditorTab(),
              ),
              _ => Padding(
                padding: const EdgeInsets.all(AppTokens.spacingLg),
                child: AboutTab(),
              ),
            },
          ),
        ],
      ),
    );
  }
}

/// Custom app bar with logo, title, and action buttons
class _CustomAppBar extends StatelessWidget {
  const _CustomAppBar({
    required this.isDark,
    required this.locale,
    required this.tabIndex,
    required this.onTabChanged,
  });

  final bool isDark;
  final Locale locale;
  final int tabIndex;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppTokens.getSurface(theme.brightness),
        border: Border(
          bottom: BorderSide(
            color: AppTokens.getBorder(theme.brightness),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.spacingLg,
            vertical: AppTokens.spacingSm,
          ),
          child: Row(
            children: [
              // Logo
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTokens.primary,
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                  child: Image.asset(
                    'assets/vibe-deck-logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: AppTokens.spacingMd),

              // Title section
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vibe Deck',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: AppTokens.weightSemibold,
                        color: AppTokens.getTextPrimary(theme.brightness),
                      ),
                    ),
                    Text(
                      'Desktop Host',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppTokens.getTextSecondary(theme.brightness),
                      ),
                    ),
                  ],
                ),
              ),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(
                    value: 0,
                    icon: Icon(Icons.dashboard_customize),
                    label: Text('Host'),
                  ),
                  ButtonSegment(
                    value: 1,
                    icon: Icon(Icons.grid_view),
                    label: Text('Deck Editor'),
                  ),
                  ButtonSegment(
                    value: 2,
                    icon: Icon(Icons.info_outline_rounded),
                    label: Text('About'),
                  ),
                ],
                selected: <int>{tabIndex},
                onSelectionChanged: (set) => onTabChanged(set.first),
              ),
              const SizedBox(width: AppTokens.spacingMd),

              // Language selector
              _LanguageSelector(currentLocale: locale),
            ],
          ),
        ),
      ),
    );
  }
}

/// Language selector dropdown
class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({required this.currentLocale});

  final Locale currentLocale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppI18n.of(context);

    return PopupMenuButton<Locale>(
      initialValue: currentLocale,
      tooltip: t.text('Language', 'Язык'),
      icon: Icon(
        Icons.language_rounded,
        color: AppTokens.getTextSecondary(theme.brightness),
      ),
      style: IconButton.styleFrom(
        backgroundColor: AppTokens.getSurfaceVariant(theme.brightness),
        padding: const EdgeInsets.all(AppTokens.spacingSm),
      ),
      position: PopupMenuPosition.under,
      offset: const Offset(0, 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      ),
      onSelected: (value) => context.read<LocaleController>().setLocale(value),
      itemBuilder: (context) => <PopupMenuEntry<Locale>>[
        PopupMenuItem<Locale>(
          value: Locale('en'),
          child: _LanguageMenuItemContent(
            label: 'English',
            isSelected: currentLocale.languageCode == 'en',
          ),
        ),
        PopupMenuItem<Locale>(
          value: Locale('ru'),
          child: _LanguageMenuItemContent(
            label: 'Русский',
            isSelected: currentLocale.languageCode == 'ru',
          ),
        ),
      ],
    );
  }
}

/// Language menu item content
class _LanguageMenuItemContent extends StatelessWidget {
  const _LanguageMenuItemContent({
    required this.label,
    required this.isSelected,
  });

  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected
                ? AppTokens.primary
                : AppTokens.getTextPrimary(theme.brightness),
            fontWeight: isSelected
                ? AppTokens.weightSemibold
                : AppTokens.weightRegular,
          ),
        ),
        const Spacer(),
        if (isSelected)
          Icon(Icons.check_rounded, size: 18, color: AppTokens.primary),
      ],
    );
  }
}
