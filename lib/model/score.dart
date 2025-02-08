class Score {
  final int? skillID;
  final String name;
  final String? type;
  final int score;
  final int discipleID;
  String? resultScore;
  String? evaluationType;
  int? parentSkillID;
  int? maxValue;
  int? minValue;
  DateTime? date;

  Score({
    required this.name,
    required this.discipleID,
    required this.skillID,
    required this.score,
    this.evaluationType,
    this.resultScore,
    this.type,
    this.date,
    this.parentSkillID,
    this.maxValue,
    this.minValue,
  });

  Score copyWith({DateTime? date, int? score, String? name, int? discipleID}) {
    return Score(
      date: date ?? this.date,
      score: score ?? this.score,
      name: name ?? this.name,
      discipleID: discipleID ?? this.discipleID,
      skillID: skillID ?? this.skillID,
      type: type ?? this.type,
      evaluationType: evaluationType ?? this.evaluationType,
      parentSkillID: parentSkillID ?? this.parentSkillID,
      maxValue: maxValue ?? this.maxValue,
      minValue: minValue ?? this.minValue,
    );
  }

  factory Score.fromJson(
    Map<String, dynamic> json,
    int discipleID,
    String skillType,
  ) {
    return Score(
      skillID: json['id'] as int? ?? 0,
      name: (json['name'] ?? "Overall").toUpperCase(),
      discipleID: discipleID,
      type: skillType,
      score: (json['score'] ?? 0) as int,
      evaluationType: json['evaluation_type'] as String?,
      parentSkillID: json['parent_skill_id'] as int?,
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      maxValue: json['max_value'] as int?,
      minValue: json['min_value'] as int?,
    );
  }
}
