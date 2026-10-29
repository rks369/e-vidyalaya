import 'package:flutter/material.dart';

class DashBoardTiles extends StatelessWidget {

  const DashBoardTiles({
    super.key,
    required this.icon,
    required this.title,
    required this.onPress,
  });

  final IconData icon;
  final String title;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {

    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        onTap: onPress,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );

  }

}
