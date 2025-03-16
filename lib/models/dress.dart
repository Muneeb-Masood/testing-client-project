class Dress {
  String dressTitle;
  String tailorDocId;
  String tailorShopName;
  String customerDocId;
  String customerEmail;
  int amount;
  String dressImage;
  String completionDate;
  double rating;
  // DressStatus status;

  Dress({
    required this.dressTitle,
    required this.tailorDocId,
    required this.tailorShopName,
    required this.amount,
    required this.dressImage,
    required this.completionDate,
    required this.rating,
    required this.customerEmail,
    required this.customerDocId,
  });

  factory Dress.fromJson(Map<String, dynamic> json) {
    return Dress(
      dressTitle: json['dressTitle'],
      tailorDocId: json['tailorDocId'],
      tailorShopName: json['tailorShopName'],
      amount: json['amount'],
      dressImage: json['dressImage'],
      completionDate: json['completionDate'],
      rating: json['rating'],
      customerEmail: json['customerEmail'],
      customerDocId: json['customerDocId'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['dressTitle'] = dressTitle;
    data['tailorDocId'] = tailorDocId;
    data['tailorShopName'] = tailorShopName;
    data['amount'] = amount;
    data['dressImage'] = dressImage;
    data['completionDate'] = completionDate;
    data['rating'] = rating;
    data['customerEmail'] = customerEmail;
    data['customerDocId'] = customerDocId;
    return data;
  }
}
