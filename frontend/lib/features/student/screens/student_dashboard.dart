import 'dart:developer';

import 'package:evidyalaya/core/services/change_screen.dart';
import 'package:evidyalaya/core/widgets/dashboard_tile.dart';
import 'package:evidyalaya/core/widgets/responsive.dart';
import 'package:evidyalaya/features/auth/bloc/auth_cubit.dart';
import 'package:evidyalaya/features/chat/screens/director_chat.dart';
import 'package:evidyalaya/features/student/screens/director_class_subjects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentDashBoard extends StatelessWidget {

  const StudentDashBoard({super.key});

  @override
  Widget build(BuildContext context) {

    final blocProvider = BlocProvider.of<AuthCubit>(context);
    return DashboardGrid(
      children: [
        DashBoardTiles(
          icon: Icons.menu_book_outlined,
          title: 'Subjects',
          onPress: () {

            log(blocProvider.userModel!.currentClass.toString());
            changeScreen(
              context: context,
              screen: StudentClassSubjects(
                classId: blocProvider.userModel!.currentClass,
              ),
            );

          },
        ),
        DashBoardTiles(
          icon: Icons.chat_bubble_outline_rounded,
          title: 'Chat',
          onPress: () {

            changeScreen(
              context: context,
              screen: const DirectorChat(),
            );

          },
        ),
      ],
    );

  }

}
