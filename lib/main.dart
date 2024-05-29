// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'vocab_provider.dart';
import 'quiz_screen.dart';

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
  static const bool isDevelopment = bool.fromEnvironment('dart.vm.product') == false;

  // Provide example text only in development mode
  final TextEditingController _controller = TextEditingController(
      text: isDevelopment ? '''1. Hi, how are you? - Hej, hur mår du?
2. I like to read books. Jag gillar att läsa böcker.
3. Can you help me? - Kan du hjälpa mig?
''' : ''
  );

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
              decoration: InputDecoration(
                hintText: 'Enter vocab pairs in the format:\n1. English - Swedish',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Provider.of<VocabProvider>(context, listen: false).addEntries(_controller.text);
                  },
                  child: Text('Add Entries'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Provider.of<VocabProvider>(context, listen: false).resetEntries();
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
            Consumer<VocabProvider>(
              builder: (context, vocabProvider, child) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: vocabProvider.entries.length,
                    itemBuilder: (context, index) {
                      final entry = vocabProvider.entries[index];
                      return ListTile(
                        title: Row(
                          children: [
                            Expanded(child: Text('${entry.english} - ${entry.swedish}')),
                            IconButton(
                              icon: Icon(Icons.arrow_left),
                              onPressed: () {
                                Provider.of<VocabProvider>(context, listen: false).moveSeparatorLeft(index);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.arrow_right),
                              onPressed: () {
                                Provider.of<VocabProvider>(context, listen: false).moveSeparatorRight(index);
                              },
                            ),
                          ],
                        ),
                        tileColor: entry.hasDash ? Colors.transparent : Colors.red.withOpacity(0.3),
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
