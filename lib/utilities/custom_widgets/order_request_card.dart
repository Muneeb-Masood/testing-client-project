import 'package:test/main.dart';
import 'package:test/models/order.dart';
import 'package:test/utilities/custom_widgets/rectangular_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';

import '../../networking/api_helper.dart';
import '../../utilities/constants.dart';

class OrderRequestCard extends StatelessWidget {
  const OrderRequestCard(
      {Key? key,
      required this.orderRequest,
      required this.onCustomerPressed,
      required this.onOrderRequestStatusChanged})
      : super(key: key);
  final OrderRequest orderRequest;
  final ValueChanged<OrderRequest> onCustomerPressed;
  final Function(OrderRequest, OrderRequestStatus) onOrderRequestStatusChanged;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Card(
      color: kSkinColor,
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: kOrangeColor, width: 0.4),
      ),
      elevation: 3.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                radius: 26,
                backgroundColor: kOrangeColor,
                child: CircleAvatar(
                  backgroundImage: (orderRequest.dressImage.contains('assets')
                      ? AssetImage(orderRequest.dressImage)
                      : NetworkImage(orderRequest.dressImage) as ImageProvider),
                  backgroundColor: kLightSkinColor,
                  radius: 25,
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (orderRequest.isCustomizationOnly)
                    Text("customization order request", style: kBoldTextStyle())
                        .tr(),
                  if (orderRequest.isCustomizationOnly)
                    const Divider(
                      color: kDarkOrange,
                      endIndent: 20,
                    ),
                  Text(
                    getCategory(orderRequest.dressInfo.category),
                    style: kInputStyle.copyWith(fontSize: 18),
                  ).tr(),
                ],
              ),
              subtitle: DefaultTextStyle(
                style: kInputStyle.copyWith(color: Colors.black, fontSize: 13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(getTranslatedText("گاہک کا نام: ", 'customer: '),
                            style: kInputStyle),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03,
                          child: TextButton(
                            style:
                                TextButton.styleFrom(padding: EdgeInsets.zero),
                            child: translatedTextWidget(
                              orderRequest.customer.name,
                              style: reminderButtonStyle,
                            ),
                            onPressed: () {
                              onCustomerPressed(orderRequest);
                            },
                          ),
                        ),
                      ],
                    ),
                    Text(
                      getTranslatedText(
                          "رقم:  ${orderRequest.isCustomizationOnly ? orderRequest.dressInfo.customizationPrice : orderRequest.dressInfo.price} روپے۔",
                          "amount: Rs. ${orderRequest.isCustomizationOnly ? orderRequest.dressInfo.customizationPrice : orderRequest.dressInfo.price}"),
                      style: kInputStyle,
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.003),
                    RichText(
                      text: TextSpan(
                          text: getTranslatedText(
                              "آپشن کے ذریعے پیمائش: ", "measurements via: "),
                          style: kInputStyle.copyWith(fontSize: 13),
                          children: [
                            TextSpan(
                              text: urduMeasurement(
                                  orderRequest.measurementChoice.name),
                              style: kBoldTextStyle(),
                            ),
                          ]),
                    ),
                    // SizedBox(
                    //     height: MediaQuery.of(context).size.height * 0.003),
                    // RichText(
                    //   text: TextSpan(
                    //       text: "Measurements: ",
                    //       style: kInputStyle.copyWith(
                    //           color: Colors.black, fontSize: 13),
                    //       children: [
                    //         TextSpan(
                    //           text: 'not received',
                    //           style: kInputStyle.copyWith(
                    //               color: Colors.red.shade600, fontSize: 13),
                    //         ),
                    //       ]),
                    // ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.003),
                    // RichText(
                    //   text: TextSpan(
                    //       text: "Cloth: ",
                    //       style: kInputStyle.copyWith(
                    //           color: Colors.black, fontSize: 13),
                    //       children: [
                    //         TextSpan(
                    //           text: 'not received',
                    //           style: kInputStyle.copyWith(
                    //               color: Colors.red.shade600, fontSize: 13),
                    //         ),
                    //       ]),
                    // ),
                    // SizedBox(
                    //     height: MediaQuery.of(context).size.height * 0.003),
                    FutureBuilder(
                      future: ApiHelper.translateText(
                          differenceGreaterThan1(orderRequest.date!)
                              ? Jiffy.parse(orderRequest.date!).yMMMMEEEEd
                              : Jiffy.parse(orderRequest.date!).fromNow()),
                      builder: (_, st) {
                        return Text(
                          getTranslatedText("وقت: ${st.data ?? '..'}",
                              "timestamp: ${differenceGreaterThan1(orderRequest.date!) ? Jiffy.parse(orderRequest.date!).yMMMMEEEEd : " ${Jiffy.parse(orderRequest.date!).fromNow()}"}"),
                          style: kInputStyle,
                        );
                      },
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.015),
                    Row(
                      children: [
                        SizedBox(
                          width: size.width * 0.3,
                          height: size.width * 0.08,
                          child: RectangularRoundedButton(
                              buttonName: 'Accept',
                              fontSize: 15,
                              onPressed: () {
                                onOrderRequestStatusChanged(
                                    orderRequest, OrderRequestStatus.accepted);
                              },
                              color: Colors.green.shade400,
                              padding: EdgeInsets.zero),
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.02),
                        SizedBox(
                          width: size.width * 0.3,
                          height: size.width * 0.08,
                          child: RectangularRoundedButton(
                            buttonName: 'Decline',
                            fontSize: 15,
                            onPressed: () {
                              onOrderRequestStatusChanged(
                                  orderRequest, OrderRequestStatus.declined);
                            },
                            color: Colors.red.shade400,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool differenceGreaterThan1(String date) {
    // Define the two dates to compare
    DateTime date1 = DateTime.parse(date);
    DateTime date2 = DateTime.now();

// Calculate the difference between the two dates in days
    int differenceInDays = date2.difference(date1).inDays;

// Check if the difference is greater than a week (7 days)
    if (differenceInDays > 1) {
      return true;
    } else {
      return false;
    }
  }

  urduMeasurement(String text) {
    final map = {
      "online": "آن لائن",
      "physical": "ذاتی طور پر",
      "viaAgent": "ایجنٹ کے ذریعے",
    };
    if (isUrduActivated) {
      return map[text];
    }
    return spaceSeparatedText(text);
  }
}
