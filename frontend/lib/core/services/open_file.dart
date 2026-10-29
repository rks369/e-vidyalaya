import 'package:evidyalaya/core/utils/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openFile({
  required BuildContext context,
  required String url,
}) async {

  final opened = await launchUrl(
    Uri.parse(url),
    mode: LaunchMode.externalApplication,
  );
  if (!opened && context.mounted) {
    showErrorMessage(
      context: context,
      error: 'Could not open the file',
    );
  }

}
