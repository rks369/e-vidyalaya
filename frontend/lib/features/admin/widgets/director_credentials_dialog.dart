import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> showDirectorCredentialsDialog({
  required BuildContext context,
  required String userName,
  required String? emailedTo,
}) {

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text('Director credentials'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CredentialRow(
            label: 'User Id',
            value: userName,
          ),
          const SizedBox(height: 8),
          Text(
            emailedTo == null
                ? 'The password could not be emailed. Use "Forgot password" '
                      'once email works.'
                : 'The password was emailed to $emailedTo.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    ),
  );

}

class _CredentialRow extends StatelessWidget {

  const _CredentialRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              SelectableText(value),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Copy $label',
          icon: const Icon(Icons.copy),
          onPressed: () => Clipboard.setData(ClipboardData(text: value)),
        ),
      ],
    );

  }

}
