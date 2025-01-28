class Disciple {
  final int id;
  final String name;
  final String surname;
  String? profilePicture;
  String? userName;
  String? password;
  String? age;
  int? overall;
  String? position;
  String? mail;
  String? phoneNumber;
  bool? private;

  Disciple({
    required this.id,
    required this.name,
    required this.surname,
    this.userName,
    this.password,
    this.age,
    this.overall,
    this.position,
    this.profilePicture,
    this.phoneNumber,
    this.mail,
    this.private,
  });
  // JSON'dan Disciple nesnesine dönüştürme fonksiyonu
  factory Disciple.fromJson(Map<String, dynamic> json) {
    return Disciple(
      id: json['id'],
      name: json['name'] ?? "-",
      surname: json['surname'] ?? "-",
      profilePicture: json['profile_picture'],
      userName: json['username'] ?? "-",
      password: json['password'] ?? "-",
      age: (json['age'] ?? "-").toString(),
      overall: json['overall'],
      position: json['position'] ?? "-",
      mail: json['mail'] ?? "-",
      phoneNumber: json['phone_number'] ?? "-",
      private: json['private'] == 1 ? true : false, // bool değere çevirme
    );
  }
}
