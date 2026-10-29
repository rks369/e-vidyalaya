import 'package:evidyalaya/core/widgets/auth_header.dart';
import 'package:evidyalaya/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class FullRow extends StatelessWidget {

  const FullRow({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) => child;

}

class ResponsiveFields extends StatelessWidget {

  const ResponsiveFields({
    super.key,
    required this.children,
    this.fieldWidth = 340,
    this.maxColumns = 3,
  });

  final List<Widget> children;
  final double fieldWidth;
  final int maxColumns;

  bool _spans(Widget child) =>
      child is AuthHeader || child is PrimaryButton || child is FullRow;

  bool _spacer(Widget child) => child is SizedBox && child.child == null;

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
      builder: (context, constraints) {

        const gap = 16.0;
        final columns = (constraints.maxWidth / fieldWidth).floor().clamp(1, maxColumns);
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final child in children)
              if (!_spacer(child))
                SizedBox(
                  width: _spans(child) ? constraints.maxWidth : width,
                  child: child is FullRow ? child.child : child,
                ),
          ],
        );

      },
    );

  }

}
