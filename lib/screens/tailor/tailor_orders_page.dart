import 'package:test/main.dart';
import 'package:test/models/order.dart';
import 'package:test/networking/firestore_helper.dart';
import 'package:test/screens/customer/customer_profile.dart';
import 'package:test/screens/tailor/tailor_main_screen.dart';
import 'package:test/utilities/constants.dart';
import 'package:test/utilities/my_drawer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_zoom_drawer/config.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:loading_overlay/loading_overlay.dart';

import '../../utilities/custom_widgets/order_request_card.dart';
import '../../utilities/custom_widgets/tailor_order_card.dart';
import '../../utilities/my_dialog.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<DresssewOrder> totalOrders = [];
  List<OrderRequest> orderRequests = [];
  bool isLoadingOrders = false;
  bool isLoadingOrderRequests = false;
  final fireStorer = FireStoreHelper();
  final controller = ZoomDrawerController();
  int activeTabIndex = 0;
  OrderTailorPaymentInfo tailorPaymentInfo =
      OrderTailorPaymentInfo(PaymentMethod.jazzcash, dummyNumber);

  @override
  void initState() {
    super.initState();
    loadOrderRequests();
    loadOrders().then((value) {
      // final orders = totalOrders
      //     .where((element) =>
      //         element.status == OrderStatus.inProgress ||
      //         element.status == OrderStatus.justStarted)
      //     .toList();
      // showNotificationsForOrdersWithDeadlinesInTwoDays(orders);
    });
  }

  Future loadOrders() async {
    if (mounted) setState(() => isLoadingOrders = true);
    await fireStorer
        .loadOrdersOfDocId(currentTailor!.id!, isCustomerId: false)
        .then((value) {
      if (value.isNotEmpty) totalOrders = value;
      // totalOrders.sort((o, o2) {
      //   return o.creationDate.compareTo(o2.creationDate) * -1;
      // });
      if (mounted) {
        setState(() {});
      }
    });
    Future.delayed(const Duration(seconds: 3)).then((value) {
      if (isLoadingOrders && mounted) {
        setState(() {
          isLoadingOrders = false;
        });
      }
    });
    if (mounted) setState(() => isLoadingOrders = false);
  }

  loadOrderRequests() async {
    if (mounted) setState(() => isLoadingOrderRequests = true);
    if (currentTailor == null) {
      await loadCurrentTailor(() {
        if (mounted) {
          setState(() {});
        }
      });
    }
    orderRequests = List.from(currentTailor!.orderRequests.where(
        (element) => element.requestStatus == OrderRequestStatus.pending));
    orderRequests.sort((o, o2) {
      return o.date!.compareTo(o2.date!) * -1;
    });
    if (mounted) setState(() => isLoadingOrderRequests = false);
  }

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;
    return MyDrawer(
      userData: appUser!,
      controller: controller,
      onBack: () => setState(() {}),
      mainScreen: DefaultTabController(
        initialIndex: activeTabIndex,
        length: 4,
        child: Scaffold(
          // floatingActionButton: FloatingActionButton(onPressed: () async {
          //   print(await ApiHelper.translateText("Naveed Ahmed"));
          // }),
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                controller.open!.call();
              },
              icon: const Padding(
                padding: EdgeInsets.all(5),
                child: Icon(Icons.menu),
              ),
            ),
            title: Text(
              activeTabIndex < 2 ? 'Order Requests' : 'Orders',
              style: kInputStyle.copyWith(color: Colors.white),
            ).tr(),
            actions: [
              IconButton(
                  tooltip:
                      'Refresh ${activeTabIndex == 0 ? "order requests" : "orders"}',
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    activeTabIndex == 0 ? loadOrderRequests() : loadOrders();
                  })
            ],
            bottom: TabBar(
              isScrollable: true,
              labelStyle: kInputStyle,
              onTap: (index) {
                if (mounted) {
                  setState(() {
                    activeTabIndex = index;
                  });
                }
                if (index == 0) {
                  loadOrderRequests();
                } else {
                  loadOrders();
                }
              },
              tabs: [
                Tab(text: getTranslatedText("نئی درخواستیں", 'New')),
                Tab(text: getTranslatedText("مقبول", 'Accepted')),
                Tab(text: getTranslatedText('جاری آرڈرس', "In progress")),
                Tab(text: getTranslatedText("مکمل", 'Completed')),
              ],
            ),
          ),
          body: LoadingOverlay(
            isLoading: isLoadingOrders || isLoadingOrderRequests,
            progressIndicator: kSpinner(context),
            child: TabBarView(
              children: [
                buildNewOrdersTabContent(),
                buildAcceptedOrdersTabContent(),
                buildInProgressOrdersTabContent(),
                buildCompletedOrdersTabContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  buildCompletedOrdersTabContent() {
    final orders = totalOrders
        .where((element) => element.status == OrderStatus.completed)
        .toList();
    orders.sort((o1, o2) => o1.deliveredOn!.compareTo(o2.deliveredOn!) * -1);
    return SingleChildScrollView(
      child: orders.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.35),
                Text(
                  'No completed orders.',
                  style: kTextStyle.copyWith(color: Colors.grey, fontSize: 18),
                ).tr(),
              ],
            )
          : Column(
              children: [
                ...List.generate(
                  orders.length,
                  (index) => TailorOrderCard(
                    order: orders[index],
                    onChangeStatus: () => setState(() {}),
                    onCustomerPressed: onCustomerPressed,
                  ),
                )
              ],
            ),
    );
  }

  buildInProgressOrdersTabContent() {
    final orders = totalOrders
        .where((element) =>
            element.status == OrderStatus.inProgress ||
            element.status == OrderStatus.justStarted)
        .toList();
    orders.sort((o1, o2) =>
        o1.expectedDeliveryDate!.compareTo(o2.expectedDeliveryDate!));
    return SingleChildScrollView(
      child: orders.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.35),
                Text(
                  'No orders in progress.',
                  style: kTextStyle.copyWith(color: Colors.grey, fontSize: 18),
                ).tr(),
              ],
            )
          : Column(
              children: [
                ...List.generate(
                  orders.length,
                  (index) => TailorOrderCard(
                    order: orders[index],
                    onCustomerPressed: onCustomerPressed,
                    onChangeStatus: () {
                      loadOrders();
                    },
                  ),
                )
              ],
            ),
    );
  }

  void navigateToScreen(Widget screen) {
    Navigator.push(
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

  void onCustomerPressed(DresssewOrder order) {
    bool taskSuccessful = false;
    bool timedOut = false;
    if (mounted) {
      setState(() => isLoadingOrderRequests = isLoadingOrders = true);
    }
    FireStoreHelper().getCustomerWithDocId(order.customerId).then((value) {
      if (mounted) {
        setState(() => {
              isLoadingOrderRequests = isLoadingOrders = false,
              taskSuccessful = true
            });
      }
      if (!timedOut) {
        navigateToScreen(CustomerProfile(customer: value!));
      } else {
        print('cant go');
      }
    });
    Future.delayed(const Duration(seconds: 4)).then((value) {
      if (!taskSuccessful) {
        showMyBanner(context, getTranslatedText("ٹائم آؤٹ.", "Timed out."));
        setState(() {
          timedOut = true;
        });
      }
      if (mounted) {
        setState(() => isLoadingOrderRequests = isLoadingOrders = false);
      }
    });
  }

  void onCustomerNamePressed(OrderRequest order) {
    bool taskSuccessful = false;
    if (mounted) {
      setState(() => isLoadingOrderRequests = isLoadingOrders = true);
    }
    FireStoreHelper().getCustomerWithDocId(order.customer.id!).then((value) {
      if (mounted) {
        setState(() => {
              isLoadingOrderRequests = isLoadingOrders = false,
              taskSuccessful = true
            });
      }
      navigateToScreen(CustomerProfile(customer: value!));
    });
    Future.delayed(const Duration(seconds: 2)).then((value) {
      if (!taskSuccessful) {
        showMyBanner(context, getTranslatedText("ٹائم آؤٹ.", "Timed out."));
      }
      if (mounted) setState(() => isLoadingOrders = false);
    });
  }

  buildNewOrdersTabContent() {
    // loadOrderRequests();
    return SingleChildScrollView(
      child: orderRequests.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.35),
                Text(
                  'No order requests.',
                  style: kTextStyle.copyWith(color: Colors.grey, fontSize: 18),
                ).tr(),
              ],
            )
          : Column(
              children: [
                ...List.generate(
                  orderRequests.length,
                  (index) => OrderRequestCard(
                    orderRequest: orderRequests[index],
                    onCustomerPressed: onCustomerNamePressed,
                    onOrderRequestStatusChanged: (rq, st) =>
                        updateOrderRequestStatus(orderRequests[index], st),
                  ),
                )
              ],
            ),
    );
  }

  updateOrderRequestStatus(
      OrderRequest request, OrderRequestStatus status) async {
    final size = MediaQuery.of(context).size;
    final orderReq = currentTailor!.orderRequests
        .firstWhere((element) => element.date == request.date);
    if (status == OrderRequestStatus.accepted) {
      bool accountInfoAdded = await getPaymentInfo(size);
      DresssewOrder order = DresssewOrder(
        isCustomizationOnly: orderReq.isCustomizationOnly,
        paymentMethod: PaymentMethod.jazzcash,
        tailorId: currentTailor!.id!,
        creationDate: DateTime.now().toIso8601String(),
        tailorPaymentInfo: tailorPaymentInfo,
        measurementChoice: orderReq.measurementChoice,
        tailorShopName: currentTailor!.shop!.name,
        dressCategory: orderReq.dressInfo.category,
        dressImage: orderReq.dressImage,
        advanceDeposited: 0,
        customerEmail: orderReq.customer.email,
        customerId: orderReq.customer.id!,
        status: OrderStatus.notStartedYet,
        totalAmount: orderReq.isCustomizationOnly
            ? orderReq.dressInfo.customizationPrice!.toDouble()
            : orderReq.dressInfo.price.toDouble(),
        amountRemaining: orderReq.dressInfo.price.toDouble(),
        clothDeliveryCharges: currentTailor!.shop!.viaAgentCharges,
      );
      if (!accountInfoAdded) {
        await showMyDialog(
            context,
            'Info missing',
            getTranslatedText(
                "اکاؤنٹ کی معلومات شامل کریں۔", "Add account info."));
        return;
      }
      //if account info added
      if (mounted) {
        setState(() => isLoadingOrderRequests = true);
      }
      order.tailorPaymentInfo = tailorPaymentInfo;
      request.requestStatus = status;
      bool orderSuccessful = await fireStorer.placeOrder(order);
      print('order placed');
      if (orderSuccessful) {
        fireStorer
            .createNewOrderRequestForCustomer(request, currentTailor!,
                orderId: order.orderId)
            .then((value) {
          print("order request: $value");
          print(tailorPaymentInfo.toJson());
          Fluttertoast.showToast(
            msg: getTranslatedText("آرڈر کامیابی سے قبول کیا گیا۔",
                "Order accepted successfully."),
            textColor: Colors.white,
            backgroundColor: kOrangeColor,
          );
        });
      }
    } else if (status == OrderRequestStatus.declined) {
      String? reason = orderRequestDeclineReasons.first;
      final textController = TextEditingController(text: reason);
      textController.addListener(() {
        setState(() {});
      });
      //adding reason for decline
      await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => StatefulBuilder(builder: (context, setState) {
          return Card(
            color: kLightSkinColor,
            margin: EdgeInsets.symmetric(
                vertical: size.height * 0.2, horizontal: size.width * 0.02),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Provide a reason',
                    style: TextStyle(fontSize: 25),
                  ).tr(),
                  SizedBox(height: size.height * 0.02),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text('Choose:').tr(),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DropdownButton<String>(
                      value: reason,
                      onChanged: (newValue) {
                        setState(() {
                          reason = newValue;
                          textController.text = reason!;
                        });
                      },
                      items: orderRequestDeclineReasons
                          .map<DropdownMenuItem<String>>((value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(color: Colors.black54),
                          ).tr(),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: textController,
                    maxLines: 5,
                    minLines: 3,
                    decoration: InputDecoration(
                      labelText: getTranslatedText("وجہ", 'reason'),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5)),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  Center(
                      child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(getTranslatedText("ٹھيک ہے", 'Ok'))))
                ],
              ),
            ),
          );
        }),
      );
      reason = textController.text;
      if (reason == null || reason!.isEmpty) {
        showMyDialog(
            context,
            'Error!',
            getTranslatedText("مسترد کرنے کی ایک وجہ فراہم کریں.",
                'Provide a decline reason.'));
        return;
      }
      print("reason: $reason");
      request.requestStatus = status;
      if (mounted) {
        setState(() => isLoadingOrderRequests = true);
      }
      await fireStorer
          .createNewOrderRequestForCustomer(request, currentTailor!,
              reason: reason)
          .then((value) {
        print("order request: $value");
      });
      Fluttertoast.showToast(
        msg: getTranslatedText("درخواست کامیابی سے وجہ کے ساتھ مسترد کردی گئی۔",
            "Request declined with reason successfully."),
        textColor: Colors.white,
        backgroundColor: kOrangeColor,
      );
    }
    // in both cases either accepted/declined the orderrequest should be deleted & a order created if accepted or nothing
    // should be done if declined.
    orderReq.requestStatus = status;
    loadOrderRequests();
    loadOrders();
    print("request count:${currentTailor!.orderRequests.length} ");
    currentTailor!.orderRequests
        .removeWhere((element) => element.date == request.date);
    print("request count now:${currentTailor!.orderRequests.length} ");
    fireStorer.updateTailor(currentTailor!).then((value) => {
          print('Tailor has changed requests status.'),
          // Fluttertoast.showToast(
          //     msg: "Request status updated.", backgroundColor: Colors.blue),
          // loadOrderRequests(),
          if (mounted) setState(() => isLoadingOrderRequests = false)
        });
    Future.delayed(const Duration(seconds: 4)).then((value) => {
          if (mounted)
            setState(() => isLoadingOrderRequests = isLoadingOrders = false)
        });
  }

  buildAcceptedOrdersTabContent() {
    // loadOrders();

    final orders = totalOrders
        .where((element) => element.status == OrderStatus.notStartedYet)
        .toList();
    orders.sort((o1, o2) {
      return o1.creationDate.compareTo(o2.creationDate) * -1;
    });
    return SingleChildScrollView(
      child: orders.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.35),
                Text(
                  'No accepted orders requests.',
                  style: kTextStyle.copyWith(color: Colors.grey, fontSize: 18),
                ).tr(),
              ],
            )
          : Column(
              children: [
                ...List.generate(
                  orders.length,
                  (index) => TailorOrderCard(
                    order: orders[index],
                    onChangeStatus: () => loadOrders(),
                    onCustomerPressed: onCustomerPressed,
                  ),
                )
              ],
            ),
    );
  }

  IntlPhoneField buildPhoneNumberField() {
    return IntlPhoneField(
      onChanged: (phone) => setState(() {
        tailorPaymentInfo.accountNumber = phone.completeNumber;
      }),
      flagsButtonPadding: const EdgeInsets.all(10),
      decoration: kTextFieldDecoration.copyWith(
        hintText: dummyNumber,
        hintStyle: kInputStyle,
        labelText: getTranslatedText("فون نمبر", 'phone#'),
        // labelStyle: kInputStyle,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      ),
      style: kInputStyle.copyWith(
        locale: context.locale,
      ),
      keyboardType: TextInputType.phone,
      initialCountryCode: 'PK',
      // countries: ["PK"],
    );
  }

  Future<bool> getPaymentInfo(size) async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        return Card(
          color: kLightSkinColor,
          margin: EdgeInsets.symmetric(
              vertical: size.height * 0.2, horizontal: size.width * 0.02),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Account number',
                  style: TextStyle(fontSize: 25),
                ).tr(),
                SizedBox(height: size.height * 0.02),
                const Text(
                  'Enter account number for customer to deposit advance:',
                  textAlign: TextAlign.center,
                ).tr(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text('choose account type').tr(),
                    DropdownButton<PaymentMethod>(
                      value: tailorPaymentInfo.paymentMethod,
                      onChanged: (newValue) {
                        setState(() {
                          tailorPaymentInfo.paymentMethod = newValue!;
                        });
                      },
                      items: PaymentMethod.values
                          .map<DropdownMenuItem<PaymentMethod>>((value) {
                        return DropdownMenuItem<PaymentMethod>(
                          value: value,
                          child: Text(
                            value.name,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                buildPhoneNumberField(),
                SizedBox(height: size.height * 0.02),
                Center(
                    child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Ok').tr()))
              ],
            ),
          ),
        );
      }),
    );
    return tailorPaymentInfo.accountNumber == dummyNumber ||
            tailorPaymentInfo.accountNumber.isEmpty
        ? false
        : true;
  }

  // void showNotificationsForOrdersWithDeadlinesInTwoDays(
  //     List<DresssewOrder> orders) {
  //   for (var o in orders) {
  //     final notification = MyNotification(
  //         orderId: o.orderId!,
  //         tailorId: o.tailorId,
  //         customerId: o.customerId,
  //         dressCategory: o.dressCategory,
  //         customerName: '',
  //         tailorShopName: o.tailorShopName,
  //         timestamp: DateTime.now().toIso8601String(),
  //         sentByTailor: false,
  //         type: NotificationType.deadlineComingInTwoDays);
  //     fireStorer.addNotification(notification);
  //   }
  // }
}
