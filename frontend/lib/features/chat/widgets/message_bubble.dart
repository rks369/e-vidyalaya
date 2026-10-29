import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {

  const MessageBubble({
    super.key,
    required this.text,
    required this.isMe,
    this.senderName,
  });

  final String text;
  final bool isMe;
  final String? senderName;

  @override
  Widget build(BuildContext context) {

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    const round = Radius.circular(18);
    const tight = Radius.circular(4);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (senderName != null && !isMe)
            Padding(
              padding: const EdgeInsets.only(
                left: 4,
                bottom: 2,
              ),
              child: Text(
                senderName!,
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: isMe ? scheme.primary : scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.only(
                  topLeft: round,
                  topRight: round,
                  bottomLeft: isMe ? round : tight,
                  bottomRight: isMe ? tight : round,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Text(
                  text,
                  style: textTheme.bodyMedium?.copyWith(
                    color: isMe ? scheme.onPrimary : scheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

  }

}
