
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vocab_trainer/vocab_entry.dart';

Color getEntryColor(Result result) {
  int practiceScore = result.needsMorePracticeScore();
  if (practiceScore == 0) {
    return Colors.green;
  } else {
    // Calculate gradient color between yellow and red
    const int red = 255;
    final int green = 210 - ((practiceScore - 1) * 30); // 31 is the step size between yellow and red
    return Color.fromARGB(255, red, green, 0);
  }
}