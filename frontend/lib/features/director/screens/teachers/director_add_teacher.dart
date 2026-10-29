import 'package:evidyalaya/core/models/user_model.dart';
import 'package:evidyalaya/core/services/email_validator.dart';
import 'package:evidyalaya/core/services/show_progress_dialog.dart';
import 'package:evidyalaya/core/widgets/auth_header.dart';
import 'package:evidyalaya/core/widgets/primary_button.dart';
import 'package:evidyalaya/core/widgets/responsive_fields.dart';
import 'package:evidyalaya/features/auth/bloc/auth_cubit.dart';
import 'package:evidyalaya/features/director/services/director_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DirectorAddTeacher extends StatelessWidget {

  const DirectorAddTeacher({super.key});

  @override
  Widget build(BuildContext context) {

    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final String domain = BlocProvider.of<AuthCubit>(context).domainName;

    final TextEditingController name = TextEditingController();
    final TextEditingController id = TextEditingController();

    final TextEditingController email = TextEditingController();
    final TextEditingController mobile = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Add Teacher')),
      body: SingleChildScrollView(
        child: Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: ResponsiveFields(
                children: [
                  const SizedBox(
                    height: 50,
                    width: double.infinity,
                  ),
                  const AuthHeader(
                    title: 'Add Teacher',
                    subtitle: 'Enter Details to Add Teacher',
                  ),
                  TextFormField(
                    controller: name,
                    validator: (value) {

                      if (value!.isEmpty) {
                        return 'Please Enter Name';
                      } else if (value.length < 3) {
                        return 'Name Should be of 3 Character';
                      } else {
                        return null;
                      }

                    },
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: 'Enter Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: id,
                    validator: (value) {

                      if (value!.isEmpty) {
                        return 'Please Enter Id';
                      } else if (value.length < 3) {
                        return 'id Should be of 3 Character';
                      } else {
                        return null;
                      }

                    },
                    decoration: const InputDecoration(
                      labelText: 'ID',
                      hintText: 'Enter Id',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {

                      if (value!.isEmpty) {
                        return 'Please Enter A Email';
                      } else if (!EmailValidator.validate(email: value)) {
                        return 'Please Enter A Valid Email';
                      } else {
                        return null;
                      }

                    },
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      hintText: 'Enter E-mail',
                      prefixIcon: Icon(Icons.mail),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: mobile,
                    keyboardType: TextInputType.phone,
                    validator: (value) {

                      if (value!.isEmpty) {
                        return 'Please Enter Mobile Number';
                      } else if (value.length < 10) {
                        return 'Mobile Number Should be of 10 digits';
                      } else {
                        return null;
                      }

                    },
                    decoration: const InputDecoration(
                      labelText: 'Mobile',
                      hintText: 'Enter Mobile Number',
                      prefixIcon: Icon(Icons.smartphone),
                    ),
                  ),
                  const SizedBox(height: 10),
                  PrimaryButton(
                    onPressed: () async {

                      if (formKey.currentState!.validate()) {
                        showProgressDialog(context: context);
                        UserModel userModel = UserModel(
                          id: 0,
                          name: name.text,
                          email: email.text,
                          phone: mobile.text,
                          // ignore: prefer_interpolation_to_compose_strings
                          userName:
                              name.text.split(' ')[0] + id.text + '@' + domain,
                          designation: 'Teacher',
                          profilePicture: 'profilePicture',
                          currentClass: -1,
                        );

                        DirectorService.addteacher(
                          context: context,
                          userModel: userModel,
                        ).then(
                          (value) {

                            Navigator.pop(context);

                          },
                        );
                      }

                    },
                    child: const Text('Add teacher'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

  }

}
