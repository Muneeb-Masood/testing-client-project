class UserLocation {
  double longitude;
  double latitude;

  UserLocation({required this.longitude, required this.latitude});

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };

  static UserLocation fromMap(Map<String, dynamic> json) =>
      UserLocation(longitude: json['longitude'], latitude: json['latitude']);
}
