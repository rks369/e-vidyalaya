import 'package:evidyalaya/core/api/api_client.dart';
import 'package:evidyalaya/core/services/show_progress_dialog.dart';
import 'package:evidyalaya/core/utils/custom_snack_bar.dart';
import 'package:evidyalaya/core/widgets/auth_header.dart';
import 'package:evidyalaya/core/widgets/primary_button.dart';
import 'package:evidyalaya/core/widgets/responsive.dart';
import 'package:flutter/material.dart';

class ChangePassword extends StatelessWidget {

  const ChangePassword({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final GlobalKey<FormState> formkey = GlobalKey<FormState>();

    final TextEditingController currentPassword = TextEditingController();

    final TextEditingController typepass = TextEditingController();

    final TextEditingController retypepass = TextEditingController();
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Change Password')),
        body: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: Breakpoints.formWidth),
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
                        const AuthHeader(
                          title: 'Change Password',
                          subtitle: 'to Change Your Password',
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
                            hintText: 'Enter Current Password',
                            labelText: 'Current Password',
                          ),
                          keyboardType: TextInputType.visiblePassword,
                        ),
                        const SizedBox(height: 15.0),
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
                            hintText: 'Enter New Password',
                            labelText: 'New Password',
                          ),
                          keyboardType: TextInputType.visiblePassword,
                        ),
                        const SizedBox(height: 15.0),
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
                            hintText: 'Re-Enter The Password',
                            labelText: 'Confirm Password',
                          ),
                          keyboardType: TextInputType.visiblePassword,
                        ),
                        const SizedBox(height: 15.0),
                        PrimaryButton(
                          child: const Text('Change Password'),
                          onPressed: () async {

                            if (!formkey.currentState!.validate()) {
                              return;
                            }
                            showProgressDialog(context: context);
                            try {
                              await ApiClient.instance.post(
                                path: '/auth/change-password',
                                body: {
                                  'currentPassword': currentPassword.text,
                                  'newPassword': typepass.text,
                                },
                              );
                              if (!context.mounted) {
                                return;
                              }
                              showSuccessMessage(
                                context: context,
                                message: 'Password Changed Sucessfully!',
                              );
                              Navigator.pop(context);
                              Navigator.pop(context);
                            } on ApiException catch (e) {
                              if (!context.mounted) {
                                return;
                              }
                              showErrorMessage(
                                context: context,
                                error: e.message,
                              );
                              Navigator.pop(context);
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
      ),
    );

  }

}
