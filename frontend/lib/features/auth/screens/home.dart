import 'package:evidyalaya/core/models/user_model.dart';
import 'package:evidyalaya/core/widgets/responsive.dart';
import 'package:evidyalaya/features/auth/bloc/auth_cubit.dart';
import 'package:evidyalaya/features/auth/widgets/side_drawer.dart';
import 'package:evidyalaya/features/director/screens/director_dashboard.dart';
import 'package:evidyalaya/features/student/screens/student_dashboard.dart';
import 'package:evidyalaya/features/teacher/screens/teacher_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Home extends StatelessWidget {

  const Home({super.key});

  Widget _dashboard({required UserModel user}) {

    return switch (user.designation.toUpperCase()) {
      'DIRECTOR' => const DirectorDashBoard(),
      'TEACHER' => const TeacherDashBoard(),
      'STUDENT' => const StudentDashBoard(),
      _ => const Center(child: Text('Your role has no dashboard')),
    };

  }

  @override
  Widget build(BuildContext context) {

    final user = BlocProvider.of<AuthCubit>(context).userModel!;
    final dashboard = _dashboard(user: user);

    return LayoutBuilder(
      builder: (context, constraints) {

        final wide = constraints.maxWidth >= Breakpoints.wide;

        return Scaffold(
          appBar: AppBar(
            title: const Text('E-Vidyalaya'),
            automaticallyImplyLeading: !wide,
          ),
          drawer: wide ? null : const SideDrawer(),
          body: wide
              ? Row(
                  children: [
                    const SizedBox(
                      width: 320,
                      child: SideDrawer(),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: dashboard),
                  ],
                )
              : dashboard,
        );

      },
    );

  }

}
