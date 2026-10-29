import 'package:evidyalaya/core/api/api_client.dart';
import 'package:evidyalaya/core/models/class_model.dart';
import 'package:evidyalaya/core/models/subject_model.dart';
import 'package:evidyalaya/core/models/user_model.dart';

class TeacherService {

  static Future<List<ClassModel>> getClassList() async {

    try {
      final rows = await ApiClient.instance.get(path: '/teacher/classes') as List;
      return rows
          .map(
            (row) => ClassModel(
              id: row['class_id'],
              name: row['class_name'],
              teacherId: row['class_teacher_id'],
            ),
          )
          .toList();
    } on ApiException {
      return [];
    }

  }

  static Future<List<SubjectModel>> getSubjectList() async {

    try {
      final rows = await ApiClient.instance.get(path: '/teacher/subjects') as List;
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
    } on ApiException {
      return [];
    }

  }

  static Future<List<UserModel>> getStudentList() async {

    try {
      final rows = await ApiClient.instance.get(path: '/teacher/students') as List;
      return rows.map((row) => UserModel.fromJson(json: row)).toList();
    } on ApiException {
      return [];
    }

  }

}
