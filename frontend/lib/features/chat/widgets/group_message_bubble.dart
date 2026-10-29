import 'package:evidyalaya/features/chat/widgets/message_bubble.dart';
import 'package:flutter/material.dart';

class GroupMessageBubble extends StatelessWidget {

  const GroupMessageBubble({
    super.key,
    required this.senderName,
    required this.text,
    required this.isMe,
  });

  final String senderName;
  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {

    return MessageBubble(
      text: text,
      isMe: isMe,
      senderName: senderName,
    );

  }

}
