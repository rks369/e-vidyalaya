import 'package:evidyalaya/features/chat/screens/chat_classes.dart';
import 'package:evidyalaya/features/chat/screens/chat_students.dart';
import 'package:evidyalaya/features/chat/screens/chat_subjects.dart';
import 'package:evidyalaya/features/chat/screens/chat_teachers.dart';
import 'package:flutter/material.dart';

class ChatTabs extends StatelessWidget {

  const ChatTabs({super.key});

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chat'),
          bottom: TabBar(
            tabs: const [
              Tab(
                icon: Icon(Icons.group),
                text: 'Classes',
              ),
              Tab(
                icon: Icon(Icons.class_),
                text: 'Subjects',
              ),
              Tab(
                icon: Icon(Icons.school),
                text: 'Teachers',
              ),
              Tab(
                icon: Icon(Icons.account_box_rounded),
                text: 'Students',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ChatClasses(),
            ChatSubjects(),
            ChatTeachers(),
            ChatStudents(),
          ],
        ),
      ),
    );

  }

}
