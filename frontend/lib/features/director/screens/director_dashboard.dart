import 'package:evidyalaya/core/services/change_screen.dart';
import 'package:evidyalaya/core/widgets/dashboard_tile.dart';
import 'package:evidyalaya/core/widgets/responsive.dart';
import 'package:evidyalaya/features/chat/screens/chat_tabs.dart';
import 'package:evidyalaya/features/director/screens/director_classes.dart';
import 'package:evidyalaya/features/director/screens/director_students.dart';
import 'package:evidyalaya/features/director/screens/director_teachers.dart';
import 'package:flutter/material.dart';

class DirectorDashboard extends StatelessWidget {

  const DirectorDashboard({super.key});

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
              screen: const DirectorClasses(),
            );

          },
        ),
        DashboardTile(
          icon: Icons.person_outline_rounded,
          title: 'Teachers',
          onTap: () {

            changeScreen(
              context: context,
              screen: const DirectorTeachers(),
            );

          },
        ),
        DashboardTile(
          icon: Icons.groups_outlined,
          title: 'Students',
          onTap: () {

            changeScreen(
              context: context,
              screen: const DirectorStudents(),
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
