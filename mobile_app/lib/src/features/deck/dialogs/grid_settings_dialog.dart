import 'package:flutter/material.dart';

import '../../../design/design_tokens.dart';
import '../../../i18n.dart';
import '../../../models/deck_models.dart';

class GridSettingsResult {
  const GridSettingsResult({
    required this.rows,
    required this.cols,
    required this.spacing,
    required this.autoAspectRatio,
    required this.manualRatio,
  });

  final int rows;
  final int cols;
  final double spacing;
  final bool autoAspectRatio;
  final double manualRatio;
}

class GridSettingsDialog extends StatefulWidget {
  const GridSettingsDialog({super.key, required this.profile});

  final DeckProfile profile;

  @override
  State<GridSettingsDialog> createState() => _GridSettingsDialogState();
}

class _GridSettingsDialogState extends State<GridSettingsDialog> {
  late final TextEditingController _rowsCtrl;
  late final TextEditingController _colsCtrl;
  late final TextEditingController _spacingCtrl;
  late final TextEditingController _ratioCtrl;
  late bool _autoAspectRatio;

  @override
  void initState() {
    super.initState();
    _rowsCtrl = TextEditingController(text: widget.profile.rows.toString());
    _colsCtrl = TextEditingController(text: widget.profile.cols.toString());
    _spacingCtrl = TextEditingController(
      text: widget.profile.cellSpacing.toStringAsFixed(1),
    );
    _ratioCtrl = TextEditingController(
      text: (widget.profile.buttonAspectRatio ?? 1.0).toStringAsFixed(2),
    );
    _autoAspectRatio = widget.profile.autoAspectRatio;
  }

  @override
  void dispose() {
    _rowsCtrl.dispose();
    _colsCtrl.dispose();
    _spacingCtrl.dispose();
    _ratioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppI18n.of(context);
    return AlertDialog(
      title: Text(t.text('Grid settings', 'Настройки сетки')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _rowsCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: t.text('Rows', 'Ряды')),
            ),
            TextField(
              controller: _colsCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: t.text('Columns', 'Столбцы'),
              ),
            ),
            TextField(
              controller: _spacingCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: t.text('Cell spacing', 'Расстояние между ячейками'),
                hintText: '0..48',
              ),
            ),
            const SizedBox(height: AppTokens.spacingSm),
            DropdownButtonFormField<String>(
              initialValue: _autoAspectRatio ? 'auto' : 'manual',
              decoration: InputDecoration(
                labelText: t.text(
                  'Button aspect ratio mode',
                  'Режим пропорций кнопки',
                ),
              ),
              items: <DropdownMenuItem<String>>[
                DropdownMenuItem(
                  value: 'auto',
                  child: Text(t.text('Auto', 'Авто')),
                ),
                DropdownMenuItem(
                  value: 'manual',
                  child: Text(t.text('Manual', 'Ручной')),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _autoAspectRatio = value == 'auto';
                });
              },
            ),
            if (!_autoAspectRatio)
              TextField(
                controller: _ratioCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: t.text(
                    'Manual ratio (width/height)',
                    'Ручная пропорция (ширина/высота)',
                  ),
                  hintText: '0.2..5.0',
                ),
              ),
            const SizedBox(height: AppTokens.spacingSm),
            Text(
              t.text(
                'Max buttons: $maxButtons. If capacity decreases, extra buttons will be hidden.',
                'Максимум кнопок: $maxButtons. Если вместимость уменьшится, лишние кнопки будут скрыты.',
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.text('Cancel', 'Отмена')),
        ),
        FilledButton(
          onPressed: () {
            final rows =
                int.tryParse(_rowsCtrl.text.trim()) ?? widget.profile.rows;
            final cols =
                int.tryParse(_colsCtrl.text.trim()) ?? widget.profile.cols;
            final spacing =
                double.tryParse(
                  _spacingCtrl.text.trim().replaceAll(',', '.'),
                ) ??
                widget.profile.cellSpacing;
            final manualRatio =
                double.tryParse(_ratioCtrl.text.trim().replaceAll(',', '.')) ??
                widget.profile.buttonAspectRatio ??
                1.0;
            Navigator.pop(
              context,
              GridSettingsResult(
                rows: rows,
                cols: cols,
                spacing: spacing,
                autoAspectRatio: _autoAspectRatio,
                manualRatio: manualRatio,
              ),
            );
          },
          child: Text(t.text('Apply', 'Применить')),
        ),
      ],
    );
  }
}
