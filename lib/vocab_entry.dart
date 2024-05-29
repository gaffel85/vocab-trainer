// lib/vocab_entry.dart

class VocabEntry {
  final String swedish;
  final String english;
  final bool hasDash;

  VocabEntry({required this.swedish, required this.english, required this.hasDash});

  factory VocabEntry.fromJson(Map<String, dynamic> json) {
    return VocabEntry(
      swedish: json['swedish'],
      english: json['english'],
      hasDash: json['hasDash'],
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
