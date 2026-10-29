import 'package:evidyalaya/core/widgets/responsive.dart';
import 'package:evidyalaya/core/widgets/user_avatar.dart';
import 'package:flutter/material.dart';

class ProfileRow {

  const ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

}

class ProfileAction {

  const ProfileAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

}

class ProfileCard extends StatelessWidget {

  const ProfileCard({
    super.key,
    required this.name,
    required this.url,
    required this.role,
    required this.details,
    this.actions = const [],
  });

  final String name;
  final String url;
  final String role;
  final List<ProfileRow> details;
  final List<ProfileAction> actions;

  @override
  Widget build(BuildContext context) {

    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Breakpoints.formWidth),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  UserAvatar(
                    name: name,
                    url: url,
                    radius: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role,
                    style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  for (final row in details)
                    ListTile(
                      onTap: row.onTap,
                      leading: Icon(
                        row.icon,
                        color: scheme.primary,
                      ),
                      title: Text(
                        row.label,
                        style: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                      subtitle: Text(
                        row.value,
                        style: text.bodyLarge,
                      ),
                    ),
                  if (actions.isNotEmpty) const Divider(),
                  for (final action in actions)
                    ListTile(
                      onTap: action.onTap,
                      leading: Icon(
                        action.icon,
                        color: action.destructive ? scheme.error : scheme.onSurfaceVariant,
                      ),
                      title: Text(
                        action.label,
                        style: TextStyle(color: action.destructive ? scheme.error : null),
                      ),
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

  }

}
