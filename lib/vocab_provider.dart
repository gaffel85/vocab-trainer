// lib/vocab_provider.dart

import 'package:flutter/material.dart';
import 'vocab_entry.dart';

class VocabProvider with ChangeNotifier {
  List<VocabEntry> _entries = [];

  List<VocabEntry> get entries => _entries;

  void addEntries(String text) {
    final lines = text.split('\n');
    for (var line in lines) {
      if (line.trim().isEmpty) continue;

      final parts = line.split(RegExp(r'\d+\.\s*'));
      if (parts.length > 1) {
        final entryText = parts[1].trim();
        final dashIndex = entryText.indexOf(' - ');

        if (dashIndex != -1) {
          final swedish = entryText.substring(0, dashIndex).trim();
          final english = entryText.substring(dashIndex + 3).trim();
          _entries.add(VocabEntry(swedish: swedish, english: english, hasDash: true));
        } else {
          final vocabParts = entryText.split(' ');
          final separatorIndex = vocabParts.length ~/ 2;
          final swedishPart = vocabParts.sublist(0, separatorIndex).join(' ');
          final englishPart = vocabParts.sublist(separatorIndex).join(' ');
          _entries.add(VocabEntry(swedish: swedishPart.trim(), english: englishPart.trim(), hasDash: false));
        }
      }
    }
    notifyListeners();
  }

  void resetEntries() {
    _entries.clear();
    notifyListeners();
  }

  void updateEntry(int index, VocabEntry newEntry) {
    if (index >= 0 && index < _entries.length) {
      _entries[index] = newEntry;
      notifyListeners();
    }
  }

  void removeEntry(int index) {
    if (index >= 0 && index < _entries.length) {
      _entries.removeAt(index);
      notifyListeners();
    }
  }

  void moveSeparatorLeft(int index) {
    if (index >= 0 && index < _entries.length) {
      final entry = _entries[index];
      final parts = entry.english.split(' ');
      if (parts.length > 1) {
        final movedWord = parts.first;
        final newSwedish = '${entry.swedish} $movedWord';
        final newEnglish = parts.sublist(1).join(' ');
        _entries[index] = VocabEntry(swedish: newSwedish.trim(), english: newEnglish.trim(), hasDash: true);
        notifyListeners();
      }
    }
  }

  void moveSeparatorRight(int index) {
    if (index >= 0 && index < _entries.length) {
      final entry = _entries[index];
      final parts = entry.swedish.split(' ');
      if (parts.length > 1) {
        final movedWord = parts.last;
        final newSwedish = parts.sublist(0, parts.length - 1).join(' ');
        final newEnglish = '$movedWord ${entry.english}';
        _entries[index] = VocabEntry(swedish: newSwedish.trim(), english: newEnglish.trim(), hasDash: true);
        notifyListeners();
      }
    }
  }
}
