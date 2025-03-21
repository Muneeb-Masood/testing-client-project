import 'dart:async';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:badges/badges.dart' as badges;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test/main.dart';
import 'package:test/models/customer.dart';
import 'package:test/models/notification.dart';
import 'package:test/models/order.dart';
import 'package:test/networking/firestore_helper.dart';
import 'package:test/networking/notification_helper.dart';
import 'package:test/screens/customer/customer_home.dart';
import 'package:test/screens/customer/customer_profile.dart';
import 'package:test/screens/customer/customer_search_tailor.dart';
import 'package:test/screens/customer/processed_order_request.dart';
import 'package:test/utilities/constants.dart';
import 'package:test/utilities/my_drawer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Customer? currentCustomer;

class CustomerMainScreen extends StatefulWidget {
  static const id = "/customer_main_screen";

  const CustomerMainScreen({super.key});
  @override
  _CustomerMainScreenState createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends State<CustomerMainScreen> {
  final controller = ZoomDrawerController();
  int index = 0;
  List<AcceptedOrDeclinedOrderRequest> orderRequests = [];
  final _streamController =
      StreamController<List<DocumentSnapshot>>.broadcast();
  late StreamSubscription<QuerySnapshot> _subscription;
  final helper = FireStoreHelper();
  int seenRequests = 0;

  Timer? notificationTimer;

  var timerSeconds = 5;

  final notiHelper = NotificationHelper();
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 2), () {
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
    loadCurrentCustomer();
    startNotificationTimer();
    _subscription = FirebaseFirestore.instance
        .collection("orderRequests")
        .where("customerEmail",
            isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .snapshots()
        .listen((querySnapshot) {
      List<DocumentSnapshot> documents = querySnapshot.docs;
      _streamController.add(documents);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
    _streamController.close();
  }

  startNotificationTimer() {
    notificationTimer =
        Timer.periodic(Duration(seconds: timerSeconds), (timer) async {
      getNotifications();
    });
  }

  getNotifications() async {
    var notis = await helper.getNotifications(appUser!.customerOrTailorId!,
        isTailor: false);
    //the notis which haven't been seen yet
    notis = notis.where((element) => element.sentByTailor).toList();
    if (notis.isNotEmpty) {
      showNotifications(notis);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MyDrawer(
      userData: appUser!,
      controller: controller,
      onBack: () => setState(() {}),
      mainScreen: Scaffold(
        appBar: index != 0
            ? null
            : AppBar(
                title: Text('Tailors',
                        style: kInputStyle.copyWith(
                            fontSize: 20, color: Colors.white))
                    .tr(),
                leading: IconButton(
                  onPressed: () {
                    controller.open!.call();
                  },
                  icon: const Padding(
                    padding: EdgeInsets.all(5),
                    child: Icon(Icons.menu),
                  ),
                ),
                actions: [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: 5.0,
                          right: isUrduActivated ? 0 : 20,
                          left: isUrduActivated ? 20 : 0),
                      child: badges.Badge(
                        showBadge: orderRequests.isNotEmpty &&
                            orderRequests.length > seenRequests,
                        badgeStyle: const badges.BadgeStyle(
                            badgeColor: Colors.white,
                            padding: EdgeInsets.all(4)),
                        position: badges.BadgePosition.topEnd(),
                        badgeContent: Text(
                          '${orderRequests.length - seenRequests}',
                        ),
                        child: InkWell(
                          onTap: () async {
                            orderRequests.sort((o, o2) {
                              if (DateTime.parse(o.createdOn)
                                  .isAfter(DateTime.parse(o2.createdOn))) {
                                return -1;
                              } else if (DateTime.parse(o.createdOn)
                                  .isBefore(DateTime.parse(o2.createdOn))) {
                                return 1;
                              }
                              return 0;
                            });
                            navigateToScreen(
                              ProcessedOrderRequestPage(
                                  orderRequests: orderRequests),
                            ).then((value) {
                              if (mounted) setState(() {});
                            });

                            // (await SharedPreferences.getInstance())
                            //     .setInt('seen', orderRequests.length)
                            //     .then((value) =>
                            //         loadSeenNotificationsAboutOrderRequests());
                          },
                          child: const Icon(Icons.notifications_outlined),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: _streamController.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final data = snapshot.data!.toList();
                    orderRequests = data
                        .map(
                          (e) => AcceptedOrDeclinedOrderRequest.fromJson(
                              e.data() as Map<String, dynamic>),
                        )
                        .toList();
                    seenRequests = orderRequests
                        .where((element) => element.seenStatus == 1)
                        .length;
                    // SchedulerBinding.instance.addPostFrameCallback((_) {
                    //   // This will be called after the widget tree has finished building.
                    //   setState(() {
                    //     // Update the state here.
                    //   });
                    // });
                    Future.delayed(const Duration(seconds: 2)).then((value) {
                      if (mounted) setState(() {});
                    });
                  }
                  return index == 0
                      ? const SearchTailor()
                      : index == 1
                          ? const SearchTailor()
                          // : index == 2
                          //     ? StoreScreen()
                          : const CustomerProfile();
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: AnimatedBottomNavigationBar(
          icons: const [
            FontAwesomeIcons.house,
            FontAwesomeIcons.magnifyingGlass,
            // FontAwesomeIcons.shop,
            FontAwesomeIcons.user,
          ],

          inactiveColor: Colors.white38,
          borderColor: Colors.white,
          activeColor: Colors.white,
          activeIndex: index,
          backgroundColor: kOrangeColor.withAlpha(140),
          gapLocation: GapLocation.none,
          leftCornerRadius: 32,
          rightCornerRadius: 32,
          onTap: (index) => setState(() {
            if (index == 0) return;
            this.index = index;
          }),
          //other params
        ),
      ),
    );
  }

  Future loadCurrentCustomer() async {
    final customer =
        await helper.getCustomerWithDocId(appUser!.customerOrTailorId!);
    if (customer != null) {
      currentCustomer = customer;

      if (mounted) {
        setState(() {});
        print('Current customer loaded successfully.');
      }
    }
  }

  // void loadCustomersOrderRequests() async {
  //   final result = await FirebaseFirestore.instance
  //       .collection("tailors")
  //       .where("orderRequests.customer.email",
  //           isEqualTo: currentCustomer!.email)
  //       .get();
  //   print(result.docs.length);
  //   result.docs.forEach((element) {
  //     print(element);
  //   });
  //   print('No data');
  // }

  Future<void> navigateToScreen(Widget screen) async {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => screen,
      ),
    ).then((value) {
      if (mounted) {
        setState(() {});
      }
    });
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
