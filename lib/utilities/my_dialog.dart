import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'constants.dart';

Future showMyBanner(context, text) async {
  ScaffoldMessenger.of(context).showMaterialBanner(
    MaterialBanner(
      onVisible: () {
        Future.delayed(Duration(milliseconds: 1200)).then((value) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
          }
        });
      },
      content: Text(
        text,
        style: kTextStyle,
      ),
      backgroundColor: kLightSkinColor,
      actions: [
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
          },
          child: Text('Dismiss',
                  style: kBoldTextStyle()
                      .copyWith(decoration: TextDecoration.underline))
              .tr(),
        )
      ],
    ),
  );
}

Future showMyDialog(context, String title, String msg,
    {int disposeAfterMillis = 2000, bool isError = true}) async {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      Future.delayed(Duration(milliseconds: disposeAfterMillis), () {
        if (context.mounted) {
          Navigator.pop(context);
        }
      });
      return AlertDialog(
        backgroundColor: kLightSkinColor,
        title: Center(
          child: Text(title,
                  style: kInputStyle.copyWith(
                      color: isError ? Colors.red : Colors.green, fontSize: 22))
              .tr(),
        ),
        content: Text(
          msg,
          textAlign: TextAlign.center,
          style: kTextStyle,
        ),
      );
    },
  );
}
