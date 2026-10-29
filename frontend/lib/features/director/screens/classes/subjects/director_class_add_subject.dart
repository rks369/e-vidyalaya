import 'package:evidyalaya/core/models/user_model.dart';
import 'package:evidyalaya/core/services/show_progress_dialog.dart';
import 'package:evidyalaya/core/widgets/auth_header.dart';
import 'package:evidyalaya/core/widgets/primary_button.dart';
import 'package:evidyalaya/core/widgets/responsive_fields.dart';
import 'package:evidyalaya/features/director/services/director_service.dart';
import 'package:flutter/material.dart';

class DirectorClassAddSubject extends StatefulWidget {

  final int classId;
  const DirectorClassAddSubject({
    super.key,
    required this.classId,
  });

  @override
  State<DirectorClassAddSubject> createState() => _DirectorClassAddSubject();

}

class _DirectorClassAddSubject extends State<DirectorClassAddSubject> {

  List<UserModel> teacherList = [];

  @override
  void initState() {

    setTeacherList();
    super.initState();

  }

  Future<void> setTeacherList() async {

    DirectorService.getTeacherList().then((value) {

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
      appBar: AppBar(title: const Text('Add Subject')),
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
                    title: 'Add Subject',
                    subtitle: 'Enter Details to Add Subject',
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
                      labelText: 'Subject Name',
                      hintText: 'Enter Subject Name',
                      prefixIcon: Icon(Icons.class_),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField(
                    decoration: const InputDecoration(
                      labelText: 'Subject Teacher',
                      hintText: 'Select Subject Teacher',
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
                        DirectorService.addSubject(
                          context: context,
                          classId: widget.classId,
                          subjectName: name.text,
                          teacher: classTeacher,
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
