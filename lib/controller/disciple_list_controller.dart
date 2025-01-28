import 'dart:convert';

import 'package:http/http.dart' as http;

import '../controller/academy_controller.dart';
import '../model/disciple.dart';

class DiscipleListController {
  String domainName = AcademyController().getAcademyDomain();

  Future<List<Disciple>> fetchDiscipleListData() async {
    final response =
        await http.get(Uri.parse('$domainName/get_disciple_list.php'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData =
          json.decode(response.body) as Map<String, dynamic>;

      final List<dynamic> disciplesJson =
          jsonData['disciples'] as List<dynamic>;
      return disciplesJson
          .map((json) => Disciple.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load disciples');
    }
  }

  Future<List<Disciple>> fetchSearchedDiscipleListData(String query) async {
    final response = await http.get(
      Uri.parse(
          '$domainName/get_disciple_list_of_searched_query.php?search=$query'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData =
          json.decode(response.body) as Map<String, dynamic>;

      // Check if the 'disciples' key exists and is not null
      if (jsonData.containsKey('disciples') && jsonData['disciples'] != null) {
        final List<dynamic> disciplesJson =
            jsonData['disciples'] as List<dynamic>;

        // Map the JSON to a list of Disciple objects
        return disciplesJson
            .map((json) => Disciple.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        // If the 'disciples' key is not present or is null, return an empty list
        return [];
      }
    } else {
      throw Exception('Failed to load disciples');
    }
  }

  Future<List<int>> fetchPrivateIDs() async {
    final url = '${domainName}get_private_disciple_ids.php';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData =
          json.decode(response.body) as Map<String, dynamic>;

      // 'ids' anahtarının var olup olmadığını ve null olup olmadığını kontrol et
      if (jsonData.containsKey('ids') && jsonData['ids'] != null) {
        final List<int> privateIDs =
            (jsonData['ids'] as List<dynamic>).map((id) => id as int).toList();
        return privateIDs;
      } else {
        // Eğer 'ids' anahtarı yoksa ya da null ise, boş bir liste döndür
        return [];
      }
    } else {
      throw Exception('Failed to load private disciple IDs');
    }
  }
}
