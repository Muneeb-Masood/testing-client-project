import 'package:test/models/measurement.dart';
import 'package:test/models/order.dart';
import 'package:test/models/shop.dart';
import 'package:test/models/user_location.dart';
import 'package:test/utilities/constants.dart';

class Tailor {
  String tailorName;
  String email;
  String? id;
  bool availableToWork;
  String? userDocId;
  Gender gender;
  String? phoneNumber;
  StitchingType stitchingType;
  List<String> expertise;
  String? profileImageUrl;
  List<RateItem> rates;
  Shop? shop;
  int? experience;
  bool customizes;
  int onTimeDelivery;
  //average rating
  double rating;
  List<OrderRequest> orderRequests;
  // List<DresssewOrder> orders;
  UserLocation location;
  List<Review> reviews;

  Tailor({
    this.id,
    this.userDocId,
    this.availableToWork = true,
    required this.tailorName,
    this.phoneNumber,
    this.shop,
    this.orderRequests = const [],
    required this.email,
    this.experience,
    this.customizes = false,
    this.onTimeDelivery = 100,
    this.rating = 0,
    required this.gender,
    // this.orders = const [],
    this.profileImageUrl,
    this.rates = const [],
    this.reviews = const [],
    this.expertise = const [],
    required this.stitchingType,
    required this.location,
  });

  static Tailor fromJson(Map<String, dynamic> json) => Tailor(
        id: json['id'],
        userDocId: json['user_doc_id'],
        tailorName: json['tailor_name'],
        phoneNumber: json['phone_number'],
        shop: Shop.fromJson(json['shop']),
        email: json['email'],
        orderRequests: (json['orderRequests'] != null
            ? (json['orderRequests'] as List)
                .map((e) => OrderRequest.fromJson(e))
                .toList()
            : []),
        availableToWork: json['availableToWork'] ?? true,
        reviews: (json['reviews'] != null
            ? (json['reviews'] as List).map((e) => Review.fromJson(e)).toList()
            : []),
        gender: getGender(json['gender']),
        experience: json['experience'],
        customizes: json['customizes'],
        onTimeDelivery: json['on_time_delivery'].toInt(),
        rating: json['rating']?.toDouble(),
        // orders: (json['orders'] != null
        //     ? (json['orders'] as List)
        //         .map((e) => DresssewOrder.fromJson(e))
        //         .toList()
        //     : []),
        rates:
            (json['rates'] as List).map((e) => RateItem.fromJson(e)).toList(),
        expertise: json['expertise'].cast<String>(),
        stitchingType: getStitchingType(json['stitchingType']),
        location: UserLocation.fromMap(json['user_location']),
        profileImageUrl: json['profile_image_url'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'tailor_name': tailorName,
        'user_doc_id': userDocId,
        'availableToWork': availableToWork,
        'phone_number': phoneNumber,
        'email': email,
        'gender': gender.name,
        'experience': experience,
        'shop': shop?.toJson(),
        'orderRequests': orderRequests.map((e) => e.toJson()).toList(),
        'reviews': reviews.map((e) => e.toJson()).toList(),
        'profile_image_url': profileImageUrl,
        'customizes': customizes,
        'on_time_delivery': onTimeDelivery,
        'user_location': location.toJson(),
        'rating': rating,
        // 'orders': orders.map((e) => e.toJson()).toList(),
        'rates': rates.map((e) => e.toJson()).toList(),
        'expertise': expertise,
        'stitchingType': stitchingType.name,
      };

  @override
  String toString() {
    return toJson().toString();
  }
}

class Review {
  String customerName;
  String customerProfileUrl;
  double rating;
  String reviewText;
  String reviewDate;
  String orderId;
  String category;
  List<String> reviewsImageUrls;

  Review({
    required this.customerProfileUrl,
    required this.reviewDate,
    required this.customerName,
    required this.rating,
    required this.reviewText,
    required this.orderId,
    required this.category,
    this.reviewsImageUrls = const [],
  });

  static Review fromJson(Map<String, dynamic> json) => Review(
        customerName: json['customer_name'],
        customerProfileUrl: json['profile_url'],
        rating: json['rating'].toDouble(),
        reviewText: json['review_text'],
        orderId: json['order_id'],
        reviewDate: json['review_date'],
        category: json['category'],
        reviewsImageUrls: (json['reviews_image_urls'] as List).cast<String>(),
      );

  Map<String, dynamic> toJson() => {
        'customer_name': customerName,
        'profile_url': customerProfileUrl,
        'rating': rating,
        'review_text': reviewText,
        'order_id': orderId,
        'review_date': reviewDate,
        'category': category,
        'reviews_image_urls': reviewsImageUrls,
      };
}

///dress item rate template
class RateItem {
  String category;
  int price;
  int? customizationPrice;
  String dressImage;

  RateItem(
      {required this.category,
      required this.price,
      required this.dressImage,
      this.customizationPrice});

  static RateItem fromJson(Map<String, dynamic> json) => RateItem(
        category: json['category'],
        price: json['price'],
        customizationPrice: json["customizationPrice"],
        dressImage: json['dressImage'] ?? dressImages[json['category']],
      );

  Map<String, dynamic> toJson() => {
        'category': category,
        'price': price,
        'dressImage': dressImage,
        'customizationPrice': customizationPrice,
      };

  @override
  String toString() {
    return toJson().values.toString();
  }
}

enum StitchingType {
  gents,
  ladies,
  both,
}

StitchingType getStitchingType(String type) {
  StitchingType stitchingType = type == StitchingType.gents.name
      ? StitchingType.gents
      : type == StitchingType.ladies.name
          ? StitchingType.ladies
          : StitchingType.both;
  return stitchingType;
}

enum Gender { male, female }

Gender getGender(String type) {
  Gender gender = type == Gender.male.name ? Gender.male : Gender.female;
  return gender;
}

MeasurementChoice getMeasurementChoice(String type) {
  MeasurementChoice measurementChoice = type == MeasurementChoice.physical.name
      ? MeasurementChoice.physical
      : type == MeasurementChoice.online.name
          ? MeasurementChoice.online
          : MeasurementChoice.viaAgent;
  return measurementChoice;
}
