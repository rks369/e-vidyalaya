import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.error_outline_rounded,
          size: 75,
        ),
        const SizedBox(
          height: 25,
        ),
        Text(
          'Something Went Wrong',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(
          height: 25,
        ),
        const Text(
          'Something Went Wrong Please Try After Some Time !',
        ),
        const SizedBox(
          height: 25,
        ),
        ElevatedButton(
            onPressed: () {},
            child: const Text(
              'Try Again',
            ))
      ],
    ));
  }
}
