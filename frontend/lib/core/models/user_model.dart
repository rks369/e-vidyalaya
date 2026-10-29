class UserModel {

  int id;
  String name;
  String email;
  String phone;
  String userName;
  String designation;
  String profilePicture;
  int currentClass;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.userName,
    required this.designation,
    required this.profilePicture,
    required this.currentClass,
  });

  factory UserModel.fromJson({required Map<String, dynamic> json}) => UserModel(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    phone: json['phone'],
    userName: json['username'],
    designation: json['designation'],
    profilePicture: json['profile_picture'],
    currentClass: json['current_class'],
  );

}
