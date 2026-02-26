import 'package:evidyalaya/bloc/auth_cubit.dart';
import 'package:evidyalaya/database/director_my_sql_helper.dart';
import 'package:evidyalaya/models/subject_model.dart';
import 'package:evidyalaya/screens/director/chat/group_chat.dart';
import 'package:evidyalaya/services/change_screen.dart';
import 'package:evidyalaya/widgets/error.dart';
import 'package:evidyalaya/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DirectorChatSubjects extends StatelessWidget {
  const DirectorChatSubjects({super.key});

  @override
  Widget build(BuildContext context) {
    final blocProvider = BlocProvider.of<AuthCubit>(context);

    return FutureBuilder(
        future: DirectorMySQLHelper.getAllSubjectList(blocProvider.domainName),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const ErrorScreen();
          if (!snapshot.hasData) {
            return const Loading();
          } else {
            List<SubjectModel> list = snapshot.data!;

            if (list.isEmpty) {
              return Center(
                child: Text(
                  'No Class Exists !!!',
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
                      leading: CircleAvatar(child: Text(list[index].name[0])),
                      subtitle: Text(list[index].className!),
                      title: Text(list[index].name),
                      onTap: () {
                        changeScreen(
                            context,
                            GroupChat(
                              chatType: 'classChat',
                              groupName: list[index].name,
                              groupId: list[index].id,
                            ));
                      },
                    ),
                  );
                });
          }
        });
  }
}
