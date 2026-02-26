import 'package:evidyalaya/bloc/auth_cubit.dart';
import 'package:evidyalaya/database/director_my_sql_helper.dart';
import 'package:evidyalaya/models/user_model.dart';
import 'package:evidyalaya/screens/auth/login.dart';
import 'package:evidyalaya/services/email_validator.dart';
import 'package:evidyalaya/services/show_progress_dialog.dart';
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
      appBar: AppBar(
        title: const Text('Add Teacher'),
      ),
      body: SingleChildScrollView(
        child: Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: Column(
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
                    'Add Teacher',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text(
                    'Enter Details to Add Teacher',
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const SizedBox(
                    height: 10,
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
                      border: OutlineInputBorder(),
                      labelText: 'Name',
                      hintText: 'Enter Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
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
                      border: OutlineInputBorder(),
                      labelText: 'ID',
                      hintText: 'Enter Id',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: email,
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
                      labelText: 'E-mail',
                      hintText: 'Enter E-mail',
                      prefixIcon: Icon(Icons.mail),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
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
                      border: OutlineInputBorder(),
                      labelText: 'Mobile',
                      hintText: 'Enter Mobile Number',
                      prefixIcon: Icon(Icons.smartphone),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  FilledElevatedButoon(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        showProgressDialog(context);
                        UserModel userModel = UserModel(
                            id: 0,
                            name: name.text,
                            email: email.text,
                            phone: mobile.text,
                            // ignore: prefer_interpolation_to_compose_strings
                            userName: name.text.split(' ')[0] +
                                id.text +
                                '@' +
                                domain,
                            designation: 'Teacher',
                            profilePicture: 'profilePicture',
                            currentClass: -1);

                        DirectorMySQLHelper.addteacher(
                                context, userModel, domain)
                            .then((value) {
                          Navigator.pop(context);
                        });
                      }
                    },
                    child: const Text('Add teacher'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
