import 'package:evidyalaya/core/widgets/status_view.dart';
import 'package:flutter/material.dart';

class NoInternet extends StatelessWidget {

  const NoInternet({
    super.key,
    this.onRetry,
  });

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {

    return StatusView(
      icon: Icons.wifi_off_rounded,
      title: "You're offline",
      message: 'Check your internet connection.',
      onRetry: onRetry,
    );

  }

}
