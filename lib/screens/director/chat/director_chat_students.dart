import 'package:evidyalaya/bloc/auth_cubit.dart';
import 'package:evidyalaya/database/director_my_sql_helper.dart';
import 'package:evidyalaya/models/user_model.dart';
import 'package:evidyalaya/screens/director/chat/chat.dart';
import 'package:evidyalaya/services/change_screen.dart';
import 'package:evidyalaya/widgets/error.dart';
import 'package:evidyalaya/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DirectorChatStudents extends StatelessWidget {
  const DirectorChatStudents({super.key});

  @override
  Widget build(BuildContext context) {
    final blocProvider = BlocProvider.of<AuthCubit>(context);

    return FutureBuilder(
        future: DirectorMySQLHelper.getStudentList(blocProvider.domainName),
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
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage(list[index].profilePicture),
                      ),
                      title: Text(list[index].name),
                      onTap: () {
                        changeScreen(
                            context,
                            Chat(
                              userModel: list[index],
                            ));
                      },
                    ),
                  );
                });
          }
        });
  }
}
