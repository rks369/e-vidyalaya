import 'package:flutter/material.dart';

class AppListTile extends StatelessWidget {

  const AppListTile({
    super.key,
    required this.title,
    this.leading,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final Widget title;
  final Widget? leading;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {

    return Card(
      child: Center(
        child: ListTile(
          onTap: onTap,
          leading: leading,
          title: title,
          subtitle: subtitle,
          trailing: trailing ??
              (onTap == null
                  ? null
                  : Icon(
                      Icons.chevron_right_rounded,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )),
        ),
      ),
    );

  }

}
