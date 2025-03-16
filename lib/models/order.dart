import 'package:test/models/cloth.dart';
import 'package:test/models/measurement.dart';
import 'package:test/models/tailor.dart';

import 'customer.dart';

class DresssewOrder {
  String? orderId;
  double totalAmount;
  double amountRemaining;
  double advanceDeposited;
  String customerId;
  String customerEmail;
  List<Measurement>? measurements;
  MeasurementChoice measurementChoice;
  int clothDeliveryCharges;
  Cloth? cloth;
  bool isCustomizationOnly;
  bool clothReceivedByTailor;
  String tailorId;
  String? expectedDeliveryDate;
  String? deliveredOn;
  String creationDate;
  String dressImage;
  String dressCategory;
  OrderStatus status;
  String anyComments; //can be instructions
  PaymentMethod paymentMethod;
  String tailorShopName;
  OrderTailorPaymentInfo tailorPaymentInfo;
  double rating;

  DresssewOrder({
    this.orderId,
    this.anyComments = '',
    required this.paymentMethod,
    required this.measurementChoice,
    this.measurements,
    this.cloth,
    this.isCustomizationOnly = false,
    this.clothDeliveryCharges = 0,
    required this.tailorId,
    this.clothReceivedByTailor = false,
    required this.tailorShopName,
    required this.tailorPaymentInfo,
    required this.dressCategory,
    required this.dressImage,
    required this.advanceDeposited,
    required this.customerEmail,
    required this.customerId,
    this.expectedDeliveryDate,
    this.deliveredOn,
    required this.creationDate,
    required this.status,
    this.rating = 0,
    required this.totalAmount,
    required this.amountRemaining,
  });
  static DresssewOrder fromJson(Map<String, dynamic> json) {
    return DresssewOrder(
      orderId: json['orderId'],
      totalAmount: json["totalAmount"] != null
          ? json["totalAmount"].toDouble()
          : 0.toDouble(),
      advanceDeposited: json["advanceDeposited"] != null
          ? json["advanceDeposited"].toDouble()
          : 0.toDouble(),
      amountRemaining: json["amountRemaining"] != null
          ? json["amountRemaining"].toDouble()
          : 0.toDouble(),
      customerId: json['customerId'],
      clothReceivedByTailor: json['clothReceivedByTailor'],
      customerEmail: json['customerEmail'],
      tailorId: json['tailorId'],
      tailorShopName: json['tailorShopName'],
      expectedDeliveryDate: json['deliveryDate'],
      deliveredOn: json['deliveredOn'],
      measurements: json['measurements'] == null
          ? null
          : (json['measurements'] as List)
              .map((e) => Measurement.fromJson(e))
              .toList(),
      cloth: json['cloth'] == null ? null : Cloth.fromJson(json['cloth']),
      dressCategory: json['category'],
      dressImage: json['dressImage'],
      status: getOrderStatus(json['status']),
      anyComments: json['comments'],
      paymentMethod: getPaymentMethod(json['paymentMethod']),
      tailorPaymentInfo:
          OrderTailorPaymentInfo.fromJson(json['tailorPaymentInfo']),
      rating: json["rating"] != null ? json["rating"].toDouble() : 0.toDouble(),
      measurementChoice: getMeasurementChoice(json['measurementChoice']),
      creationDate: json['creationDate'],
      clothDeliveryCharges: json['clothDeliveryCharges'],
      isCustomizationOnly: json['isCustomizationOnly'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'totalAmount': totalAmount,
      'advanceDeposited': advanceDeposited,
      'paymentMethod': paymentMethod.name,
      'customerId': customerId,
      'customerEmail': customerEmail,
      'tailorId': tailorId,
      'deliveryDate': expectedDeliveryDate,
      'deliveredOn': deliveredOn,
      'creationDate': creationDate,
      'category': dressCategory,
      'tailorPaymentInfo': tailorPaymentInfo.toJson(),
      'measurementChoice': measurementChoice.name,
      'dressImage': dressImage,
      'status': status.name,
      'measurements': measurements?.map((e) => e.toJson()).toList(),
      'cloth': cloth?.toJson(),
      'clothReceivedByTailor': clothReceivedByTailor,
      'comments': anyComments,
      'tailorShopName': tailorShopName,
      'rating': rating,
      'amountRemaining': amountRemaining,
      'clothDeliveryCharges': clothDeliveryCharges,
    };
  }

  @override
  String toString() {
    return toJson().toString();
  }
}

// final paymentInfo = OrderTailorPaymentInfo(PaymentMethod.jazzcash, dummyNumber);

class OrderTailorPaymentInfo {
  PaymentMethod paymentMethod; //can be "jazzcash" or "easypaisa"
  String accountNumber;
  OrderTailorPaymentInfo(this.paymentMethod, this.accountNumber);
  Map<String, dynamic> toJson() => {
        "paymentMethod": paymentMethod.name,
        "accountNumber": accountNumber,
      };

  static fromJson(Map<String, dynamic> json) => OrderTailorPaymentInfo(
      getPaymentMethod(json['paymentMethod']), json['accountNumber']);
}

PaymentMethod getPaymentMethod(String type) {
  return type == PaymentMethod.jazzcash.name
      ? PaymentMethod.jazzcash
      : PaymentMethod.easypaisa;
}

OrderStatus getOrderStatus(String type) {
  OrderStatus orderStatus = type == OrderStatus.notStartedYet.name
      ? OrderStatus.notStartedYet
      : type == OrderStatus.justStarted.name
          ? OrderStatus.justStarted
          : type == OrderStatus.inProgress.name
              ? OrderStatus.inProgress
              : OrderStatus.completed;
  return orderStatus;
}

enum OrderStatus {
  notStartedYet,
  justStarted,
  inProgress,
  completed,
}

OrderRequestStatus getOrderRequestStatus(String type) {
  OrderRequestStatus status = type == OrderRequestStatus.pending.name
      ? OrderRequestStatus.pending
      : type == OrderRequestStatus.accepted.name
          ? OrderRequestStatus.accepted
          : OrderRequestStatus.declined;
  return status;
}

enum OrderRequestStatus {
  pending,
  accepted,
  declined,
}

//request made by customer and shown to tailor whether he accepts or denies its his choice
class OrderRequest {
  RateItem dressInfo;
  Customer customer;
  String? date;
  MeasurementChoice measurementChoice;
  OrderRequestStatus? requestStatus;
  String dressImage;
  bool isCustomizationOnly;

  OrderRequest({
    required this.dressInfo,
    required this.date,
    required this.customer,
    this.requestStatus = OrderRequestStatus.pending,
    required this.dressImage,
    required this.measurementChoice,
    this.isCustomizationOnly = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'customer': customer.toJson(),
      'dressInfo': dressInfo.toJson(),
      'date': date,
      'isCustomizationOnly': isCustomizationOnly,
      'measurementChoice': measurementChoice.name,
      'requestStatus': requestStatus?.name,
      'dressImage': dressImage,
    };
  }

  factory OrderRequest.fromJson(Map<String, dynamic> json) {
    return OrderRequest(
      dressInfo: RateItem.fromJson(json['dressInfo']),
      customer: Customer.fromJson(json['customer']),
      date: json['date'],
      isCustomizationOnly: json['isCustomizationOnly'],
      measurementChoice: getMeasurementChoice(json['measurementChoice']),
      requestStatus: getOrderRequestStatus(json['requestStatus']),
      dressImage: json['dressImage'],
    );
  }
}

enum PaymentMethod {
  jazzcash,
  easypaisa,
}

class AcceptedOrDeclinedOrderRequest {
  String? id;
  String customerEmail;
  bool isCustomizationOnly;
  String tailorShopName;
  String dressItem;
  String customerDocId;
  String tailorDocId;
  int status; // if 1 then accepted if 0 then declined
  int seenStatus; //if 1 then seen if 0 then unseen yet by customer
  String? reasonIfDeclined;
  String? orderIdIfAccepted;

  String createdOn;

  String requestDate;

  AcceptedOrDeclinedOrderRequest({
    this.id,
    required this.customerEmail,
    required this.tailorShopName,
    required this.customerDocId,
    required this.tailorDocId,
    required this.dressItem,
    required this.status,
    required this.seenStatus,
    this.isCustomizationOnly = false,
    required this.createdOn,
    this.reasonIfDeclined,
    this.orderIdIfAccepted,
    required this.requestDate,
  });

  factory AcceptedOrDeclinedOrderRequest.fromJson(Map<String, dynamic> json) {
    return AcceptedOrDeclinedOrderRequest(
      id: json['id'],
      customerEmail: json['customerEmail'],
      tailorShopName: json['tailorShopName'],
      customerDocId: json['customerDocId'],
      tailorDocId: json['tailorDocId'],
      status: json['status'],
      seenStatus: json['seenStatus'],
      reasonIfDeclined: json['reason'],
      orderIdIfAccepted: json['orderIdIfAccepted'],
      createdOn: json['createdOn'],
      dressItem: json['dressItem'],
      requestDate: json['requestDate'],
      isCustomizationOnly: json['isCustomizationOnly'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['customerEmail'] = customerEmail;
    data['tailorShopName'] = tailorShopName;
    data['customerDocId'] = customerDocId;
    data['tailorDocId'] = tailorDocId;
    data['status'] = status;
    data['seenStatus'] = seenStatus;
    data['isCustomizationOnly'] = isCustomizationOnly;
    data['reason'] = reasonIfDeclined;
    data['orderIdIfAccepted'] = orderIdIfAccepted;
    data['createdOn'] = createdOn;
    data['dressItem'] = dressItem;
    data['requestDate'] = requestDate;
    return data;
  }
}

final orderRequestDeclineReasons = [
  "Currently, We are busy in some other projects.",
  "We are unable to fulfill the order due to a personal emergency.",
  "The materials required for the order are currently unavailable.",
  "The order requires specialized equipment or tools that I do not have access to.",
  "We are currently not accepting orders for the requested item or service.",
];
