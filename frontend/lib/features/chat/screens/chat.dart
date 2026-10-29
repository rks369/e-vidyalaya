import 'package:evidyalaya/core/models/user_model.dart';
import 'package:evidyalaya/core/widgets/user_avatar.dart';
import 'package:evidyalaya/features/chat/services/chat_service.dart';
import 'package:evidyalaya/features/chat/widgets/chat_view.dart';
import 'package:flutter/material.dart';

class Chat extends StatelessWidget {

  final UserModel userModel;
  const Chat({
    super.key,
    required this.userModel,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            UserAvatar(
              name: userModel.name,
              url: userModel.profilePicture,
            ),
            const SizedBox(width: 12),
            Text(userModel.name),
          ],
        ),
      ),
      body: ChatView(
        kind: ChatKind.user,
        targetId: userModel.id,
      ),
    );

  }

}
