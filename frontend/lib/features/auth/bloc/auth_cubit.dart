import 'package:evidyalaya/core/api/api_client.dart';
import 'package:evidyalaya/core/models/user_model.dart';
import 'package:evidyalaya/core/services/chat_socket.dart';
import 'package:evidyalaya/features/auth/services/auth_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthState { init, loading, loggedIn, loggedOut, error }

class AuthCubit extends Cubit<AuthState> {

  UserModel? userModel;
  late String domainName;
  late int userId;

  AuthCubit() : super(AuthState.loading) {

    authCheck();
    emit(AuthState.loading);

  }
  
  void authCheck() async {

    final sharedPreferences = await SharedPreferences.getInstance();
    final token = sharedPreferences.getString('token') ?? '';
    domainName = sharedPreferences.getString('domainName') ?? '';
    if (!(sharedPreferences.getBool('loggedIn') ?? false) ||
        token.isEmpty ||
        domainName.isEmpty) {
      emit(AuthState.loggedOut);
      return;
    }

    ApiClient.instance.token = token;
    userId = sharedPreferences.getInt('id') ?? -1;
    try {
      userModel = await AuthService.getUser();
      emit(AuthState.loggedIn);
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        logout();
      } else {
        emit(AuthState.error);
      }
    }

  }

  void login({
    required UserModel userModel,
    required String domain,
  }) {

    SharedPreferences.getInstance().then((sharedPreferences) {

      sharedPreferences.setBool(
        'loggedIn',
        true,
      );
      sharedPreferences.setInt(
        'id',
        userModel.id,
      );
      sharedPreferences.setString(
        'domainName',
        domain,
      );
      sharedPreferences.setString(
        'token',
        ApiClient.instance.token ?? '',
      );

      this.userModel = userModel;
      userId = userModel.id;
      domainName = domain;
      emit(AuthState.loggedIn);
      return;

    });

  }

  void logout() async {

    ChatSocket.instance.disconnect();
    ApiClient.instance.token = null;
    SharedPreferences.getInstance().then((sharedPreferences) {

      sharedPreferences.setBool(
        'loggedIn',
        false,
      );
      sharedPreferences.setInt(
        'id',
        -1,
      );
      sharedPreferences.setString(
        'domainName',
        "",
      );
      sharedPreferences.setString(
        'token',
        "",
      );

      emit(AuthState.loggedOut);
      return;

    });

  }

}
