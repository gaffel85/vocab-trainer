// lib/quiz_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'vocab_provider.dart';
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
  final List<String> _answers = [];
  final List<int> _attempts = [];
  int _hintLevel = 0;
  String _currentHint = '';
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    _initializeAttemptsAndAnswers();
  }

  void _initializeAttemptsAndAnswers() {
    final vocabProvider = Provider.of<VocabProvider>(context, listen: false);
    _attempts.clear();
    _answers.clear();
    for (var i = 0; i < vocabProvider.entries.length; i++) {
      _attempts.add(0);
      _answers.add('');
    }
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
      final normalizedAnswer = _normalize(_answerController.text);
      if (_normalize(currentEntry.english) == normalizedAnswer) {
        _score++;
      }
      _answers[_currentIndex] = _answerController.text;
      _attempts[_currentIndex] += 1;
      _goToNextQuestion();
    }
  }

  String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r"[^\w\s']"), '') // Remove non-alphanumeric characters except for spaces and apostrophes
        .replaceAll(RegExp(r"['‘’]"), "'") // Normalize apostrophes
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

    var indices = List<int>.generate(chars.length, (index) => index)..shuffle(random);
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
      if (_currentIndex < Provider.of<VocabProvider>(context, listen: false).entries.length - 1) {
        _currentIndex++;
        _hintLevel = 0;
        _showHint = false;
        _answerController.clear();
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(score: _score, attempts: _attempts),
          ),
        );
      }
    });
  }

  void _goToPreviousQuestion() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
        _hintLevel = 0;
        _showHint = false;
        _answerController.clear();
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
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text('${_currentIndex + 1}/${vocabProvider.entries.length}'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: vocabProvider.entries.length,
                itemBuilder: (context, index) {
                  if (index < _currentIndex - 5 || index > _currentIndex + 5) {
                    return Container();
                  }
                  final entry = vocabProvider.entries[index];
                  return ListTile(
                    dense: true,
                    title: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${entry.swedish} ',
                            style: TextStyle(color: Colors.black),
                          ),
                          TextSpan(
                            text: _getUserAnswer(index),
                            style: TextStyle(
                              color: _getEntryColor(index),
                            ),
                          ),
                        ],
                      ),
                    ),
                    subtitle: index == _currentIndex
                        ? TextField(
                      controller: _answerController,
                      autofocus: true,
                      onSubmitted: (_) => _checkAnswer(),
                      decoration: InputDecoration(
                        hintText: 'Type the English translation here',
                      ),
                    )
                        : Container(),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _goToPreviousQuestion,
                  child: Text('Back'),
                ),
                ElevatedButton(
                  onPressed: _provideHint,
                  child: Text('Hint'),
                ),
                ElevatedButton(
                  onPressed: _checkAnswer,
                  child: Text('Next'),
                ),
              ],
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

  Color _getEntryColor(int index) {
    if (_answers[index].isEmpty) {
      return Colors.black;
    } else if (_normalize(_answers[index]) == _normalize(Provider.of<VocabProvider>(context, listen: false).entries[index].english)) {
      return Colors.green;
    } else if (_attempts[index] == 1) {
      return Colors.red;
    } else if (_attempts[index] == 2) {
      return Colors.yellow;
    } else if (_attempts[index] == 3) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _getUserAnswer(int index) {
    if (_answers[index].isNotEmpty) {
      return _answers[index];
    } else {
      return '';
    }
  }
}
