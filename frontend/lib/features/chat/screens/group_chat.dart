import 'package:evidyalaya/features/chat/services/chat_service.dart';
import 'package:evidyalaya/features/chat/widgets/chat_view.dart';
import 'package:flutter/material.dart';

class GroupChat extends StatelessWidget {

  final ChatKind kind;
  final int groupId;
  final String groupName;
  const GroupChat({
    super.key,
    required this.kind,
    required this.groupId,
    required this.groupName,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.group),
            const SizedBox(width: 12),
            Text(groupName),
          ],
        ),
      ),
      body: ChatView(
        kind: kind,
        targetId: groupId,
      ),
    );

  }

}
