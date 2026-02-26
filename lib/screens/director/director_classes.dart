import 'package:evidyalaya/bloc/auth_cubit.dart';
import 'package:evidyalaya/database/director_my_sql_helper.dart';
import 'package:evidyalaya/models/class_model.dart';
import 'package:evidyalaya/screens/director/classes/director_add_class.dart';
import 'package:evidyalaya/screens/director/classes/director_class_subjects.dart';
import 'package:evidyalaya/screens/director/classes/director_class_student.dart';
import 'package:evidyalaya/screens/director/director_dashboard.dart';
import 'package:evidyalaya/screens/teacher/teacher_students.dart';
import 'package:evidyalaya/services/change_screen.dart';
import 'package:evidyalaya/widgets/dashboard_tile.dart';
import 'package:evidyalaya/widgets/error.dart';
import 'package:evidyalaya/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DirectorClasses extends StatelessWidget {
  const DirectorClasses({super.key});

  @override
  Widget build(BuildContext context) {
    final String domain = BlocProvider.of<AuthCubit>(context).domainName;
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Classes',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          changeScreen(context, const DirectorAddClass());
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder(
          future: DirectorMySQLHelper.getClassList(domain),
          builder: (context, snapshot) {
            if (snapshot.hasError) return const ErrorScreen();
            if (!snapshot.hasData) {
              return const Loading();
            } else {
              List<ClassModel> list = snapshot.data!;

              if (list.isEmpty) {
                return Center(
                  child: Text(
                    'No Student Exists !!!',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                );
              }
              return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return Center(
                                  child: GridView.count(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 10.0,
                                    mainAxisSpacing: 10.0,
                                    children: [
                                      DashBoardTiles(
                                          imagePath: 'images/student.png',
                                          title: 'Students',
                                          onPress: () {
                                            changeScreen(
                                                context,
                                                DirectorClassStudents(
                                                  classId: list[index].id,
                                                ));
                                          }),
                                      DashBoardTiles(
                                          imagePath: 'images/clipboard.png',
                                          title: 'Subjects',
                                          onPress: () {
                                            changeScreen(
                                                context,
                                                DirectorClassSubjects(
                                                  classId: list[index].id,
                                                ));
                                          }),
                                    ],
                                  ),
                                );
                              });
                        },
                        leading: const Icon(Icons.school),
                        title: Text(list[index].name),
                      ),
                    );
                  });
            }
          }),
    );
  }
}
