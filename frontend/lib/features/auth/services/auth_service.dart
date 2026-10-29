import 'package:evidyalaya/core/api/api_client.dart';
import 'package:evidyalaya/core/models/user_model.dart';
import 'package:evidyalaya/core/utils/custom_snack_bar.dart';
import 'package:flutter/cupertino.dart';

class AuthService {

  static String domainOf({required String username}) {

    final at = username.indexOf('@');
    return at < 0 ? '' : username.substring(at + 1).split('.').first;

  }

  static Future<UserModel?> login({
    required BuildContext context,
    required String username,
    required String password,
  }) async {

    try {
      final result = await ApiClient.instance.post(
        path: '/auth/login',
        body: {
          'username': username,
          'password': password,
        },
      );
      ApiClient.instance.token = result['token'];
      if (context.mounted) {
        showSuccessMessage(
          context: context,
          message: 'Login Successfully',
        );
      }
      return UserModel.fromJson(json: result['user']);
    } on ApiException catch (e) {
      if (context.mounted) {
        showErrorMessage(
          context: context,
          error: e.message,
        );
      }
      return null;
    }

  }

  static Future<UserModel> getUser() async {

    final result = await ApiClient.instance.get(path: '/auth/me');
    return UserModel.fromJson(json: result['user']);

  }

}
