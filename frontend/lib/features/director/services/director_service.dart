import 'package:evidyalaya/core/api/api_client.dart';
import 'package:evidyalaya/core/models/class_model.dart';
import 'package:evidyalaya/core/models/notes_model.dart';
import 'package:evidyalaya/core/models/subject_model.dart';
import 'package:evidyalaya/core/models/user_model.dart';
import 'package:evidyalaya/core/utils/custom_snack_bar.dart';
import 'package:flutter/material.dart';

class DirectorService {

  static Future<List> _list({
    required String path,
    Map<String, String>? query,
  }) async {

    try {
      return await ApiClient.instance.get(
        path: path,
        query: query,
      ) as List;
    } on ApiException {
      return [];
    }

  }

  static Future<List<UserModel>> getStudentList() async {

    final rows = await _list(path: '/students');
    return rows.map((row) => UserModel.fromJson(json: row)).toList();

  }

  static Future<List<UserModel>> getStudentListOfClass({required int classId}) async {

    final rows = await _list(
      path: '/students',
      query: {'classId': '$classId'},
    );
    return rows.map((row) => UserModel.fromJson(json: row)).toList();

  }

  static Future<List<UserModel>> getTeacherList() async {

    final rows = await _list(path: '/teachers');
    return rows.map((row) => UserModel.fromJson(json: row)).toList();

  }

  static Future<List<ClassModel>> getClassList() async {

    final rows = await _list(path: '/classes');
    return rows
        .map(
          (row) => ClassModel(
            id: row['class_id'],
            name: row['class_name'],
            teacherId: row['class_teacher_id'],
          ),
        )
        .toList();

  }

  static Future<List<SubjectModel>> getSubjectList({required int classId}) async {

    final rows = await _list(path: '/classes/$classId/subjects');
    return rows
        .map(
          (row) => SubjectModel(
            id: row['subject_id'],
            classId: row['class_id'],
            name: row['subject_name'],
            teacherId: row['subject_teacher_id'],
          ),
        )
        .toList();

  }

  static Future<List<NotesModel>> getNoteList({required int subjectId}) async {

    final rows = await _list(path: '/subjects/$subjectId/notes');
    return rows
        .map(
          (row) => NotesModel(
            id: row['note_id'],
            title: row['note_title'],
            ext: row['note_ext'],
            url: row['note_url'],
          ),
        )
        .toList();

  }

  static Future<List<SubjectModel>> getAllSubjectList() async {

    final rows = await _list(path: '/subjects');
    return rows
        .map(
          (row) => SubjectModel(
            id: row['subject_id'],
            classId: row['class_id'],
            className: row['class_name'],
            name: row['subject_name'],
            teacherId: row['subject_teacher_id'],
          ),
        )
        .toList();

  }

  static Future<void> addClass({
    required BuildContext context,
    required String className,
    required UserModel teacher,
  }) async {

    try {
      await ApiClient.instance.post(
        path: '/classes',
        body: {
          'className': className,
          'teacherId': teacher.id,
        },
      );
      if (!context.mounted) {
        return;
      }
      showSuccessMessage(
        context: context,
        message: 'Class Created Successfully',
      );
      Navigator.pop(context);
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (context.mounted) {
        showErrorMessage(
          context: context,
          error: e.message,
        );
      }
    }

  }

  static Future<void> addSubject({
    required BuildContext context,
    required int classId,
    required String subjectName,
    required UserModel teacher,
  }) async {

    try {
      await ApiClient.instance.post(
        path: '/subjects',
        body: {
          'classId': classId,
          'subjectName': subjectName,
          'teacherId': teacher.id,
        },
      );
      if (!context.mounted) {
        return;
      }
      showSuccessMessage(
        context: context,
        message: 'Class Created Successfully',
      );
      Navigator.pop(context);
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (context.mounted) {
        showErrorMessage(
          context: context,
          error: e.message,
        );
      }
    }

  }

  static Future<void> addNote({
    required int subjectId,
    required String title,
    required String ext,
    required String url,
  }) => ApiClient.instance.post(
    path: '/notes',
    body: {
      'subjectId': subjectId,
      'title': title,
      'ext': ext,
      'url': url,
    },
  );

  static Future<void> addTeacher({
    required BuildContext context,
    required UserModel userModel,
  }) =>
      _addUser(
        context: context,
        path: '/teachers',
        label: 'Teacher',
        body: {
          'name': userModel.name,
          'email': userModel.email,
          'phone': userModel.phone,
          'userName': userModel.userName,
        },
      );

  static Future<void> addStudent({
    required BuildContext context,
    required UserModel userModel,
  }) =>
      _addUser(
        context: context,
        path: '/students',
        label: 'Student',
        body: {
          'name': userModel.name,
          'email': userModel.email,
          'phone': userModel.phone,
          'userName': userModel.userName,
          'currentClass': userModel.currentClass,
        },
      );

  static Future<void> _addUser({
    required BuildContext context,
    required String path,
    required String label,
    required Map<String, dynamic> body,
  }) async {

    try {
      final result = await ApiClient.instance.post(
        path: path,
        body: body,
      );
      if (!context.mounted) {
        return;
      }
      if (result['emailed'] == true) {
        showSuccessMessage(
          context: context,
          message: '$label Added Successfully',
        );
      } else {
        showErrorMessage(
          context: context,
          error: '$label added, but the password email failed. '
          'User Id: ${result['userName']}. They can use "Forgot password" '
          'once email works.',
        );
      }
      Navigator.pop(context);
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (context.mounted) {
        showErrorMessage(
          context: context,
          error: e.message,
        );
      }
    }

  }

}
