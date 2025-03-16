import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test/models/product.dart';
import 'package:http/http.dart' as http;

class ApiHelper {
  final instance = FirebaseFirestore.instance;
  static const key = "b88b71c8b11a42eb9a8b19febd4d1fae";

  static Future<String> translateText(String text) async {
    final url = Uri.parse(
        'https://api.cognitive.microsofttranslator.com/translate?api-version=3.0&from=en&to=ur');

    final headers = {
      'Ocp-Apim-Subscription-Key': key,
      'Ocp-Apim-Subscription-Region': 'eastus',
      'Content-Type': 'application/json; charset=UTF-8',
    };

    final body = jsonEncode([
      {'Text': text}
    ]);

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final translatedText =
          jsonDecode(response.body)[0]['translations'][0]['text'];
      return translatedText;
    } else {
      print('Failed to translate text.: ${response.statusCode}');
      return "";
    }
  }

  Future<List<Product>> loadAllProducts() async {
    final List<Product> products = [];
    // final result = await instance.collection("products").get();
    // if (result.docs.isNotEmpty) {
    //   result.docs.forEach((element) {
    //     final product = Product.fromJson(element.data());
    //     products.add(product);
    //   });
    // }
    jsonData.forEach((element) {
      final product = Product.fromJson(element);
      products.add(product);
    });
    return products;
  }
}

final jsonData = [
  {
    "name": "Product 1",
    "description":
        "Mood Exclusive Stormy Weather and Copper Hibiscus Hex Polyester Stretch Satin",
    "price": 300,
    "imageUrl":
        "https://www.moodfabrics.com/media/catalog/product/cache/97db670f3df31818ced9c267af3eee34/3/3/330838.jpg",
    "productUrl":
        "https://www.moodfabrics.com/british-imported-berry-ornate-leafy-tiles-printed-polyester-velvet-awg3221",
  },
  {
    "name": "Product 2",
    "description": "Bright White and Black Floral Re-Embroidered Stretch",
    "price": 440,
    "imageUrl":
        "https://www.moodfabrics.com/media/catalog/product/4/2/421964-c.jpg",
    "productUrl":
        "https://www.moodfabrics.com/british-imported-berry-ornate-leafy-tiles-printed-polyester-velvet-awg3221",
  },
  {
    "name": "Product 3",
    "description": "Natural Bone Carved Circular 2-Hole Button - 36L/23mm",
    "price": 943,
    "imageUrl":
        "https://www.moodfabrics.com/media/catalog/product/cache/1f81309f5bf327b1153122abcf75bc50/3/2/322789-d.jpg",
    "productUrl":
        "https://www.moodfabrics.com/british-imported-berry-ornate-leafy-tiles-printed-polyester-velvet-awg3221",
  },
  {
    "name": "Product 4",
    "description":
        "British Imported Berry Ornate Leafy Tiles Printed Polyester",
    "price": 87,
    "imageUrl":
        "https://www.moodfabrics.com/media/catalog/product/cache/1f81309f5bf327b1153122abcf75bc50/A/W/AWG3221-d.jpg",
    "productUrl":
        "https://www.moodfabrics.com/british-imported-berry-ornate-leafy-tiles-printed-polyester-velvet-awg3221",
  },
];
