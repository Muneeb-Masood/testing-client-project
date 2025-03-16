import 'package:test/models/order.dart';
import 'package:test/networking/api_helper.dart';
import 'package:test/screens/customer/customer_main_screen.dart';
import 'package:test/screens/customer/customer_order_info_page.dart';
import 'package:test/screens/order_measurements_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jiffy/jiffy.dart';

import '../../main.dart';
import '../../models/measurement.dart';
import '../../models/notification.dart';
import '../../networking/firestore_helper.dart';
import '../../networking/notification_helper.dart';
import '../../screens/customer/deposit_remaining.dart';
import '../../screens/customer/rate_tailor_for_order.dart';
import '../../screens/tailor/tailor_main_screen.dart';
import '../../utilities/constants.dart';

class CustomerOrderCard extends StatelessWidget {
  final helper = FireStoreHelper();

  CustomerOrderCard(
      {Key? key,
      required this.order,
      required this.onShopPressed,
      required this.onOrderUpdate})
      : super(key: key);
  final DresssewOrder order;
  final ValueChanged<DresssewOrder> onShopPressed;
  //when a customer adds measurements or etc
  final VoidCallback onOrderUpdate;
  @override
  Widget build(BuildContext context) {
    return Card(
      color: kSkinColor,
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: kOrangeColor, width: 0.25),
      ),
      elevation: 3.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //order started but still not completed & deadline is already met
            if (order.status != OrderStatus.completed &&
                order.status != OrderStatus.notStartedYet &&
                order.expectedDeliveryDate!
                        .compareTo(DateTime.now().toIso8601String()) ==
                    -1)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2),
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'This order is late for its expected delivery date.',
                            style: kTextStyle.copyWith(
                              color: Colors.red.shade700,
                              fontSize: 13,
                            ),
                          ).tr(),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.032,
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: TextButton(
                            style:
                                TextButton.styleFrom(padding: EdgeInsets.zero),
                            child: Text(
                              'Send reminder',
                              style: reminderButtonStyle,
                            ).tr(),
                            onPressed: () {
                              NotificationHelper.sendNotification(
                                order,
                                NotificationType.orderIsBeingLate,
                                customerName: currentCustomer!.name,
                                sentByTailor: false,
                              ).then(
                                (value) => Fluttertoast.showToast(
                                  msg: getTranslatedText(
                                      "یاد دہانی کامیابی کے ساتھ بھیج دی گئی۔",
                                      'Reminder sent successfully.'),
                                  textColor: Colors.white,
                                  backgroundColor: kOrangeColor,
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                    Divider(color: kOrangeColor),
                  ],
                ),
              ),
            //order completed but dues remaining
            if (order.status == OrderStatus.completed &&
                order.amountRemaining != 0)
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            "You have not cleared dues for this order yet.",
                            style: kInputStyle.copyWith(
                                color: Colors.red.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.w200),
                          ).tr(),
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.01),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.032,
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: TextButton(
                            style:
                                TextButton.styleFrom(padding: EdgeInsets.zero),
                            child: Text(
                              'Pay dues',
                              style: reminderButtonStyle,
                            ).tr(),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DepositRemainingDuesOfOrder(
                                    order: order,
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                    Divider(
                      thickness: 0.4,
                      color: kOrangeColor,
                    ),
                  ],
                ),
              ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 5),
              leading: Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: kOrangeColor,
                  child: CircleAvatar(
                    backgroundImage: (order.dressImage.contains('assets')
                        ? AssetImage(order.dressImage)
                        : NetworkImage(order.dressImage) as ImageProvider),
                    backgroundColor: Colors.white,
                    radius: 25,
                  ),
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (order.isCustomizationOnly)
                    Text("customization order", style: kBoldTextStyle(size: 14))
                        .tr(),
                  if (order.isCustomizationOnly)
                    const Divider(color: kDarkOrange),
                  Text(
                    getCategory(order.dressCategory),
                    style: kInputStyle.copyWith(fontSize: 18),
                  ).tr(),
                ],
              ),
              subtitle: DefaultTextStyle(
                style: kInputStyle.copyWith(color: Colors.black, fontSize: 13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                      child: TextButton(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: FutureBuilder(
                          future: ApiHelper.translateText(order.tailorShopName),
                          builder: (_, st) {
                            return Text(
                              getTranslatedText(
                                  st.data ?? '..', order.tailorShopName),
                              style: reminderButtonStyle,
                            );
                          },
                        ),
                        onPressed: () {
                          onShopPressed(order);
                        },
                      ),
                    ),
                    Text(
                      getTranslatedText(
                          "جمع کرائی گئی رقم:  ${order.advanceDeposited} روپے۔",
                          "amount deposited: Rs. ${order.advanceDeposited}"),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.005),
                    Text(
                      getTranslatedText("کل رقم:  ${order.totalAmount} روپے۔",
                          "total amount: Rs. ${order.totalAmount}"),
                    ),

                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.005),
                    if (order.status == OrderStatus.completed &&
                        order.amountRemaining != 0)
                      Text(
                        getTranslatedText(
                            "باقی رقم:  ${order.amountRemaining} روپے۔",
                            "amount remaining: Rs. ${order.amountRemaining}"),
                      ),
                    // if (order.status == OrderStatus.completed &&
                    //     order.amountRemaining != 0)
                    //   SizedBox(
                    //     height: MediaQuery.of(context).size.height * 0.032,
                    //     child: TextButton(
                    //       style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    //       child: Text(
                    //         'Pay dues',
                    //         style: TextStyle(
                    //             decoration: isUrduActivated
                    // ? null
                    // : TextDecoration.underline,
                    //             color: Colors.blue.shade700,
                    //             fontFamily: 'Georgia',
                    //             fontSize: 12),
                    //       ),
                    //       onPressed: () async {
                    //         //TODO add remaining deposit remainder implementation
                    //         await Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //             builder: (context) =>
                    //                 DepositRemainingDuesOfOrder(
                    //               order: order,
                    //             ),
                    //           ),
                    //         );
                    //         onOrderUpdate();
                    //       },
                    //     ),
                    //   ),
                    if (order.status == OrderStatus.completed &&
                        order.amountRemaining != 0)
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.005),
                    if (order.status != OrderStatus.completed)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: getTranslatedText("آپشن کے ذریعے پیمائش: ",
                                  "measurements via: "),
                              style: kInputStyle.copyWith(
                                color: Colors.black,
                                fontSize: 13,
                              ),
                              children: [
                                WidgetSpan(
                                  child: Text(
                                    urduMeasurement(
                                        order.measurementChoice.name),
                                    style: kBoldTextStyle().copyWith(
                                      color: Colors.green.shade700,
                                      fontSize: 13,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.005),
                          RichText(
                            text: TextSpan(
                              text: getTranslatedText(
                                  "پیمائش: ", "measurements: "),
                              style: kInputStyle.copyWith(
                                color: Colors.black,
                                fontSize: 13,
                              ),
                              children: [
                                WidgetSpan(
                                  child: Text(
                                    order.measurements != null
                                        ? getTranslatedText(
                                            "شامل کی جا چکی ہے", "added")
                                        : getTranslatedText(
                                            "ابھی تک شامل نہیں کی گئی ہے",
                                            "not added yet"),
                                    style: kBoldTextStyle().copyWith(
                                      color: order.measurements == null
                                          ? Colors.red.shade700
                                          : Colors.green.shade700,
                                      fontSize: 13,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                )
                              ],
                            ),
                          ),
                          order.measurementChoice == MeasurementChoice.online
                              ? order.measurements == null
                                  ? SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.032,
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero),
                                        child: Text(
                                          'Add Measurements',
                                          style: reminderButtonStyle,
                                        ).tr(),
                                        onPressed: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  OrderMeasurementsPage(
                                                      order: order),
                                            ),
                                          );
                                          if (order.measurements != null) {
                                            NotificationHelper.sendNotification(
                                              order,
                                              NotificationType
                                                  .customerAddedMeasurements,
                                              customerName:
                                                  currentCustomer!.name,
                                              sentByTailor: false,
                                            );
                                          }
                                          onOrderUpdate();
                                        },
                                      ),
                                    )
                                  : SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.032,
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero),
                                        child: Text(
                                          'View measurements',
                                          style: reminderButtonStyle,
                                        ).tr(),
                                        onPressed: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  OrderMeasurementsPage(
                                                      order: order),
                                            ),
                                          );
                                          onOrderUpdate();
                                        },
                                      ),
                                    )
                              : order.measurements == null
                                  ? const SizedBox()
                                  : SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.032,
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero),
                                        child: Text(
                                          'View measurements',
                                          style: reminderButtonStyle,
                                        ).tr(),
                                        onPressed: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  OrderMeasurementsPage(
                                                      order: order),
                                            ),
                                          );
                                          onOrderUpdate();
                                        },
                                      ),
                                    ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.005),
                        ],
                      ),
                    RichText(
                      text: TextSpan(
                          text: getTranslatedText(
                              "آرڈر اِسٹیٹَس: ", "order status: "),
                          style: kInputStyle.copyWith(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                          children: [
                            TextSpan(
                              text: urduOrderStatus(order.status.name),
                              style: kBoldTextStyle().copyWith(
                                color: order.status == OrderStatus.completed
                                    ? Colors.blue.shade700
                                    : order.status == OrderStatus.notStartedYet
                                        ? Colors.red.shade700
                                        : Colors.green.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ]),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.005),
                    if (order.status != OrderStatus.notStartedYet)
                      FutureBuilder(
                          future: ApiHelper.translateText(Jiffy.parse(
                                  order.status == OrderStatus.completed
                                      ? order.deliveredOn!
                                      : order.expectedDeliveryDate!)
                              .yMMMMEEEEd),
                          builder: (_, st) {
                            final date = Jiffy.parse(
                                    order.status == OrderStatus.completed
                                        ? order.deliveredOn!
                                        : order.expectedDeliveryDate!)
                                .yMMMMEEEEd;
                            return Text(
                              "${order.status == OrderStatus.completed ? getTranslatedText("مکمل ہونے کی تاریخ: ", "delivered on: ") : getTranslatedText("متوقع مکمل ہونے کی تاریخ: ", "expected delivery date: ")} ${getTranslatedText(st.data ?? '..', date)}",
                            );
                          }),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.005),
                    //rating bar
                    if (order.status == OrderStatus.completed &&
                        order.amountRemaining == 0)
                      order.rating == 0
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "you haven't rated yet.",
                                  style: TextStyle(color: Colors.grey),
                                ).tr(),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.032,
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero),
                                    child: Text(
                                      'Rate now ',
                                      style: reminderButtonStyle,
                                    ).tr(),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              RateTailorForOrder(order: order),
                                        ),
                                      ).then((value) => onOrderUpdate());
                                    },
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${currentTailor != null ? getTranslatedText("گاہک نے درجہ بندی کی ہے: ", "customer rated: ") : getTranslatedText("آپ نے درجہ بندی کی ہے: ", "you rated: ")}(${order.rating.toString()})',
                                ),
                                Center(
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    child: FittedBox(
                                      child: RatingBarIndicator(
                                        unratedColor: Colors.grey.shade400,
                                        rating: order.rating,
                                        itemBuilder: (context, index) =>
                                            const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        itemCount: 5,
                                        itemSize: 15.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                  ],
                ),
              ),
              trailing: IconButton(
                style: IconButton.styleFrom(padding: EdgeInsets.zero),
                icon: Icon(
                    isUrduActivated
                        ? FontAwesomeIcons.arrowLeft
                        : FontAwesomeIcons.arrowRight,
                    size: 20,
                    color: Theme.of(context).primaryColor),
                onPressed: () async {
                  await Navigator.push(context,
                      MaterialPageRoute(builder: (context) {
                    return OrderInfoPage(
                      order: order,
                      isTailorView: false,
                    );
                  }));
                  print("dress card tapped from cusoer card");
                  // onOrderUpdate();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
