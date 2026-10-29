import 'package:evidyalaya/core/bloc/connection_cubit.dart';
import 'package:evidyalaya/core/utils/constants.dart';
import 'package:evidyalaya/core/widgets/error.dart';
import 'package:evidyalaya/core/widgets/info_page.dart';
import 'package:evidyalaya/core/widgets/loading.dart';
import 'package:evidyalaya/core/widgets/no_internet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PrivacyPolicy extends StatelessWidget {

  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy'),
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
              return InfoPage(
                content: privacyPolicy,
              );
          }

        },
      ),
    );

  }

}
