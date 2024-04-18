import 'package:flutter/material.dart';
import 'package:test_rv/constants.dart';

class CommonBody extends StatelessWidget {
  final Gradient gradientColor = kPrimaryGradientColor;
  final String instructionText;
  final bool isListening;
  final bool speechEnabled;
  final String wordsSpoken;
  final double confidenceLevel;
  const CommonBody({super.key, required this.instructionText, required this.isListening, required this.speechEnabled, required this.wordsSpoken, required this.confidenceLevel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient:gradientColor
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(instructionText,
                style: const TextStyle(fontSize: 20.0),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  wordsSpoken,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
            if (!isListening && confidenceLevel > 0)
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 100,
                ),
                child: Text(
                  "Confidence: ${(confidenceLevel * 100).toStringAsFixed(1)}%",
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
