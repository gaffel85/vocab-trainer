// lib/quiz_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'vocab_provider.dart';
import 'vocab_entry.dart';
import 'result_screen.dart';
import 'dart:math';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  final TextEditingController _answerController = TextEditingController();
  final List<int> _attempts = [];
  int _hintLevel = 0;
  String _currentHint = '';
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    _attempts.add(0);
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _checkAnswer() {
    final vocabProvider = Provider.of<VocabProvider>(context, listen: false);
    if (_currentIndex < vocabProvider.entries.length) {
      final currentEntry = vocabProvider.entries[_currentIndex];
      if (_normalize(currentEntry.english) == _normalize(_answerController.text)) {
        _score++;
        _attempts[_currentIndex] += 1;
        _goToNextQuestion();
      } else {
        _attempts[_currentIndex] += 1;
        _provideHint();
      }
    }
  }

  String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r"[^\w\s']"), '')  // Remove non-alphanumeric characters except for spaces and apostrophes
        .replaceAll(RegExp(r"['‘’]"), "'")   // Normalize apostrophes
        .trim();
  }

  void _generateHint() {
    final vocabProvider = Provider.of<VocabProvider>(context, listen: false);
    if (_currentIndex < vocabProvider.entries.length) {
      final currentEntry = vocabProvider.entries[_currentIndex];
      final normalizedAnswer = _normalize(currentEntry.english);
      switch (_hintLevel) {
        case 0:
          _currentHint = normalizedAnswer.replaceAll(RegExp(r'\w'), '*');
          break;
        case 1:
          _currentHint = _revealLetters(normalizedAnswer, 0.33);
          break;
        case 2:
          _currentHint = _revealLetters(normalizedAnswer, 0.66);
          break;
        case 3:
          _currentHint = currentEntry.english;
          break;
        default:
          _currentHint = currentEntry.english;
          break;
      }
    }
  }

  String _revealLetters(String input, double percentage) {
    final random = Random();
    final chars = input.split('');
    final numLettersToReveal = (chars.where((c) => RegExp(r'\w').hasMatch(c)).length * percentage).round();

    var indices = List<int>.generate(chars.length, (index) => index)
      ..shuffle(random);
    int revealed = 0;

    for (int i = 0; i < chars.length; i++) {
      if (RegExp(r'\w').hasMatch(chars[indices[i]]) && revealed < numLettersToReveal) {
        revealed++;
      } else if (chars[indices[i]] != ' ') {
        chars[indices[i]] = '*';
      }
    }

    return chars.join('');
  }

  void _goToNextQuestion() {
    setState(() {
      _currentIndex++;
      _hintLevel = 0;
      _showHint = false;
      if (_currentIndex >= Provider.of<VocabProvider>(context, listen: false).entries.length) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(score: _score, attempts: _attempts),
          ),
        );
      } else {
        _answerController.clear();
        _attempts.add(0);
      }
    });
  }

  void _provideHint() {
    setState(() {
      if (_hintLevel < 3) {
        _hintLevel++;
      }
      _showHint = true;
      _generateHint();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vocabProvider = Provider.of<VocabProvider>(context);
    if (_currentIndex >= vocabProvider.entries.length) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Quiz Completed'),
        ),
        body: Center(
          child: Text('Congratulations! You have completed the quiz.'),
        ),
      );
    }

    final currentEntry = vocabProvider.entries[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Score: $_score/${_currentIndex}',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Remaining: ${vocabProvider.entries.length - _currentIndex}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              currentEntry.swedish,
              style: TextStyle(fontSize: 24),
            ),
            TextField(
              controller: _answerController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Type the English translation here',
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _checkAnswer,
              child: Text('Continue'),
            ),
            SizedBox(height: 10),
            _showHint
                ? Text(
              _currentHint,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            )
                : Container(),
          ],
        ),
      ),
    );
  }
}
