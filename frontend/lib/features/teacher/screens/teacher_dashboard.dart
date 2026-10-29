import 'package:evidyalaya/core/services/change_screen.dart';
import 'package:evidyalaya/core/widgets/dashboard_tile.dart';
import 'package:evidyalaya/core/widgets/responsive.dart';
import 'package:evidyalaya/features/chat/screens/director_chat.dart';
import 'package:evidyalaya/features/teacher/screens/teacher_classes.dart';
import 'package:evidyalaya/features/teacher/screens/teacher_students.dart';
import 'package:evidyalaya/features/teacher/screens/teacher_subject.dart';
import 'package:flutter/material.dart';

class TeacherDashBoard extends StatelessWidget {

  const TeacherDashBoard({super.key});

  @override
  Widget build(BuildContext context) {

    return DashboardGrid(
      children: [
        DashBoardTiles(
          icon: Icons.school_outlined,
          title: 'Classes',
          onPress: () {

            changeScreen(
              context: context,
              screen: const TeacherClasses(),
            );

          },
        ),
        DashBoardTiles(
          icon: Icons.menu_book_outlined,
          title: 'Subjects',
          onPress: () {

            changeScreen(
              context: context,
              screen: const TeacherSubjects(),
            );

          },
        ),
        DashBoardTiles(
          icon: Icons.groups_outlined,
          title: 'Students',
          onPress: () {

            changeScreen(
              context: context,
              screen: const TeacherStudents(),
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
