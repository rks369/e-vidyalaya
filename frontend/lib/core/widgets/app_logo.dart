import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {

  const AppLogo({
    super.key,
    this.icon = Icons.school_rounded,
  });

  final IconData icon;

  @override
  Widget build(BuildContext context) {

    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        icon,
        size: 32,
        color: scheme.onPrimaryContainer,
      ),
    );

  }

}
