import 'package:flutter/material.dart';
import 'package:know_better/utilities/styles/size_config.dart';

class Button extends StatelessWidget {
  final void Function()? onPressed;
  final String label;
  final Color color;
  final Color textColor;

  const Button({
    this.onPressed,
    this.label = 'Button',
    this.color = const Color(0xFF7816F7),
    this.textColor = const Color(0xFFFFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: SizeConfig.heightMultiplier * 8,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
          color: color,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            color: textColor,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
