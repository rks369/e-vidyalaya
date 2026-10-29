import 'package:evidyalaya/core/services/show_progress_dialog.dart';
import 'package:evidyalaya/core/widgets/auth_header.dart';
import 'package:evidyalaya/core/widgets/responsive.dart';
import 'package:evidyalaya/features/admin/services/admin_service.dart';
import 'package:flutter/material.dart';

class AdminLogin extends StatefulWidget {

  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();

}

class _AdminLoginState extends State<AdminLogin> {

  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _hidePassword = true;

  @override
  void dispose() {

    _username.dispose();
    _password.dispose();
    super.dispose();

  }

  Future<void> _submit() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final navigator = Navigator.of(context);
    showProgressDialog(context: context);
    await AdminService.login(
      context: context,
      username: _username.text.trim().toLowerCase(),
      password: _password.text,
    );
    navigator.pop();

  }

  @override
  Widget build(BuildContext context) {

    return AuthLayout(
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AuthHeader(
                title: 'Admin sign in',
                subtitle: 'Manage institutes on E-Vidyalaya',
                icon: Icons.admin_panel_settings_outlined,
              ),
              TextFormField(
                controller: _username,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.username],
                validator: (value) => (value ?? '').trim().isEmpty
                    ? 'Please Enter The Username'
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Username',
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _password,
                obscureText: _hidePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onFieldSubmitted: (_) => _submit(),
                validator: (value) =>
                    (value ?? '').isEmpty ? 'Please Enter The Password' : null,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    tooltip: _hidePassword ? 'Show password' : 'Hide password',
                    icon: Icon(
                      _hidePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        setState(() => _hidePassword = !_hidePassword),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submit,
                  child: const Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }

}
