import 'package:evidyalaya/core/models/class_model.dart';
import 'package:evidyalaya/core/services/change_screen.dart';
import 'package:evidyalaya/core/widgets/adaptive_list.dart';
import 'package:evidyalaya/core/widgets/app_list_tile.dart';
import 'package:evidyalaya/core/widgets/empty_state.dart';
import 'package:evidyalaya/core/widgets/error.dart';
import 'package:evidyalaya/core/widgets/loading.dart';
import 'package:evidyalaya/features/director/screens/classes/director_class_subjects.dart';
import 'package:evidyalaya/features/teacher/services/teacher_service.dart';
import 'package:flutter/material.dart';

class TeacherClasses extends StatelessWidget {

  const TeacherClasses({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Classes'),
      ),
      body: FutureBuilder(
        future: TeacherService.getClassList(),
        builder: (context, snapshot) {

          if (snapshot.hasError) {
            return const ErrorScreen();
          }
          if (!snapshot.hasData) {
            return const Loading();
          } else {
            List<ClassModel> list = snapshot.data!;

            if (list.isEmpty) {
              return const EmptyState(
                message: 'No classes yet',
                icon: Icons.school_outlined,
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
                    onTap: () {

                      changeScreen(
                        context: context,
                        screen: DirectorClassSubjects(classId: list[index].id),
                      );

                    },
                    leading: const Icon(Icons.school),
                    title: Text(list[index].name),
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
