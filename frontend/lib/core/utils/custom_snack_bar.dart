import 'dart:math' as math;

import 'package:flutter/material.dart';

const _maxWidth = 560.0;

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showErrorMessage({
  required BuildContext context,
  required String error,
}) {

  final scheme = Theme.of(context).colorScheme;

  return _show(
    context: context,
    text: error,
    background: scheme.errorContainer,
    foreground: scheme.onErrorContainer,
  );

}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSuccessMessage({
  required BuildContext context,
  required String message,
}) {

  final scheme = Theme.of(context).colorScheme;

  return _show(
    context: context,
    text: message,
    background: scheme.primaryContainer,
    foreground: scheme.onPrimaryContainer,
  );

}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _show({
  required BuildContext context,
  required String text,
  required Color background,
  required Color foreground,
}) {

  final width = math.min(
    _maxWidth,
    MediaQuery.sizeOf(context).width - 32,
  );

  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      width: width,
      backgroundColor: background,
      closeIconColor: foreground,
      content: Text(
        text,
        style: TextStyle(color: foreground),
      ),
    ),
  );

}
