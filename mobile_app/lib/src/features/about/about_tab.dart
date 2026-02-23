import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../i18n.dart';

class AboutTab extends StatelessWidget {
  const AboutTab({super.key});

  static final Uri _projectUrl = Uri.parse(
    'https://github.com/vvadev/vibe-deck',
  );
  static final Uri _developerUrl = Uri.parse('https://github.com/vvadev');

  @override
  Widget build(BuildContext context) {
    final t = AppI18n.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(
          t.text('About Vibe Deck', 'О Vibe Deck'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Text(
          t.text(
            'Vibe Deck is a pair of desktop and mobile apps for controlling action decks over a local network.',
            'Vibe Deck — это пара desktop и mobile приложений для управления action-колодой по локальной сети.',
          ),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
        Card(
          child: ListTile(
            leading: const Icon(Icons.code_rounded),
            title: Text(t.text('Project on GitHub', 'Проект на GitHub')),
            subtitle: Text(_projectUrl.toString()),
            trailing: const Icon(Icons.open_in_new_rounded),
            onTap: () => _openLink(context, _projectUrl),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.person_rounded),
            title: Text(t.text('Developer: vvadev', 'Разработчик: vvadev')),
            subtitle: Text(_developerUrl.toString()),
            trailing: const Icon(Icons.open_in_new_rounded),
            onTap: () => _openLink(context, _developerUrl),
          ),
        ),
      ],
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
