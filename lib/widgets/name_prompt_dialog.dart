import 'package:flutter/material.dart';

/// Liste adı sorar; iptal edilirse `null` döner.
Future<String?> showNamePromptDialog(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  String? initialValue,
  String hint = 'Örn. Haftalık alışveriş',
}) {
  final controller = TextEditingController(text: initialValue);

  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(hintText: hint),
          onSubmitted: (value) {
            final trimmed = value.trim();
            if (trimmed.isNotEmpty) Navigator.of(context).pop(trimmed);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () {
              final trimmed = controller.text.trim();
              if (trimmed.isEmpty) return;
              Navigator.of(context).pop(trimmed);
            },
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  ).whenComplete(controller.dispose);
}
