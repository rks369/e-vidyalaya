import 'package:evidyalaya/bloc/auth_cubit.dart';
import 'package:evidyalaya/database/director_my_sql_helper.dart';
import 'package:evidyalaya/models/user_model.dart';
import 'package:evidyalaya/screens/auth/login.dart';
import 'package:evidyalaya/services/show_progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DirectorAddClass extends StatefulWidget {
  const DirectorAddClass({super.key});

  @override
  State<DirectorAddClass> createState() => _DirectorAddClassState();
}

class _DirectorAddClassState extends State<DirectorAddClass> {
  List<UserModel> teacherList = [];

  @override
  void initState() {
    setTeaherList();
    super.initState();
  }

  setTeaherList() async {
    final String domain = BlocProvider.of<AuthCubit>(context).domainName;

    DirectorMySQLHelper.getTeachersList(domain).then((value) {
      setState(() {
        teacherList = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    final TextEditingController name = TextEditingController();
    late UserModel classTeacher;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Class'),
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
                    'Create Class',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text(
                    'Enter Details to Create Class',
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
                      labelText: 'Class Name',
                      hintText: 'Enter Class Name',
                      prefixIcon: Icon(Icons.class_),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  DropdownButtonFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Class Teaher',
                        hintText: 'Select Class Teacher',
                        prefixIcon: Icon(Icons.person),
                      ),
                      items: teacherList.map((e) {
                        return DropdownMenuItem(value: e, child: Text(e.name));
                      }).toList(),
                      onChanged: (value) {
                        classTeacher = value!;
                      }),
                  const SizedBox(
                    height: 20,
                  ),
                  FilledElevatedButoon(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        showProgressDialog(context);
                        DirectorMySQLHelper.createClass(
                                context, name.text, classTeacher)
                            .whenComplete(() {
                          Navigator.pop(context);
                        });
                      }
                    },
                    child: const Text('Create Class'),
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
