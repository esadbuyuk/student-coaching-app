import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/score.dart';
import 'academy_controller.dart';

class ScoreController {
  // Main Skills can not be changed.
  // Must be 5 Main Skill
  String domainName = AcademyController().getAcademyDomain();

  ScoreController();

  // offense 1
  // defense 2
  // shoot 4
  // physical 5
  // dribble 6

  Future<List<Score>> fetchAllMainSkill() async {
    final response =
        await http.get(Uri.parse('$domainName/get_all_main_skill.php'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData =
          json.decode(response.body) as Map<String, dynamic>;

      // Check if 'skills' exists and is not null
      final List<dynamic>? subSkillsData = jsonData['skills'] as List<dynamic>?;

      if (subSkillsData != null) {
        return subSkillsData.map((jsonItem) {
          return Score.fromJson(
              jsonItem as Map<String, dynamic>, 0, 'main skill');
        }).toList();
      } else {
        // If 'sub_skills' is null, return an empty list
        return [];
      }
    } else {
      throw Exception('Failed to load skill content data');
    }
  }

  Future<List<Score>> fetchAllSubSkillOfMainSkill(int skillID) async {
    final response = await http.get(Uri.parse(
        '$domainName/get_all_sub_skill_of_main_skill.php?skillId=$skillID'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData =
          json.decode(response.body) as Map<String, dynamic>;

      // Check if 'sub_skills' exists and is not null
      final List<dynamic>? subSkillsData =
          jsonData['sub_skills'] as List<dynamic>?;

      if (subSkillsData != null) {
        return subSkillsData.map((jsonItem) {
          return Score.fromJson(
              jsonItem as Map<String, dynamic>, 0, 'sub skill');
        }).toList();
      } else {
        // If 'sub_skills' is null, return an empty list
        return [];
      }
    } else {
      throw Exception('Failed to load skill content data');
    }
  }

  Future<List<Score>> fetchSkillContentData(int discipleID, int skillID) async {
    // final response = await http.get(Uri.parse(
    //     '$domainName/sub_skills_of_the_disciple.php?discipleId=$discipleID&skillId=$skillID'));
    final response = await http.get(Uri.parse(
        '${domainName}sub_skills_of_the_disciple.php?discipleId=$discipleID&skillId=$skillID'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData =
          json.decode(response.body) as List<dynamic>;

      return jsonData.map((jsonItem) {
        return Score.fromJson(
            jsonItem as Map<String, dynamic>, discipleID, 'sub skill');
      }).toList();
    } else {
      throw Exception('Failed to load skill content data');
    }
  }

  Future<Map<String, List<Score>>> fetchMultiScoresWithDates(
      int discipleID) async {
    final response = await http.get(Uri.parse(
        '${domainName}get_scores_with_dates_of_all_main_skills.php?discipleId=$discipleID'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData =
          json.decode(response.body) as Map<String, dynamic>;

      // Initialize the result map.
      final Map<String, List<Score>> skillScores = {};

      jsonData.forEach((skill, scoresList) {
        if (scoresList is List) {
          skillScores[skill] = scoresList.map((scoreData) {
            return Score.fromJson(
                scoreData as Map<String, dynamic>, discipleID, "main skill");
          }).toList();
        }
      });

      return skillScores;
    } else {
      throw Exception('Failed to load skill scores data');
    }
  }

  Future<List<Score>> fetchOverallScoresWithDates(int discipleID) async {
    final response = await http.get(Uri.parse(
        '$domainName/get_overall_scores_with_dates.php?discipleId=$discipleID'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData =
          json.decode(response.body) as List<dynamic>;

      return jsonData.map((jsonItem) {
        return Score.fromJson(
          jsonItem as Map<String, dynamic>,
          discipleID,
          'overall',
        );
      }).toList();
    } else {
      throw Exception('Failed to load skill content data');
    }
  }

  Future<List<Score>> fetchSkillScoresWithDates(
      int discipleID, int skillID) async {
    final response = await http.get(Uri.parse(
        '$domainName/scores_with_dates_of_the_skill.php?discipleId=$discipleID&skillId=$skillID'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData =
          json.decode(response.body) as List<dynamic>;

      return jsonData.map((jsonItem) {
        return Score.fromJson(
          jsonItem as Map<String, dynamic>,
          discipleID,
          'main skill',
        );
      }).toList();
    } else {
      throw Exception('Failed to load skill content data');
    }
  }

  Future<bool> pushSkillScore(Score score) async {
    try {
      // 4 saniyelik zaman aşımı kontrolü ekliyoruz
      final response = await http
          .get(
            Uri.parse(
              '$domainName/fill_raw_test_results.php?discipleId=${score.discipleID}&subSkillId=${score.skillID}&rawScore=${score.resultScore}',
            ),
          )
          .timeout(const Duration(seconds: 4)); // 4 saniyelik zaman aşımı

      if (response.statusCode == 200) {
        // print(
        //     "Pushed: ${score.resultScore}, ${score.skillID}, ${score.discipleID}");
        return true;
      } else {
        throw Exception('Failed to load skill content data');
      }
    } on TimeoutException {
      // print("Zaman aşımı gerçekleşti: $e");
      return false;
    }
    // catch (e) {
    //   // print("Bir hata oluştu: $e");
    //   return false;
    // }
  }

  addNewSubSkill(double maxScoreofTheSubSkill) {}
}
