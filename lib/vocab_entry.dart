// lib/vocab_entry.dart

// lib/vocab_entry.dart

class Result {
  final String answer;
  final bool isCorrect;
  final int hintsUsed;
  final int attempts;

  Result({
    required this.answer,
    required this.isCorrect,
    required this.hintsUsed,
    required this.attempts,
  });

  Result copyWith({
    String? answer,
    bool? isCorrect,
    int? hintsUsed,
    int? attempts,
  }) {
    return Result(
      answer: answer ?? this.answer,
      isCorrect: isCorrect ?? this.isCorrect,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      attempts: attempts ?? this.attempts,
    );
  }
}

class VocabEntry {
  final String swedish;
  final String english;
  final bool hasDash;
  List<Result> results;

  VocabEntry({
    required this.swedish,
    required this.english,
    this.hasDash = true,
    required this.results,
  });

  factory VocabEntry.fromJson(Map<String, dynamic> json) {
    return VocabEntry(
      swedish: json['swedish'],
      english: json['english'],
      hasDash: json['hasDash'],
      results: []
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'swedish': swedish,
      'english': english,
      'hasDash': hasDash,
    };
  }
}
