// ignore_for_file: use_build_context_synchronously

import 'package:test/networking/api_helper.dart';
import 'package:test/networking/firestore_helper.dart';
import 'package:test/screens/customer/customer_order_info_page.dart';
import 'package:test/screens/customer/rate_tailor_for_order.dart';
import 'package:test/screens/customer/steps_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../models/notification.dart';
import '../models/order.dart';
import '../screens/customer/deposit_remaining.dart';
import '../utilities/constants.dart';

class NotificationHelper {
  static final FireStoreHelper _helper = FireStoreHelper();

  ///sending notifications
  static Future<bool> sendNotification(
      DresssewOrder order, NotificationType type,
      {bool sentByTailor = true, String customerName = ''}) async {
    final notification = MyNotification(
      orderId: order.orderId!,
      tailorId: order.tailorId,
      customerId: order.customerId,
      dressCategory: order.dressCategory,
      tailorShopName: order.tailorShopName,
      timestamp: DateTime.now().toIso8601String(),
      customerName: customerName,
      sentByTailor: sentByTailor,
      type: type,
    );
    return _helper.addNotification(notification);
  }

  ///showing notifications
  Future<void> showNotification(
      BuildContext context, MyNotification notification) async {
    _helper.deleteNotification(notification);
    switch (notification.type) {
      case NotificationType.toCompleteSteps:
        return _showNotiForCompletingSteps(context, notification);

      case NotificationType.customerCompletedSteps:
        return _showNotiForCustomerCompletedSteps(context, notification);

      case NotificationType.toSubmitMeasurements:
        return _showNotiForSubmittingMeasurements(context, notification);

      case NotificationType.customerAddedMeasurements:
        return _showNotiForCustomerAddedMeasurements(context, notification);

      case NotificationType.customerToSubmitCloth:
        return _showNotiForCustomerToSubmitCloth(context, notification);

      case NotificationType.orderStatusUpdated:
        return _showNotiForOrderStatusUpdated(context, notification);

      // case NotificationType.deadlineComingInTwoDays:
      //   return _showNotiForDeadlineComingInTwoDays(context, notification);

      case NotificationType.orderIsBeingLate:
        return _showNotiForOrderIsBeingLate(context, notification);

      case NotificationType.toPayDuesAndAddReview:
        return showNotiForPayDuesAndAddReview(context, notification);

      case NotificationType.toAddReview:
        return _showNotiForAddingReview(context, notification);

      case NotificationType.customerAddedReview:
        return _showNotiForCustomerAddedReview(context, notification);
    }
  }

  Future<void> _showNotiForCompletingSteps(
      BuildContext context, MyNotification notification) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Card(
            color: kLightSkinColor,
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: MediaQuery.of(context).size.height * 0.28,
            ),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: kDarkOrange),
                        ),
                      ),
                    ),
                    Text("* Reminder *",
                            style: kTitleStyle.copyWith(
                                fontSize: 25, color: Colors.green.shade700))
                        .tr(),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: FutureBuilder(
                          future: ApiHelper.translateText(
                              notification.tailorShopName),
                          builder: (_, st) {
                            return Text(
                              getTranslatedText(
                                  "آپ کے پاس '${notification.dressCategory}' کا آرڈر دینے کے لئے بقیہ مراحل کو مکمل کرنے کے لئے '${st.data ?? '..'}' سے ایک یاد دہانی ہے۔",
                                  "You have a Reminder from '${notification.tailorShopName}' to complete remaining steps to place an order of '${getCategory(notification.dressCategory)}'."),
                              textAlign: TextAlign.center,
                              style: kInputStyle.copyWith(fontSize: 15),
                            );
                          }),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    ElevatedButton(
                      onPressed: () async {
                        final order = await _helper
                            .getOrderWithOrderId(notification.orderId);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StepsScreen(
                                order: order!, comingFromANotification: true),
                          ),
                        ).then((value) => Navigator.pop(context));
                      },
                      child: Text(
                        'Do it now',
                        style: kInputStyle.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ).tr(), //bcz agr amount remaining haito rating b nh de hogi wo uske bad ka step haina
                      //but agr amuontremianing=0 hai or rate nh kiya to to just review krega tailor ka work
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<void> _showNotiForCustomerCompletedSteps(
      BuildContext context, MyNotification notification) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Card(
            color: kLightSkinColor,
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: MediaQuery.of(context).size.height * 0.3,
            ),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: kDarkOrange)),
                      ),
                    ),
                    Text("* Info *",
                            style: kTitleStyle.copyWith(
                                fontSize: 25, color: Colors.green.shade700))
                        .tr(),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: FutureBuilder(
                          future: ApiHelper.translateText(
                              notification.tailorShopName),
                          builder: (_, st) {
                            return Text(
                              getTranslatedText(
                                "'${st.data ?? '..'}' نے '${getCategory(notification.dressCategory)}' کا آرڈر مکمل کر لیا ہے، آپ اب اس پر کام شروع کر سکتے ہیں۔",
                                "'${notification.customerName}' has completed placing order of '${getCategory(notification.dressCategory)}', you can start working on it now.",
                              ),
                              textAlign: TextAlign.center,
                              style: kInputStyle.copyWith(fontSize: 15),
                            );
                          }),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    ElevatedButton(
                      onPressed: () async {
                        final order = await _helper
                            .getOrderWithOrderId(notification.orderId);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderInfoPage(
                                order: order!, isTailorView: true),
                          ),
                        ).then((value) => Navigator.pop(context));
                      },
                      child: Text(
                        'View order',
                        style: kInputStyle.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ).tr(), //bcz agr amount remaining haito rating b nh de hogi wo uske bad ka step haina
                      //but agr amuontremianing=0 hai or rate nh kiya to to just review krega tailor ka work
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<void> _showNotiForSubmittingMeasurements(
      BuildContext context, MyNotification notification) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Card(
            color: kLightSkinColor,
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: MediaQuery.of(context).size.height * 0.26,
            ),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: kDarkOrange)),
                      ),
                    ),
                    Text("* Reminder *",
                            style: kTitleStyle.copyWith(
                                fontSize: 25, color: Colors.green.shade700))
                        .tr(),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: FutureBuilder(
                          future: ApiHelper.translateText(
                              notification.tailorShopName),
                          builder: (_, st) {
                            return Text(
                              getTranslatedText(
                                "آپ کے پاس '${getCategory(notification.dressCategory)}' کے آرڈر کے لئے پیمائش شامل کرنے کے لئے '${st.data ?? '..'}' سے ایک یاد دہانی ہے، کیونکہ آپ نے 'آن لائن' آپشن کے ذریعے پیمائش کا انتخاب کیا ہے۔",
                                "You have a Reminder from '${notification.tailorShopName}' for adding measurements for order of '${getCategory(notification.dressCategory)}', as you have chosen measurements 'via online' option.",
                              ),
                              textAlign: TextAlign.center,
                              style: kInputStyle.copyWith(fontSize: 15),
                            );
                          }),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    ElevatedButton(
                      onPressed: () async {
                        final order = await _helper
                            .getOrderWithOrderId(notification.orderId);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderInfoPage(
                                order: order!, isTailorView: false),
                          ),
                        ).then((value) => Navigator.pop(context));
                      },
                      child: Text(
                        'View order',
                        style: kInputStyle.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ).tr(),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<void> _showNotiForCustomerAddedMeasurements(
      BuildContext context, MyNotification notification) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Card(
            color: kLightSkinColor,
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: MediaQuery.of(context).size.height * 0.3,
            ),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: kDarkOrange)),
                      ),
                    ),
                    Text("* Info *",
                            style: kTitleStyle.copyWith(
                                fontSize: 25, color: Colors.green.shade700))
                        .tr(),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: FutureBuilder(
                          future: ApiHelper.translateText(
                              notification.customerName),
                          builder: (_, st) {
                            return Text(
                              getTranslatedText(
                                "'${st.data ?? '..'}' نے '${getCategory(notification.dressCategory)}' کے آرڈر کے لیے پیمائش شامل کی ہے، اس پر ایک نظر ڈالیں۔",
                                "'${notification.customerName}' has added measurements for the order of '${getCategory(notification.dressCategory)}', take a look at it.",
                              ),
                              textAlign: TextAlign.center,
                              style: kInputStyle.copyWith(fontSize: 15),
                            );
                          }),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    ElevatedButton(
                      onPressed: () async {
                        final order = await _helper
                            .getOrderWithOrderId(notification.orderId);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderInfoPage(
                                order: order!, isTailorView: true),
                          ),
                        ).then((value) => Navigator.pop(context));
                      },
                      child: Text(
                        'View order',
                        style: kInputStyle.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ).tr(), //bcz agr amount remaining haito rating b nh de hogi wo uske bad ka step haina
                      //but agr amuontremianing=0 hai or rate nh kiya to to just review krega tailor ka work
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<void> _showNotiForCustomerToSubmitCloth(
      BuildContext context, MyNotification notification) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Card(
            color: kLightSkinColor,
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: MediaQuery.of(context).size.height * 0.26,
            ),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: kDarkOrange)),
                      ),
                    ),
                    Text("* Reminder *",
                            style: kTitleStyle.copyWith(
                                fontSize: 25, color: Colors.green.shade700))
                        .tr(),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: FutureBuilder(
                          future: ApiHelper.translateText(
                              notification.tailorShopName),
                          builder: (_, st) {
                            return Text(
                              getTranslatedText(
                                "آپ کے پاس '${getCategory(notification.dressCategory)}' کے آرڈر کے لیے کپڑا جمع کرانے کے لیے '${st.data ?? '..'}' کی طرف سے ایک یاد دہانی ہے، کیونکہ آپ نے 'خود ہی' کے آپشن کے ذریعے کپڑے جمع کرانے کا انتخاب کیا ہے۔",
                                "You have a Reminder from '${notification.tailorShopName}' to submit cloth for order of '${getCategory(notification.dressCategory)}', as you have chosen cloth 'via myself' option.",
                              ),
                              textAlign: TextAlign.center,
                              style: kInputStyle.copyWith(fontSize: 15),
                            );
                          }),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    ElevatedButton(
                      onPressed: () async {
                        final order = await _helper
                            .getOrderWithOrderId(notification.orderId);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderInfoPage(
                                order: order!, isTailorView: false),
                          ),
                        ).then((value) => Navigator.pop(context));
                      },
                      child: Text(
                        'View order',
                        style: kInputStyle.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ).tr(), //bcz agr amount remaining haito rating b nh de hogi wo uske bad ka step haina
                      //but agr amuontremianing=0 hai or rate nh kiya to to just review krega tailor ka work
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<void> _showNotiForOrderStatusUpdated(
      BuildContext context, MyNotification notification) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Card(
            color: kLightSkinColor,
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: MediaQuery.of(context).size.height * 0.28,
            ),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: kDarkOrange)),
                      ),
                    ),
                    Text("* Update *",
                            style: kTitleStyle.copyWith(
                                fontSize: 25, color: Colors.green.shade700))
                        .tr(),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: FutureBuilder(
                          future: ApiHelper.translateText(
                              notification.tailorShopName),
                          builder: (_, st) {
                            return Text(
                              getTranslatedText(
                                "${getCategory(notification.dressCategory)}' کے لئے آپ کے آرڈر اسٹیٹَس کو '${st.data ?? '..'}' کی جانب سے اپ ڈیٹ کیا گیا ہے، اس پر ایک نظر ڈالیں۔",
                                "Order status of your order for '${getCategory(notification.dressCategory)}' has been updated by '${notification.tailorShopName}', take a look at it.",
                              ),
                              textAlign: TextAlign.center,
                              style: kInputStyle.copyWith(fontSize: 15),
                            );
                          }),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    ElevatedButton(
                      onPressed: () async {
                        final order = await _helper
                            .getOrderWithOrderId(notification.orderId);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderInfoPage(
                                order: order!, isTailorView: false),
                          ),
                        ).then((value) => Navigator.pop(context));
                      },
                      child: Text(
                        'View order',
                        style: kInputStyle.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ).tr(), //bcz agr amount remaining haito rating b nh de hogi wo uske bad ka step haina
                      //but agr amuontremianing=0 hai or rate nh kiya to to just review krega tailor ka work
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<void> _showNotiForDeadlineComingInTwoDays(
      BuildContext context, MyNotification notification) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Card(
            color: kLightSkinColor,
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: MediaQuery.of(context).size.height * 0.3,
            ),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: kDarkOrange)),
                      ),
                    ),
                    Text("* Warning *",
                            style: kTitleStyle.copyWith(
                                fontSize: 25, color: Colors.amber.shade600))
                        .tr(),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(
                        getTranslatedText(
                          "${getCategory(notification.dressCategory)} کے آرڈر کی ڈیڈ لائن دو دن کے اندر آ رہی ہے۔",
                          "The deadline for the order of '${getCategory(notification.dressCategory)}' is nearing within two days.",
                        ),
                        textAlign: TextAlign.center,
                        style: kInputStyle.copyWith(fontSize: 15),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    ElevatedButton(
                      onPressed: () async {
                        final order = await _helper
                            .getOrderWithOrderId(notification.orderId);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderInfoPage(
                                order: order!, isTailorView: true),
                          ),
                        ).then((value) => Navigator.pop(context));
                      },
                      child: const Text(
                        'View order',
                      ).tr(),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<void> _showNotiForOrderIsBeingLate(
      BuildContext context, MyNotification notification) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Card(
            color: kLightSkinColor,
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: MediaQuery.of(context).size.height * 0.3,
            ),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: kDarkOrange)),
                      ),
                    ),
                    Text("* Reminder *",
                            style: kTitleStyle.copyWith(
                                fontSize: 25, color: Colors.green.shade700))
                        .tr(),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: FutureBuilder(
                          future: ApiHelper.translateText(
                              notification.customerName),
                          builder: (_, st) {
                            return Text(
                              getTranslatedText(
                                "آپ کے پاس '${st.data ?? '..'}' کی طرف سے یاد دہانی ہے کہ اس کا '${getCategory(notification.dressCategory)}' کا آرڈرکو دیر ہو گئی ہے۔",
                                "You have a Reminder from '${notification.customerName}' that his order of '${getCategory(notification.dressCategory)}' is being late.",
                              ),
                              textAlign: TextAlign.center,
                              style: kInputStyle.copyWith(fontSize: 15),
                            );
                          }),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    ElevatedButton(
                      onPressed: () async {
                        final order = await _helper
                            .getOrderWithOrderId(notification.orderId);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderInfoPage(
                                order: order!, isTailorView: true),
                          ),
                        ).then((value) => Navigator.pop(context));
                      },
                      child: Text(
                        'View order',
                        style: kInputStyle.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ).tr(), //bcz agr amount remaining haito rating b nh de hogi wo uske bad ka step haina
                      //but agr amuontremianing=0 hai or rate nh kiya to to just review krega tailor ka work
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<void> showNotiForPayDuesAndAddReview(
      BuildContext context, MyNotification notification) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Card(
            color: kLightSkinColor,
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: MediaQuery.of(context).size.height * 0.24,
            ),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: kDarkOrange)),
                      ),
                    ),
                    Text("* Order Completed *",
                            style: kTitleStyle.copyWith(
                                fontSize: 25, color: Colors.green.shade700))
                        .tr(),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: FutureBuilder(
                          future: ApiHelper.translateText(
                              notification.tailorShopName),
                          builder: (_, st) {
                            return Text(
                              getTranslatedText(
                                "'${getCategory(notification.dressCategory)}' کے لئے آپ کا آرڈر '${st.data ?? '..'}' کی جانب سے مکمل کیا گیا ہے، بقیہ واجبات ادا کریں اور درزی کا جائزہ دیں۔",
                                "Your order for '${getCategory(notification.dressCategory)}' is completed by '${notification.tailorShopName}', pay remaining dues & review the tailor.",
                              ),
                              textAlign: TextAlign.center,
                              style: kInputStyle.copyWith(fontSize: 15),
                            );
                          }),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.65,
                          child: ElevatedButton(
                            onPressed: () async {
                              final order = await _helper
                                  .getOrderWithOrderId(notification.orderId);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderInfoPage(
                                      order: order!, isTailorView: false),
                                ),
                              ).then((value) => Navigator.pop(context));
                            },
                            child: Text(
                              'View order',
                              style: kInputStyle.copyWith(
                                  fontSize: 13, color: Colors.white),
                            ).tr(), //bcz agr amount remaining haito rating b nh de hogi wo uske bad ka step haina
                            //but agr amuontremianing=0 hai or rate nh kiya to to just review krega tailor ka work
                          ),
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.03),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.65,
                          child: ElevatedButton(
                            onPressed: () async {
                              final order = await _helper
                                  .getOrderWithOrderId(notification.orderId);
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DepositRemainingDuesOfOrder(
                                          order: order!),
                                ),
                              );
                            },
                            child: Text(
                              getTranslatedText(
                                  "واجبات کی ادائیگی اور جائزہ شامل کریں",
                                  'Pay dues & Add Review'),
                              textAlign: TextAlign.center,
                              style: kInputStyle.copyWith(
                                  fontSize: 13, color: Colors.white),
                            ), //bcz agr amount remaining haito rating b nh de hogi wo uske bad ka step haina
                            //but agr amuontremianing=0 hai or rate nh kiya to to just review krega tailor ka work
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<void> _showNotiForAddingReview(
      BuildContext context, MyNotification notification) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Card(
            color: kLightSkinColor,
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: MediaQuery.of(context).size.height * 0.24,
            ),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: kDarkOrange)),
                      ),
                    ),
                    Text("* Reminder *",
                            style: kTitleStyle.copyWith(
                                fontSize: 25, color: Colors.green.shade700))
                        .tr(),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: FutureBuilder(
                          future: ApiHelper.translateText(
                              notification.tailorShopName),
                          builder: (_, st) {
                            return Text(
                              getTranslatedText(
                                "آپ کے پاس '${getCategory(notification.dressCategory)}' کے آرڈر کے لئے جائزہ شامل کرنے کے لئے '${st.data ?? '..'}' سے ایک یاد دہانی ہے۔ ہمیں بتائیں کہ آپ کا تجربہ کیسا رہا.",
                                "You have a Reminder from '${notification.tailorShopName}' to add a review for order of '${getCategory(notification.dressCategory)}'. Tell us how was your experience.",
                              ),
                              textAlign: TextAlign.center,
                              style: kInputStyle.copyWith(fontSize: 15),
                            );
                          }),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: ElevatedButton(
                            onPressed: () async {
                              final order = await _helper
                                  .getOrderWithOrderId(notification.orderId);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderInfoPage(
                                      order: order!, isTailorView: false),
                                ),
                              ).then((value) => Navigator.pop(context));
                            },
                            child: Text(
                              'View order',
                              style: kInputStyle.copyWith(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ).tr(), //bcz agr amount remaining haito rating b nh de hogi wo uske bad ka step haina
                            //but agr amuontremianing=0 hai or rate nh kiya to to just review krega tailor ka work
                          ),
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.03),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: ElevatedButton(
                            onPressed: () async {
                              final order = await _helper
                                  .getOrderWithOrderId(notification.orderId);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RateTailorForOrder(order: order!),
                                ),
                              ).then((value) => Navigator.pop(context));
                            },
                            child: Text(
                              getTranslatedText(
                                  "جائزہ شامل کریں", 'Add Review'),
                              style: kInputStyle.copyWith(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ), //bcz agr amount remaining haito rating b nh de hogi wo uske bad ka step haina
                            //but agr amuontremianing=0 hai or rate nh kiya to to just review krega tailor ka work
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<void> _showNotiForCustomerAddedReview(
      BuildContext context, MyNotification notification) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Card(
            color: kLightSkinColor,
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: MediaQuery.of(context).size.height * 0.3,
            ),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: kDarkOrange)),
                      ),
                    ),
                    Text("* Info *",
                            style: kTitleStyle.copyWith(
                                fontSize: 25, color: Colors.green.shade700))
                        .tr(),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: FutureBuilder(
                          future: ApiHelper.translateText(
                              notification.customerName),
                          builder: (_, st) {
                            return Text(
                              getTranslatedText(
                                "'${st.data ?? '..'}' نے '${getCategory(notification.dressCategory)}' کے آرڈر پر ایک جائزہ شامل کیا ہے، اس پر ایک نظر ڈالیں۔",
                                "'${notification.customerName}' has added a review on order of '${getCategory(notification.dressCategory)}', take a look at it.",
                              ),
                              textAlign: TextAlign.center,
                              style: kInputStyle.copyWith(fontSize: 15),
                            );
                          }),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    ElevatedButton(
                      onPressed: () async {
                        final order = await _helper
                            .getOrderWithOrderId(notification.orderId);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderInfoPage(
                                order: order!, isTailorView: true),
                          ),
                        ).then((value) => Navigator.pop(context));
                      },
                      child: Text(
                        'View order',
                        style: kInputStyle.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ).tr(), //bcz agr amount remaining haito rating b nh de hogi wo uske bad ka step haina
                      //but agr amuontremianing=0 hai or rate nh kiya to to just review krega tailor ka work
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
