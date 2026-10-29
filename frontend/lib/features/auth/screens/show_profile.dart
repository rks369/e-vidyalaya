import 'package:evidyalaya/core/bloc/connection_cubit.dart';
import 'package:evidyalaya/core/models/user_model.dart';
import 'package:evidyalaya/core/widgets/error.dart';
import 'package:evidyalaya/core/widgets/loading.dart';
import 'package:evidyalaya/core/widgets/no_internet.dart';
import 'package:evidyalaya/core/widgets/profile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class ShowProfile extends StatelessWidget {

  final UserModel userModel;
  const ShowProfile({
    Key? key,
    required this.userModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

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
                    onTap: () async {

                      await launchUrl(
                        Uri(
                          scheme: 'tel',
                          path: userModel.phone,
                        ),
                      );

                    },
                  ),
                  ProfileRow(
                    icon: Icons.mail_outline_rounded,
                    label: 'E-mail',
                    value: userModel.email,
                    onTap: () async {

                      await launchUrl(
                        Uri(
                          scheme: 'mailto',
                          path: userModel.email,
                        ),
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
