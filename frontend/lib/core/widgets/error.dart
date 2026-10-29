import 'package:evidyalaya/core/widgets/status_view.dart';
import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {

  const ErrorScreen({
    super.key,
    this.onRetry,
  });

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {

    return StatusView(
      icon: Icons.error_outline_rounded,
      title: 'Something went wrong',
      message: 'Please try again after some time.',
      color: Theme.of(context).colorScheme.error,
      onRetry: onRetry,
    );

  }

}
