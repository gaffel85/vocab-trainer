// lib/vocab_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'vocab_entry.dart';
import 'dart:convert';

class VocabProvider with ChangeNotifier {
  List<VocabEntry> _entries = [];

  List<VocabEntry> get entries => _entries;

  VocabProvider() {
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesString = prefs.getString('vocabEntries');
    if (entriesString != null) {
      final List<dynamic> jsonList = jsonDecode(entriesString);
      _entries = jsonList.map((json) => VocabEntry.fromJson(json)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _entries.map((entry) => entry.toJson()).toList();
    prefs.setString('vocabEntries', jsonEncode(jsonList));
  }

  void addEntries(String text, bool fromEnglish) {
    final lines = text.split('\n');
    for (var line in lines) {
      if (line.trim().isEmpty) continue;

      final parts = line.split(RegExp(r'\d+\.\s*'));
      if (parts.length > 1) {
        final entryText = parts[1].trim();
        final dashIndex = entryText.indexOf(' - ');

        if (dashIndex != -1) {
          final first = entryText.substring(0, dashIndex).trim();
          final second = entryText.substring(dashIndex + 3).trim();
          String english = first;
          String swedish = second;
          if (!fromEnglish) {
            english = second;
            swedish = first;
          }
          _entries.add(VocabEntry(swedish: swedish, english: english, hasDash: true, results: []));
        } else {
          final vocabParts = entryText.split(' ');
          final separatorIndex = vocabParts.length ~/ 2;
          final first = vocabParts.sublist(0, separatorIndex).join(' ');
          final second = vocabParts.sublist(separatorIndex).join(' ');
          String english = first;
          String swedish = second;
          if (!fromEnglish) {
            english = second;
            swedish = first;
          }
          _entries.add(VocabEntry(swedish: swedish.trim(), english: english.trim(), hasDash: false, results: []));
        }
      }
    }
    _saveEntries();
    notifyListeners();
  }

  void resetEntries() {
    _entries.clear();
    _saveEntries();
    notifyListeners();
  }

  void updateEntry(int index, VocabEntry newEntry) {
    if (index >= 0 && index < _entries.length) {
      _entries[index] = newEntry;
      _saveEntries();
      notifyListeners();
    }
  }

  void removeEntry(int index) {
    if (index >= 0 && index < _entries.length) {
      _entries.removeAt(index);
      _saveEntries();
      notifyListeners();
    }
  }

  void moveSeparatorLeft(int index) {
    if (index >= 0 && index < _entries.length) {
      final entry = _entries[index];
      final englishParts = entry.english.split(' ');
      final swedishParts = entry.swedish.split(' ');

      if (englishParts.length > 1) {
        final lastWordOfEnglish = englishParts.removeLast();
        swedishParts.insert(0, lastWordOfEnglish);
        _entries[index] = VocabEntry(
          swedish: swedishParts.join(' ').trim(),
          english: englishParts.join(' ').trim(),
          hasDash: true,
          results: entry.results, // Keep the existing results
        );
        _saveEntries();
        notifyListeners();
      }
    }
  }

  void moveSeparatorRight(int index) {
    if (index >= 0 && index < _entries.length) {
      final entry = _entries[index];
      final englishParts = entry.english.split(' ');
      final swedishParts = entry.swedish.split(' ');

      if (swedishParts.length > 1) {
        final firstWordOfSwedish = swedishParts.removeAt(0);
        englishParts.add(firstWordOfSwedish);
        _entries[index] = VocabEntry(
          swedish: swedishParts.join(' ').trim(),
          english: englishParts.join(' ').trim(),
          hasDash: true,
          results: entry.results, // Keep the existing results
        );
        _saveEntries();
        notifyListeners();
      }
    }
  }

  void addResult(int index, Result result) {
    if (index < _entries.length) {
      _entries[index].results.add(result);
      _saveEntries();
      notifyListeners();
    }
  }
}
