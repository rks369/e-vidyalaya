import 'package:evidyalaya/core/widgets/app_logo.dart';
import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.school_rounded,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {

    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Column(
      children: [
        AppLogo(icon: icon),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 28),
      ],
    );

  }

}
