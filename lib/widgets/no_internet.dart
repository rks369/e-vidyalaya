import 'package:flutter/material.dart';

class NoInternet extends StatelessWidget {
  const NoInternet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.wifi_off_rounded,
          size: 75,
        ),
        const SizedBox(
          height: 25,
        ),
        Text(
          'You\'re Offline',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(
          height: 25,
        ),
        const Text(
          'Check Your Internet Connection',
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
