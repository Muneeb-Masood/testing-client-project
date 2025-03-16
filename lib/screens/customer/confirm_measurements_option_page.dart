import 'package:test/models/measurement.dart';
import 'package:test/models/order.dart';
import 'package:test/models/tailor.dart';
import 'package:test/networking/firestore_helper.dart';
import 'package:test/utilities/constants.dart';
import 'package:test/utilities/custom_widgets/rectangular_button.dart';
import 'package:test/utilities/my_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';

import '../../models/customer.dart';
import 'customer_main_screen.dart';

class ConfirmMeasurementsOptions extends StatefulWidget {
  final RateItem chosenDressItem;
  final bool isCustomizationOnly;
  const ConfirmMeasurementsOptions(
      {Key? key,
      required this.customer,
      required this.chosenDressItem,
      required this.chosenTailor,
      this.isCustomizationOnly = false})
      : super(key: key);
  final Customer customer;
  final Tailor chosenTailor;
  @override
  State<ConfirmMeasurementsOptions> createState() =>
      _ConfirmMeasurementsOptionsState();
}

class _ConfirmMeasurementsOptionsState
    extends State<ConfirmMeasurementsOptions> {
  MeasurementChoice? measurementChoice;

  bool measurementChoiceSelected = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 5)).then((value) =>
        setState(() => measurementChoice = widget.customer.measurementChoice));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return LoadingOverlay(
      isLoading: isLoading,
      progressIndicator: kSpinner(context),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(size.width * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: size.width * 0.01,
                ),
                Text(
                  getTranslatedText(
                      "پیمائش جمع کرنے کے آپشن ", 'Confirm Measurements'),
                  textAlign: TextAlign.center,
                  style: kTitleStyle.copyWith(fontSize: 28),
                ),
                SizedBox(
                  height: size.width * 0.01,
                ),
                Text(
                  getTranslatedText('کی تصدیق کریں', "Option"),
                  textAlign: TextAlign.center,
                  style: kInputStyle.copyWith(fontSize: 20),
                ),
                SizedBox(
                  height: size.width * 0.02,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        RadioListTile<MeasurementChoice>(
                          activeColor: kOrangeColor,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: size.height * 0.008,
                              horizontal: size.width * 0.008),
                          title: Text(
                            'Online Submission',
                            style: kInputStyle.copyWith(locale: context.locale),
                          ).tr(),
                          subtitle: Text(
                            'I will submit measurements online.',
                            style: kTextStyle.copyWith(
                                locale: context.locale, fontSize: 12),
                          ).tr(),
                          value: MeasurementChoice.online,
                          groupValue: measurementChoice,
                          onChanged: (val) {
                            setState(() {
                              measurementChoiceSelected = true;
                              measurementChoice = val;
                            });
                          },
                        ),
                        RadioListTile<MeasurementChoice>(
                          activeColor: kOrangeColor,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: size.height * 0.008,
                              horizontal: size.width * 0.008),
                          title: Text(
                            'Physical Measurements',
                            style: kInputStyle.copyWith(locale: context.locale),
                          ).tr(),
                          subtitle: Text(
                            "I will come to tailor's shop to submit measurements.",
                            style: kTextStyle.copyWith(
                                locale: context.locale, fontSize: 12),
                          ).tr(),
                          value: MeasurementChoice.physical,
                          groupValue: measurementChoice,
                          onChanged: (val) {
                            setState(() {
                              measurementChoice = val;
                              measurementChoiceSelected = true;
                            });
                          },
                        ),
                        RadioListTile<MeasurementChoice>(
                          activeColor: kOrangeColor,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: size.height * 0.008,
                              horizontal: size.width * 0.008),
                          title: Text(
                            'Measurements via Agent',
                            style: kInputStyle.copyWith(locale: context.locale),
                          ).tr(),
                          subtitle: Text(
                            'Tailor will send an agent to take measurements.',
                            style: kTextStyle.copyWith(
                                locale: context.locale, fontSize: 12),
                          ).tr(),
                          value: MeasurementChoice.viaAgent,
                          groupValue: measurementChoice,
                          onChanged: (val) {
                            setState(() {
                              measurementChoice = val;
                              measurementChoiceSelected = true;
                            });
                          },
                        ),
                        SizedBox(height: size.height * 0.04),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: size.width * 0.02),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: RectangularRoundedButton(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    buttonName: 'Continue',
                    onPressed: () {
                      if (measurementChoice == null) {
                        showMyBanner(
                            context,
                            getTranslatedText(
                                'ایک آپشن منتخب کریں۔', 'Select an option.'));
                        return;
                      }
                      // if (measurementChoice == MeasurementChoice.online) {
                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => CustomerMeasurementsPage(
                      //               customer: widget.customer,
                      //               chosenDressItem: widget.chosenDressItem,
                      //             )),
                      //   );
                      // } else {
                      OrderRequest request = OrderRequest(
                        date: DateTime.now().toIso8601String(),
                        customer: widget.customer,
                        isCustomizationOnly: widget.isCustomizationOnly,
                        measurementChoice: measurementChoice!,
                        dressInfo: widget.chosenDressItem,
                        dressImage:
                            dressImages[widget.chosenDressItem.category]!,
                      );
                      widget.chosenTailor.orderRequests.add(request);
                      if (mounted) setState(() => isLoading = true);
                      FireStoreHelper()
                          .updateTailor(widget.chosenTailor)
                          .then((value) async {
                        debugPrint("Order request status: $value");
                        if (value) {
                          await showMyDialog(
                              context,
                              'Info.',
                              getTranslatedText("آرڈر کی درخواست کامیاب ہوئی۔",
                                  'Order request successful.'),
                              isError: false,
                              disposeAfterMillis: 1500);
                          if (mounted) setState(() => isLoading = false);
                          // ignore: use_build_context_synchronously
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            CustomerMainScreen.id,
                            (Route<dynamic> route) => false,
                          );
                        }
                      });
                      Future.delayed(const Duration(seconds: 5)).then((value) {
                        if (mounted) setState(() => isLoading = false);
                      });
                      // }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
