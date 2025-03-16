import 'package:test/main.dart';
import 'package:test/models/tailor.dart';
import 'package:test/screens/customer/confirm_measurements_option_page.dart';
import 'package:test/screens/customer/customer_main_screen.dart';
import 'package:test/utilities/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DressSewingChoiceScreen extends StatefulWidget {
  const DressSewingChoiceScreen({Key? key, required this.chosenTailor})
      : super(key: key);
  final Tailor chosenTailor;

  @override
  State<DressSewingChoiceScreen> createState() =>
      _DressSewingChoiceScreenState();
}

class _DressSewingChoiceScreenState extends State<DressSewingChoiceScreen> {
  bool customizationOnly = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Choose an item to proceed',
                  style: kInputStyle.copyWith(fontSize: 25),
                  textAlign: TextAlign.center,
                ).tr(),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              if (widget.chosenTailor.customizes)
                buildCustomizesDressQuestionTile(),
              if (widget.chosenTailor.customizes)
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.chosenTailor.rates.length,
                  // itemExtent: 100,
                  itemBuilder: (context, index) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 2, vertical: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        tileColor: kSkinColor,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ConfirmMeasurementsOptions(
                                  chosenTailor: widget.chosenTailor,
                                  customer: currentCustomer!,
                                  isCustomizationOnly: customizationOnly,
                                  chosenDressItem:
                                      widget.chosenTailor.rates[index],
                                ),
                              ));
                        },
                        title: Text(
                          getCategory(
                              widget.chosenTailor.rates[index].category),
                          style: kInputStyle,
                        ).tr(),
                        subtitle: Text(
                          getTranslatedText(
                              "${customizationOnly ? widget.chosenTailor.rates[index].customizationPrice : widget.chosenTailor.rates[index].price} روپے.",
                              "Rs. ${customizationOnly ? widget.chosenTailor.rates[index].customizationPrice : widget.chosenTailor.rates[index].price}"),
                          style: kTextStyle.copyWith(),
                        ),
                        trailing: Icon(
                          isUrduActivated
                              ? FontAwesomeIcons.arrowLeft
                              : FontAwesomeIcons.arrowRight,
                          color: kOrangeColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  CheckboxListTile buildCustomizesDressQuestionTile() {
    return CheckboxListTile(
      activeColor: kOrangeColor,
      contentPadding: const EdgeInsets.only(left: 10),
      title: Text(
        'I want dress customization',
        style: kInputStyle.copyWith(fontSize: 18),
      ).tr(),
      value: customizationOnly,
      onChanged: (val) {
        customizationOnly = val ?? false;
        setState(() {});
      },
    );
  }
}
