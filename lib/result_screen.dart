// lib/result_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'vocab_provider.dart';
import 'vocab_entry.dart';
import 'main.dart';  // Import for navigation back to the home screen

class ResultScreen extends StatelessWidget {
  final int score;
  final List<int> attempts;

  ResultScreen({required this.score, required this.attempts});

  @override
  Widget build(BuildContext context) {
    final vocabProvider = Provider.of<VocabProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Results'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Your Score: $score/${vocabProvider.entries.length}',
              style: TextStyle(fontSize: 24),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: vocabProvider.entries.length,
                itemBuilder: (context, index) {
                  final entry = vocabProvider.entries[index];
                  final numAttempts = attempts[index];
                  Color tileColor;

                  switch (numAttempts) {
                    case 1:
                      tileColor = Colors.green;
                      break;
                    case 2:
                      tileColor = Colors.yellow;
                      break;
                    case 3:
                      tileColor = Colors.orange;
                      break;
                    default:
                      tileColor = Colors.red;
                      break;
                  }

                  return ListTile(
                    title: Text(entry.swedish),
                    subtitle: Text(entry.english),
                    trailing: Text('$numAttempts tries'),
                    tileColor: tileColor.withOpacity(0.3),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => VocabHomePage()),
                      (route) => false,
                );
              },
              child: Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
