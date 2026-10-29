import 'package:evidyalaya/app.dart';
import 'package:evidyalaya/core/bloc/connection_cubit.dart';
import 'package:evidyalaya/features/auth/bloc/auth_cubit.dart';
import 'package:evidyalaya/features/auth/screens/auth_gate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final userModule = FlavorModule(
  providers: [
    BlocProvider<ConnectionCubit>(create: (context) => ConnectionCubit()),
    BlocProvider<AuthCubit>(create: (context) => AuthCubit()),
  ],
  routes: {'/': (_) => const AuthGate()},
);
