import 'package:evidyalaya/core/widgets/loading.dart';
import 'package:flutter/material.dart';

showProgressDialog({required BuildContext context}) {

  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {

      return const Loading();

    },
  );

}
