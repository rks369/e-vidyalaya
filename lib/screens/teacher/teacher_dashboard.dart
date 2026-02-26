import 'package:evidyalaya/screens/director/director_chat.dart';
import 'package:evidyalaya/screens/teacher/teacher_classes.dart';
import 'package:evidyalaya/screens/teacher/teacher_students.dart';
import 'package:evidyalaya/screens/teacher/teacher_subject.dart';
import 'package:evidyalaya/services/change_screen.dart';
import 'package:flutter/material.dart';

class TeacherDashBoard extends StatelessWidget {
  const TeacherDashBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10.0,
      mainAxisSpacing: 10.0,
      children: [
        DashBoardTiles(
            imagePath: 'images/class.png',
            title: 'Classes',
            onPress: () {
              changeScreen(context, const TeacherClasses());
            }),
        DashBoardTiles(
            imagePath: 'images/clipboard.png',
            title: 'Subjects',
            onPress: () {
              changeScreen(context, const TeacherSubjects());
            }),
        DashBoardTiles(
            imagePath: 'images/student.png',
            title: 'Students',
            onPress: () {
              changeScreen(context, const TeacherStudents());
            }),
        DashBoardTiles(
            imagePath: 'images/chat.png',
            title: 'Chat',
            onPress: () {
              changeScreen(context, const DirectorChat());
            })
      ],
    );
  }
}

class DashBoardTiles extends StatelessWidget {
  const DashBoardTiles(
      {Key? key,
      required this.imagePath,
      required this.title,
      required this.onPress})
      : super(key: key);

  final String imagePath;
  final String title;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: const BorderRadius.all(Radius.circular(25))),
        margin: const EdgeInsets.all(16),
        height: 50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset(
              imagePath,
              height: 100,
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge,
            )
          ],
        ),
      ),
    );
  }
}
