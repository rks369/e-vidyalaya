import 'package:evidyalaya/core/models/subject_model.dart';
import 'package:evidyalaya/core/services/change_screen.dart';
import 'package:evidyalaya/core/widgets/adaptive_list.dart';
import 'package:evidyalaya/core/widgets/app_list_tile.dart';
import 'package:evidyalaya/core/widgets/empty_state.dart';
import 'package:evidyalaya/core/widgets/error.dart';
import 'package:evidyalaya/core/widgets/loading.dart';
import 'package:evidyalaya/features/director/screens/classes/subjects/director_class_add_subject.dart';
import 'package:evidyalaya/features/director/screens/classes/subjects/notes.dart';
import 'package:evidyalaya/features/director/services/director_service.dart';
import 'package:flutter/material.dart';

class DirectorClassSubjects extends StatelessWidget {

  final int classId;
  const DirectorClassSubjects({
    super.key,
    required this.classId,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subjetcs'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {

          changeScreen(
            context: context,
            screen: DirectorClassAddSubject(classId: classId),
          );

        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: DirectorService.getSubjectList(classId: classId),
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
              padding: const EdgeInsets.only(bottom: 88),
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
                        screen: Notes(subjectModel: list[index]),
                      );

                    },
                    leading: CircleAvatar(child: Text(list[index].name[0])),
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
