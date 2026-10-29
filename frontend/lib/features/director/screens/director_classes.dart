import 'package:evidyalaya/core/models/class_model.dart';
import 'package:evidyalaya/core/services/change_screen.dart';
import 'package:evidyalaya/core/widgets/adaptive_list.dart';
import 'package:evidyalaya/core/widgets/app_list_tile.dart';
import 'package:evidyalaya/core/widgets/dashboard_tile.dart';
import 'package:evidyalaya/core/widgets/empty_state.dart';
import 'package:evidyalaya/core/widgets/error.dart';
import 'package:evidyalaya/core/widgets/loading.dart';
import 'package:evidyalaya/features/director/screens/classes/director_add_class.dart';
import 'package:evidyalaya/features/director/screens/classes/director_class_students.dart';
import 'package:evidyalaya/features/director/screens/classes/director_class_subjects.dart';
import 'package:evidyalaya/features/director/services/director_service.dart';
import 'package:flutter/material.dart';

class DirectorClasses extends StatelessWidget {

  const DirectorClasses({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Classes'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {

          changeScreen(
            context: context,
            screen: const DirectorAddClass(),
          );

        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: DirectorService.getClassList(),
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

                      showModalBottomSheet(
                        context: context,
                        builder: (context) {

                          return SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                0,
                                16,
                                16,
                              ),
                              child: SizedBox(
                                height: 130,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: DashboardTile(
                                        icon: Icons.groups_outlined,
                                        title: 'Students',
                                        onTap: () {

                                          changeScreen(
                                            context: context,
                                            screen: DirectorClassStudents(
                                              classId: list[index].id,
                                            ),
                                          );

                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: DashboardTile(
                                        icon: Icons.menu_book_outlined,
                                        title: 'Subjects',
                                        onTap: () {

                                          changeScreen(
                                            context: context,
                                            screen: DirectorClassSubjects(
                                              classId: list[index].id,
                                            ),
                                          );

                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );

                        },
                      );

                    },
                    leading: const Icon(Icons.school_outlined),
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
