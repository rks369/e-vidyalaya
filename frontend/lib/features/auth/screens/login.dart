import 'package:evidyalaya/core/services/change_screen.dart';
import 'package:evidyalaya/core/services/show_progress_dialog.dart';
import 'package:evidyalaya/core/widgets/auth_header.dart';
import 'package:evidyalaya/core/widgets/responsive.dart';
import 'package:evidyalaya/features/auth/bloc/auth_cubit.dart';
import 'package:evidyalaya/features/auth/screens/forgot_password.dart';
import 'package:evidyalaya/features/auth/screens/home.dart';
import 'package:evidyalaya/features/auth/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Login extends StatefulWidget {

  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();

}

class _LoginState extends State<Login> {

  final _formKey = GlobalKey<FormState>();
  final _userId = TextEditingController();
  final _password = TextEditingController();
  bool _hidePassword = true;

  @override
  void dispose() {

    _userId.dispose();
    _password.dispose();
    super.dispose();

  }

  Future<void> _submit() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final auth = context.read<AuthCubit>();
    final userId = _userId.text.trim().toLowerCase();

    showProgressDialog(context: context);
    final user = await AuthService.login(
      context: context,
      username: userId,
      password: _password.text,
    );
    if (!mounted) {
      return;
    }

    Navigator.pop(context);
    if (user == null) {
      return;
    }

    auth.login(
      userModel: user,
      domain: AuthService.domainOf(username: userId),
    );
    changeScreenReplacement(
      context: context,
      screen: const Home(),
    );

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
                title: 'Welcome back',
                subtitle: 'Sign in to continue to E-Vidyalaya',
              ),
              TextFormField(
                controller: _userId,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.username],
                validator: (value) {

                  final text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return 'Please Enter The User ID';
                  }
                  if (!text.contains('@')) {
                    return 'The User ID looks like name@school.evidyalaya.in';
                  }
                  return null;

                },
                decoration: const InputDecoration(
                  hintText: 'Enter The User ID ...',
                  labelText: 'User ID',
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _password,
                obscureText: _hidePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onFieldSubmitted: (_) => _submit(),
                validator: (value) {

                  if (value == null || value.isEmpty) {
                    return 'Please Enter Password';
                  }
                  return null;

                },
                decoration: InputDecoration(
                  hintText: 'Enter The Password ...',
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
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => changeScreen(
                    context: context,
                    screen: const ForgotPassword(),
                  ),
                  child: const Text('Forgot Password ?'),
                ),
              ),
              const SizedBox(height: 15),
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
