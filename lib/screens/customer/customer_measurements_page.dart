import 'package:test/main.dart';
import 'package:test/models/measurement.dart';
import 'package:test/models/tailor.dart';
import 'package:test/networking/firestore_helper.dart';
import 'package:test/utilities/constants.dart';
import 'package:test/utilities/custom_widgets/rate_input_text_field.dart';
import 'package:test/utilities/custom_widgets/rectangular_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_overlay/loading_overlay.dart';

import '../../models/customer.dart';

class CustomerMeasurementsPage extends StatefulWidget {
  //if its null then that means reached from profile section to update measurements
  final RateItem? chosenDressItem;
  //if tailor is viewing customer measures from customers profile then make everything read only
  final bool isTailorView;
  const CustomerMeasurementsPage(
      {Key? key,
      required this.customer,
      this.chosenDressItem,
      this.isTailorView = false})
      : super(key: key);
  final Customer customer;
  @override
  State<CustomerMeasurementsPage> createState() =>
      _CustomerMeasurementsPageState();
}

class _CustomerMeasurementsPageState extends State<CustomerMeasurementsPage> {
  bool isEditMode = false;
  bool isUpdatingMeasurements = false;
  List<Measurement> measurements = List.generate(
    totalMeasurements.length,
    (index) => Measurement(
        title: capitalizeText(
            spaceSeparatedText(totalMeasurements.keys.elementAt(index))),
        measure: 0),
  );
  final measurementsControllers = List.generate(
      totalMeasurements.length, (index) => TextEditingController(text: '0'));
  String unit = 'in';

  setEditMode() {
    //will be editable only if it has been opned from customer profile.
    if (widget.chosenDressItem == null && !widget.isTailorView) {
      isEditMode = true;
    }
    if (mounted) setState(() {});
  }

  setControllerValuesToCustomers() {
    // if()
    // widget.customer.measurements.forEach((element) { });
    if (widget.customer.measurements.isNotEmpty) {
      for (int i = 0; i < widget.customer.measurements.length; i++) {
        String val = widget.customer.measurements[i].measure.toString();
        measurementsControllers[i].text = val;
        measurements[i].measure = widget.customer.measurements[i].measure;
      }
      unit = widget.customer.measurements[0].unit;
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void initState() {
    super.initState();
    setEditMode();
    setControllerValuesToCustomers();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return LoadingOverlay(
      isLoading: isUpdatingMeasurements,
      progressIndicator: kSpinner(context),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isEditMode)
                SizedBox(
                  height: size.height * 0.04,
                  child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        FontAwesomeIcons.arrowLeft,
                        color: Theme.of(context).primaryColor,
                      )),
                ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(size.width * 0.05, 0,
                      size.width * 0.05, size.width * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: size.width * 0.01,
                      ),
                      Text(
                        '${isEditMode && widget.isTailorView ? getTranslatedText("ایڈٹ کریں", "Edit") : isEditMode && !widget.isTailorView ? getTranslatedText("شامل کریں", "Add") : ''} ${getTranslatedText("پیمائش", "Measurements")}',
                        textAlign: TextAlign.center,
                        style: kTitleStyle.copyWith(
                            fontSize: isEditMode ? 25 : 30),
                      ),
                      SizedBox(
                        height: size.width * 0.01,
                      ),
                      if (!isEditMode && !widget.isTailorView)
                        Text(
                          getTranslatedText(
                              "${catgKeyVals[getCategory(widget.chosenDressItem!.category)]} کے لئے",
                              'for ${getCategory(widget.chosenDressItem!.category)}'),
                          textAlign: TextAlign.center,
                          style: kInputStyle.copyWith(fontSize: 20),
                        ),
                      SizedBox(
                        height: size.width * 0.02,
                      ),
                      if (isEditMode && !widget.isTailorView)
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  getTranslatedText("یونٹ", 'Unit'),
                                  style: kInputStyle,
                                ),
                                const SizedBox(),
                                DropdownButton<String>(
                                  value: unit == "in"
                                      ? getTranslatedText("انچ", 'inches')
                                      : getTranslatedText(
                                          "سینٹی میٹر", 'centimeters'),
                                  style: kBoldTextStyle(),
                                  iconEnabledColor: kOrangeColor,
                                  dropdownColor: kLightSkinColor,
                                  onChanged: (newValue) {
                                    if (newValue != null) {
                                      if ((unit == 'in' &&
                                              (newValue == 'inches' ||
                                                  newValue == "انچ")) ||
                                          (unit == 'cm' &&
                                              (newValue == 'centimeters' ||
                                                  newValue == "سینٹی میٹر"))) {
                                        return;
                                      }
                                      unit = (newValue == 'inches' ||
                                              newValue == "انچ")
                                          ? 'in'
                                          : "cm";
                                    }
                                    setState(() {});
                                    print(unit);
                                  },
                                  items: [
                                    getTranslatedText("انچ", 'inches'),
                                    getTranslatedText(
                                        "سینٹی میٹر", 'centimeters'),
                                  ].map<DropdownMenuItem<String>>((value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: size.width * 0.01,
                            ),
                          ],
                        ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: List.generate(
                              measurements.length,
                              (i) {
                                // if (i == measurements.length && !isEditMode) {
                                //   buildCommentsTextField();
                                // }
                                return Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 2,
                                      vertical: size.height * 0.03),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: size.width * 0.4,
                                        height: size.height * 0.1,
                                        child: Align(
                                            alignment: isUrduActivated
                                                ? Alignment.centerRight
                                                : Alignment.centerLeft,
                                            child: GestureDetector(
                                              onTap: () =>
                                                  onMeasurementImageTapped(
                                                      totalMeasurements.values
                                                          .elementAt(i)),
                                              child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  child: Image.asset(
                                                      totalMeasurements.values
                                                          .elementAt(i))),
                                            )),
                                      ),
                                      const SizedBox(),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              capitalizeText(
                                                spaceSeparatedText(
                                                    totalMeasurements.keys
                                                        .elementAt(i)),
                                              ).tr(),
                                              style: kInputStyle,
                                            ),
                                          ),
                                          SizedBox(height: size.height * 0.01),
                                          RateInputField(
                                            enabled: !widget.isTailorView,
                                            suffixText: unit == "in"
                                                ? getTranslatedText(
                                                    "انچ", 'inches')
                                                : getTranslatedText(
                                                    "سینٹی میٹر",
                                                    'centimeters'),
                                            onChanged: (val) {
                                              if (val != null &&
                                                  val.isNotEmpty) {
                                                try {
                                                  measurements[i].measure =
                                                      double.parse(val);
                                                  if (mounted) setState(() {});
                                                  print(
                                                      "Measurmenets updated.");
                                                } catch (e) {
                                                  print(
                                                      'Exception parsing :$e');
                                                }
                                              }
                                            },
                                            validateField: false,
                                            controller:
                                                measurementsControllers[i],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: size.width * 0.02),
                      if (!widget.isTailorView)
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: RectangularRoundedButton(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            buttonName: isEditMode ? 'Update' : 'Continue',
                            onPressed: () {
                              widget.customer.measurements = measurements;
                              if (mounted) setState(() {});
                              if (isEditMode) {
                                if (mounted) {
                                  setState(() {
                                    isUpdatingMeasurements = true;
                                  });
                                }
                                Future.delayed(const Duration(seconds: 5))
                                    .then((val) {
                                  if (mounted && isUpdatingMeasurements) {
                                    setState(() {
                                      isUpdatingMeasurements = false;
                                    });
                                    return;
                                  }
                                });
                                for (var element
                                    in widget.customer.measurements) {
                                  element.unit = unit;
                                }
                                FireStoreHelper()
                                    .updateCustomer(widget.customer)
                                    .then((value) {
                                  if (value) {
                                    if (mounted) {
                                      setState(() {
                                        isUpdatingMeasurements = false;
                                      });
                                    }
                                    Fluttertoast.showToast(
                                      msg: getTranslatedText(
                                          "پیمائش کامیابی سے اپ ڈیٹ کی گئی ہے.",
                                          "Measurements updated successfully."),
                                      gravity: ToastGravity.CENTER,
                                      textColor: Colors.white,
                                      backgroundColor: kOrangeColor,
                                    );
                                    Navigator.pop(context);
                                  }
                                });
                                return;
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  //
  // Container buildCommentsTextField() {
  //   return Container(
  //     margin: const EdgeInsets.all(5),
  //     child: TextFormField(
  //       style: kInputStyle,
  //       onChanged: (val) {
  //         if (val != null && val.isNotEmpty) {
  //           setState(() {
  //             orderComments = val;
  //           });
  //         }
  //       },
  //       decoration: kTextFieldDecoration.copyWith(
  //         prefixIcon: const IconTheme(
  //             data: IconThemeData(color: Colors.black54),
  //             child: Icon(Icons.comment, size: 18)),
  //         // hintText: hint,
  //         labelText: 'Any Comments',
  //         hintText: '',
  //         labelStyle: kTextStyle,
  //       ),
  //     ),
  //   );
  // }

  void onMeasurementImageTapped(String imageUrl) {
    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(10.0),
      image: DecorationImage(
        image: AssetImage(imageUrl),
        fit: BoxFit.fill,
      ),
    );
    showDialog(
      context: context,
      builder: (context) => Container(
        margin: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.18,
          horizontal: MediaQuery.of(context).size.width * 0.05,
        ),
        decoration: decoration.copyWith(),
      ),
    );
  }
}
