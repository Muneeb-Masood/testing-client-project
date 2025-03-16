import 'package:test/models/dress.dart';
import 'package:test/models/order.dart';
import 'package:test/networking/firestore_helper.dart';
import 'package:test/screens/customer/customer_main_screen.dart';
import 'package:test/utilities/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';

import '../../utilities/custom_widgets/customer_order_card.dart';
import '../../utilities/my_dialog.dart';
import '../tailor/tailor_profile.dart';

class CustomerDressesPage extends StatefulWidget {
  const CustomerDressesPage({Key? key}) : super(key: key);

  @override
  State<CustomerDressesPage> createState() => _CustomerDressesPageState();
}

class _CustomerDressesPageState extends State<CustomerDressesPage> {
  List<DresssewOrder> customersOrders = [];
  bool isLoadingOrders = false;
  final fireStorer = FireStoreHelper();

  @override
  void initState() {
    super.initState();
    loadCustomerOrders();
  }

  loadCustomerOrders() async {
    if (mounted) setState(() => isLoadingOrders = true);
    await fireStorer
        .loadOrdersOfDocId(currentCustomer!.id!, isCustomerId: true)
        .then((value) {
      if (value.isNotEmpty) customersOrders = value;
      //only show those orders that are completely placed by customers i.e placed via steps screen
      customersOrders = customersOrders.where((o) => o.cloth != null).toList();
      if (mounted) {
        setState(() {});
      }
    });
    if (mounted) setState(() => isLoadingOrders = false);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            title: const Text('My dresses').tr(),
            bottom: TabBar(
              onTap: (index) => loadCustomerOrders(),
              tabs: [
                Tab(text: getTranslatedText("مکمل", 'Completed')),
                Tab(text: getTranslatedText("نا مکمل", 'Not Completed')),
              ],
            ),
            actions: [
              IconButton(
                  tooltip: getTranslatedText("میری ڈریسِس", "my dresses"),
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    loadCustomerOrders();
                  })
            ],
          ),
          body: LoadingOverlay(
            isLoading: isLoadingOrders,
            progressIndicator: kSpinner(context),
            child: TabBarView(
              children: [
                buildCompletedDressesTabContent(),
                buildNotCompletedDressesTabContent(),
              ],
            ),
          )),
    );
  }

  buildCompletedDressesTabContent() {
    final orders = customersOrders
        .where((element) => element.status == OrderStatus.completed)
        .toList();
    orders.sort((o1, o2) {
      //sort in decreasing order
      return o1.deliveredOn!.compareTo(o2.deliveredOn!) * -1;
    });
    return SingleChildScrollView(
      child: orders.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.35),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    getTranslatedText(
                        "ابھی تک لباس کا کوئی آرڈر مکمل نہیں ہوا ہے۔",
                        'No dress orders completed yet.'),
                    style:
                        kTextStyle.copyWith(color: Colors.grey, fontSize: 18),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                ...List.generate(
                  orders.length,
                  (index) => CustomerOrderCard(
                    order: orders[index],
                    onShopPressed: onTailorShopPressed,
                    onOrderUpdate: loadCustomerOrders,
                  ),
                )
              ],
            ),
    );
  }

  buildNotCompletedDressesTabContent() {
    final orders = customersOrders
        .where((element) => element.status != OrderStatus.completed)
        .toList();
    orders.sort((o1, o2) {
      //also deal with not yet started status orders that do not have deliveryDate not deliveredOn
      if (o1.status == OrderStatus.notStartedYet ||
          o2.status == OrderStatus.notStartedYet) {
        return 0;
      }
      return o1.expectedDeliveryDate!.compareTo(o2.expectedDeliveryDate!) * -1;
    });
    return SingleChildScrollView(
      child: orders.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.35),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    getTranslatedText(
                        "کوئی آرڈر نہیں دیا گیا ہے.", 'No orders placed.'),
                    style:
                        kTextStyle.copyWith(color: Colors.grey, fontSize: 18),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                ...List.generate(
                  orders.length,
                  (index) => CustomerOrderCard(
                    order: orders[index],
                    onShopPressed: onTailorShopPressed,
                    onOrderUpdate: loadCustomerOrders,
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

  void onTailorShopPressed(DresssewOrder order) {
    bool taskSuccessful = false;
    if (mounted) setState(() => isLoadingOrders = true);
    fireStorer.getTailorWithDocId(order.tailorId).then((value) {
      if (mounted) {
        setState(() => {isLoadingOrders = false, taskSuccessful = true});
      }
      navigateToScreen(TailorProfile(tailor: value!));
    });
    Future.delayed(const Duration(seconds: 5)).then((value) {
      if (!taskSuccessful) {
        showMyBanner(context, getTranslatedText("ٹائم آؤٹ.", "Timed out."));
      }
      if (mounted) setState(() => isLoadingOrders = false);
    });
  }
}
