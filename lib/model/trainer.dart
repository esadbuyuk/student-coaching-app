
class Trainer {
  String name;
  String surname;
  int id;
  String? profilePicture;
  String? userName;
  String? password;
  String? age;
  String? position;
  String? mail;
  String? phoneNumber;

  Trainer({
    required this.name,
    required this.surname,
    required this.id,
    this.userName,
    this.password,
    this.age,
    this.position,
    this.profilePicture,
    this.mail,
    this.phoneNumber,
  });

  factory Trainer.fromJson(Map<String, dynamic> json) {
    return Trainer(
      id: json['id'],
      name: json['name'] ?? "-",
      surname: json['surname'] ?? "-",
      profilePicture: json['profile_picture'],
      userName: json['username'] ?? "-",
      password: json['password'] ?? "-",
      age: (json['age'] ?? "-").toString(),
      position: json['position'] ?? "-",
      phoneNumber: json['phone_number'] ?? "-",
    );
  }
}
