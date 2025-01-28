import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../controller/user_controller.dart';
import '../model/trainer.dart';
import 'academy_controller.dart';

class TrainerController {
  int _trainerId;
  String domainName = AcademyController().getAcademyDomain();

  TrainerController({int trainerId = 5}) : _trainerId = trainerId;

  int getTrainerID() {
    return _trainerId;
  }

  Future<Trainer> fetchTrainerData() async {
    if (UserController().isUserAuthorized()) {
      _trainerId = UserController().getUserID();
    }

    final url = 'http://13.60.244.86/get_coach.php?coachId=$_trainerId';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final trainerData = data['coach'];
      _trainerId = trainerData['id'];

      return Trainer.fromJson(trainerData);
    } else {
      throw Exception('Failed to load player data');
    }
  }

  Future<Trainer> fetchNextTrainerData() async {
    final response = await http.get(
      Uri.parse('${domainName}get_next_coach.php?coachId=$_trainerId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final trainerData = data['coach'];
      _trainerId = trainerData['id'];

      return Trainer.fromJson(trainerData);
    } else {
      throw Exception('Failed to load player data');
    }
  }

  Future<Trainer> fetchPreviousTrainerData() async {
    final response = await http.get(
      Uri.parse('${domainName}get_previous_coach.php?coachId=$_trainerId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final trainerData = data['coach'];
      _trainerId = trainerData['id'];

      return Trainer.fromJson(trainerData);
    } else {
      throw Exception('Failed to load player data');
    }
  }

  Future<bool> changeInformation(
      int id, String propertyToChange, String newValue) async {
    try {
      // 4 saniyelik zaman aşımı kontrolü ekliyoruz
      final response = await http
          .get(
            Uri.parse(
              '${domainName}update_coach.php?coachId=$id&$propertyToChange=$newValue',
            ),
          )
          .timeout(const Duration(seconds: 4)); // 4 saniyelik zaman aşımı

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to load skill content data');
      }
    } on TimeoutException {
      return false;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> uploadProfilePhoto(File imageFile) async {
    // Fotoğrafı base64 formatına çevir
    List<int> imageBytes = await imageFile.readAsBytes();
    String base64Image = base64Encode(imageBytes);

    // API'ye POST isteği gönder
    String apiUrl = "${domainName}update_coach_profile_picture.php";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'coachId': _trainerId.toString(),
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
      throw Exception("Error: $e");
    }
  }

  Future<void> deleteProfilePhoto() async {
    final response = await http.get(Uri.parse(
        '${domainName}delete_coach_profile_picture.php?coachId=$_trainerId'));

    if (response.statusCode == 200) {
      // final List<dynamic> jsonData =
      // json.decode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to load disciple skills');
    }
  }
}
