import 'package:flutter/material.dart';

class AdaptiveList extends StatelessWidget {

  const AdaptiveList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
    this.extent = 72,
    this.columnWidth = 480,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry padding;
  final double extent;
  final double columnWidth;

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
      builder: (context, constraints) {

        final fits = (constraints.maxWidth / columnWidth).floor();
        final columns = fits.clamp(1, itemCount < 1 ? 1 : itemCount);

        return GridView.builder(
          padding: padding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisExtent: extent,
          ),
          itemCount: itemCount,
          itemBuilder: itemBuilder,
        );

      },
    );

  }

}
