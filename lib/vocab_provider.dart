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

  void addEntries(String text) {
    final lines = text.split('\n');
    for (var line in lines) {
      if (line.trim().isEmpty) continue;

      final parts = line.split(RegExp(r'\d+\.\s*'));
      if (parts.length > 1) {
        final entryText = parts[1].trim();
        final dashIndex = entryText.indexOf(' - ');

        if (dashIndex != -1) {
          final english = entryText.substring(0, dashIndex).trim();
          final swedish = entryText.substring(dashIndex + 3).trim();
          _entries.add(VocabEntry(swedish: swedish, english: english, hasDash: true));
        } else {
          final vocabParts = entryText.split(' ');
          final separatorIndex = vocabParts.length ~/ 2;
          final englishPart = vocabParts.sublist(0, separatorIndex).join(' ');
          final swedishPart = vocabParts.sublist(separatorIndex).join(' ');
          _entries.add(VocabEntry(swedish: swedishPart.trim(), english: englishPart.trim(), hasDash: false));
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
        );
        _saveEntries();
        notifyListeners();
      }
    }
  }
}
