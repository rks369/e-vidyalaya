import 'package:evidyalaya/core/models/user_model.dart';
import 'package:evidyalaya/core/services/change_screen.dart';
import 'package:evidyalaya/core/widgets/adaptive_list.dart';
import 'package:evidyalaya/core/widgets/app_list_tile.dart';
import 'package:evidyalaya/core/widgets/empty_state.dart';
import 'package:evidyalaya/core/widgets/error.dart';
import 'package:evidyalaya/core/widgets/loading.dart';
import 'package:evidyalaya/core/widgets/user_avatar.dart';
import 'package:evidyalaya/features/chat/screens/chat.dart';
import 'package:evidyalaya/features/director/services/director_service.dart';
import 'package:flutter/material.dart';

class DirectorChatTeachers extends StatelessWidget {

  const DirectorChatTeachers({super.key});

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: DirectorService.getTeachersList(),
      builder: (context, snapshot) {

        if (snapshot.hasError) {
          return const ErrorScreen();
        }
        if (!snapshot.hasData) {
          return const Loading();
        } else {
          List<UserModel> list = snapshot.data!;

          if (list.isEmpty) {
            return const EmptyState(
              message: 'No teachers yet',
              icon: Icons.person_outline_rounded,
            );
          }
          return AdaptiveList(
            itemCount: list.length,
            itemBuilder: (context, index) {

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: AppListTile(
                  leading: UserAvatar(
                    name: list[index].name,
                    url: list[index].profilePicture,
                  ),
                  title: Text(list[index].name),
                  onTap: () {

                    changeScreen(
                      context: context,
                      screen: Chat(userModel: list[index]),
                    );

                  },
                ),
              );

            },
          );
        }

      },
    );

  }

}
