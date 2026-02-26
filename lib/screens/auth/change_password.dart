import 'dart:convert';

import 'package:evidyalaya/bloc/auth_cubit.dart';
import 'package:evidyalaya/bloc/connection_cubit.dart';
import 'package:evidyalaya/screens/auth/login.dart';
import 'package:evidyalaya/services/show_progress_dialog.dart';
import 'package:evidyalaya/utils/constant.dart';
import 'package:evidyalaya/utils/custom_snack_bar.dart';
import 'package:evidyalaya/utils/style.dart';
import 'package:evidyalaya/widgets/error.dart';
import 'package:evidyalaya/widgets/loading.dart';
import 'package:evidyalaya/widgets/no_internet.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mysql1/mysql1.dart';

class ChangePassword extends StatelessWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final blocProvider = BlocProvider.of<AuthCubit>(context);

    final GlobalKey<FormState> formkey = GlobalKey<FormState>();

    final TextEditingController currentPassword = TextEditingController();

    final TextEditingController typepass = TextEditingController();

    final TextEditingController retypepass = TextEditingController();
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Change Password')),
        body: Center(
          child: SingleChildScrollView(
            child: Card(
              margin: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: formkey,
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
                        'Change Password',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const Text(
                        'to Change Your Password',
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        controller: currentPassword,
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
                          hintText: 'Enter Current Password',
                          labelText: 'Current Password',
                        ),
                        keyboardType: TextInputType.visiblePassword,
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      TextFormField(
                        controller: typepass,
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
                          hintText: 'Enter New Password',
                          labelText: 'New Password',
                        ),
                        keyboardType: TextInputType.visiblePassword,
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      TextFormField(
                        controller: retypepass,
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
                          hintText: 'Re-Enter The Password',
                          labelText: 'Confirm Password',
                        ),
                        keyboardType: TextInputType.visiblePassword,
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      FilledElevatedButoon(
                        child: const Text('Change Password'),
                        onPressed: () {
                          if (formkey.currentState!.validate()) {
                            showProgressDialog(context);
                            final hmacSha256 =
                                Hmac(sha256, secretKey); // HMAC-SHA256
                            final currentPasswordDigest = hmacSha256
                                .convert(utf8.encode(currentPassword.text))
                                .toString();
                            MySqlConnection.connect(getConnctionSettings(
                                    blocProvider.domainName))
                                .then(
                              (conn) {
                                conn.query(
                                    'SELECT * FROM `users` WHERE id = ?;',
                                    [blocProvider.userId]).then((result) {
                                  if (result.isEmpty) {
                                    showErrorMessage(context, "No User Exits");
                                  } else if (result.first['password'] ==
                                      currentPasswordDigest) {
                                    final newPasswordDigest = hmacSha256
                                        .convert(utf8.encode(typepass.text))
                                        .toString();

                                    conn.query(
                                        'UPDATE `users` SET `password`=? WHERE id = ?',
                                        [
                                          newPasswordDigest,
                                          blocProvider.userId
                                        ]).then(
                                      (value) {
                                        if (value.insertId != null) {
                                          showSuccessMessage(context,
                                              'Password Changed Sucessfully!');
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        } else {
                                          showErrorMessage(
                                              context, 'Some Error Occured');
                                          Navigator.pop(context);
                                        }
                                      },
                                    ).onError((error, stackTrace) {
                                      showErrorMessage(
                                          context, "Some Error occured $error");
                                      Navigator.pop(context);
                                    });
                                  } else {
                                    showErrorMessage(
                                        context, "Current Password Is Wrong");
                                    Navigator.pop(context);
                                  }
                                }).onError((error, stackTrace) {
                                  showErrorMessage(
                                      context, "Some Error occured $error");
                                  Navigator.pop(context);
                                });
                              },
                            ).onError(
                              (error, stackTrace) {
                                showErrorMessage(
                                    context, "Some Error occured $error");
                                Navigator.pop(context);
                              },
                            );
                          }
                        },
                      ),
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
