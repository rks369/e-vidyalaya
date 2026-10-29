import 'package:evidyalaya/core/api/api_client.dart';
import 'package:evidyalaya/core/services/show_progress_dialog.dart';
import 'package:evidyalaya/core/utils/custom_snack_bar.dart';
import 'package:evidyalaya/core/widgets/auth_header.dart';
import 'package:evidyalaya/core/widgets/responsive.dart';
import 'package:flutter/material.dart';

class ResetWithCode extends StatefulWidget {

  const ResetWithCode({
    super.key,
    required this.userName,
  });

  final String userName;

  @override
  State<ResetWithCode> createState() => _ResetWithCodeState();

}

class _ResetWithCodeState extends State<ResetWithCode> {

  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();

  @override
  void dispose() {

    _code.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();

  }

  Future<void> _reset() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    showProgressDialog(context: context);
    try {
      await ApiClient.instance.post(
        path: '/auth/reset-password',
        body: {
          'username': widget.userName,
          'code': _code.text.trim(),
          'newPassword': _password.text,
        },
      );
      if (!mounted) {
        return;
      }
      Navigator.pop(context);
      showSuccessMessage(
        context: context,
        message: 'Password changed. Please sign in.',
      );
      Navigator.pop(context);
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
            AuthHeader(
              title: 'Enter the code',
              subtitle: 'Check the email for ${widget.userName}. The code works once and expires in 15 minutes.',
              icon: Icons.lock_reset,
            ),
            TextFormField(
              controller: _code,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  (value ?? '').trim().isEmpty ? 'Please Enter The Code' : null,
              decoration: const InputDecoration(
                labelText: 'Reset code',
              ),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _password,
              obscureText: true,
              textInputAction: TextInputAction.next,
              validator: (value) => (value ?? '').length < 8
                  ? 'Password should be at least 8 characters'
                  : null,
              decoration: const InputDecoration(
                labelText: 'New password',
              ),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _confirmation,
              obscureText: true,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _reset(),
              validator: (value) =>
                  value != _password.text ? 'Passwords do not match' : null,
              decoration: const InputDecoration(
                labelText: 'Confirm password',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _reset,
                child: const Text('Change password'),
              ),
            ),
          ],
        ),
      ),
    );

  }

}
