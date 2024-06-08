// lib/result_screen.dart

import 'package:flutter/material.dart';
import 'package:vocab_trainer/color_utils.dart';
import 'vocab_provider.dart';
import 'package:provider/provider.dart';

class ResultScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final vocabProvider = Provider.of<VocabProvider>(context);
    final entries = vocabProvider.entries;

    return Scaffold(
      appBar: AppBar(
        title: Text('Results'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  final results = entry.results;
                  final lastResult = results.isNotEmpty ? results.last : null;

                  final userAnswer = lastResult?.answer ?? "";
                  final isCorrect = _normalize(userAnswer) == _normalize(entry.english);

                  return ListTile(
                    title: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${entry.swedish} - ',
                            style: TextStyle(color: Colors.black),
                          ),
                          TextSpan(
                            text: userAnswer,
                            style: TextStyle(
                              color: isCorrect ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    subtitle: !isCorrect
                        ? Text(
                      'Correct Answer: ${entry.english}',
                      style: TextStyle(color: Colors.red),
                    )
                        : null,
                    trailing: Icon(Icons.check_circle, color: getEntryColor(lastResult!))
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back to Main Screen'),
            ),
          ],
        ),
      ),
    );
  }

  String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r"[^\w\s']"), '') // Remove non-alphanumeric characters except for spaces and apostrophes
        .replaceAll(RegExp(r"['‘’]"), "'") // Normalize apostrophes
        .trim();
  }
}
