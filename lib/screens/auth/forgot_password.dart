import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:evidyalaya/database/my_sql_helper.dart';
import 'package:evidyalaya/screens/auth/login.dart';
import 'package:evidyalaya/services/change_screen.dart';
import 'package:evidyalaya/services/email_validator.dart';
import 'package:evidyalaya/services/random_pasword_generator.dart';
import 'package:evidyalaya/utils/constant.dart';
import 'package:evidyalaya/utils/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mysql1/mysql1.dart';

class ResetPassword extends StatelessWidget {
  const ResetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController userName = TextEditingController();
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Card(
              margin: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
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
                        'Reset Password',
                        style: Theme.of(context).textTheme.labelLarge,
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
                        controller: userName,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please Enter A Email';
                          } else if (!EmailValidator.validate(value)) {
                            return 'Please Enter A Valid Email';
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              changeScreen(context, const Login());
                            },
                            child: Text(
                              'Login',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                        ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                        onPressed: () async {
                          String userId = userName.text;

                          String domain = userId.split('@')[1].split('.')[0];
                          await MySQLHelper.domianExists(context, domain)
                              .then((result) {
                            if (result) {
                              MySqlConnection.connect(
                                      getConnctionSettings(domain))
                                  .then(
                                (conn) async {
                                  conn.query(
                                      'SELECT * FROM `users` WHERE users.username = ?;',
                                      [userId]).then(
                                    (result) {
                                      if (result.isEmpty) {
                                        showErrorMessage(
                                            context, "No User Exits");
                                      } else {
                                        showProgressDialog(context);
                                        String password =
                                            RandomPasswordGenerator()
                                                .randomPassword(
                                                    letters: true,
                                                    uppercase: true,
                                                    number: true,
                                                    passwordLength: 10);
                                        final hmacSha256 = Hmac(
                                            sha256, secretKey); // HMAC-SHA256
                                        final passwordDigest = hmacSha256
                                            .convert(utf8.encode(password))
                                            .toString();
                                        final message = Message()
                                          ..from = senderAdress
                                          ..recipients
                                              .add(result.first['email'])
                                          ..subject =
                                              'E-Vidyalaya Password Reset'
                                          ..text =
                                              'Welcome To E-vidyalaya Sync.\nPassword Reset For . \n\n\nUser Id  : ${userName.text}\nPassword : $password';

                                        showSuccessMessage(context,
                                            "Mail Send To ${result.first['email']}");
                                        send(message, smtpServer).whenComplete(
                                          () async {
                                            conn.query(
                                                'UPDATE `users` SET `password`=? WHERE username = ?;',
                                                [
                                                  passwordDigest,
                                                  userName.text
                                                ]).then(
                                              (value) {
                                                if (value.insertId != null) {
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                } else {
                                                  showErrorMessage(context,
                                                      'Some Error Occured');
                                                  Navigator.pop(context);
                                                }
                                              },
                                            ).onError((error, stackTrace) {
                                              showErrorMessage(context,
                                                  "Some Error occured $error");
                                              Navigator.pop(context);
                                            });
                                          },
                                        );
                                      }
                                    },
                                  );
                                },
                              ).onError(
                                (error, stackTrace) {
                                  showErrorMessage(
                                      context, "Some Error occured $error");
                                },
                              );
                            } else {
                              showErrorMessage(
                                  context, 'Please Enter A Valid Domian Name');
                            }
                          }).onError((error, stackTrace) {
                            showErrorMessage(
                                context, 'Soe=mething Went Wrong !$error');
                          });
                        },
                        child: const Text(
                          'Reset',
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
