// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'vocab_provider.dart';
import 'quiz_screen.dart';
import 'vocab_entry.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VocabProvider(),
      child: MaterialApp(
        title: 'Vocab Trainer',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: VocabHomePage(),
      ),
    );
  }
}

class VocabHomePage extends StatelessWidget {
  // Check if the app is running in development mode
  static const bool isDevelopment =
      bool.fromEnvironment('dart.vm.product') == false;

  // Provide example text only in development mode
  final TextEditingController _controller = TextEditingController(
      text: isDevelopment
          ? '''1. trust                -    lita på
2. drawing            -    teckning
3. ruler                -    linjal
4. parallel            -    parallell
5. circle                -    cirkel
6. spot                -    punkt, fläck
7. cross            -    kryss
8. cover            -    täcka
9. stirra på            -    stare at
10. index finger        -    pekfinger
'''
          : '');

  Color _getEntryColor(Result result) {
    int practiceScore = result.needsMorePracticeScore();
    if (practiceScore == 0) {
      return Colors.green;
    } else if (practiceScore == 1) {
      return Colors.yellow;
    } else if (practiceScore == 7) {
      return Colors.red;
    } else {
      // Calculate gradient color between yellow and red
      final int red = 255;
      final int green = 255 -
          ((practiceScore - 1) *
              31); // 31 is the step size between yellow and red
      return Color.fromARGB(255, red, green, 0);
    }
  }

  Icon _getPracticeIcon(int practiceScore) {
    if (practiceScore == 0) {
      return Icon(Icons.check_circle, color: Colors.green);
    } else if (practiceScore == 1) {
      return Icon(Icons.check_circle, color: Colors.yellow);
    } else if (practiceScore == 7) {
      return Icon(Icons.error, color: Colors.red);
    } else {
      return Icon(Icons.warning,
          color: _getEntryColor(Result(
            answer: '',
            isCorrect: false,
            hintsUsed: 0,
            attempts: practiceScore,
          )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vocab Trainer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText:
                    'Enter vocab pairs in the format:\n1. English - Swedish',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Provider.of<VocabProvider>(context, listen: false)
                        .addEntries(_controller.text, true);
                  },
                  child: Text('Add Entries Eng-Swe'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Provider.of<VocabProvider>(context, listen: false)
                        .addEntries(_controller.text, false);
                  },
                  child: Text('Add Entries Swe-Eng'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Provider.of<VocabProvider>(context, listen: false)
                        .resetEntries();
                  },
                  child: Text('Reset List'),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QuizScreen()),
                );
              },
              child: Text('Start Quiz'),
            ),
            ElevatedButton(
              onPressed: () {
                final vocabProvider = Provider.of<VocabProvider>(context, listen: false);

                final results = vocabProvider.entries
                    .map((entry) => entry.results.last.needsMorePracticeScore());

                final indexes = vocabProvider.entries
                    .asMap()
                    .entries
                    .where((entry) => entry.value.results.isNotEmpty && entry.value.results.last.needsMorePracticeScore() > 0)
                    .map((entry) => entry.key)
                    .toList();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizScreen(indexes: indexes),
                  ),
                );
              },
              child: Text('Start Practice Quiz'),
            ),
            Consumer<VocabProvider>(
              builder: (context, vocabProvider, child) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: vocabProvider.entries.length,
                    itemBuilder: (context, index) {
                      final entry = vocabProvider.entries[index];
                      final latestResult = entry.results.isNotEmpty ? entry.results.last : null;
                      final practiceScore =
                          latestResult?.needsMorePracticeScore() ?? 0;
                      return ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.english,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        entry.swedish,
                                        style: TextStyle(color: Colors.blueGrey),
                                      ),
                                    ],
                                  ),
                                ),
                                if (latestResult != null && practiceScore > 0) ...[
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('attempts: ${latestResult.attempts}'),
                                      Text('hints used: ${latestResult.hintsUsed}'),
                                    ],
                                  ),
                                ],
                                SizedBox(width: 10),
                                _getPracticeIcon(practiceScore),
                                IconButton(
                                  icon: Icon(Icons.arrow_left),
                                  onPressed: () {
                                    Provider.of<VocabProvider>(context,
                                            listen: false)
                                        .moveSeparatorLeft(index);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.arrow_right),
                                  onPressed: () {
                                    Provider.of<VocabProvider>(context,
                                            listen: false)
                                        .moveSeparatorRight(index);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        tileColor: entry.hasDash
                            ? Colors.transparent
                            : Colors.red.withOpacity(0.3),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
