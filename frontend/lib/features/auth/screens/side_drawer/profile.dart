import 'package:evidyalaya/core/bloc/connection_cubit.dart';
import 'package:evidyalaya/core/models/user_model.dart';
import 'package:evidyalaya/core/services/change_screen.dart';
import 'package:evidyalaya/core/widgets/error.dart';
import 'package:evidyalaya/core/widgets/loading.dart';
import 'package:evidyalaya/core/widgets/no_internet.dart';
import 'package:evidyalaya/core/widgets/profile_card.dart';
import 'package:evidyalaya/features/auth/bloc/auth_cubit.dart';
import 'package:evidyalaya/features/auth/screens/change_password.dart';
import 'package:evidyalaya/features/auth/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserProfile extends StatelessWidget {

  const UserProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final UserModel userModel = BlocProvider.of<AuthCubit>(context).userModel!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: BlocBuilder<ConnectionCubit, ConnectionStates>(
        builder: (context, state) {

          switch (state) {
            case ConnectionStates.checking:
              return const Loading();
            case ConnectionStates.notConnected:
              return const NoInternet();
            case ConnectionStates.error:
              return const ErrorScreen();
            case ConnectionStates.connected:
              return ProfileCard(
                name: userModel.name,
                url: userModel.profilePicture,
                role: userModel.designation,
                details: [
                  ProfileRow(
                    icon: Icons.person_outline_rounded,
                    label: 'User ID',
                    value: userModel.userName,
                  ),
                  ProfileRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: userModel.phone,
                  ),
                  ProfileRow(
                    icon: Icons.mail_outline_rounded,
                    label: 'E-mail',
                    value: userModel.email,
                  ),
                ],
                actions: [
                  ProfileAction(
                    icon: Icons.lock_reset_rounded,
                    label: 'Change password',
                    onTap: () {

                      changeScreen(
                        context: context,
                        screen: ChangePassword(),
                      );

                    },
                  ),
                  ProfileAction(
                    icon: Icons.logout_rounded,
                    label: 'Logout',
                    destructive: true,
                    onTap: () {

                      context.read<AuthCubit>().logout();
                      changeScreenReplacement(
                        context: context,
                        screen: const Login(),
                      );

                    },
                  ),
                ],
              );
          }

        },
      ),
    );

  }

}
