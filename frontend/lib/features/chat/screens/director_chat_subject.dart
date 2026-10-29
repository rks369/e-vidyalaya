import 'package:evidyalaya/core/models/subject_model.dart';
import 'package:evidyalaya/core/services/change_screen.dart';
import 'package:evidyalaya/core/widgets/adaptive_list.dart';
import 'package:evidyalaya/core/widgets/app_list_tile.dart';
import 'package:evidyalaya/core/widgets/empty_state.dart';
import 'package:evidyalaya/core/widgets/error.dart';
import 'package:evidyalaya/core/widgets/loading.dart';
import 'package:evidyalaya/features/chat/screens/group_chat.dart';
import 'package:evidyalaya/features/chat/services/chat_service.dart';
import 'package:evidyalaya/features/director/services/director_service.dart';
import 'package:flutter/material.dart';

class DirectorChatSubjects extends StatelessWidget {

  const DirectorChatSubjects({super.key});

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: DirectorService.getAllSubjectList(),
      builder: (context, snapshot) {

        if (snapshot.hasError) {
          return const ErrorScreen();
        }
        if (!snapshot.hasData) {
          return const Loading();
        } else {
          List<SubjectModel> list = snapshot.data!;

          if (list.isEmpty) {
            return const EmptyState(
              message: 'No subjects yet',
              icon: Icons.menu_book_outlined,
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
                  leading: CircleAvatar(child: Text(list[index].name[0])),
                  subtitle: Text(list[index].className!),
                  title: Text(list[index].name),
                  onTap: () {

                    changeScreen(
                      context: context,
                      screen: GroupChat(
                        kind: ChatKind.subject,
                        groupName: list[index].name,
                        groupId: list[index].id,
                      ),
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
