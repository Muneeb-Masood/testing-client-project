import 'dart:async';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:test/main.dart';
import 'package:test/models/tailor.dart';
import 'package:test/networking/firestore_helper.dart';
import 'package:test/screens/tailor/tailor_customers_page.dart';
import 'package:test/screens/tailor/tailor_orders_page.dart';
import 'package:test/utilities/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../models/notification.dart';
import '../../networking/notification_helper.dart';
import 'tailor_profile.dart';

Tailor? currentTailor;

class TailorMainScreen extends StatefulWidget {
  static const id = "/tailor_main_screen";

  const TailorMainScreen({super.key});
  @override
  _TailorMainScreenState createState() => _TailorMainScreenState();
}

class _TailorMainScreenState extends State<TailorMainScreen> {
  int index = 0;
  final helper = FireStoreHelper();

  Timer? notificationTimer;

  var timerSeconds = 5;

  final notiHelper = NotificationHelper();

  @override
  void initState() {
    super.initState();
    startNotificationTimer();
    Future.delayed(const Duration(milliseconds: 2), () {
      //setting urdu
      if (context.locale == const Locale("ur", "PK")) {
        isUrduActivated = true;
      } else {
        isUrduActivated = false;
      }
      if (mounted) {
        setState(() {});
      }
    });
    loadCurrentTailor(() {
      if (mounted) {
        setState(() {});
        print('Current tailor loaded successfully.');
      }
    });
  }

  startNotificationTimer() {
    notificationTimer =
        Timer.periodic(Duration(seconds: timerSeconds), (timer) async {
      getNotifications();
    });
  }

  getNotifications() async {
    var notis = await helper.getNotifications(appUser!.customerOrTailorId!);
    //the notis which haven't been seen yet
    notis = notis.where((element) => !element.sentByTailor).toList();
    if (notis.isNotEmpty) {
      showNotifications(notis);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentTailor == null
          ? kSpinner(context)
          : index == 0
              ? const OrdersPage()
              : index == 1
                  ? const MyCustomersPage()
                  : TailorProfile(tailor: currentTailor!),
      bottomNavigationBar: AnimatedBottomNavigationBar(
        backgroundColor: kOrangeColor.withAlpha(140),
        inactiveColor: Colors.white38,
        borderColor: Colors.white,
        activeColor: Colors.white,
        icons: const [
          FontAwesomeIcons.bagShopping,
          FontAwesomeIcons.userGroup,
          FontAwesomeIcons.user,
        ],
        activeIndex: index,
        gapLocation: GapLocation.none,
        // notchSmoothness: NotchSmoothness.verySmoothEdge,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        onTap: (index) => setState(() => this.index = index),
        //other params
      ),
    );
  }

  Future<void> showNotifications(List<MyNotification> notiList) async {
    if (mounted) {
      setState(() {
        timerSeconds = 1800; //30 mins
      });
    }
    notificationTimer?.cancel();
    print("length: ${notiList.length}");
    for (var notification in notiList) {
      await notiHelper.showNotification(context, notification);
      await Future.delayed(const Duration(milliseconds: 500));
    }
    notiList.clear();
    if (mounted) {
      setState(() {
        timerSeconds = 5;
      });
    }
    return startNotificationTimer();
  }
}

Future loadCurrentTailor(VoidCallback afterFunction) async {
  final tailor =
      await FireStoreHelper().getTailorWithDocId(appUser!.customerOrTailorId!);
  if (tailor != null) {
    currentTailor = tailor;
    afterFunction();
    print('Current tailor loaded successfully.');
  }
}
