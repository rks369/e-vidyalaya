import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SpinKitFadingFour(
            size: 100, color: Theme.of(context).colorScheme.primary),
        const SizedBox(
          height: 10,
        ),
        Text(
          "Please Wait...",
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ],
    ));
  }
}
