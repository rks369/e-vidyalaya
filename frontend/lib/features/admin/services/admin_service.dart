import 'package:evidyalaya/core/api/api_client.dart';
import 'package:evidyalaya/core/utils/custom_snack_bar.dart';
import 'package:evidyalaya/features/admin/admin_session.dart';
import 'package:evidyalaya/features/admin/models/institute_model.dart';
import 'package:evidyalaya/features/admin/widgets/director_credentials_dialog.dart';
import 'package:flutter/cupertino.dart';

class AdminService {

  static Future<bool> login({
    required BuildContext context,
    required String username,
    required String password,
  }) async {

    try {
      final result = await ApiClient.instance.post(
        path: '/admin/login',
        body: {
          'username': username,
          'password': password,
        },
      );
      await AdminSession.save(token: result['token']);
      return true;
    } on ApiException catch (e) {
      if (context.mounted) {
        showErrorMessage(
          context: context,
          error: e.message,
        );
      }
      return false;
    }

  }

  static Future<void> addInstitute({
    required BuildContext context,
    required InstituteModel instituteModel,
  }) async {

    try {
      final result = await ApiClient.instance.post(
        path: '/admin/institutes',
        body: {
          'code': instituteModel.code,
          'name': instituteModel.name,
          'domain': instituteModel.domain,
          'address': instituteModel.address,
          'mobile': instituteModel.mobile,
          'email': instituteModel.email,
          'logo': instituteModel.logo,
        },
      );
      if (!context.mounted) {
        return;
      }
      Navigator.pop(context);
      await showDirectorCredentialsDialog(
        context: context,
        userName: result['userName'],
        emailedTo: result['emailed'] ? instituteModel.email : null,
      );

      if (!context.mounted) {
        return;
      }
      showSuccessMessage(
        context: context,
        message: 'Institute Added Successfully',
      );
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (!context.mounted) {
        return;
      }
      Navigator.pop(context);
      if (e.isUnauthorized) {
        await AdminSession.clear();
      }
      if (!context.mounted) {
        return;
      }
      showErrorMessage(
        context: context,
        error: e.message,
      );
    }

  }

  static Future<List<InstituteModel>> getInstitute() async {

    final rows = await ApiClient.instance.get(path: '/admin/institutes') as List;
    return rows.map((row) => InstituteModel.fromJson(json: row)).toList();

  }

}
