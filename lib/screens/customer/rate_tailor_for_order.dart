import 'dart:io';

import 'package:test/models/order.dart';
import 'package:test/networking/firestore_helper.dart';
import 'package:test/screens/customer/customer_main_screen.dart';
import 'package:test/utilities/custom_widgets/rectangular_button.dart';
import 'package:test/utilities/my_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_overlay/loading_overlay.dart';

import '../../models/notification.dart';
import '../../models/tailor.dart';
import '../../networking/notification_helper.dart';
import '../../utilities/constants.dart';

class RateTailorForOrder extends StatefulWidget {
  const RateTailorForOrder({Key? key, required this.order}) : super(key: key);
  final DresssewOrder order;
  @override
  State<RateTailorForOrder> createState() => _RateTailorForOrderState();
}

class _RateTailorForOrderState extends State<RateTailorForOrder> {
  Tailor? tailor;
  bool isReviewing = false;
  final reviewTextController = TextEditingController();
  List<String> images = [];
  double rating = 0.0;

  final helper = FireStoreHelper();

  bool addImages = false;
  bool isUploadingImage = false;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadTailor();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return LoadingOverlay(
      isLoading: isReviewing,
      progressIndicator: kSpinner(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            getTranslatedText(
                "${getSingleWord(widget.order.tailorShopName)}} کے کام کا جائزہ",
                "Review ${getSingleWord(widget.order.tailorShopName)}'s work"),
            style: kInputStyle.copyWith(fontSize: 18),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: DefaultTextStyle(
              style: kInputStyle.copyWith(color: Colors.black),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildAddRatingWidget(),
                  CheckboxListTile(
                    title: Text(
                      getTranslatedText("تصاویر شامل کریں", 'Add images'),
                      style: kInputStyle,
                    ),
                    value: addImages,
                    onChanged: (bool? value) {
                      if (value != null) {
                        addImages = value;
                        if (!addImages) clearImagesList();
                        if (mounted) {
                          setState(() {});
                        }
                      }
                    },
                  ),
                  if (addImages && images.isNotEmpty)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (images.length < 4)
                              Text(
                                getTranslatedText(
                                    "آپ زیادہ سے زیادہ 4 تصاویر شامل کرسکتے ہیں۔",
                                    'You can add up to 4 images.'),
                                style: kTextStyle,
                              ),
                            Text(
                              getTranslatedText("تصاویر(${images.length}):",
                                  'images(${images.length}):'),
                              style: kTextStyle,
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.01),
                          ],
                        ),
                      ),
                    ),
                  if (addImages)
                    Wrap(
                      spacing: MediaQuery.of(context).size.width * 0.01,
                      runSpacing: MediaQuery.of(context).size.height * 0.02,
                      children: [
                        //shop image 1 container(while he hasn't uploaded any image)
                        //shop image 1 container(while he hasn't uploaded any image)
                        ...List.generate(images.length + 1, (index) {
                          return index < images.length
                              ? buildImageItem(size, images[index],
                                  onRemove: () async {
                                  final Reference storageReference =
                                      FirebaseStorage.instance
                                          .refFromURL(images[index]);
                                  images.removeWhere(
                                      (element) => element == images[index]);
                                  storageReference.delete().then((value) =>
                                      print('delete from firebase.'));
                                  setState(() {});
                                })
                              : images.length == 4
                                  ? const SizedBox()
                                  : buildUploadImageContainer(size,
                                      onPressed: onPickImage);
                        })
                      ],
                    ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  TextField(
                    minLines: 7,
                    maxLines: 8,
                    style: kInputStyle.copyWith(fontSize: 15),
                    controller: reviewTextController,
                    decoration: kTextFieldDecoration.copyWith(
                      hintText: getTranslatedText(
                          'اپنا جائزہ یہاں لکھیں', 'write your review here'),
                      labelText: getTranslatedText("جائزہ", 'review'),
                      labelStyle: kTextStyle,
                      hintStyle: kTextStyle,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: RectangularRoundedButton(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      onPressed: () async {
                        if (rating == 0) {
                          showMyDialog(
                              context,
                              'Error!',
                              getTranslatedText(
                                  "درجہ بندی شامل کریں", 'Add a rating'),
                              disposeAfterMillis: 1200);
                          return;
                        } else if (reviewTextController.text.trim().isEmpty) {
                          showMyDialog(
                              context,
                              'Error!',
                              getTranslatedText(
                                  'جائزہ لکھیں', 'Add review text'),
                              disposeAfterMillis: 1200);
                          return;
                        } else if (addImages && images.isEmpty) {
                          showMyDialog(
                              context,
                              'Error!',
                              getTranslatedText(
                                  'تصاویر شامل کریں۔', 'Add images.'),
                              disposeAfterMillis: 1200);
                          return;
                        } else if (isUploadingImage) {
                          showMyDialog(
                              context,
                              'Error!',
                              getTranslatedText('تصویر اپ لوڈ ہونے دیں۔',
                                  'Let the image be uploaded.'),
                              disposeAfterMillis: 1500);
                          return;
                        }
                        widget.order.rating = rating;

                        if (mounted) {
                          setState(() {
                            isReviewing = true;
                          });
                        }
                        helper
                            .updateOrder(widget.order)
                            .then((value) => debugPrint('Order updated.'));
                        Review review = Review(
                            reviewsImageUrls: images,
                            customerProfileUrl:
                                currentCustomer!.profileImageUrl!,
                            reviewDate: DateTime.now().toIso8601String(),
                            customerName: currentCustomer!.name,
                            rating: rating,
                            reviewText: reviewTextController.text.trim(),
                            orderId: widget.order.orderId!,
                            category: widget.order.dressCategory);
                        print("old rating: ${tailor!.rating}");
                        tailor!.reviews.add(review);
                        //calculating new rating
                        double rat = 0;
                        for (var element in tailor!.reviews) {
                          rat += element.rating;
                        }
                        tailor!.rating = rat / tailor!.reviews.length;
                        print("new rating: ${tailor!.rating}");
                        await helper
                            .updateTailor(tailor!)
                            .then((value) => Fluttertoast.showToast(
                                  msg: getTranslatedText(
                                      "جائزہ کامیابی سے شامل کیا گیا.",
                                      'Review added successfully.'),
                                  textColor: Colors.white,
                                  backgroundColor: kOrangeColor,
                                ));
                        NotificationHelper.sendNotification(
                          widget.order,
                          NotificationType.customerAddedReview,
                          customerName: currentCustomer!.name,
                          sentByTailor: false,
                        );
                        if (mounted) {
                          setState(() {
                            isReviewing = false;
                          });
                        }
                        Navigator.pop(context);
                      },
                      buttonName: 'Done',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future onPickImage() async {
    if (images.length < 4) {
      final file = await picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        final storageRef = FirebaseStorage.instance.ref().child(
            '${widget.order.orderId}/ri${DateTime.now().millisecondsSinceEpoch.hashCode}.png');
        final uploadTask = await storageRef.putFile(File(file.path));
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        setState(() {
          images.add(downloadUrl);
        });
      }
    }
  }

  void loadTailor() async {
    final t = await FireStoreHelper().getTailorWithDocId(widget.order.tailorId);
    if (t != null) {
      tailor = t;
      if (mounted) {
        setState(() {});
      }
    }
  }

  Widget buildAddRatingWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Rating",
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontFamily: 'Georgia',
          ),
        ).tr(),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        RatingBar(
          ratingWidget: RatingWidget(
            full: const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            half: const Icon(Icons.star_half_outlined, color: Colors.amber),
            empty: const Icon(Icons.star_border, color: Colors.amber),
          ),
          onRatingUpdate: (val) {
            setState(() => rating = val);
          },
          allowHalfRating: true,
        ),
        if (rating != 0)
          Column(
            children: [
              Text(
                rating.toString(),
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 25,
                ),
              ),
            ],
          ),
      ],
    );
  }

  String getSingleWord(String tailorShopName) {
    final text = tailorShopName.substring(
        0,
        !tailorShopName.contains(' ')
            ? tailorShopName.length
            : tailorShopName.indexOf(' '));
    return text;
  }

  Widget buildImageItem(size, String? url, {required VoidCallback onRemove}) =>
      Container(
        width: size.width * 0.4,
        height: size.width * 0.38,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: (url == null
                ? const AssetImage('assets/user.png')
                : NetworkImage(url) as ImageProvider),
            fit: BoxFit.cover,
          ),
        ),
        child: Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: InkWell(
              onTap: onRemove,
              child: const CircleAvatar(
                radius: 12,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.clear,
                  color: Colors.red,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      );
  buildUploadImageContainer(size, {required Future Function() onPressed}) {
    return Container(
      width: size.width * 0.4,
      height: size.width * 0.38,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(blurRadius: 2, offset: Offset(1, 1), color: Colors.grey),
        ],
      ),
      child: isUploadingImage
          ? Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LoadingOverlay(
                    isLoading: true,
                    progressIndicator: kSpinner(context, ratioFactor: 0.25),
                    child: const Text('')),
              ),
            )
          : IconButton(
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(FontAwesomeIcons.upload, color: Colors.grey.shade600),
                  Text('Upload', style: kTextStyle.copyWith(fontSize: 18)).tr()
                ],
              ),
              onPressed: () async {
                if (mounted) {
                  setState(() {
                    isUploadingImage = true;
                  });
                }
                await onPressed();
                if (mounted) {
                  setState(() {
                    isUploadingImage = false;
                  });
                }
              },
            ),
    );
  }

  // SpinKitDualRing buildLoadingSpinner() {
  //   return const SpinKitDualRing(
  //     color: Colors.blue,
  //   );
  //   // return SpinKitDoubleBounce(
  //   //   itemBuilder: (BuildContext context, int index) {
  //   //     return DecoratedBox(
  //   //       decoration: BoxDecoration(
  //   //         color: index.isEven ? Colors.blue : Colors.white,
  //   //       ),
  //   //     );
  //   //   },
  //   // );
  // }

  void clearImagesList() async {
    for (var value in images) {
      final Reference storageReference =
          FirebaseStorage.instance.refFromURL(value);
      await storageReference
          .delete()
          .then((value) => print('delete from firebase.'));
    }
    images.clear();
    if (mounted) setState(() {});
  }
}
