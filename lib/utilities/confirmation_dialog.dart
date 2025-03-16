import 'package:test/utilities/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final String confirmText;
  final String okBtnText;

  ConfirmationDialog(
      {required this.onConfirm,
      required this.confirmText,
      this.okBtnText = 'Delete'});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirmation').tr(),
      content: Text(confirmText).tr(),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel').tr(),
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
        ),
        TextButton(
          child: Text(
            okBtnText,
            style: kInputStyle.copyWith(
              color: okBtnText == "Delete" ? Colors.red : Colors.black,
            ),
          ).tr(),
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
            onConfirm(); // Execute the callback
          },
        ),
      ],
    );
  }
}
