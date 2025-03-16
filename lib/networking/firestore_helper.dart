import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test/models/app_user.dart';
import 'package:test/models/customer.dart';
import 'package:test/models/notification.dart';
import 'package:test/models/order.dart';
import 'package:test/models/tailor.dart';
import 'package:test/utilities/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:fluttertoast/fluttertoast.dart';

/**class to help firestore collections related task*/
class FireStoreHelper {
  static final _orderRequestCollection =
      FirebaseFirestore.instance.collection("orderRequests");
  final instance = FirebaseFirestore.instance;
  Future<List<Tailor>> loadAllTailors() async {
    List<Tailor> tailors = [];
    final result = await instance.collection("tailors").get();
    if (result.docs.isNotEmpty) {
      for (var element in result.docs) {
        final tailor = Tailor.fromJson(element.data());
        tailors.add(tailor);
      }
    }
    return tailors;
  }

  Future<List<Tailor>> loadTailorsOfCity(String shopCity) async {
    List<Tailor> tailors = [];
    final result = await instance
        .collection("tailors")
        .where("shop.city", isEqualTo: shopCity)
        .get();
    if (result.docs.isNotEmpty) {
      for (var element in result.docs) {
        final tailor = Tailor.fromJson(element.data());
        tailors.add(tailor);
      }
    }
    return tailors;
  }

  Future<Tailor?> getTailorWithEmail(String email) async {
    final result = await instance
        .collection("tailors")
        .where('email', isEqualTo: email)
        .get();
    if (result.docs.isNotEmpty) {
      final tailor = Tailor.fromJson(result.docs.first.data());
      return tailor;
    }
    return null;
  }

  Future<Tailor?> getTailorWithDocId(String id) async {
    final result = await instance.collection("tailors").doc(id).get();
    if (result.exists) {
      final tailor = Tailor.fromJson(result.data() as Map<String, dynamic>);
      return tailor;
    }
    return null;
  }

  Future<Customer?> getCustomerWithDocId(String id) async {
    final result = await instance.collection("customers").doc(id).get();
    if (result.exists) {
      final customer = Customer.fromJson(result.data() as Map<String, dynamic>);
      return customer;
    }
    return null;
  }

  Future<Customer?> getCustomerWithEmail(String email) async {
    final result = await instance
        .collection("customers")
        .where('email', isEqualTo: email)
        .get();
    if (result.docs.isNotEmpty) {
      final customer = Customer.fromJson(result.docs.first.data());
      return customer;
    }
    return null;
  }

  Future<List<Customer>> loadAllCustomers() async {
    List<Customer> customers = [];
    final result = await instance.collection("customers").get();
    if (result.docs.isNotEmpty) {
      for (var element in result.docs) {
        final customer = Customer.fromJson(element.data());
        customers.add(customer);
      }
    }
    return customers;
  }

  Future<AppUser?> getAppUserWithEmail(String? email) async {
    final result = await instance
        .collection("users")
        .where('email', isEqualTo: email)
        .get();
    if (result.docs.isNotEmpty) {
      final user = AppUser.fromJson(result.docs.first.data());
      return user;
    }
    return null;
  }

  Future<AppUser?> getAppUserWithDocId(String id) async {
    final result = await instance.collection("users").doc(id).get();
    if (result.exists) {
      final appUser = AppUser.fromJson(result.data() as Map<String, dynamic>);
      return appUser;
    }
    return null;
  }

  Future<List<AppUser>> loadAllUsers() async {
    List<AppUser> appUsers = [];
    final result = await instance.collection("users").get();
    if (result.docs.isNotEmpty) {
      for (var element in result.docs) {
        final user = AppUser.fromJson(element.data());
        appUsers.add(user);
      }
    }
    return appUsers;
  }

  Future<bool> updateTailor(Tailor tailor) async {
    try {
      await instance
          .collection("tailors")
          .doc(tailor.id)
          .update(tailor.toJson());
    } catch (e) {
      debugPrint("Exception while updating tailor: $e");
      return false;
    }
    return true;
  }

  Future<bool> updateCustomer(Customer customer) async {
    try {
      await instance
          .collection("customers")
          .doc(customer.id)
          .update(customer.toJson());
    } catch (e) {
      debugPrint("Exception while updating tailor: $e");
      return false;
    }
    return true;
  }

  Future<bool> updateAppUser(AppUser appUser) async {
    try {
      await instance
          .collection("users")
          .doc(appUser.id)
          .update(appUser.toJson());
    } catch (e) {
      debugPrint("Exception while updating tailor: $e");
      return false;
    }
    return true;
  }

  ///loads orders based on doc id=> if doc id =tailor id, then tailor's all orders
  Future<List<DresssewOrder>> loadOrdersOfDocId(String docId,
      {bool isCustomerId = true}) async {
    List<DresssewOrder> orders = [];
    String field = isCustomerId ? "customerId" : "tailorId";
    final result = await instance
        .collection("orders")
        .where(field, isEqualTo: docId)
        .get();
    if (result.docs.isNotEmpty) {
      for (var element in result.docs) {
        final order = DresssewOrder.fromJson(element.data());
        orders.add(order);
      }
    }
    return orders;
  }

  Future<bool> placeOrder(DresssewOrder order) async {
    try {
      final docId = await instance.collection("orders").add(order.toJson());
      order.orderId = docId.id;
      updateOrder(order).then((value) {
        if (value) print("order id updated");
      });
    } catch (e) {
      debugPrint("Exception while updating tailor: $e");
      return false;
    }
    return true;
  }

  Future<bool> updateOrder(DresssewOrder order) async {
    try {
      await instance
          .collection("orders")
          .doc(order.orderId)
          .update(order.toJson());
    } catch (e) {
      debugPrint("Exception while updating tailor: $e");
      return false;
    }
    return true;
  }

  Future<bool> createNewOrderRequestForCustomer(
      OrderRequest request, Tailor tailor,
      {String? orderId, String? reason}) async {
    try {
      AcceptedOrDeclinedOrderRequest orderRequest =
          AcceptedOrDeclinedOrderRequest(
        customerEmail: request.customer.email,
        tailorShopName: tailor.shop!.name,
        isCustomizationOnly: request.isCustomizationOnly,
        tailorDocId: tailor.id!,
        customerDocId: request.customer.id!,
        dressItem: request.dressInfo.category,
        requestDate: request.date!,
        status: request.requestStatus == OrderRequestStatus.accepted ? 1 : 0,
        seenStatus: 0,
        createdOn: DateTime.now().toIso8601String(),
        orderIdIfAccepted: orderId,
        reasonIfDeclined: reason,
      );
      final doc = await _orderRequestCollection.add(orderRequest.toJson());
      orderRequest.id = doc.id;
      doc
          .update(orderRequest.toJson())
          .then((value) => print("Order request id added"));
      // Fluttertoast.showToast(msg: "Order request for customer added.");
      return true;
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        textColor: Colors.white,
        backgroundColor: kOrangeColor,
      );
      print(e);
      return false;
    }
  }

  void makeOrderRequestsSeen(
      List<AcceptedOrDeclinedOrderRequest> orderRequests) async {
    for (var request in orderRequests) {
      if (request.seenStatus == 0) {
        makeOrderRequestSeen(request);
      }
    }
  }

  Future makeOrderRequestSeen(
      AcceptedOrDeclinedOrderRequest orderRequest) async {
    final doc = instance.collection('orderRequests').doc(orderRequest.id!);
    orderRequest.seenStatus = 1;
    doc
        .update(orderRequest.toJson())
        .then((value) => print("updated request# ${orderRequest.id}"));
  }

  void deleteOrderRequestsIfOlderThanMonth(
      List<AcceptedOrDeclinedOrderRequest> orderRequests) {
    for (var request in orderRequests) {
      if (requestOlderThanOneMonth(request.createdOn)) {
        deleteOrderRequest(request);
      }
    }
  }

  bool requestOlderThanOneMonth(String date) {
    DateTime date1 = DateTime.parse(date);
    DateTime date2 = DateTime.now();

    int differenceInDays = date2.difference(date1).inDays;

    if (differenceInDays >= 30) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> deleteOrderRequest(
      AcceptedOrDeclinedOrderRequest request) async {
    final doc = instance.collection('orderRequests').doc(request.id!);
    doc.delete().then((value) => Fluttertoast.showToast(
          textColor: Colors.white,
          backgroundColor: kOrangeColor,
          msg: getTranslatedText("درخواست# ${request.id} ڈلیٹ کی گئی ہے۔",
              "deleted request# ${request.id}"),
        ));
    if (request.status == 1) {
      //also delete order placed, if accepted
      final doc2 =
          instance.collection('orders').doc(request.orderIdIfAccepted!);
      await doc2.get().then((value) {
        if (value.get("advanceDeposited").toDouble() == 0) {
          doc2.delete().then((value) => print(
              "Also deleted corresponding order# ${request.orderIdIfAccepted}"));
          print("ok deleting");
        }
      });
    }
  }

  Future<DresssewOrder?> getOrderWithOrderId(String id) async {
    final result = await instance.collection("orders").doc(id).get();
    if (result.exists) {
      final order =
          DresssewOrder.fromJson(result.data() as Map<String, dynamic>);
      return order;
    }
    return null;
  }

  Future<List<Customer>> loadCustomersOfTailor(tailorDocId) async {
    List<Customer> customers = [];
    final orders = await loadOrdersOfDocId(tailorDocId, isCustomerId: false);
    for (var o in orders) {
      final c = await getCustomerWithDocId(o.customerId);
      customers.add(c!);
    }
    return customers;
  }

  ///loads orders of tailor for customer
  ///used for loading loading measurements of a customer from previous order
  Future<List<DresssewOrder>> loadOrdersOfTailorForCustomer(
      String tailorId, String customerId,
      {bool completedOnly = false}) async {
    List<DresssewOrder> orders = [];
    final result = await instance
        .collection("orders")
        .where("tailorId", isEqualTo: tailorId)
        .where("customerId", isEqualTo: customerId)
        .where("status",
            whereIn: completedOnly
                ? ['completed']
                : ['inProgress', 'justStarted', 'completed'])
        .get();
    if (result.docs.isNotEmpty) {
      for (var element in result.docs) {
        final order = DresssewOrder.fromJson(element.data());
        orders.add(order);
      }
    }
    return orders;
  }

  Future<List<DresssewOrder>> loadCompletedOrdersOfTailor(
      String tailorId) async {
    List<DresssewOrder> orders = [];
    final result = await instance
        .collection("orders")
        .where("tailorId", isEqualTo: tailorId)
        .where("status", isEqualTo: 'completed')
        .get();
    if (result.docs.isNotEmpty) {
      for (var element in result.docs) {
        final order = DresssewOrder.fromJson(element.data());
        orders.add(order);
      }
    }
    return orders;
  }

  Future<bool> deleteAccount(String id, bool isTailor) async {
    if (isTailor) {
      return deleteTailor(id);
    } else {
      return deleteCustomer(id);
    }
  }

  Future<bool> deleteCustomer(String id) async {
    try {
      //delete account
      await FirebaseAuth.instance.currentUser!.delete();
      //delete tailor
      await instance
          .collection('customers')
          .doc(id)
          .delete()
          .then((value) => print('customer doc deleted.'));
      //delete orders
      var value = await instance
          .collection('orders')
          .where('customerId', isEqualTo: id)
          .get();
      for (var val in value.docs) {
        await val.reference
            .delete()
            .then((value) => print('deleted order: ${val.id}'));
      }

      //deleting order requests
      value = await _orderRequestCollection
          .where('customerDocId', isEqualTo: id)
          .get();
      for (var val in value.docs) {
        await val.reference
            .delete()
            .then((value) => print('deleted order request: ${val.id}'));
      }

      Fluttertoast.showToast(
        textColor: Colors.white,
        backgroundColor: kSkinColor,
        msg: getTranslatedText("اکاؤنٹ کامیابی سے ڈلیٹ کر دیا گیا۔",
            'Account deleted successfully.'),
      );
      FirebaseAuth.instance.signOut();
      return true;
    } catch (e) {
      print('Exception deleting: $e');
      return false;
    }
  }

  Future<bool> deleteTailor(String id) async {
    try {
      //delete user first
      await FirebaseAuth.instance.currentUser!.delete();
      //delete tailor
      await instance
          .collection('tailors')
          .doc(id)
          .delete()
          .then((value) => print('tailor doc deleted.'));
      //delete orders
      //delete orders
      var value = await instance
          .collection('orders')
          .where('tailorId', isEqualTo: id)
          .get();
      for (var val in value.docs) {
        await val.reference
            .delete()
            .then((value) => print('deleted order: ${val.id}'));
      }

      //deleting order requests
      value = await _orderRequestCollection
          .where('tailorDocId', isEqualTo: id)
          .get();
      for (var val in value.docs) {
        await val.reference
            .delete()
            .then((value) => print('deleted order request: ${val.id}'));
      }

      Fluttertoast.showToast(
        textColor: Colors.white,
        backgroundColor: kSkinColor,
        msg: getTranslatedText("اکاؤنٹ کامیابی سے ڈلیٹ کر دیا گیا۔",
            'Account deleted successfully.'),
      );
      FirebaseAuth.instance.signOut();
      return true;
    } catch (e) {
      print('Exception deleting: $e');
      return false;
    }
  }

  Future<bool> addNotification(MyNotification notification) async {
    try {
      final doc =
          await instance.collection('notifications').add(notification.toJson());
      notification.id = doc.id;
      await doc.update(notification.toJson());
      print('Notification ${notification.type.name} added.');
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<List<MyNotification>> _getCustomerNotifications(String cId) async {
    final result = await instance
        .collection('notifications')
        .where("customerId", isEqualTo: cId)
        .where("sentByTailor", isEqualTo: true)
        .orderBy("timestamp")
        .get();
    final list = <MyNotification>[];
    for (var value in result.docs) {
      list.add(MyNotification.fromJson(value.data()));
    }
    return list;
  }

  Future<List<MyNotification>> _getTailorNotifications(String tId) async {
    final result = await instance
        .collection('notifications')
        .where("tailorId", isEqualTo: tId)
        .where("sentByTailor", isEqualTo: false)
        .orderBy("timestamp")
        .get();
    final list = <MyNotification>[];
    for (var value in result.docs) {
      list.add(MyNotification.fromJson(value.data()));
    }
    return list;
  }

  Future<List<MyNotification>> getNotifications(String docId,
      {bool isTailor = true}) async {
    return isTailor
        ? _getTailorNotifications(docId)
        : _getCustomerNotifications(docId);
  }

  Future<void> deleteNotification(MyNotification notification) async {
    try {
      // QuerySnapshot snapshot = await FirebaseFirestore.instance
      //     .collection('notifications')
      //     .where('timestamp', isEqualTo: notification.timestamp)
      //     .get();
      //
      // for (var doc in snapshot.docs) {
      //   doc.reference.delete().then((value) => print('deleted ${doc.id}'));
      // }
      final doc = FirebaseFirestore.instance
          .collection('notifications')
          .doc(notification.id);
      doc.delete().then((value) => print('deleted ${doc.id}'));
    } catch (e) {
      print('Error deleting document: $e');
    }
  }
}
