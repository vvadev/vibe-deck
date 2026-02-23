import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../design/design_tokens.dart';
import '../../i18n.dart';

class AboutTab extends StatelessWidget {
  const AboutTab({super.key});

  static final Uri _projectUrl = Uri.parse(
    'https://github.com/vvadev/vibe-deck',
  );
  static final Uri _developerUrl = Uri.parse('https://github.com/vvadev');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppI18n.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Card(
          color: AppTokens.getSurface(theme.brightness),
          child: Padding(
            padding: const EdgeInsets.all(AppTokens.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  t.text('About Vibe Deck', 'О Vibe Deck'),
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: AppTokens.spacingMd),
                Text(
                  t.text(
                    'Vibe Deck is a pair of desktop and mobile apps for controlling action decks over a local network.',
                    'Vibe Deck — это пара desktop и mobile приложений для управления action-колодой по локальной сети.',
                  ),
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: AppTokens.spacingLg),
                _LinkTile(
                  icon: Icons.code_rounded,
                  title: t.text('Project on GitHub', 'Проект на GitHub'),
                  subtitle: _projectUrl.toString(),
                  onTap: () => _openLink(context, _projectUrl),
                ),
                const SizedBox(height: AppTokens.spacingSm),
                _LinkTile(
                  icon: Icons.person_rounded,
                  title: t.text('Developer: vvadev', 'Разработчик: vvadev'),
                  subtitle: _developerUrl.toString(),
                  onTap: () => _openLink(context, _developerUrl),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openLink(BuildContext context, Uri uri) async {
    final t = AppI18n.of(context);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (launched || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          t.text('Could not open link', 'Не удалось открыть ссылку'),
        ),
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.open_in_new_rounded),
      onTap: onTap,
    );
  }
}
