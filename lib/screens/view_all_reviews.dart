import 'package:test/networking/api_helper.dart';
import 'package:test/utilities/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../models/tailor.dart';
import '../utilities/custom_widgets/editable_text.dart';

class ViewAllReviews extends StatelessWidget {
  const ViewAllReviews({Key? key, required this.reviews}) : super(key: key);
  final List<Review> reviews;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          getTranslatedText("تمام جائزے(${reviews.length})",
              'All Reviews(${reviews.length})'),
          style: kInputStyle.copyWith(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: buildReviews(context),
        ),
      ),
    );
  }

  Widget buildReviews(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(
        reviews.length,
        (index) => Card(
          color: kLightSkinColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.blue,
                    child: CircleAvatar(
                      backgroundImage:
                          NetworkImage(reviews[index].customerProfileUrl),
                      backgroundColor: Colors.white,
                      radius: 25,
                    ),
                  ),
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureBuilder(
                              future: ApiHelper.translateText(
                                  reviews[index].customerName),
                              builder: (_, st) {
                                return Text(
                                  getTranslatedText(st.data ?? '..',
                                      reviews[index].customerName),
                                  style: kInputStyle,
                                );
                              }),
                          FittedBox(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  getTranslatedText("لباس: ", 'dress: '),
                                  style: kInputStyle.copyWith(fontSize: 12),
                                ),
                                Text(
                                  getCategory(reviews[index].category),
                                  style: kInputStyle.copyWith(fontSize: 12),
                                ).tr(),
                              ],
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.005),
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.22,
                            child: FittedBox(
                              child: RatingBarIndicator(
                                unratedColor: Colors.grey.shade400,
                                rating: reviews[index].rating,
                                itemBuilder: (context, index) => const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                itemCount: 5,
                                itemSize: 15.0,
                              ),
                            ),
                          ),
                          Text(
                            '${reviews[index].rating}',
                            style: kTextStyle.copyWith(fontSize: 12),
                            textAlign: TextAlign.center,
                          )
                        ],
                      )
                    ],
                  ),
                  subtitle: FutureBuilder(
                      future:
                          ApiHelper.translateText(reviews[index].reviewText),
                      builder: (_, st) {
                        return reviews[index].reviewText.length >= 180
                            ? ExpandableText(getTranslatedText(
                                st.data ?? '..', reviews[index].reviewText))
                            : Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Text(
                                  getTranslatedText(st.data ?? '..',
                                      reviews[index].reviewText),
                                  style: kTextStyle.copyWith(fontSize: 12),
                                  textAlign: TextAlign.start,
                                ),
                              );
                      }),
                  // trailing: ,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    spacing: MediaQuery.of(context).size.width * 0.05,
                    runSpacing: 5,
                    children: List.generate(
                      reviews[index].reviewsImageUrls.length,
                      (index2) => buildShopImageItem(
                          context, reviews[index].reviewsImageUrls[index2]),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.015),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildShopImageItem(context, String url) {
    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(10.0),
      color: kSkinColor,
      image: DecorationImage(
        image: NetworkImage(url),
        fit: BoxFit.fill,
      ),
    );
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => Card(
            margin: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.15,
              horizontal: MediaQuery.of(context).size.width * 0.04,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: decoration,
                ),
                Positioned(
                  right: 0,
                  child: SizedBox(
                    child: FloatingActionButton(
                      mini: true,
                      isExtended: false,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(Icons.close),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.32,
        height: MediaQuery.of(context).size.height * 0.16,
        decoration: decoration,
      ),
    );
  }
}
