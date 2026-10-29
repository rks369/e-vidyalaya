import 'package:evidyalaya/core/services/change_screen.dart';
import 'package:evidyalaya/core/widgets/dashboard_tile.dart';
import 'package:evidyalaya/core/widgets/responsive.dart';
import 'package:evidyalaya/features/chat/screens/director_chat.dart';
import 'package:evidyalaya/features/director/screens/director_classes.dart';
import 'package:evidyalaya/features/director/screens/director_students.dart';
import 'package:evidyalaya/features/director/screens/director_teachers.dart';
import 'package:flutter/material.dart';

class DirectorDashBoard extends StatelessWidget {

  const DirectorDashBoard({super.key});

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
              screen: const DirectorClasses(),
            );

          },
        ),
        DashBoardTiles(
          icon: Icons.person_outline_rounded,
          title: 'Teachers',
          onPress: () {

            changeScreen(
              context: context,
              screen: const DirectorTeachers(),
            );

          },
        ),
        DashBoardTiles(
          icon: Icons.groups_outlined,
          title: 'Students',
          onPress: () {

            changeScreen(
              context: context,
              screen: const DirectorStudents(),
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
