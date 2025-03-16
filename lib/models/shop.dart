class Shop {
  String name;
  String address;
  String city;
  String country;
  int postalCode;
  int viaAgentCharges;
  String? shopImage1Url;
  String? shopImage2Url;
  // Map<String, List<int>> shopImagesBytes;

  Shop({
    required this.address,
    required this.city,
    required this.name,
    this.country = "Pakistan",
    required this.postalCode,
    required this.viaAgentCharges,
    this.shopImage1Url,
    this.shopImage2Url,
    // this.shopImagesBytes = const {},
  });

  static Shop fromJson(Map<String, dynamic> json) {
    return Shop(
      address: json['address'],
      city: json['city'],
      name: json['name'],
      country: json['country'],
      postalCode: json['postal_code'],
      shopImage1Url: json['shop_image1_url'],
      shopImage2Url: json['shop_image2_url'],
      viaAgentCharges: json['viaAgentCharges'],
    );
    // shopImagesBytes: json['shop_images'] as Map<String, List<int>>);
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'city': city,
        'country': country,
        'postal_code': postalCode,
        'viaAgentCharges': viaAgentCharges,
        'shop_image1_url': shopImage1Url,
        'shop_image2_url': shopImage2Url,
        // 'shop_images': shopImagesBytes,
      };
}

//for storing shop images bytes to firebase as it doesn't support nested arrays
Map<String, dynamic> listToJson(List<int> ints) {
  Map<String, dynamic> map = Map();
  for (int i = 0; i < ints.length; i++) {
    map[i.toString()] = ints[i];
  }
  return map;
}

List<int> jsonToList(Map<String, dynamic> json) {
  List<int> ints = [];
  for (var value in json.values) {
    ints.add(value as int);
  }
  return ints;
}

// class ShopLocation {
//   double latitude;
//   double longitude;
//
//   ShopLocation(this.latitude, this.longitude);
//
//   static ShopLocation fromJson(Map<String, dynamic> json) {
//     return ShopLocation(json['latitude'], json['longitude']);
//   }
//
//   Map<String, dynamic> toJson() => {
//         'latitude': latitude,
//         'longitude': longitude,
//       };
// }
