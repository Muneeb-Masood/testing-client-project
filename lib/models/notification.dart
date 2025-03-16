MyNotification dummyNotification(type) => MyNotification(
      orderId: "DIEOQbkikdRo3nzW2rN3",
      tailorId: "FaNcTehPAsyZI6zg2icz",
      customerId: "3DT59Rgp3CfSIg9FgUdT",
      dressCategory: "Shervaani",
      customerName: "Ahmed Ali",
      tailorShopName: "Fahad Tailors",
      timestamp: "2023-05-13T18:13:37.553031",
      type: type,
    );

class MyNotification {
  String? id;
  //if true(tailor sent remainder) then show noti based on customerId to customer
  //if false then show it to the tailor himself based on tailorId
  bool sentByTailor;
  String orderId;
  String dressCategory;
  String customerName;
  String tailorShopName;
  String tailorId;
  String customerId;
  String timestamp;
  NotificationType type;

  MyNotification({
    this.id,
    this.sentByTailor = true,
    required this.orderId,
    required this.tailorId,
    required this.customerId,
    required this.dressCategory,
    required this.customerName,
    required this.tailorShopName,
    required this.timestamp,
    required this.type,
  });

  factory MyNotification.fromJson(Map<String, dynamic> json) {
    return MyNotification(
      id: json['id'],
      sentByTailor: json['sentByTailor'],
      orderId: json['orderId'],
      tailorId: json['tailorId'],
      customerId: json['customerId'],
      dressCategory: json['dressCategory'],
      customerName: json['customerName'],
      tailorShopName: json['tailorShopName'],
      timestamp: json['timestamp'],
      type: _parseNotificationType(json['type']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sentByTailor': sentByTailor,
      'orderId': orderId,
      'customerId': customerId,
      'tailorId': tailorId,
      'dressCategory': dressCategory,
      'customerName': customerName,
      'tailorShopName': tailorShopName,
      'timestamp': timestamp,
      'type': _notificationTypeToString(type),
    };
  }

  static NotificationType _parseNotificationType(String value) {
    return NotificationType.values.firstWhere(
      (type) => _notificationTypeToString(type) == value,
      orElse: () => NotificationType.toAddReview,
    );
  }

  static String _notificationTypeToString(NotificationType type) {
    return type.toString().split('.').last;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}

enum NotificationType {
  toCompleteSteps,
  customerCompletedSteps,
  toSubmitMeasurements,
  customerAddedMeasurements,
  customerToSubmitCloth,
  orderStatusUpdated,
  // deadlineComingInTwoDays, // if this is there, which i have implemented the  it will tease again & again the tailor
  // i have added a label on tailor_order_card to repsent if an order has deadline within two days
  orderIsBeingLate,
  toPayDuesAndAddReview,
  toAddReview,
  customerAddedReview,
}
