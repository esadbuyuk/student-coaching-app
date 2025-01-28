import 'dart:math';

import '../model/score.dart';

List<Score> generateOverallScores(int count) {
  List<Score> scores = [];
  Random random = Random();
  List<int> years = [2024, 2025, 2026, 2027];

  for (int i = 0; i < count; i++) {
    int randomYear = years[random.nextInt(years.length)];
    int randomScore = random.nextInt(101); // 0 ile 100 arasında bir sayı
    int randomDays = random.nextInt(365); // Seçilen yıl içindeki bir gün sayısı
    DateTime randomDate =
        DateTime(randomYear, 1, 1).add(Duration(days: randomDays));

    scores.add(
      Score(
        skillID: i + 1,
        discipleID: 1,
        name: 'OVERALL',
        type: 'overall',
        score: randomScore,
        date: randomDate,
      ),
    );
  }

  return filterScores(scores);
}

List<Score> generateSkillScores(int count) {
  List<Score> scores = [];
  Random random = Random();
  List<int> years = [2024, 2025, 2026, 2027];
  List<String> names = [
    "OFFENSE",
    "DEFENSE",
    "PASS",
    "SHOOT",
    "PHYSICAL",
    "DRIBBLE"
  ];

  for (int i = 0; i < count; i++) {
    int randomYear = years[random.nextInt(years.length)];
    String randomName = names[random.nextInt(names.length)];
    int randomScore = random.nextInt(101); // 0 ile 100 arasında bir sayı
    int randomDays = random.nextInt(365); // Seçilen yıl içindeki bir gün sayısı
    DateTime randomDate =
        DateTime(randomYear, 1, 1).add(Duration(days: randomDays));

    scores.add(
      Score(
        skillID: i + 1,
        discipleID: 1,
        name: randomName,
        type: 'main skill',
        score: randomScore,
        date: randomDate,
      ),
    );
  }

  return filterScores(scores);
}

List<Score> filterScores(List<Score> scores) {
  Map<String, Score> uniqueScores = {};

  for (Score score in scores) {
    String key = '${score.date!.year}-${score.date!.month}';
    if (!uniqueScores.containsKey(key)) {
      uniqueScores[key] = score;
    }
  }

  return uniqueScores.values.toList();
}
