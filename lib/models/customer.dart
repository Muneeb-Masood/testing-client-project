import 'package:test/models/measurement.dart';
import 'package:test/models/tailor.dart';
import 'package:test/models/user_location.dart';

// Dress myDress = Dress(
//   dressTitle: 'My Dress',
//   tailorDocId: '123456',
//   tailorShopName: 'Tailor Shop',
//   amount: 50,
//   dressImage: 'my-dress.png',
//   completionDate: '2023-03-30',
//   rating: 4.5,
//   customerEmail: 'ahmed@gmail.com',
//   customerDocId: '3DT59Rgp3CfSIg9FgUdT',
// );

class Customer {
  String? id;
  String name;
  String email;
  Gender? gender;
  List<Review> reviewsGiven;
  String? phoneNumber;
  String? profileImageUrl;
  String? address;
  String? city;
  String? userDocId;
  List<Measurement> measurements;
  MeasurementChoice measurementChoice;
  UserLocation location;
  // List<Dress> myDresses;

  Customer({
    this.id,
    required this.city,
    required this.name,
    required this.email,
    this.gender,
    this.reviewsGiven = const [],
    this.userDocId,
    this.profileImageUrl,
    this.address,
    this.measurementChoice = MeasurementChoice.online,
    this.phoneNumber,
    this.measurements = const [],
    required this.location,
    // this.myDresses = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'user_doc_id': userDocId,
        'gender': gender?.name,
        'orders': reviewsGiven.map((e) => e.toJson()).toList(),
        'phone_number': phoneNumber,
        'measurement_choice': measurementChoice.name,
        'address': address,
        'city': city,
        'measurements': measurements.map((e) => e.toJson()).toList(),
        'profile_image_url': profileImageUrl,
        'user_location': location.toJson(),
        // 'dresses': myDresses.map((e) => e.toJson()).toList(),
      };

  static Customer fromJson(Map<String, dynamic> json) {
    return Customer(
        name: json['name'],
        gender: json['gender'] != null ? getGender(json['gender']) : null,
        email: json['email'],
        measurementChoice: getMeasurementChoice(json['measurement_choice']),
        profileImageUrl: json['profile_image_url'],
        id: json['id'],
        userDocId: json['user_doc_id'],
        address: json['address'],
        city: json['city'] ?? 'Jamshoro',
        measurements: (json['measurements'] as List)
            .map((e) => Measurement.fromJson(e))
            .toList(),
        phoneNumber: json['phone_number'],
        location: UserLocation.fromMap(json['user_location']),
        // myDresses: json['dresses'] == null
        //     ? [myDress]
        //     : (json['dresses'] as List).map((e) => Dress.fromJson(e)).toList(),
        reviewsGiven:
            (json['orders'] as List).map((e) => Review.fromJson(e)).toList());
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
