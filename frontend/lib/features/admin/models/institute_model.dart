class InstituteModel {

  final int id;
  final String code;
  final String name;
  final String domain;
  final String address;
  final String mobile;
  final String email;
  final String logo;

  InstituteModel({
    required this.id,
    required this.code,
    required this.name,
    required this.domain,
    required this.address,
    required this.mobile,
    required this.email,
    required this.logo,
  });

  factory InstituteModel.fromJson({required Map<String, dynamic> json}) => InstituteModel(
    id: json['id'],
    code: json['code'],
    name: json['name'],
    domain: json['domain'],
    address: json['address'],
    mobile: json['mobile'],
    email: json['email'],
    logo: json['logo'],
  );

}
