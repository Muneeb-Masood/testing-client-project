import 'package:test/models/cloth.dart';
import 'package:test/models/notification.dart';
import 'package:test/models/order.dart';
import 'package:test/models/tailor.dart';
import 'package:test/networking/api_helper.dart';
import 'package:test/networking/firestore_helper.dart';
import 'package:test/networking/payment_helper.dart';
import 'package:test/utilities/constants.dart';
import 'package:test/utilities/custom_widgets/rectangular_button.dart';
import 'package:test/utilities/my_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:im_stepper/stepper.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:loading_overlay/loading_overlay.dart';

import '../../networking/notification_helper.dart';
import 'customer_main_screen.dart';

class StepsScreen extends StatefulWidget {
  const StepsScreen(
      {Key? key, required this.order, this.comingFromANotification = false})
      : super(key: key);
  final DresssewOrder order;
  final bool comingFromANotification;
  @override
  State<StepsScreen> createState() => _StepsScreenState();
}

class _StepsScreenState extends State<StepsScreen> {
  PaymentMethod? paymentMethod;
  DeliveryOption? deliveryOption;
  int stepNum = 0;
  String? accountNumber;
  final depositAmountController = TextEditingController();
  Tailor? tailor;

  bool isPlacingOrder = false;

  int clothDeliveryChargesViaAgent = 0;

  final helper = FireStoreHelper();

  List<Widget> steps(Size size) => [
        clothDetails(size),
        depositAdvanceSelectOption(size),
        depositAdvanceEnterAccountNumber(size),
        depositAdvanceEnterDepositAmount(size),
      ];

  loadTailor() async {
    tailor = await helper.getTailorWithDocId(widget.order.tailorId);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    clothDeliveryChargesViaAgent = widget.order.clothDeliveryCharges;
    Future.delayed(const Duration(milliseconds: 2))
        .then((value) => setState(() {}));
    loadTailor();
    depositAmountController.addListener(() {
      if (mounted) setState(() {});
      try {
        final val = depositAmountController.text.trim();
        if (val.isNotEmpty && double.parse(val) > widget.order.totalAmount) {
          showMyDialog(
              context, 'Error', "deposit amount can't exceed total amount.");
        }
      } catch (e) {
        print("ecption: $e");
      }
    });
  }

  @override
  void dispose() {
    depositAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return LoadingOverlay(
      isLoading: isPlacingOrder,
      progressIndicator: kSpinner(context),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(size.width * 0.05),
            child: SingleChildScrollView(
              child: AnimatedContainer(
                duration: const Duration(seconds: 2),
                child: Column(
                  children: [
                    NumberStepper(
                      numbers: [
                        1,
                        2,
                        3,
                        4,
                      ],
                      activeStep: stepNum,
                      activeStepBorderColor: Theme.of(context).primaryColor,
                      activeStepBorderWidth: 2,
                      stepRadius: 12,
                      lineLength: 40,
                      activeStepColor: Colors.white,
                      stepColor: Colors.white,
                      enableNextPreviousButtons: false,
                      numberStyle: kBoldTextStyle(),
                    ),
                    steps(size)[stepNum],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  //he must deposit 50% in advance
  Widget clothDetails(size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: size.width * 0.03,
        ),
        Text(
          getTranslatedText("کپڑا جمع کرنے کی معلومات", 'Cloth Submission'),
          textAlign: TextAlign.center,
          style: kTitleStyle.copyWith(fontSize: 30),
        ),
        SizedBox(
          height: size.width * 0.08,
        ),
        Text(
          getTranslatedText("کپڑا جمع کرنے کا آپشن منتخب کریں",
              'Choose option to submit cloth'),
          style: kInputStyle,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        RadioListTile<DeliveryOption>(
          contentPadding: EdgeInsets.zero,
          activeColor: kOrangeColor,
          value: DeliveryOption.mySelf,
          groupValue: deliveryOption,
          onChanged: (value) {
            if (mounted) {
              setState(() {
                deliveryOption = value;
              });
            }
          },
          subtitle: deliveryOption != DeliveryOption.mySelf
              ? null
              : FutureBuilder(
                  future: ApiHelper.translateText(tailor!.shop!.city),
                  builder: (_, st) {
                    return Text(
                      "${getTranslatedText("درزی کا پتہ:", "tailor address:")} ${tailor == null ? '...' : "${tailor!.shop!.address}, ${getTranslatedText(st.data ?? '..', tailor!.shop!.city)}."}",
                      style: kInputStyle.copyWith(
                        fontSize: 13,
                      ),
                    );
                  }),
          title: Text(
            'I will deliver & receive it myself',
            style: kInputStyle.copyWith(fontSize: 14),
          ).tr(),
        ),
        RadioListTile<DeliveryOption>(
          contentPadding: EdgeInsets.zero,
          activeColor: kOrangeColor,
          value: DeliveryOption.viaAgent,
          groupValue: deliveryOption,
          onChanged: (value) {
            if (mounted) {
              setState(() {
                deliveryOption = value;
              });
            }
          },
          subtitle: deliveryOption != DeliveryOption.viaAgent
              ? null
              : FutureBuilder(
                  future: ApiHelper.translateText(
                      "${currentCustomer!.address}, ${currentCustomer!.city}."),
                  builder: (_, st) {
                    final ad =
                        "${currentCustomer!.address}, ${currentCustomer!.city}.";
                    return Text(
                      '${getTranslatedText("آپ کا پتہ:", "your address:")} ${currentCustomer == null ? '...' : getTranslatedText(st.data ?? '..', ad)}',
                      style: kInputStyle.copyWith(
                        fontSize: 13,
                      ),
                    );
                  }),
          title: Text(
            'Tailor send me an agent to receive & deliver it.',
            style: kInputStyle.copyWith(fontSize: 14),
          ).tr(),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        Text(
          'Note:',
          style:
              kInputStyle.copyWith(fontSize: 13, color: Colors.grey.shade700),
        ).tr(),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (deliveryOption == DeliveryOption.viaAgent)
                //TODO can be calculated based on distance
                Text(
                  getTranslatedText(
                    "1. ${urduClothOption(deliveryOption!.name)} ڈلیوری چارجز: $clothDeliveryChargesViaAgent روپے۔",
                    "1. ${capitalizeText(spaceSeparatedText(deliveryOption!.name))} delivery charges: Rs. $clothDeliveryChargesViaAgent",
                  ),
                  style: kInputStyle.copyWith(fontSize: 13),
                ),
              if (deliveryOption == DeliveryOption.viaAgent)
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Text(
                getTranslatedText(
                  "${deliveryOption == DeliveryOption.viaAgent ? "2" : "1"}. آپ نے پیمائش جمع کرانے کے لئے '${urduMeasurement(widget.order.measurementChoice.name)}' آپشن کا انتخاب کیا ہے۔ ",
                  "${deliveryOption == DeliveryOption.viaAgent ? "2." : "1."} You have chosen '${spaceSeparatedText(widget.order.measurementChoice.name)}' option for measurements submission.",
                ),
                style: kInputStyle.copyWith(fontSize: 13),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.015),
            ],
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.05),
        buildNextButton(
            shouldProceedOnly: deliveryOption != null,
            error: getTranslatedText("جمع کرانے کا طریقہ منتخب کریں۔",
                "Select a submission method.")),
      ],
    );
  }

  Widget depositAdvanceEnterAccountNumber(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: size.width * 0.03,
        ),
        Text(
          getTranslatedText("ایڈوانس ڈپازٹ", 'Deposit Advance'),
          textAlign: TextAlign.center,
          style: kTitleStyle.copyWith(fontSize: 30),
        ),
        SizedBox(
          height: size.width * 0.01,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: size.width * 0.035,
              backgroundImage: AssetImage(
                  'assets/${paymentMethod == PaymentMethod.jazzcash ? "jazzcash" : "easypaisa"}.png'),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.03),
            Text(
              capitalizeText(paymentMethod?.name ?? ''),
              style: kInputStyle,
            ),
          ],
        ),
        SizedBox(
          height: size.width * 0.1,
        ),
        Text(
          getTranslatedText(
            "اپنا ${paymentMethod?.name} اکاؤنٹ نمبر درج کریں",
            'Enter your ${paymentMethod?.name} account number',
          ),
          style: kInputStyle,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        buildPhoneNumberField(),
        SizedBox(height: MediaQuery.of(context).size.height * 0.005),
        Text(
          'tailor account:',
          style:
              kInputStyle.copyWith(fontSize: 13, color: Colors.grey.shade700),
        ).tr(),
        Card(
          color: Colors.white24,
          shadowColor: Colors.black12,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              zeroedPhoneNumber(widget.order.tailorPaymentInfo.accountNumber),
              style: kInputStyle,
            ),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.04),
        Text(
          'Note:',
          style:
              kInputStyle.copyWith(fontSize: 13, color: Colors.grey.shade700),
        ).tr(),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getTranslatedText(
                    "یہ پیسہ براہ راست درزی کے اکاؤنٹ میں جمع کرایا جائے گا۔",
                    "This money will be deposited directly into tailor's account."),
                style: kInputStyle.copyWith(fontSize: 13),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.015),
            ],
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.05),
        buildNextButton(
            shouldProceedOnly:
                accountNumber != null && accountNumber!.isNotEmpty,
            error: getTranslatedText(
                "اپنا اکاؤنٹ نمبر درج کریں۔ ", "Enter your account number.")),
      ],
    );
  }

  Widget depositAdvanceSelectOption(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: size.width * 0.03,
        ),
        Text(
          getTranslatedText("ایڈوانس ڈپازٹ", 'Deposit Advance'),
          textAlign: TextAlign.center,
          style: kTitleStyle.copyWith(fontSize: 30),
        ),
        SizedBox(
          height: size.width * 0.01,
        ),
        Text(
          getTranslatedText("آپشن منتخب کریں", 'Choose option'),
          textAlign: TextAlign.center,
          style: kInputStyle.copyWith(fontSize: 20),
        ),
        SizedBox(
          height: size.width * 0.02,
        ),
        RadioListTile<PaymentMethod>(
          value: PaymentMethod.jazzcash,
          groupValue: paymentMethod,
          activeColor: kOrangeColor,
          onChanged: (value) {
            if (mounted) {
              setState(() {
                paymentMethod = value;
              });
            }
          },
          title: Row(
            children: [
              CircleAvatar(
                radius: size.width * 0.035,
                backgroundImage: AssetImage('assets/jazzcash.png'),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.03),
              FutureBuilder(
                  future: ApiHelper.translateText("Jazzcash"),
                  builder: (_, st) {
                    return Text(
                      getTranslatedText('Jazzcash', 'Jazzcash'),
                      style: kInputStyle,
                    );
                  }),
            ],
          ),
        ),
        RadioListTile<PaymentMethod>(
          value: PaymentMethod.easypaisa,
          activeColor: kOrangeColor,
          groupValue: paymentMethod,
          onChanged: (value) {
            if (mounted) {
              setState(() {
                paymentMethod = value;
              });
            }
          },
          title: Row(
            children: [
              CircleAvatar(
                radius: size.width * 0.04,
                backgroundImage: AssetImage('assets/easypaisa.png'),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.025),
              FutureBuilder(
                  future: ApiHelper.translateText("Easypaisa"),
                  builder: (_, st) {
                    return Text(
                      getTranslatedText(st.data ?? '..', 'Easypaisa'),
                      style: kInputStyle,
                    );
                  }),
            ],
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.05),
        Text(
          'Note:',
          style:
              kInputStyle.copyWith(fontSize: 13, color: Colors.grey.shade700),
        ).tr(),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1. ${getTranslatedText("یقینی بنائیں کہ آپ کا اکاؤنٹ فعال ہے۔", "Ensure your Account is active.")}',
                style: kInputStyle.copyWith(fontSize: 13),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.015),
              Text(
                '2. ${getTranslatedText("آپ کے اکاؤنٹ میں کافی بیلنس ہے۔", "Your Account has sufficient balance.")}',
                style: kInputStyle.copyWith(fontSize: 13),
              ),
            ],
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.07),
        buildNextButton(
            shouldProceedOnly: paymentMethod != null,
            error: getTranslatedText(
                "ادائیگی کا طریقہ منتخب کریں.", "Select a payment method.")),
      ],
    );
  }

  Widget buildNextButton({
    required bool shouldProceedOnly,
    String? error,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: RectangularRoundedButton(
        padding: const EdgeInsets.symmetric(vertical: 10),
        translateText: stepNum == 3 ? false : true,
        buttonName: stepNum == 3
            ? getTranslatedText(
                "جمع کریں اور آرڈر دیں", 'Deposit & Place order')
            : 'Next',
        onPressed: () async {
          if (!shouldProceedOnly) {
            if (error != null) {
              showMyBanner(context, error);
            }
            return;
          }
          if (stepNum == 3) {
            final o = widget.order;
            o.cloth = Cloth(delivery: deliveryOption!);
            o.paymentMethod = paymentMethod!;
            if (deliveryOption == DeliveryOption.viaAgent) {
              o.totalAmount += clothDeliveryChargesViaAgent;
            }
            final val = depositAmountController.text.trim();
            if (double.parse(val) > widget.order.totalAmount) {
              showMyDialog(
                  context,
                  'Error!',
                  getTranslatedText(
                      "ڈپازٹ کی رقم کل رقم سے زیادہ نہیں ہوسکتی ہے۔",
                      "deposit amount can't exceed total amount."));
              return;
            }
            //adding optional comments
            await showDialog(
                context: context,
                builder: (context) {
                  final orderCommentsController = TextEditingController();
                  orderCommentsController.addListener(() {
                    if (mounted) setState(() {});
                  });
                  return StatefulBuilder(builder: (context, setState) {
                    return Card(
                      margin: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.05,
                        vertical: MediaQuery.of(context).size.height * 0.27,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.05),
                              Text(
                                  getTranslatedText("اضافی ہدایات شامل کریں",
                                      'Additional instructions'),
                                  style: kTitleStyle.copyWith(
                                      fontSize: 22,
                                      color: Colors.blue.shade700)),
                              Text(
                                getTranslatedText("(اختیاری)", "(Optional)"),
                                textAlign: TextAlign.center,
                                style: kInputStyle.copyWith(fontSize: 15),
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.03),
                              TextField(
                                minLines: 4,
                                maxLines: 5,
                                controller: orderCommentsController,
                                decoration: kTextFieldDecoration.copyWith(
                                  labelText: getTranslatedText(
                                      "ہدایات", 'instructions'),
                                  hintText: getTranslatedText(
                                      "اپنی اضافی ہدایات یہاں لکھیں",
                                      'write your additional instructions here'),
                                  hintStyle: kTextStyle,
                                  labelStyle: kTextStyle,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                ),
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.02),
                              ElevatedButton(
                                onPressed: () {
                                  o.anyComments =
                                      orderCommentsController.text.trim();
                                  setState(() {});
                                  Navigator.pop(context);
                                },
                                child: const Text('Done').tr(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
                });
            print('Comments: ${o.anyComments}');
            PaymentHelper paymentHelper = PaymentHelper();
            bool successful = false;
            if (mounted) {
              setState(() {
                isPlacingOrder = true;
              });
            }
            final paid = await paymentHelper.payAmount(
                accountNumber!,
                widget.order.tailorPaymentInfo.accountNumber,
                double.parse(val),
                paymentMethod!);
            if (paid) {
              o.advanceDeposited = double.parse(val);
              o.amountRemaining = o.totalAmount - o.advanceDeposited;
              helper.updateOrder(o).then((value) {
                Fluttertoast.showToast(
                  msg: getTranslatedText(
                      "کامیابی سے آرڈر دیا گیا۔", "Order placed successfully."),
                  textColor: Colors.white,
                  backgroundColor: kOrangeColor,
                );
                if (mounted) {
                  setState(() {
                    successful = value;
                    isPlacingOrder = false;
                  });
                }
                NotificationHelper.sendNotification(
                  widget.order,
                  NotificationType.customerCompletedSteps,
                  customerName: currentCustomer!.name,
                  sentByTailor: false,
                );
                if (widget.comingFromANotification) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    CustomerMainScreen.id,
                    (Route<dynamic> route) => false,
                  );
                }
              });
            } else {
              showMyDialog(
                  context,
                  'Error!',
                  getTranslatedText("براہ مہربانی 50٪ ڈپازٹ ادا کریں.",
                      'Please pay 50% deposit.'));
            }

            await Future.delayed(const Duration(seconds: 5)).then((value) {
              if (!successful && paid) {
                showMyBanner(
                    context, getTranslatedText("ٹائم آؤٹ.", "Timed out."));
                if (context.mounted) {
                  setState(() {
                    isPlacingOrder = false;
                  });
                }
                return;
              }
            });
          }
          if (stepNum < 3) {
            stepNum++;
            if (context.mounted) setState(() {});
          }
        },
      ),
    );
  }

  IntlPhoneField buildPhoneNumberField() {
    return IntlPhoneField(
      onChanged: (phone) => setState(() {
        accountNumber = phone.completeNumber;
      }),
      flagsButtonPadding: const EdgeInsets.all(10),
      decoration: kTextFieldDecoration.copyWith(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        hintText: dummyNumber,
        hintStyle: kInputStyle,
        labelText: getTranslatedText("فون نمبر", 'phone#'),
        // labelStyle: kInputStyle,
      ),
      keyboardType: TextInputType.phone,
      style: kInputStyle.copyWith(
        locale: context.locale,
      ),
      initialCountryCode: 'PK',
      // countries: [''],
    );
  }

  Widget depositAdvanceEnterDepositAmount(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: size.width * 0.03,
        ),
        Text(
          getTranslatedText("ایڈوانس ڈپازٹ", 'Deposit Advance'),
          textAlign: TextAlign.center,
          style: kTitleStyle.copyWith(fontSize: 30),
        ),
        SizedBox(
          height: size.width * 0.01,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: size.width * 0.035,
              backgroundImage: AssetImage(
                  'assets/${paymentMethod == PaymentMethod.jazzcash ? "jazzcash" : "easypaisa"}.png'),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.03),
            Text(
              capitalizeText(paymentMethod?.name ?? ''),
              style: kInputStyle,
            ),
          ],
        ),
        SizedBox(
          height: size.width * 0.1,
        ),
        if (deliveryOption == DeliveryOption.viaAgent)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getTranslatedText(
                    "آرڈر کی رقم:  ${widget.order.totalAmount} روپے۔",
                    "order amount: Rs. ${widget.order.totalAmount}"),
                style: kInputStyle,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Text(
                getTranslatedText(
                    "ایجنٹ کے ذریعے کپڑے ڈلیور کرنے کے اخراجات: $clothDeliveryChargesViaAgent روپے",
                    'cloth delivery charges: Rs. $clothDeliveryChargesViaAgent'),
                style: kInputStyle,
              ),
              SizedBox(
                height: size.width * 0.02,
              ),
            ],
          ),
        Text(
          getTranslatedText(
              "کل رقم:  ${widget.order.totalAmount + (deliveryOption == DeliveryOption.viaAgent ? clothDeliveryChargesViaAgent : 0)} روپے۔",
              "total amount: Rs. ${widget.order.totalAmount + (deliveryOption == DeliveryOption.viaAgent ? clothDeliveryChargesViaAgent : 0)}"),
          style: kInputStyle,
        ),
        SizedBox(
          height: size.width * 0.02,
        ),
        Text(
          getTranslatedText("ڈپازٹ کی رقم درج کریں:", 'enter deposit amount:'),
          style: kInputStyle.copyWith(color: Colors.grey.shade700),
        ),
        TextField(
          controller: depositAmountController,
          keyboardType: TextInputType.number,
          decoration: kTextFieldDecoration.copyWith(
            suffixText: getTranslatedText("روپے", 'Rs'),
            hintText: getTranslatedText("رقم روپیوں میں", 'amount in rupees'),
            hintStyle: kTextStyle,
            suffixStyle: kInputStyle,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.015),
        Text(
          'your account:',
          style:
              kInputStyle.copyWith(fontSize: 13, color: Colors.grey.shade700),
        ).tr(),
        Card(
          color: Colors.white24,
          shadowColor: Colors.black12,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              zeroedPhoneNumber(accountNumber),
              style: kInputStyle,
            ),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Text(
          getTranslatedText(
              "درزی کے اکاؤنٹ کی قسم: ${capitalizeText(widget.order.tailorPaymentInfo.paymentMethod.name)}",
              'tailor account type: ${capitalizeText(widget.order.tailorPaymentInfo.paymentMethod.name)}'),
          style:
              kInputStyle.copyWith(fontSize: 13, color: Colors.grey.shade700),
        ),
        SizedBox(
          height: size.width * 0.02,
        ),
        Text(
          'tailor account:',
          style:
              kInputStyle.copyWith(fontSize: 13, color: Colors.grey.shade700),
        ).tr(),
        Card(
          color: Colors.white24,
          shadowColor: Colors.black12,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              zeroedPhoneNumber(widget.order.tailorPaymentInfo.accountNumber),
              style: kInputStyle,
            ),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.04),
        Text(
          'Note:',
          style:
              kInputStyle.copyWith(fontSize: 13, color: Colors.grey.shade700),
        ).tr(),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "You must deposit at least 50% of the total price.",
                style: kInputStyle.copyWith(fontSize: 13),
              ).tr(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.015),
            ],
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        buildNextButton(
            shouldProceedOnly: depositAmountController.text.isNotEmpty,
            error: getTranslatedText(
                "ڈپازٹ کی رقم درج کریں۔ ", "Enter deposit amount.")),
      ],
    );
  }

  void reset() {
    // clothType = null;
    paymentMethod = null;
    depositAmountController.clear();
    accountNumber = null;
    deliveryOption = null;
    stepNum = 0;
    if (mounted) setState(() {});
    // Navigator.pushNamedAndRemoveUntil(
    //   context,
    //   CustomerMainScreen.id,
    //   (Route<dynamic> route) => false,
    // );
  }
}
