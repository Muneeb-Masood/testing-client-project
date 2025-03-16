class AppUser {
  String? id;
  String? customerOrTailorId;
  String name;
  String email;
  bool isTailor;
  //only account created or also regisered as custoemr or tailor
  bool isRegistered;
  String dateJoined;

  AppUser(
      {this.id,
      this.customerOrTailorId,
      required this.dateJoined,
      required this.name,
      required this.email,
      this.isRegistered = false,
      required this.isTailor});

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer_or_tailor_id': customerOrTailorId,
        'name': name,
        'email': email,
        'is_registered': isRegistered,
        'date_joined': dateJoined,
        'is_tailor': isTailor,
      };

  static AppUser fromJson(Map<String, dynamic> json) {
    return AppUser(
      name: json['name'],
      email: json['email'],
      isTailor: json['is_tailor'],
      id: json['id'],
      isRegistered: json['is_registered'],
      dateJoined: json['date_joined'],
      customerOrTailorId: json['customer_or_tailor_id'],
    );
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
