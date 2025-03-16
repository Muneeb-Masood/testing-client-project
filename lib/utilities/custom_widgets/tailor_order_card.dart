// ignore_for_file: use_build_context_synchronously

import 'package:test/main.dart';
import 'package:test/models/notification.dart';
import 'package:test/models/order.dart';
import 'package:test/networking/api_helper.dart';
import 'package:test/utilities/my_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jiffy/jiffy.dart';

import '../../models/measurement.dart';
import '../../networking/firestore_helper.dart';
import '../../networking/notification_helper.dart';
import '../../screens/customer/customer_order_info_page.dart';
import '../../screens/order_measurements_page.dart';
import '../../screens/tailor/tailor_main_screen.dart';
import '../../utilities/constants.dart';

///this is used to show the order info in tailor view
class TailorOrderCard extends StatelessWidget {
  final helper = FireStoreHelper();

  TailorOrderCard(
      {Key? key,
      required this.order,
      required this.onCustomerPressed,
      required this.onChangeStatus})
      : super(key: key);
  final DresssewOrder order;
  final ValueChanged<DresssewOrder> onCustomerPressed;
  final VoidCallback onChangeStatus;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: kSkinColor,
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: kOrangeColor, width: 0.3),
      ),
      elevation: 3.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //if order is being late
            if ((order.status == OrderStatus.inProgress ||
                    order.status == OrderStatus.justStarted) &&
                remainingTimeInHours() <= 48 &&
                remainingTimeInHours() >
                    0) //if less than zero, then order is late will be shown
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2),
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    FutureBuilder(
                        future: ApiHelper.translateText(remainingTime()),
                        builder: (_, st) {
                          return Text(
                            getTranslatedText(
                                "اس آرڈر کی ڈیڈ لائن ${st.data ?? '..'} کے اندر ہے۔",
                                'This order has deadline within ${remainingTime()}.'),
                            style:
                                kTextStyle.copyWith(color: Colors.red.shade700),
                          );
                        }),
                    const Divider(),
                  ],
                ),
              ),
            //order is late
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
                    Text(
                      'This order is late for its expected delivery date.',
                      style: kTextStyle.copyWith(color: Colors.red.shade700),
                    ).tr(),
                    const Divider(),
                  ],
                ),
              ),
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
                            "Dues have not been cleared by customer yet for this order.",
                            style: kTextStyle.copyWith(
                              color: Colors.red.shade700,
                              fontSize: 12,
                              height: 1.4,
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
                              //send to pay dues
                              NotificationHelper.sendNotification(
                                order,
                                NotificationType.toPayDuesAndAddReview,
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
                    const Divider(
                      thickness: 0.6,
                    ),
                  ],
                ),
              ),
            if (order.cloth == null)
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            "Order for this accepted order request hasn't been placed by customer yet.",
                            style: kInputStyle.copyWith(
                                color: Colors.red.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.w200),
                          ).tr(),
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.02),
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
                            onPressed: () async {
                              //this customer name doesn't matter here as it will be sent acc/ to customer id and only he can see this kinda noti
                              NotificationHelper.sendNotification(
                                order,
                                NotificationType.toCompleteSteps,
                              ).then((val) {
                                Fluttertoast.showToast(
                                  msg: getTranslatedText(
                                      "یاد دہانی کامیابی کے ساتھ بھیج دی گئی۔",
                                      'Reminder sent successfully.'),
                                  textColor: Colors.white,
                                  backgroundColor: kOrangeColor,
                                );
                              });
                            },
                          ),
                        )
                      ],
                    ),
                    const Divider(
                      thickness: 1,
                    ),
                  ],
                ),
              ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 5),
              leading: Padding(
                padding: EdgeInsets.only(
                    left: isUrduActivated ? 0 : 5.0,
                    right: isUrduActivated ? 5.0 : 0),
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text('customer: ').tr(),
                          Flexible(
                            child: FutureBuilder(
                                future: FireStoreHelper()
                                    .getCustomerWithDocId(order.customerId),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return TextButton(
                                      style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero),
                                      child: translatedTextWidget(
                                        snapshot.data!.name,
                                        style: reminderButtonStyle,
                                      ),
                                      onPressed: () {
                                        onCustomerPressed(order);
                                      },
                                    );
                                  }
                                  return Text(
                                    '...',
                                    style: kBoldTextStyle(),
                                  );
                                }),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.005),
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
                    //         'Send reminder',
                    //         style: TextStyle(
                    //             decoration: TextDecoration.underline,
                    //             color: Colors.blue.shade700,
                    //             fontFamily: 'Georgia',
                    //             fontSize: 12),
                    //       ),
                    //       onPressed: () {
                    //         //TODO add remaining deposit remainder implementation
                    //
                    //         Fluttertoast.showToast(
                    //             msg: 'Reminder sent successfully.',
                    //             backgroundColor: Colors.blue);
                    //       },
                    //     ),
                    //   ),
                    if (order.status == OrderStatus.completed &&
                        order.amountRemaining != 0)
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.005),
                    if (order.status == OrderStatus.notStartedYet)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                                text: getTranslatedText(
                                    "آپشن کے ذریعے پیمائش: ",
                                    "measurements via: "),
                                style: kInputStyle.copyWith(
                                    color: Colors.black, fontSize: 13),
                                children: [
                                  TextSpan(
                                    text: urduMeasurement(
                                        order.measurementChoice.name),
                                    // order.measurements != null
                                    //     ? 'received'
                                    //     : 'not received',
                                    style: kBoldTextStyle(),
                                  ),
                                ]),
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
                                    style: kBoldTextStyle(),
                                    // kInputStyle.copyWith(
                                    //   color:
                                    //   order.measurements == null
                                    //       ? Colors.red.shade700
                                    //       : Colors.green.shade700,
                                    //   fontSize: 13,
                                    // ),
                                    textAlign: TextAlign.right,
                                  ),
                                )
                              ],
                            ),
                          ),
                          //customer hasn't submitted measurements
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
                                          'Send reminder',
                                          style: reminderButtonStyle,
                                        ).tr(),
                                        onPressed: () {
                                          NotificationHelper.sendNotification(
                                            order,
                                            NotificationType
                                                .toSubmitMeasurements,
                                          ).then((value) =>
                                              Fluttertoast.showToast(
                                                msg: getTranslatedText(
                                                    "یاد دہانی کامیابی کے ساتھ بھیج دی گئی۔",
                                                    'Reminder sent successfully.'),
                                                textColor: Colors.white,
                                                backgroundColor: kOrangeColor,
                                              ));
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
                                                      order: order,
                                                      isTailorView: true),
                                            ),
                                          );
                                          onChangeStatus();
                                        },
                                      ),
                                    )
                              : order.measurements == null
                                  ? SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.034,
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
                                                      order: order,
                                                      isTailorView: true),
                                            ),
                                          );
                                          onChangeStatus();
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
                                                      order: order,
                                                      isTailorView: true),
                                            ),
                                          );
                                          onChangeStatus();
                                        },
                                      ),
                                    ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.005),
                          RichText(
                            text: TextSpan(
                                text: getTranslatedText(
                                    "ڈریس کا کپڑا دینے کا آپشن: ",
                                    "cloth via: "),
                                style: kInputStyle.copyWith(
                                    color: Colors.black, fontSize: 13),
                                children: [
                                  TextSpan(
                                    text: urduClothOption(
                                            order.cloth?.delivery.name) ??
                                        getTranslatedText(
                                            "ابھی تک شامل نہیں کیا گیا ہے",
                                            'not added'),
                                    style: kBoldTextStyle(),
                                    // kInputStyle.copyWith(
                                    //     color: order.cloth == null
                                    //         ? Colors.red.shade700
                                    //         : Colors.green.shade700,
                                    //     fontSize: 13),
                                  ),
                                ]),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.005),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "cloth: ",
                                style: kInputStyle.copyWith(
                                    color: Colors.black, fontSize: 13),
                              ).tr(),
                              Expanded(
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.03,
                                  child: DropdownButton<bool>(
                                    underline: null,
                                    isDense: true,
                                    borderRadius: BorderRadius.circular(10),
                                    dropdownColor: Colors.white,
                                    elevation: 0,
                                    icon: Icon(
                                      Icons.edit,
                                      size: 12,
                                      color: !order.clothReceivedByTailor
                                          ? Colors.red.shade700
                                          : Colors.green.shade700,
                                    ),
                                    value: order.clothReceivedByTailor,
                                    onChanged: (tailorHasReceivedCloth) {
                                      if (order.clothReceivedByTailor ==
                                          tailorHasReceivedCloth) return;
                                      if (order.cloth == null) {
                                        showMyDialog(
                                            context,
                                            'Error!',
                                            getTranslatedText(
                                                "پہلے کسٹمر کو اس مقبول آرڈر کی درخواست کا آرڈر دینے دیں۔",
                                                'Let the customer place order of this accepted order request.'),
                                            disposeAfterMillis: 4000);
                                        //also send a remainder.
                                        return;
                                      }
                                      order.clothReceivedByTailor =
                                          tailorHasReceivedCloth!;
                                      onChangeStatus();
                                      FireStoreHelper()
                                          .updateOrder(order)
                                          .then((value) {
                                        onChangeStatus();
                                        Fluttertoast.showToast(
                                          msg: getTranslatedText(
                                              "آرڈر اپ ڈیٹ کیا گیا ہے۔",
                                              'Order updated.'),
                                          textColor: Colors.white,
                                          backgroundColor: kOrangeColor,
                                        );
                                      });
                                    },
                                    items: [
                                      getTranslatedText(
                                          "ابھی تک موصول نہیں ہوا",
                                          'not received'),
                                      getTranslatedText(
                                          "موصول ہو چکا ہے", 'received')
                                    ].map((value) {
                                      return DropdownMenuItem<bool>(
                                        value: value == 'received' ||
                                                value == "موصول ہو چکا ہے"
                                            ? true
                                            : false,
                                        child: Text(
                                          value,
                                          style: kBoldTextStyle().copyWith(
                                            color: value == 'received' ||
                                                    value == "موصول ہو چکا ہے"
                                                ? Colors.green.shade700
                                                : Colors.red.shade700,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.005),
                        ],
                      ),
                    order.status == OrderStatus.completed
                        ? RichText(
                            text: TextSpan(
                              text: getTranslatedText("اِسٹیٹَس: ", "status: "),
                              style: kInputStyle.copyWith(color: Colors.black),
                              children: [
                                TextSpan(
                                  text: urduOrderStatus(order.status.name),
                                  style: kBoldTextStyle()
                                      .copyWith(color: Colors.green.shade700),
                                ),
                              ],
                            ),
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                const Text(
                                  'status: ',
                                  style: kInputStyle,
                                ).tr(),
                                Expanded(
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.028,
                                    child: DropdownButton<OrderStatus>(
                                      dropdownColor: Colors.white,
                                      isDense: true,
                                      borderRadius: BorderRadius.circular(10),
                                      elevation: 0,
                                      icon: Icon(
                                        Icons.edit,
                                        size: 12,
                                        color: order.status ==
                                                OrderStatus.completed
                                            ? Colors.blue.shade700
                                            : order.status ==
                                                    OrderStatus.notStartedYet
                                                ? Colors.red.shade700
                                                : Colors.green.shade700,
                                      ),
                                      value: order.status,
                                      onChanged: (status) async {
                                        if (order.status == status) return;
                                        if (order.cloth == null) {
                                          showMyDialog(
                                              context,
                                              'Error!',
                                              getTranslatedText(
                                                  "کسٹمر کو اس مقبول آرڈر کی درخواست کا آرڈر دینے دیں۔",
                                                  'let the customer place order of this accepted order request.'),
                                              disposeAfterMillis: 4000);
                                          //also send a remainder.
                                          return;
                                        }
                                        if (order.measurements == null) {
                                          if (order.measurementChoice ==
                                              MeasurementChoice.online) {
                                            showMyDialog(
                                                context,
                                                'Error!',
                                                getTranslatedText(
                                                    "گاہک کو پیمائش جمع کرنے دیں.",
                                                    'Let the customer submit measurements.'));
                                          } else {
                                            showMyDialog(
                                                context,
                                                'Error!',
                                                getTranslatedText(
                                                    "براہ کرم پیمائش شامل کریں.",
                                                    'Please add the measurements.'));
                                          }
                                          return;
                                        }
                                        if (!order.clothReceivedByTailor) {
                                          showMyDialog(
                                              context,
                                              'Error!',
                                              getTranslatedText(
                                                  "کپڑا وصول ہونے دیں۔",
                                                  'Let the cloth be received.'));
                                          //also send a remainder.
                                          return;
                                        }
                                        final orderCompleted = (order.status ==
                                                    OrderStatus.inProgress ||
                                                order.status ==
                                                    OrderStatus.justStarted) &&
                                            status == OrderStatus.completed;
                                        final orderStarted = order.status ==
                                                OrderStatus.notStartedYet &&
                                            (status == OrderStatus.inProgress ||
                                                status ==
                                                    OrderStatus.justStarted);
                                        //when tailor changes status from just started to inprogress
                                        final orderNowInProgress = order
                                                    .status ==
                                                OrderStatus.justStarted &&
                                            status == OrderStatus.inProgress;
                                        //if order is started
                                        if (orderStarted) {
                                          final date =
                                              await pickExpectedOrderDeliveryDate(
                                                  context);
                                          print(
                                              'Expected delivery date: $date');
                                          if (date == null) {
                                            showMyDialog(
                                                context,
                                                'Error!',
                                                getTranslatedText(
                                                    'ڈلیوری کی تاریخ شامل کریں۔',
                                                    'Add a delivery date.'));
                                            return;
                                          }
                                          order.status = status!;
                                          order.expectedDeliveryDate = date;
                                        } else if (orderNowInProgress) {
                                          order.status = status!;
                                        } else if (orderCompleted) {
                                          //hence order completed
                                          //if order completed set the corresponding delivered on date
                                          order.status = status!;
                                          order.deliveredOn =
                                              DateTime.now().toIso8601String();
                                        }

                                        //if order completed then send pay dues & review notification
                                        if (!orderCompleted) {
                                          NotificationHelper.sendNotification(
                                            order,
                                            NotificationType.orderStatusUpdated,
                                          );
                                        }
                                        onChangeStatus();
                                        helper
                                            .updateOrder(order)
                                            .then((value) => onChangeStatus);
                                        Fluttertoast.showToast(
                                          msg: getTranslatedText(
                                              'آرڈر اپ ڈیٹ کیا گیا ہے۔',
                                              'order updated.'),
                                          textColor: Colors.white,
                                          backgroundColor: kOrangeColor,
                                        );
                                        if (orderCompleted) {
                                          currentTailor!.onTimeDelivery =
                                              await calculateNewOnTimeDelivery();
                                          helper
                                              .updateTailor(currentTailor!)
                                              .then((val) => print(
                                                  'on-time-delivery updated'));
                                          NotificationHelper.sendNotification(
                                            order,
                                            NotificationType
                                                .toPayDuesAndAddReview,
                                          );
                                        }
                                      },
                                      items: (order.status ==
                                                  OrderStatus.notStartedYet
                                              ? OrderStatus.values.where(
                                                  (element) =>
                                                      element !=
                                                      OrderStatus.completed)
                                              : order.status ==
                                                          OrderStatus
                                                              .inProgress ||
                                                      order.status ==
                                                          OrderStatus
                                                              .justStarted
                                                  ? OrderStatus.values
                                                      .where((element) =>
                                                          element !=
                                                          OrderStatus
                                                              .notStartedYet)
                                                      .toList()
                                                  : OrderStatus.values)
                                          .map((OrderStatus value) {
                                        return DropdownMenuItem<OrderStatus>(
                                          value: value,
                                          child: Text(
                                            value.name,
                                            style: kBoldTextStyle().copyWith(
                                              color: value ==
                                                      OrderStatus.completed
                                                  ? Colors.blue.shade700
                                                  : value ==
                                                          OrderStatus
                                                              .notStartedYet
                                                      ? Colors.red.shade700
                                                      : Colors.green.shade700,
                                            ),
                                          ).tr(),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ]),
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
                              style: const TextStyle(
                                  height: 1.4, color: Colors.black),
                            );
                          }),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.002),
                    if (order.status == OrderStatus.completed &&
                        order.amountRemaining == 0)
                      order.rating == 0
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Not rated by customer yet.',
                                  style: TextStyle(color: Colors.grey),
                                ).tr(),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.032,
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero),
                                    child: Text(
                                      'Send reminder',
                                      style: reminderButtonStyle,
                                    ).tr(),
                                    onPressed: () {
                                      NotificationHelper.sendNotification(
                                        order,
                                        NotificationType.toAddReview,
                                      ).then((val) => Fluttertoast.showToast(
                                            msg: getTranslatedText(
                                                "یاد دہانی کامیابی کے ساتھ بھیج دی گئی۔",
                                                'Reminder sent successfully.'),
                                            textColor: Colors.white,
                                            backgroundColor: kOrangeColor,
                                          ));
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
                                        rating: order.rating,
                                        itemBuilder: (context, index) =>
                                            const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        itemCount: 5,
                                        itemSize: 15.0,
                                        unratedColor: Colors.grey.shade400,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
                      isTailorView: true,
                    );
                  }));
                  print("dress card tapped");
                  onChangeStatus();
                },
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

  Future<String?> pickExpectedOrderDeliveryDate(context) async {
    String? date;
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Card(
              color: kLightSkinColor,
              margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05,
                vertical: MediaQuery.of(context).size.height * 0.27,
              ),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Add expected delivery date for order',
                      style: kTitleStyle.copyWith(fontSize: 20),
                      textAlign: TextAlign.center,
                    ).tr(),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    FutureBuilder(
                        future: ApiHelper.translateText(Jiffy.parse(date!).yMMMMEEEEd),
                        builder: (_, st) {
                          return Text(date != null && date!.isNotEmpty
                              ? getTranslatedText(
                                  "آپ نے منتخب کیا: ${st.data ?? '..'}",
                                  "You selected: ${Jiffy.parse(date!).yMMMMEEEEd}")
                              : getTranslatedText(
                                  "تاریخ منتخب کریں", "Select a date"));
                        }),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final now = DateTime.now();
                              var dt = await showDatePicker(
                                context: context,
                                helpText: getTranslatedText(
                                    "متوقع ڈلیوری کی تاریخ",
                                    'Expected delivery date'),
                                fieldHintText: getTranslatedText(
                                    "متوقع آرڈر ڈلیوری کی تاریخ منتخب کریں",
                                    'Select expected order delivery date'),
                                fieldLabelText: getTranslatedText(
                                    "متوقع ڈلیوری کی تاریخ",
                                    'Expected delivery date'),
                                initialDate: now.add(const Duration(days: 7)),
                                firstDate: now,
                                lastDate: DateTime(now.year, 12),
                                // builder: (BuildContext context, Widget? child) {
                                //   return ,
                                //     child: child!,
                                //   );
                                // },
                              );

                              date = dt
                                  ?.add(const Duration(
                                    hours: 23,
                                    minutes: 59,
                                    seconds: 59,
                                    milliseconds: 999,
                                  ))
                                  .toIso8601String();
                              // date = dt?.toIso8601String();
                              print("expected date: $date");
                              setState(() {});
                              // Navigator.pop(context, date);
                            },
                            icon: const Icon(Icons.calendar_month),
                            label: Text(date == null || date!.isEmpty
                                    ? 'Pick'
                                    : 'Change')
                                .tr(), //bcz agr amount remaining haito rating b nh de hogi wo uske bad ka step haina
                            //but agr amuontremianing=0 hai or rate nh kiya to to just review krega tailor ka work
                          ),
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.05),
                        Flexible(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              if (date == null) {
                                showMyDialog(
                                    context,
                                    'Error!',
                                    getTranslatedText(
                                        "متوقع ترسیل کی تاریخ منتخب کریں۔",
                                        'Pick an expected delivery date.'));
                              } else {
                                Navigator.pop(context, date);
                              }
                            },
                            icon: const Icon(Icons.check),
                            label: const Text('Ok')
                                .tr(), //bcz agr amount remaining haito rating b nh de hogi wo uske bad ka step haina
                            //but agr amuontremianing=0 hai or rate nh kiya to to just review krega tailor ka work
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          });
        });
    return date;
  }

  Future<int> calculateNewOnTimeDelivery() async {
    print("old on-time delivery: ${currentTailor!.onTimeDelivery}");
    var completedOrders =
        await helper.loadCompletedOrdersOfTailor(currentTailor!.id!);
    final delayedOrders = completedOrders.where((order) {
      return DateTime.parse(order.deliveredOn!)
          .isAfter(DateTime.parse(order.expectedDeliveryDate!));
    }).toList();
    print(completedOrders.length);
    print(delayedOrders.length);
    final onTimeDelivery = (completedOrders.length - delayedOrders.length) /
        completedOrders.length;
    print(onTimeDelivery);
    print("new on-time delivery: ${(onTimeDelivery * 100).toInt()}");
    return (onTimeDelivery * 100).toInt();
  }

  String remainingTime() {
    String days = DateTime.parse(order.expectedDeliveryDate!)
        .difference(DateTime.now())
        .inDays
        .toString();
    if (days == "0") {
      days = getTranslatedText(
          "${DateTime.parse(order.expectedDeliveryDate!).difference(DateTime.now()).inHours.toString()} گھنٹے",
          "${DateTime.parse(order.expectedDeliveryDate!).difference(DateTime.now()).inHours.toString()} hour(s)");
      return "${DateTime.parse(order.expectedDeliveryDate!).difference(DateTime.now()).inHours.toString()} hour(s)";
    }
    return "$days day(s)";
    // return getTranslatedText("$days دنوں ", "$days day(s)");
  }

  int remainingTimeInHours() {
    return DateTime.parse(order.expectedDeliveryDate!)
        .difference(DateTime.now())
        .inHours;
  }
}
