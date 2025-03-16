import 'package:test/models/order.dart';
import 'package:test/networking/payment_helper.dart';
import 'package:test/screens/customer/rate_tailor_for_order.dart';
import 'package:test/utilities/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:im_stepper/stepper.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:loading_overlay/loading_overlay.dart';

import '../../models/cloth.dart';
import '../../models/tailor.dart';
import '../../networking/firestore_helper.dart';
import '../../utilities/custom_widgets/rectangular_button.dart';
import '../../utilities/my_dialog.dart';
import 'customer_main_screen.dart';

class DepositRemainingDuesOfOrder extends StatefulWidget {
  const DepositRemainingDuesOfOrder({Key? key, required this.order})
      : super(key: key);
  final DresssewOrder order;
  @override
  State<DepositRemainingDuesOfOrder> createState() =>
      _DepositRemainingDuesOfOrderState();
}

class _DepositRemainingDuesOfOrderState
    extends State<DepositRemainingDuesOfOrder> {
  PaymentMethod? paymentMethod;
  int stepNum = 0;
  String? accountNumber;
  Tailor? tailor;
  bool isPayingDues = false;

  int clothDeliveryChargesViaAgent = 0;
  List<Widget> steps(Size size) => [
        depositRemainingSelectOption(size),
        depositRemainingEnterAccountNumber(size),
        depositRemainingEnterDepositAmount(size),
      ];

  loadTailor() async {
    tailor = await FireStoreHelper().getTailorWithDocId(widget.order.tailorId);
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
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return LoadingOverlay(
      isLoading: isPayingDues,
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
                      ],
                      activeStep: stepNum,
                      activeStepBorderColor: Theme.of(context).primaryColor,
                      activeStepBorderWidth: 2,
                      stepRadius: 12,
                      lineLength: 40,
                      activeStepColor: Colors.white,
                      stepColor: Colors.white,
                      enableNextPreviousButtons: false,
                      numberStyle: kInputStyle.copyWith(
                          color: Theme.of(context).primaryColor),
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

  Widget depositRemainingEnterAccountNumber(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: size.width * 0.03,
        ),
        Text(
          getTranslatedText("واجبات جمع کروانا", 'Deposit Dues'),
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
          getTranslatedText("اپنا ${paymentMethod?.name} اکاؤنٹ نمبر درج کریں",
              'Enter your ${paymentMethod?.name} account number'),
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

  Widget depositRemainingSelectOption(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: size.width * 0.03,
        ),
        Text(
          getTranslatedText("واجبات جمع کروانا", 'Deposit Dues'),
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
              if (context.mounted)
                SizedBox(width: MediaQuery.of(context).size.width * 0.03),
              const Text(
                'Jazzcash',
                style: kInputStyle,
              ),
            ],
          ),
        ),
        RadioListTile<PaymentMethod>(
          value: PaymentMethod.easypaisa,
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
              const Text(
                'Easypaisa',
                style: kInputStyle,
              ),
            ],
          ),
        ),
        if (context.mounted)
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
        Text(
          'Note:',
          style:
              kInputStyle.copyWith(fontSize: 13, color: Colors.grey.shade700),
        ).tr(),
        if (context.mounted)
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
              if (context.mounted)
                SizedBox(height: MediaQuery.of(context).size.height * 0.015),
              Text(
                '2. ${getTranslatedText("آپ کے اکاؤنٹ میں کافی بیلنس ہے۔", "Your Account has sufficient balance.")}',
                style: kInputStyle.copyWith(fontSize: 13),
              ),
            ],
          ),
        ),
        if (context.mounted)
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
        translateText: stepNum == 2 ? false : true,
        padding: const EdgeInsets.symmetric(vertical: 10),
        buttonName: stepNum == 2
            ? getTranslatedText(
                "ادائیگی کریں اور آرڈر اپ ڈیٹ کریں", 'Pay & Update order')
            : 'Next',
        onPressed: () async {
          if (!shouldProceedOnly) {
            if (error != null) {
              showMyBanner(context, error);
            }
            return;
          }
          if (stepNum == 2) {
            final o = widget.order;
            o.paymentMethod = paymentMethod!;
            //TODO pay the dues
            PaymentHelper paymentHelper = PaymentHelper();
            bool successful = false;
            if (mounted) {
              setState(() {
                isPayingDues = true;
              });
            }
            final paid = await paymentHelper.payAmount(
                accountNumber!,
                widget.order.tailorPaymentInfo.accountNumber,
                o.amountRemaining,
                paymentMethod!);
            if (paid) {
              o.advanceDeposited += o.amountRemaining;
              o.amountRemaining = 0;
              FireStoreHelper().updateOrder(o).then((value) {
                Fluttertoast.showToast(
                  msg: getTranslatedText("آرڈر کو کامیابی سے اپ ڈیٹ کیا گیا۔",
                      "Order updated successfully."),
                  textColor: Colors.white,
                  backgroundColor: kOrangeColor,
                );
                if (mounted) {
                  setState(() {
                    successful = value;
                    isPayingDues = false;
                  });
                }
                if (widget.order.rating.toInt() == 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RateTailorForOrder(order: widget.order),
                    ),
                  );
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
                  getTranslatedText(
                      "براہ مہربانی واجبات ادا کریں۔", 'Please pay the dues.'));
            }
            await Future.delayed(const Duration(seconds: 5)).then((value) {
              if (!successful && paid) {
                showMyBanner(
                    context, getTranslatedText("ٹائم آؤٹ.", "Timed out."));
                if (context.mounted) {
                  setState(() {
                    isPayingDues = false;
                  });
                }
                return;
              }
            });
          }
          if (stepNum < 2) {
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
      // countries: ["PK"],
    );
  }

  Widget depositRemainingEnterDepositAmount(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: size.width * 0.03,
        ),
        Text(
          getTranslatedText("بقیہ رقم جمع کروانا", 'Deposit Remaining'),
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
        if (widget.order.cloth!.delivery == DeliveryOption.viaAgent)
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
              "کل رقم:  ${widget.order.totalAmount + (widget.order.cloth!.delivery == DeliveryOption.viaAgent ? clothDeliveryChargesViaAgent : 0)} روپے۔",
              "total amount: Rs. ${widget.order.totalAmount + (widget.order.cloth!.delivery == DeliveryOption.viaAgent ? clothDeliveryChargesViaAgent : 0)}"),
          style: kInputStyle,
        ),
        SizedBox(
          height: size.width * 0.02,
        ),
        Text(
          getTranslatedText("جمع کرائی گئی رقم:", 'amount deposited:'),
          style: kInputStyle.copyWith(color: Colors.grey.shade700),
        ),
        Card(
          color: Colors.white24,
          shadowColor: Colors.black12,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              getTranslatedText("${widget.order.advanceDeposited} روپے",
                  "Rs. ${widget.order.advanceDeposited}"),
              style: kInputStyle,
            ),
          ),
        ),
        Text(
          getTranslatedText("باقی رقم:", "amount remaining:"),
          style: kInputStyle.copyWith(color: Colors.grey.shade700),
        ),
        Card(
          color: Colors.white24,
          shadowColor: Colors.black12,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              getTranslatedText(" ${widget.order.amountRemaining} روپے۔",
                  "Rs. ${widget.order.amountRemaining}"),
              style: kInputStyle,
            ),
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
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            getTranslatedText("آپ کو باقی تمام رقم ابھی جمع کرنی ہوگی.",
                "You must deposit all remaining money now."),
            style: kInputStyle.copyWith(fontSize: 13),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        buildNextButton(
            shouldProceedOnly: true,
            error: getTranslatedText(
                "ڈپازٹ کی رقم درج کریں۔ ", "Enter deposit amount.")),
      ],
    );
  }
}
