import 'package:flutter/material.dart';

void changeScreen({
  required BuildContext context,
  required Widget screen,
}) {

  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => screen),
  );

}

void changeScreenReplacement({
  required BuildContext context,
  required Widget screen,
}) {

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => screen),
  );

}
