import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {

  const InfoPage({
    super.key,
    required this.content,
    this.heading,
  });

  final String content;
  final String? heading;

  @override
  Widget build(BuildContext context) {

    final text = Theme.of(context).textTheme;
    final width = MediaQuery.sizeOf(context).width;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: width > 900 ? width * 0.14 : 24,
        vertical: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (heading != null) ...[
            Text(
              heading!,
              style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            content,
            style: text.bodyMedium?.copyWith(height: 1.6),
          ),
        ],
      ),
    );

  }

}
