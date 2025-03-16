import 'package:test/utilities/constants.dart';
import 'package:test/utilities/custom_widgets/rate_input_text_field.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ItemRateInputTile extends StatelessWidget {
  final String title;
  final Function(String?) onChanged;
  final TextEditingController controller;
  final bool validateField;
  final String? suffixText;
  final double textSize;
  const ItemRateInputTile({
    super.key,
    this.validateField = true,
    required this.title,
    required this.onChanged,
    required this.controller,
    this.suffixText,
    this.textSize = 15,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: kInputStyle.copyWith(fontSize: textSize),
          ).tr(),
          RateInputField(
            validateField: validateField,
            controller: controller,
            onChanged: onChanged,
            suffixText: suffixText,
          ),
        ],
      ),
    );
  }
}
