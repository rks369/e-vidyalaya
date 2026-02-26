import 'package:evidyalaya/bloc/auth_cubit.dart';
import 'package:evidyalaya/database/director_my_sql_helper.dart';
import 'package:evidyalaya/database/teacher_my_sql_helper.dart';
import 'package:evidyalaya/models/user_model.dart';
import 'package:evidyalaya/screens/director/student/director_add_student_to_class.dart';
import 'package:evidyalaya/screens/show_profile.dart';
import 'package:evidyalaya/screens/teacher/teacher_add_student.dart';
import 'package:evidyalaya/services/change_screen.dart';
import 'package:evidyalaya/widgets/error.dart';
import 'package:evidyalaya/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DirectorClassStudents extends StatelessWidget {
  final int classId;
  const DirectorClassStudents({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    final blocProvider = BlocProvider.of<AuthCubit>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Students',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          changeScreen(
              context,
              DirectorAddStudentToClass(
                currentClass: classId,
              ));
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder(
          future: DirectorMySQLHelper.getStudentListOfClass(
              blocProvider.domainName, classId),
          builder: (context, snapshot) {
            if (snapshot.hasError) return const ErrorScreen();
            if (!snapshot.hasData) {
              return const Loading();
            } else {
              List<UserModel> list = snapshot.data!;

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
                    return GestureDetector(
                      onTap: () {
                        changeScreen(
                            context, ShowProfile(userModel: list[index]));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(list[index].profilePicture),
                          ),
                          title: Text(list[index].name),
                        ),
                      ),
                    );
                  });
            }
          }),
    );
  }
}
