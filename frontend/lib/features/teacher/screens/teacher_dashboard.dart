import 'package:evidyalaya/core/services/change_screen.dart';
import 'package:evidyalaya/core/widgets/dashboard_tile.dart';
import 'package:evidyalaya/core/widgets/responsive.dart';
import 'package:evidyalaya/features/chat/screens/chat_tabs.dart';
import 'package:evidyalaya/features/teacher/screens/teacher_classes.dart';
import 'package:evidyalaya/features/teacher/screens/teacher_students.dart';
import 'package:evidyalaya/features/teacher/screens/teacher_subjects.dart';
import 'package:flutter/material.dart';

class TeacherDashboard extends StatelessWidget {

  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {

    return DashboardGrid(
      children: [
        DashboardTile(
          icon: Icons.school_outlined,
          title: 'Classes',
          onTap: () {

            changeScreen(
              context: context,
              screen: const TeacherClasses(),
            );

          },
        ),
        DashboardTile(
          icon: Icons.menu_book_outlined,
          title: 'Subjects',
          onTap: () {

            changeScreen(
              context: context,
              screen: const TeacherSubjects(),
            );

          },
        ),
        DashboardTile(
          icon: Icons.groups_outlined,
          title: 'Students',
          onTap: () {

            changeScreen(
              context: context,
              screen: const TeacherStudents(),
            );

          },
        ),
        DashboardTile(
          icon: Icons.chat_bubble_outline_rounded,
          title: 'Chat',
          onTap: () {

            changeScreen(
              context: context,
              screen: const ChatTabs(),
            );

          },
        ),
      ],
    );

  }

}
