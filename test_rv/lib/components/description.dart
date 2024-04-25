import 'package:flutter/material.dart';

import '../../../../../../../constants.dart';

class Description extends StatelessWidget {
  const Description({
    Key? key,
    this.generatedContent,
  }) : super(key: key);

  final String? generatedContent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kDefaultPaddin / 2),
      child: Text(
        generatedContent ?? "Attijariwafa Bank : Croire en vous, c'est mettre vos ambitions au cœur de nos priorités.",
        style: TextStyle(height: 1.5, fontSize: 15),
      ),
    );
  }
}
