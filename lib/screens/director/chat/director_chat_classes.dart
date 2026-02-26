import 'package:evidyalaya/bloc/auth_cubit.dart';
import 'package:evidyalaya/database/director_my_sql_helper.dart';
import 'package:evidyalaya/models/class_model.dart';
import 'package:evidyalaya/screens/director/chat/group_chat.dart';
import 'package:evidyalaya/services/change_screen.dart';
import 'package:evidyalaya/widgets/error.dart';
import 'package:evidyalaya/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DirectorChatClasses extends StatelessWidget {
  const DirectorChatClasses({super.key});

  @override
  Widget build(BuildContext context) {
    final blocProvider = BlocProvider.of<AuthCubit>(context);

    return FutureBuilder(
        future: DirectorMySQLHelper.getClassList(blocProvider.domainName),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const ErrorScreen();
          if (!snapshot.hasData) {
            return const Loading();
          } else {
            List<ClassModel> list = snapshot.data!;

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
                      leading: const Icon(Icons.group),
                      title: Text(list[index].name),
                      onTap: () {
                        changeScreen(
                            context,
                            GroupChat(
                              chatType: 'subjectChat',
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
