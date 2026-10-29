class SubjectModel {

  int id;
  int classId;
  String? className;
  String name;
  int teacherId;

  SubjectModel({
    required this.id,
    required this.classId,
    this.className,
    required this.name,
    required this.teacherId,
  });

}
