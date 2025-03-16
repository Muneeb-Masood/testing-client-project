import 'package:test/main.dart';
import 'package:test/models/customer.dart';
import 'package:test/models/tailor.dart';
import 'package:test/networking/firestore_helper.dart';
import 'package:test/screens/tailor/tailor_main_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';

import '../../models/order.dart';
import '../../utilities/constants.dart';
import '../../utilities/custom_widgets/customer_card.dart';

class MyCustomersPage extends StatefulWidget {
  const MyCustomersPage({super.key});
  @override
  _MyCustomersPageState createState() => _MyCustomersPageState();
}

class _MyCustomersPageState extends State<MyCustomersPage> {
  bool isLoadingCustomers = false;
  Tailor tailor = currentTailor!;
  List<Customer> customers = [];
  Map<String, int> orderCount = {};
  final firestorer = FireStoreHelper();
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 20)).then((value) {
      if (mounted) {
        setState(() {});
      }
    });
    loadCustomers();
  }

  loadCustomers() async {
    toggleLoadingStatus();
    final orders =
        await firestorer.loadOrdersOfDocId(tailor.id!, isCustomerId: false);
    orderCount.clear();
    customers.clear();
    orderCount = getOrdersCount(orders);
    // if (orders.isNotEmpty) {
    //   customers.clear();
    //   for (var element in orders) {
    //     if (element.status != OrderStatus.completed) continue;
    //     final customer =
    //         await firestorer.getCustomerWithDocId(element.customerId);
    //     if (orderCount.containsKey(customer!.id)) {
    //       orderCount[customer.id!] = orderCount[customer.id!]! + 1;
    //     } else {
    //       orderCount[customer.id!] = 1;
    //       customers.add(customer);
    //     }
    //     if (mounted) setState(() {});
    //   }
    //   toggleLoadingStatus();
    // }
    // print(orders);
    for (var id in orderCount.keys) {
      final customer = await firestorer.getCustomerWithDocId(id);
      customers.add(customer!);
      if (mounted) setState(() {});
    }
    if (mounted) {
      setState(() {
        isLoadingCustomers = false;
      });
    }
    Future.delayed(const Duration(seconds: 5)).then((value) {
      if (mounted && isLoadingCustomers) {
        setState(() {
          isLoadingCustomers = false;
        });
      }
    });
  }

  void toggleLoadingStatus() {
    if (mounted) {
      setState(() {
        isLoadingCustomers = !isLoadingCustomers;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Map<String, int> getOrdersCount(List<DresssewOrder> orders) {
    Map<String, int> customerOrdersCount = {};
    for (var order in orders) {
      String id = order.customerId;
      if (order.status == OrderStatus.completed) {
        if (customerOrdersCount.containsKey(id)) {
          customerOrdersCount[id] = customerOrdersCount[id]! + 1;
        } else {
          customerOrdersCount[id] = 1;
        }
      }
    }
    return customerOrdersCount;
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: appUser == null || isLoadingCustomers,
      progressIndicator: kSpinner(context),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('My customers',
                  style:
                      kInputStyle.copyWith(fontSize: 20, color: Colors.white))
              .tr(),
          actions: [
            IconButton(
              tooltip: "refresh",
              icon: const Icon(Icons.refresh),
              onPressed: () {
                loadCustomers();
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          child: customers.isEmpty && !isLoadingCustomers
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.35),
                    Text(
                      'No customers in list.',
                      style:
                          kTextStyle.copyWith(color: Colors.grey, fontSize: 18),
                      textAlign: TextAlign.center,
                    ).tr(),
                  ],
                )
              : Column(
                  children: [
                    ...List.generate(
                      customers.length,
                      (index) => CustomerCard(
                        customer: customers[index],
                        orderCount: orderCount[customers[index].id]!,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
