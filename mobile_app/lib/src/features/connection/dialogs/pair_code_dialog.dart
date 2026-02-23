import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> showPairCodeDialog({
  required BuildContext context,
  required TextEditingController controller,
  required Future<void> Function() onPair,
  required String title,
  required String labelText,
  required String cancelText,
  required String pairText,
}) async {
  await showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
        ],
        onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        decoration: InputDecoration(labelText: labelText),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(cancelText),
        ),
        FilledButton(
          onPressed: () async {
            Navigator.pop(context);
            await onPair();
          },
          child: Text(pairText),
        ),
      ],
    ),
  );
}
