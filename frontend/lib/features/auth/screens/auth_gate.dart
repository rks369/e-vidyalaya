import 'package:evidyalaya/core/bloc/connection_cubit.dart';
import 'package:evidyalaya/core/widgets/error.dart';
import 'package:evidyalaya/core/widgets/loading.dart';
import 'package:evidyalaya/core/widgets/no_internet.dart';
import 'package:evidyalaya/features/auth/bloc/auth_cubit.dart';
import 'package:evidyalaya/features/auth/screens/home.dart';
import 'package:evidyalaya/features/auth/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthGate extends StatelessWidget {

  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: BlocBuilder<ConnectionCubit, ConnectionStates>(
        builder: (context, state) {

          switch (state) {
            case ConnectionStates.checking:
              return const Loading();
            case ConnectionStates.notConnected:
              return NoInternet(onRetry: context.read<ConnectionCubit>().retry);

            case ConnectionStates.error:
              return ErrorScreen(
                onRetry: context.read<ConnectionCubit>().retry,
              );

            case ConnectionStates.connected:
              return BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {

                  switch (state) {
                    case AuthState.init:
                      return const Scaffold(body: Loading());
                    case AuthState.loading:
                      return const Scaffold(body: Loading());
                    case AuthState.loggedIn:
                      return const Home();
                    case AuthState.loggedOut:
                      return const Login();
                    case AuthState.error:
                      return Scaffold(
                        body: ErrorScreen(
                          onRetry: context.read<AuthCubit>().authCheck,
                        ),
                      );
                  }

                },
              );
          }

        },
      ),
    );

  }

}
