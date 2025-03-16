import 'package:test/main.dart';
import 'package:test/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/product.dart';
import '../../networking/api_helper.dart';

class StoreScreen extends StatefulWidget {
  static const id = "/customer_home";

  const StoreScreen({super.key});
  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final apiStorer = ApiHelper();
  List<Product> products = [];

  bool isLoadingProducts = false;
  String searchedProductName = "";

  final searchFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProducts();
    Future.delayed(const Duration(milliseconds: 20)).then((value) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return LoadingOverlay(
      isLoading: appUser == null || isLoadingProducts,
      progressIndicator: kSpinner(context),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    buildSearchTextField(size),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    Text(
                      'Popular',
                      style: kInputStyle.copyWith(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Wrap(
                spacing: size.width * 0.03,
                runSpacing: size.height * 0.01,
                children: List.generate(
                  products.length,
                  (index) {
                    return ProductCard(
                      product: products[index],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  loadProducts() {
    toggleLoadingStatus();
    apiStorer.loadAllProducts().then((value) {
      products = value;
      if (mounted) setState(() {});
      print("Products length: ${products.length}");
      toggleLoadingStatus();
    });
  }

//25.3666667:lat,68.3666667:lon=>hyderabad

  void toggleLoadingStatus() {
    if (mounted) {
      setState(() {
        isLoadingProducts = !isLoadingProducts;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    searchFieldController.dispose();
  }

  onProductSearch(String val) {
    if (mounted) {
      if (val.isNotEmpty) {
        setState(() {
          searchedProductName = val;
        });
      }
      // print(searchedTailorName);
    }
  }

  buildSearchTextField(Size size) {
    return TextField(
      controller: searchFieldController,
      decoration: kTextFieldDecoration.copyWith(
        contentPadding: EdgeInsets.zero,
        hintText: 'search a product',
        hintStyle: kInputStyle,
        suffixIcon: IconButton(
          icon: Icon(FontAwesomeIcons.xmark, size: 18),
          onPressed: () {
            searchFieldController.clear();
            if (mounted) setState(() {});
          },
        ),
        prefixIcon: Icon(
          FontAwesomeIcons.magnifyingGlass,
          size: 15,
          color: Colors.grey,
        ),
      ),
      onChanged: onProductSearch,
      onSubmitted: onProductSearch,
    );
  }
}

enum SearchFilter {
  popular,
  fabric,
  buttons,
  laces,
}

class ProductCard extends StatelessWidget {
  const ProductCard({Key? key, required this.product}) : super(key: key);
  final Product product;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width * 0.42,
      height: size.height * 0.23,
      child: GestureDetector(
        onTap: _launchUrl,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: size.width * 0.3,
                    height: size.height * 0.12,
                    child: Image.network(product.imageUrl, fit: BoxFit.contain),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.name,
                      style: kInputStyle,
                      textAlign: TextAlign.center,
                    ),
                    // Text(
                    //   product.description.substring(0, 12),
                    //   style: kInputStyle.copyWith(fontSize: 10),
                    //   textAlign: TextAlign.center,
                    // ),
                    Text(
                      product.price.toString(),
                      style: kInputStyle,
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl() async {
    final url = Uri.parse(product.imageUrl);
    if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
      throw Exception('Could not launch $url');
    }
  }
}
