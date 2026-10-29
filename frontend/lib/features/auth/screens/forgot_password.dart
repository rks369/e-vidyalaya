import 'package:evidyalaya/core/api/api_client.dart';
import 'package:evidyalaya/core/services/change_screen.dart';
import 'package:evidyalaya/core/services/email_validator.dart';
import 'package:evidyalaya/core/services/show_progress_dialog.dart';
import 'package:evidyalaya/core/utils/custom_snack_bar.dart';
import 'package:evidyalaya/core/widgets/auth_header.dart';
import 'package:evidyalaya/core/widgets/responsive.dart';
import 'package:evidyalaya/features/auth/screens/reset_with_code.dart';
import 'package:flutter/material.dart';

class ResetPassword extends StatefulWidget {

  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();

}

class _ResetPasswordState extends State<ResetPassword> {

  final _formKey = GlobalKey<FormState>();
  final _userName = TextEditingController();

  @override
  void dispose() {

    _userName.dispose();
    super.dispose();

  }

  Future<void> _requestCode() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userName = _userName.text.trim().toLowerCase();

    showProgressDialog(context: context);
    try {
      await ApiClient.instance.post(
        path: '/auth/forgot-password',
        body: {
          'username': userName,
        },
      );
      if (!mounted) {
        return;
      }
      Navigator.pop(context);
      showSuccessMessage(
        context: context,
        message: 'If that user exists, a reset code was emailed',
      );
      changeScreenReplacement(
        context: context,
        screen: ResetWithCode(userName: userName),
      );
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      Navigator.pop(context);
      showErrorMessage(
        context: context,
        error: e.message,
      );
    }

  }

  @override
  Widget build(BuildContext context) {

    return AuthLayout(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AuthHeader(
              title: 'Reset Password',
              subtitle: 'We will email you a one-time code',
            ),
            TextFormField(
              controller: _userName,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _requestCode(),
              validator: (value) {

                final text = value?.trim() ?? '';
                if (text.isEmpty) {
                  return 'Please Enter The User ID';
                }
                if (!EmailValidator.validate(email: text)) {
                  return 'The User ID looks like name@school.evidalaya.in';
                }
                return null;

              },
              decoration: const InputDecoration(
                hintText: 'Enter The User ID ...',
                labelText: 'User ID',
              ),
            ),
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Login'),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _requestCode,
                child: const Text('Send code'),
              ),
            ),
          ],
        ),
      ),
    );

  }

}
