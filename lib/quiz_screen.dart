// lib/quiz_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vocab_trainer/vocab_entry.dart';
import 'vocab_provider.dart';
import 'result_screen.dart';
import 'dart:math';

class QuizScreen extends StatefulWidget {
  final List<int>? indexes;

  QuizScreen({this.indexes});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentLineIndex = 0;
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<ResultWithIndex> _results = [];
  String _currentHint = '';
  bool _showHint = false;

  @override
  void initState() {
    super.initState();

    final vocabProvider = Provider.of<VocabProvider>(context, listen: false);

    List<int> quizIndexes = [];
    if (widget.indexes != null && widget.indexes!.isNotEmpty) {
      quizIndexes = widget.indexes!;
    } else {
      quizIndexes = List<int>.generate(vocabProvider.entries.length, (index) => index);
    }
    _initializeResults(quizIndexes);
  }

  void _initializeResults(List<int> quizIndexes) {
    final vocabProvider = Provider.of<VocabProvider>(context, listen: false);
    _results.clear();
    for (var i = 0; i < vocabProvider.entries.length; i++) {
      if (quizIndexes.contains(i)) {
        _results.add(ResultWithIndex(index: i, result: Result(answer: '', isCorrect: false, hintsUsed: 0, attempts: 0)));
      }
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _checkAnswer() {
    final vocabProvider = Provider.of<VocabProvider>(context, listen: false);
    final currentIndex = getVocabIndex();
    if (currentIndex < vocabProvider.entries.length) {
      final currentEntry = vocabProvider.entries[currentIndex];
      final normalizedAnswer = _normalize(_answerController.text);

      if (_normalize(currentEntry.english) == normalizedAnswer) {
        _results[_currentLineIndex] = _results[_currentLineIndex].copyWith(answer: _answerController.text, isCorrect: true, attempts: _results[_currentLineIndex].attempts + 1);
      } else {
        _results[_currentLineIndex] = _results[_currentLineIndex].copyWith(answer: _answerController.text, isCorrect: false, attempts: _results[_currentLineIndex].attempts + 1);
      }

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

  int getVocabIndex() {
    if (_currentLineIndex < _results.length) {
      final result = _results[_currentLineIndex];
      return result.index;
    } else {
      return 0;
    }
  }

  void _generateHint() {
    final vocabProvider = Provider.of<VocabProvider>(context, listen: false);
    final currentIndex = getVocabIndex();
    final currentResult = _results[_currentLineIndex];
    if (currentIndex < vocabProvider.entries.length) {
      final currentEntry = vocabProvider.entries[currentIndex];
      final normalizedAnswer = _normalize(currentEntry.english);
      switch (currentResult.hintsUsed) {
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
      if (_currentLineIndex < _results.length - 1) {
        _currentLineIndex++;
        _showHint = false;
        _answerController.clear();
        _answerController.text = _getUserAnswer(_currentLineIndex);
        _focusNode.unfocus();
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          FocusScope.of(context).requestFocus(_focusNode);
        });// Request focus f
      } else {
        _saveResults();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(),
          ),
        );
      }
    });
  }

  void _goToPreviousQuestion() {
    setState(() {
      if (_currentLineIndex > 0) {
        _currentLineIndex--;
        _showHint = false;
        _answerController.clear();
        _answerController.text = _getUserAnswer(_currentLineIndex);
        _focusNode.unfocus();
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          FocusScope.of(context).requestFocus(_focusNode);
        });// Request focus f
      }
    });
  }

  void _provideHint() {
    setState(() {
      final currentResult = _results[_currentLineIndex];
      if (currentResult.hintsUsed < 3) {
        _results[_currentLineIndex] = _results[_currentLineIndex].copyWith(hintsUsed: currentResult.hintsUsed + 1);
      }
      _showHint = true;
      _generateHint();
      _focusNode.unfocus();
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        FocusScope.of(context).requestFocus(_focusNode);
      });// Request focus for the text field
    });
  }

  void _handleKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _goToNextQuestion();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _goToPreviousQuestion();
      }
    }
  }

  void _saveResults() {
    final vocabProvider = Provider.of<VocabProvider>(context, listen: false);
    for (int i = 0; i < _results.length; i++) {
      final result = _results[i];
      vocabProvider.addResult(result.index, result.result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vocabProvider = Provider.of<VocabProvider>(context);
    if (_currentLineIndex >= _results.length) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz Completed'),
        ),
        body: Center(
          child: const Text('Congratulations! You have completed the quiz.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text('${_currentLineIndex + 1}/${vocabProvider.entries.length}'),
            ),
          ),
        ],
      ),
    body: KeyboardListener(
    focusNode: FocusNode(),
    onKeyEvent: _handleKey,
    child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final currentResult = _results[index];
                  final entry = vocabProvider.entries[currentResult.index];
                  if (index < _currentLineIndex - 5 || index > _currentLineIndex + 5) {
                    return Container();
                  }
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
                    subtitle: index == _currentLineIndex
                        ? TextField(
                      controller: _answerController,
                      autofocus: true,
                      focusNode: _focusNode,
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
      )
    ),
    );
  }

  Color _getEntryColor(int index) {
    if (_results[index].answer.isEmpty) {
      return Colors.black;
    } else if (_results[index].isCorrect) {
      return Colors.green;
    } else if (_results[index].attempts == 1) {
      return Colors.red;
    } else if (_results[index].attempts == 2) {
      return Colors.yellow;
    } else if (_results[index].attempts == 3) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _getUserAnswer(int index) {
    return _results[index].answer.isNotEmpty ? _results[index].answer : '';
  }
}

/**
 * Class to map a entry index with its result
 */
class ResultWithIndex {
  final int index;
  final Result result;

  ResultWithIndex({required this.index, required this.result});
  
  ResultWithIndex copyWith({String? answer, bool? isCorrect, int? attempts, int? hintsUsed}) {
    return ResultWithIndex(
      index: index,
      result: result.copyWith(
        answer: answer ?? result.answer, 
        isCorrect: isCorrect ?? result.isCorrect, 
        attempts: attempts ?? result.attempts, 
        hintsUsed: hintsUsed ?? result.hintsUsed
        ),
    );
  }

  /// Convienent method to get the attempts
  int get attempts => result.attempts;
  int get hintsUsed => result.hintsUsed;
  bool get isCorrect => result.isCorrect;
  String get answer => result.answer;
}
