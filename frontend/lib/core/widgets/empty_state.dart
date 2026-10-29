import 'package:evidyalaya/core/widgets/status_view.dart';
import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {

  const EmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {

    return StatusView(
      icon: icon,
      title: message,
    );

  }

}
