import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app_state.dart';
import '../../../design/design_tokens.dart';
import '../../../models/deck_models.dart';

class DeckButtonCard extends StatelessWidget {
  const DeckButtonCard({super.key, required this.button, required this.enabled});

  final DeckButton button;
  final bool enabled;

  LinearGradient _gradientFor(String key) {
    switch (key) {
      case 'sky':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF00C6FB), Color(0xFF005BEA)],
        );
      case 'green':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF11998E), Color(0xFF38EF7D)],
        );
      case 'mint':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF43E97B), Color(0xFF38F9D7)],
        );
      case 'red':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFFCB2D3E), Color(0xFFEF473A)],
        );
      case 'cherry':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFFEB3349), Color(0xFFF45C43)],
        );
      case 'orange':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFFF7971E), Color(0xFFFFD200)],
        );
      case 'sunset':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFFFC4A1A), Color(0xFFF7B733)],
        );
      case 'purple':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF7F00FF), Color(0xFFE100FF)],
        );
      case 'violet':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF4776E6), Color(0xFF8E54E9)],
        );
      case 'pink':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFFFF512F), Color(0xFFDD2476)],
        );
      case 'night':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF232526), Color(0xFF414345)],
        );
      default:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF396AFC), Color(0xFF2948FF)],
        );
    }
  }

  Color _contentColorFor(LinearGradient gradient) {
    final colors = gradient.colors;
    final avgRed =
        colors.map((c) => c.r).reduce((a, b) => a + b) / colors.length;
    final avgGreen =
        colors.map((c) => c.g).reduce((a, b) => a + b) / colors.length;
    final avgBlue =
        colors.map((c) => c.b).reduce((a, b) => a + b) / colors.length;
    final averageColor = Color.fromARGB(
      255,
      avgRed.round(),
      avgGreen.round(),
      avgBlue.round(),
    );
    final brightness = ThemeData.estimateBrightnessForColor(averageColor);
    return brightness == Brightness.dark
        ? Colors.white
        : const Color(0xFF111827);
  }

  IconData _iconFor(String key) {
    switch (key) {
      case 'terminal':
        return Icons.terminal;
      case 'keyboard_return':
        return Icons.keyboard_return;
      case 'code':
        return Icons.code;
      case 'paste':
        return Icons.content_paste;
      case 'play_arrow':
        return Icons.play_arrow;
      case 'pause':
        return Icons.pause;
      case 'stop':
        return Icons.stop;
      case 'skip_next':
        return Icons.skip_next;
      case 'volume_up':
        return Icons.volume_up;
      case 'mic':
        return Icons.mic;
      case 'camera':
        return Icons.camera_alt;
      case 'flash_on':
        return Icons.flash_on;
      case 'search':
        return Icons.search;
      case 'settings':
        return Icons.settings;
      case 'bolt':
        return Icons.bolt;
      case 'rocket_launch':
        return Icons.rocket_launch;
      case 'home':
        return Icons.home;
      case 'folder':
        return Icons.folder;
      case 'send':
        return Icons.send;
      default:
        return Icons.smart_button;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _gradientFor(button.bgStyle);
    final contentColor = _contentColorFor(gradient);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(gradient: gradient),
        child: InkWell(
          onTap: enabled ? () => context.read<MobileAppState>().trigger(button) : null,
          child: Padding(
            padding: const EdgeInsets.all(AppTokens.spacingSm),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 90;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      _iconFor(button.iconKey),
                      size: compact ? 18 : 24,
                      color: contentColor,
                    ),
                    const SizedBox(height: AppTokens.spacingXs),
                    Text(
                      button.label,
                      textAlign: TextAlign.center,
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          (compact
                                  ? Theme.of(context).textTheme.labelSmall
                                  : Theme.of(context).textTheme.bodyMedium)
                              ?.copyWith(
                                color: contentColor,
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                    if (!compact) ...<Widget>[
                      const SizedBox(height: AppTokens.spacingXs),
                      Text(
                        actionTypeToWire(button.action.type),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: contentColor.withValues(alpha: 0.92),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
