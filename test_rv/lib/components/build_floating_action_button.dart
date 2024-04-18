import 'package:flutter/material.dart';
import 'package:test_rv/constants.dart';
import '../size_config.dart';
import 'package:avatar_glow/avatar_glow.dart';


class BuildFloatingActionButton extends StatelessWidget {
  final Color glowColor = kPaletteColor;
  final bool isListening;
  final void Function() startListening;
  final void Function() stopListening;
  const BuildFloatingActionButton({super.key, required this.isListening, required this.startListening, required this.stopListening});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: getProportionateScreenWidth(120.0),
          vertical: getProportionateScreenHeight(150.0)),
      child: AvatarGlow(
        startDelay: const Duration(milliseconds: 1000),
        glowColor: glowColor,
        glowShape: BoxShape.circle,
        animate: isListening,
        curve: Curves.fastOutSlowIn,
        child: SizedBox(
          width: getProportionateScreenWidth(110),
          height: getProportionateScreenHeight(110),
          child: FloatingActionButton(
            shape: CircleBorder(),
            onPressed:
            isListening ? stopListening : startListening,
            tooltip: 'Ecouter',
            backgroundColor: kPrimaryColor,
            child: Icon(
                !isListening ? Icons.mic_off : Icons.mic,
                color: Colors.white,
                size: 35),
          ),
        ),
      ),
    );
  }
}
