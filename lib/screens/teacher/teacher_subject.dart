import 'package:evidyalaya/bloc/auth_cubit.dart';
import 'package:evidyalaya/database/teacher_my_sql_helper.dart';
import 'package:evidyalaya/models/subject_model.dart';
import 'package:evidyalaya/screens/director/classes/subjects/notes.dart';
import 'package:evidyalaya/services/change_screen.dart';
import 'package:evidyalaya/widgets/error.dart';
import 'package:evidyalaya/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TeacherSubjects extends StatelessWidget {
  const TeacherSubjects({super.key});

  @override
  Widget build(BuildContext context) {
    final blocProvider = BlocProvider.of<AuthCubit>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Subjetcs',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: FutureBuilder(
          future: TeaherMySQLHelper.getSubjectList(
              blocProvider.domainName, blocProvider.userId),
          builder: (context, snapshot) {
            if (snapshot.hasError) return const ErrorScreen();
            if (!snapshot.hasData) {
              return const Loading();
            } else {
              List<SubjectModel> list = snapshot.data!;

              if (list.isEmpty) {
                return Center(
                  child: Text(
                    'No Subject Exists !!!',
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
                              context, Notes(subjectModel: list[index]));
                        },
                        leading: CircleAvatar(child: Text(list[index].name[0])),
                        title: Text(list[index].name),
                      ),
                    );
                  });
            }
          }),
    );
  }
}
