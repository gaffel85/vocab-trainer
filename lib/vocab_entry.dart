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

  int needsMorePracticeScore() {
    if (isCorrect && attempts == 1 && hintsUsed == 0) {
      return 0;
    } else if (attempts == 2) {
      return 1;
    } else if (hintsUsed == 1) {
      return 2;
    } else if (attempts == 3 || hintsUsed == 2) {
      return 3;
    } else if (attempts == 4) {
      return 4;
    } else if (hintsUsed == 3) {
      return 5;
    } else if (attempts > 4) {
      return 6;
    } else if (hintsUsed > 3) {
      return 7;
    } else {
      return 0; // In case none of the conditions match, although ideally this shouldn't happen
    }
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
        results: []);
  }

  Map<String, dynamic> toJson() {
    return {
      'swedish': swedish,
      'english': english,
      'hasDash': hasDash,
    };
  }

  int worstScoreOf2LastResults() {
    if (results.length == 1) {
      return results[0].needsMorePracticeScore();
    }
    if (results.length < 2) {
      return 0;
    }
    int score1 = results[results.length - 1].needsMorePracticeScore();
    int score2 = results[results.length - 2].needsMorePracticeScore();
    return score1 > score2 ? score1 : score2;
  }
}
