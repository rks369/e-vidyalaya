import 'package:flutter/material.dart';

class SimpleTile extends StatelessWidget {

  const SimpleTile({
    super.key,
    required this.title,
    required this.firsticon,
    required this.lasticon,
    required this.ontap,
  });

  final String title;
  final Widget firsticon;
  final VoidCallback ontap;
  final Widget lasticon;

  @override
  Widget build(BuildContext context) {

    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        onTap: ontap,
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
          child: firsticon,
        ),
        title: Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconTheme(
          data: IconThemeData(
            size: 18,
            color: scheme.onSurfaceVariant,
          ),
          child: lasticon,
        ),
      ),
    );

  }

}
