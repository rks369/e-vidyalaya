import 'package:evidyalaya/core/api/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract final class AdminSession {

  static const _key = 'adminToken';

  static final signedIn = ValueNotifier<bool?>(null);

  static Future<void> restore() async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_key) ?? '';
    ApiClient.instance.token = token.isEmpty ? null : token;
    signedIn.value = token.isNotEmpty;

  }

  static Future<void> save({required String token}) async {

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      token,
    );
    ApiClient.instance.token = token;
    signedIn.value = true;

  }

  static Future<void> clear() async {

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    ApiClient.instance.token = null;
    signedIn.value = false;

  }

}
