import 'package:test/utilities/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class RectangularRoundedButton extends StatelessWidget {
  final Color? color;
  final String buttonName;
  final double? fontSize;
  final EdgeInsets padding;
  final void Function()? onPressed;
  final bool translateText;
  const RectangularRoundedButton({
    super.key,
    this.color,
    required this.buttonName,
    this.fontSize = 18,
    this.padding = const EdgeInsets.symmetric(vertical: 16.0),
    required this.onPressed,
    this.translateText = true,
  });
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 5.0,
        backgroundColor: color ?? kOrangeColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Padding(
        padding: padding,
        child: translateText
            ? Text(
                buttonName,
                style: kTextStyle.copyWith(
                    fontSize: fontSize, color: Colors.white),
              ).tr()
            : Text(
                buttonName,
                style: kTextStyle.copyWith(
                    fontSize: fontSize, color: Colors.white),
              ),
      ),
    );
  }
}
