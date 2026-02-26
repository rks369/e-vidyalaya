import 'package:evidyalaya/bloc/auth_cubit.dart';
import 'package:evidyalaya/database/my_sql_helper.dart';
import 'package:evidyalaya/screens/auth/forgot_password.dart';
import 'package:evidyalaya/screens/home.dart';
import 'package:evidyalaya/services/change_screen.dart';
import 'package:evidyalaya/services/email_validator.dart';
import 'package:evidyalaya/utils/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    final blocProvider = BlocProvider.of<AuthCubit>(context);

    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController email = TextEditingController();
    final TextEditingController password = TextEditingController();
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Card(
              margin: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 50,
                        width: double.infinity,
                      ),
                      const Icon(
                        Icons.school_rounded,
                        size: 75,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'E-Vidyalaya ',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Sign In',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const Text(
                        'to Continue with E-Vidyalaya',
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        controller: email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please Enter A Email';
                          } else {
                            return null;
                          }
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter The User ID ...',
                          labelText: 'User ID',
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        controller: password,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please Enter Password';
                          } else if (value.length < 5) {
                            return 'Password Should be of 5 Character';
                          } else {
                            return null;
                          }
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter The Password ...',
                          labelText: 'Password',
                        ),
                        keyboardType: TextInputType.visiblePassword,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              changeScreen(context, const ResetPassword());
                            },
                            child: Text(
                              'Forgot Password ?',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      FilledElevatedButoon(
                        onPressed: () async {
                          showProgressDialog(context);
                          if (formKey.currentState!.validate()) {
                            String userId = email.text.toLowerCase();
                            String pass = password.text;

                            String domain = userId.split('@')[1].split('.')[0];
                            await MySQLHelper.domianExists(context, domain)
                                .then((result) {
                              if (result) {
                                MySQLHelper.login(context, userId, pass, domain)
                                    .then((userModel) {
                                  blocProvider.login(userModel!, domain);
                                  Navigator.pop(context);
                                  changeScreenReplacement(
                                      context, const Home());
                                }).onError((error, stackTrace) {
                                  showErrorMessage(context,
                                      'Soe=mething Went Wrong !$error');
                                });
                              } else {
                                showErrorMessage(context,
                                    'Please Enter A Valid Domian Name');
                              }
                            }).onError((error, stackTrace) {
                              showErrorMessage(
                                  context, 'Soe=mething Went Wrong !$error');
                            });
                          }
                        },
                        child: const Text(
                          'Login',
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FilledElevatedButoon extends StatelessWidget {
  const FilledElevatedButoon(
      {Key? key, required this.child, required this.onPressed})
      : super(key: key);
  final Widget child;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
      onPressed: onPressed,
      child: child,
    );
  }
}
