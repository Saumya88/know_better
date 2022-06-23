import 'package:flutter/material.dart';
import 'package:know_better/utilities/constants/global_constants.dart';
import 'package:know_better/utilities/styles/size_config.dart';

class GenderButton extends StatefulWidget {
  final Gender value;
  final bool isSelected;
  final IconData? icon;
  final Function()? onTap;
  const GenderButton({
    required this.value,
    this.isSelected = true,
    this.onTap,
    required this.icon,
  });

  @override
  _GenderButtonState createState() => _GenderButtonState();
}

class _GenderButtonState extends State<GenderButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: SizeConfig.imageSizeMultiplier * 27,
      height: SizeConfig.heightMultiplier * 4,
      decoration: BoxDecoration(
        color: widget.isSelected
            ? const Color.fromRGBO(68, 204, 136, 1.0)
            : const Color.fromRGBO(68, 204, 136, 0.1),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: InkWell(
        onTap: widget.onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              color: !widget.isSelected
                  ? const Color.fromRGBO(68, 204, 136, 1.0)
                  : Colors.white,
            ),
            SizedBox(
              width: SizeConfig.imageSizeMultiplier * 2,
            ),
            Text(
              widget.value.toString().split('.')[1].toUpperCase(),
              style: TextStyle(
                fontFamily: 'Inter',
                letterSpacing: 2,
                fontSize: SizeConfig.textMultiplier * 3.5,
                fontWeight: FontWeight.w600,
                color: !widget.isSelected
                    ? const Color.fromRGBO(68, 204, 136, 1.0)
                    : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
