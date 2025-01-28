import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../controller/user_controller.dart';
import '../model/disciple.dart';
import '../model/score.dart';
import 'academy_controller.dart';

class DiscipleController {
  int _discipleID;
  String domainName = AcademyController().getAcademyDomain();

  DiscipleController(this._discipleID);

  int getDiscipleID() {
    // print("_playerID =  $_playerID");
    return _discipleID;
  }

  Future<Disciple> fetchPlayerData() async {
    final url = '${domainName}get_disciple.php?discipleId=$_discipleID';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      return Disciple.fromJson(data['disciple']);
    } else {
      throw Exception('Failed to load player data');
    }
  }

  Future<Disciple> fetchNextPlayerData() async {
    int? userID = UserController().getUserID();
    bool isUserCoach = UserController().isUserAuthorized();

    final response = await http.get(
      Uri.parse(
          '${domainName}get_next_disciple.php?discipleId=$_discipleID&userId=$userID&isUserCoach=$isUserCoach'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final discipleData = data['disciple'];
      _discipleID = discipleData['id'];

      return Disciple.fromJson(discipleData);
    } else {
      throw Exception('Failed to load player data');
    }
  }

  Future<Disciple> fetchPreviousPlayerData() async {
    int? userID = UserController().getUserID();
    bool isUserCoach = UserController().isUserAuthorized();
    // user coach değil ise ve api ye gönderdiğim id PreviousDisciple'ın id sine eşit değilse, PreviousDisciple' ın private olmamasını sağla
    final response = await http.get(
      Uri.parse(
          '${domainName}get_previous_disciple.php?discipleId=$_discipleID&userId=$userID&isUserCoach=$isUserCoach'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final discipleData = data['disciple'];
      _discipleID = discipleData['id'];

      return Disciple.fromJson(discipleData);
    } else {
      throw Exception('Failed to load player data');
    }
  }

  Future<List<Score>> fetchDiscipleSkillsData() async {
    String domainNameYedek = "http://16.16.25.238/";
    final response = await http.get(Uri.parse(
        '${domainNameYedek}main_skills_of_the_disciple.php?discipleId=$_discipleID'));
    // http://16.16.25.238/main_skills_of_the_disciple.php?discipleId=8
    if (response.statusCode == 200) {
      final List<dynamic> jsonData =
          json.decode(response.body) as List<dynamic>;

      if (jsonData.isEmpty) {
        // API boş liste dönerse varsayılan veriyi kullan
        return List.generate(
            6,
            (index) => Score.fromJson({
                  "name": "-",
                  "score": 0,
                }, _discipleID, "main skill"));
      }

      return jsonData.map((entry) {
        return Score.fromJson(
            entry as Map<String, dynamic>, _discipleID, "main skill");
      }).toList();
    } else {
      throw Exception('Failed to load disciple skills');
    }
  }

  Future<bool> changeInformation(
      int id, String propertyToChange, String newValue) async {
    try {
      // 4 saniyelik zaman aşımı kontrolü ekliyoruz
      final response = await http
          .get(
            Uri.parse(
              '${domainName}update_disciple.php?discipleId=$id&$propertyToChange=$newValue',
            ),
          )
          .timeout(const Duration(seconds: 4)); // 4 saniyelik zaman aşımı

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to load skill content data');
      }
    } on TimeoutException {
      // catch (e) {
      // print("Zaman aşımı gerçekleşti: $e");
      return false;
    } catch (e) {
      // print("Bir hata oluştu: $e");
      return false;
    }
  }

  Future<void> uploadProfilePhoto(File imageFile) async {
    // Fotoğrafı base64 formatına çevir
    List<int> imageBytes = await imageFile.readAsBytes();
    String base64Image = base64Encode(imageBytes);

    // API'ye POST isteği gönder
    String apiUrl = "${domainName}update_disciple_profile_picture.php";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'discipleId': _discipleID.toString(),
          'profilePicture': base64Image,
        },
      );

      if (response.statusCode == 200) {
        // JSON yanıtını çöz
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] != null) {
          // print("Profile picture uploaded successfully.");
        } else if (jsonResponse['error'] != null) {
          // print("Error: ${jsonResponse['error']}");
        }
      } else {
        // print(
        //     "Failed to upload the picture. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      // print("Error: $e");
    }
  }

  Future<void> deleteProfilePhoto() async {
    final response = await http.get(Uri.parse(
        '${domainName}delete_disciple_profile_picture.php?discipleId=$_discipleID'));

    if (response.statusCode == 200) {
      // print("silme işlemi başarılı");
      // final List<dynamic> jsonData =
      // json.decode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to Delete');
    }
  }
}
