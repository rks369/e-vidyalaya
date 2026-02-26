import 'package:evidyalaya/bloc/auth_cubit.dart';
import 'package:evidyalaya/database/teacher_my_sql_helper.dart';
import 'package:evidyalaya/models/class_model.dart';
import 'package:evidyalaya/screens/director/classes/director_class_subjects.dart';
import 'package:evidyalaya/services/change_screen.dart';
import 'package:evidyalaya/widgets/error.dart';
import 'package:evidyalaya/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TeacherClasses extends StatelessWidget {
  const TeacherClasses({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<AuthCubit>(context);
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
      body: FutureBuilder(
          future: TeaherMySQLHelper.getClassList(
              bloc.domainName, bloc.userModel!.id),
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
                          changeScreen(
                              context,
                              DirectorClassSubjects(
                                classId: list[index].id,
                              ));
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
