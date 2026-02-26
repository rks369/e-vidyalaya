import 'package:flutter/material.dart';

class DashBoardTiles extends StatelessWidget {
  const DashBoardTiles(
      {Key? key,
      required this.imagePath,
      required this.title,
      required this.onPress})
      : super(key: key);

  final String imagePath;
  final String title;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: const BorderRadius.all(Radius.circular(25))),
        margin: const EdgeInsets.all(16),
        height: 50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset(
              imagePath,
              height: 100,
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge,
            )
          ],
        ),
      ),
    );
  }
}
