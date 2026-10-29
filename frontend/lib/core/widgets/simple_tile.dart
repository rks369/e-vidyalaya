import 'package:flutter/material.dart';

class SimpleTile extends StatelessWidget {

  const SimpleTile({
    super.key,
    required this.title,
    required this.leading,
    required this.trailing,
    required this.onTap,
  });

  final String title;
  final Widget leading;
  final VoidCallback onTap;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {

    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
          child: leading,
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
          child: trailing,
        ),
      ),
    );

  }

}
