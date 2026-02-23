import 'package:flutter/material.dart';

import '../../../models/deck_models.dart';
import 'deck_button_card.dart';

class DeckGrid extends StatelessWidget {
  const DeckGrid({
    super.key,
    required this.profile,
    required this.enabled,
    this.transparentEmptyCells = false,
  });

  final DeckProfile profile;
  final bool enabled;
  final bool transparentEmptyCells;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = profile.cols;
        final rows = profile.rows;
        final spacing = profile.cellSpacing;
        final totalSpacingW = spacing * (cols - 1);
        final totalSpacingH = spacing * (rows - 1);
        final safeWidth = (constraints.maxWidth - totalSpacingW).clamp(
          1.0,
          double.infinity,
        );
        final safeHeight = (constraints.maxHeight - totalSpacingH).clamp(
          1.0,
          double.infinity,
        );
        final tileWidth = safeWidth / cols;
        final tileHeight = safeHeight / rows;
        final autoAspectRatio = tileWidth / tileHeight;
        final manualAspectRatio = profile.buttonAspectRatio;
        final childAspectRatio = profile.autoAspectRatio
            ? autoAspectRatio
            : (manualAspectRatio != null && manualAspectRatio > 0
                  ? manualAspectRatio
                  : autoAspectRatio);

        final buttonsByCell = <int, DeckButton>{
          for (final button in profile.buttons)
            if (button.cellIndex >= 0 && button.cellIndex < profile.capacity)
              button.cellIndex: button,
        };

        return GridView.builder(
          itemCount: profile.capacity,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
          ),
          itemBuilder: (context, index) {
            final button = buttonsByCell[index];
            if (button == null) {
              return _EmptyCell(transparent: transparentEmptyCells);
            }
            return DeckButtonCard(button: button, enabled: enabled);
          },
        );
      },
    );
  }
}

class _EmptyCell extends StatelessWidget {
  const _EmptyCell({required this.transparent});

  final bool transparent;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: transparent ? Colors.transparent : const Color(0x11000000),
      ),
      child: transparent ? const SizedBox.shrink() : const SizedBox.shrink(),
    );
  }
}
