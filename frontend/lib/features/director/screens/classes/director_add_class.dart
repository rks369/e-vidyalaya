import 'package:evidyalaya/core/models/user_model.dart';
import 'package:evidyalaya/core/services/show_progress_dialog.dart';
import 'package:evidyalaya/core/widgets/auth_header.dart';
import 'package:evidyalaya/core/widgets/primary_button.dart';
import 'package:evidyalaya/core/widgets/responsive_fields.dart';
import 'package:evidyalaya/features/director/services/director_service.dart';
import 'package:flutter/material.dart';

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

    DirectorService.getTeachersList().then((value) {

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
      appBar: AppBar(title: const Text('Create Class')),
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
                    title: 'Create Class',
                    subtitle: 'Enter Details to Create Class',
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
                      labelText: 'Class Name',
                      hintText: 'Enter Class Name',
                      prefixIcon: Icon(Icons.class_),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField(
                    decoration: const InputDecoration(
                      labelText: 'Class Teaher',
                      hintText: 'Select Class Teacher',
                      prefixIcon: Icon(Icons.person),
                    ),
                    items: teacherList.map((e) {

                      return DropdownMenuItem(
                        value: e,
                        child: Text(e.name),
                      );

                    }).toList(),
                    onChanged: (value) {

                      classTeacher = value!;

                    },
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    onPressed: () async {

                      if (formKey.currentState!.validate()) {
                        showProgressDialog(context: context);
                        DirectorService.createClass(
                          context: context,
                          className: name.text,
                          tecaher: classTeacher,
                        ).whenComplete(() {

                          Navigator.pop(context);

                        });
                      }

                    },
                    child: const Text('Create Class'),
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
