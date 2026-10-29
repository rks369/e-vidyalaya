import 'package:evidyalaya/core/models/user_model.dart';
import 'package:evidyalaya/core/services/change_screen.dart';
import 'package:evidyalaya/core/widgets/adaptive_list.dart';
import 'package:evidyalaya/core/widgets/app_list_tile.dart';
import 'package:evidyalaya/core/widgets/empty_state.dart';
import 'package:evidyalaya/core/widgets/error.dart';
import 'package:evidyalaya/core/widgets/loading.dart';
import 'package:evidyalaya/core/widgets/user_avatar.dart';
import 'package:evidyalaya/features/auth/screens/show_profile.dart';
import 'package:evidyalaya/features/director/screens/student/director_add_student.dart';
import 'package:evidyalaya/features/director/services/director_service.dart';
import 'package:flutter/material.dart';

class DirectorStudents extends StatelessWidget {

  const DirectorStudents({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {

          changeScreen(
            context: context,
            screen: const DirectorAddStudent(),
          );

        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: DirectorService.getStudentList(),
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
                message: 'No students yet',
                icon: Icons.groups_outlined,
              );
            }
            return AdaptiveList(
              padding: const EdgeInsets.only(bottom: 88),
              itemCount: list.length,
              itemBuilder: (context, index) {

                return GestureDetector(
                  onTap: () {

                    changeScreen(
                      context: context,
                      screen: ShowProfile(userModel: list[index]),
                    );

                  },
                  child: Padding(
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
                    ),
                  ),
                );

              },
            );
          }

        },
      ),
    );

  }

}
