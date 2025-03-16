import 'dart:io';

import 'package:test/main.dart';
import 'package:test/models/tailor.dart';
import 'package:test/networking/api_helper.dart';
import 'package:test/networking/firestore_helper.dart';
import 'package:test/screens/customer/dress_sewing_item_choice_page.dart';
import 'package:test/screens/tailor/edit_my_info_card_items.dart';
import 'package:test/screens/tailor/tailor_edit_profile.dart';
import 'package:test/screens/tailor/tailor_main_screen.dart';
import 'package:test/screens/view_all_reviews.dart';
import 'package:test/utilities/constants.dart';
import 'package:test/utilities/custom_widgets/rectangular_button.dart';
import 'package:test/utilities/custom_widgets/tailor_Card.dart';
import 'package:test/utilities/my_pie_chart.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utilities/custom_widgets/editable_text.dart';
import '../../utilities/my_dialog.dart';
import '../customer/customer_main_screen.dart';
import '../login.dart';

class TailorProfile extends StatefulWidget {
  const TailorProfile({Key? key, required this.tailor}) : super(key: key);
  final Tailor tailor;
  @override
  State<TailorProfile> createState() => _TailorProfileState();
}

class _TailorProfileState extends State<TailorProfile> {
  bool isEditMode = false;
  bool isUpdatingDress = false;
  @override
  void initState() {
    super.initState();
    setEditMode();
  }

  setEditMode() {
    //willbe editable only if it has been opened from tailors own app and from main menu.
    if (widget.tailor == currentTailor) {
      isEditMode = true;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: isEditMode ? size.height * 0.01 : size.height * 0.005),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: buildTopRow(),
                        ),
                        CircleAvatar(
                          radius: size.width * 0.2,
                          backgroundColor: kOrangeColor,
                          child: CircleAvatar(
                            radius: size.width * 0.2 - 1,
                            backgroundColor: kLightSkinColor,
                            backgroundImage: NetworkImage(
                              widget.tailor.profileImageUrl!,
                            ),
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01),
                        FutureBuilder(
                            future: ApiHelper.translateText(
                                widget.tailor.tailorName),
                            builder: (_, st) {
                              return Text(
                                getTranslatedText(
                                    st.data ?? '..', widget.tailor.tailorName),
                                style: kTitleStyle.copyWith(fontSize: 20),
                              );
                            }),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.008),
                        isEditMode
                            ? buildAvailabilityBtn(size)
                            : Text(
                                widget.tailor.availableToWork
                                    ? getTranslatedText('درزی دستیاب ہے',
                                        'Available') //'${isEditMode ? "" : "Tailor "}Available'
                                    : getTranslatedText('درزی دستیاب نہیں',
                                        'Not available'), //'${isEditMode ? "Not" : ""} Available',
                                style: kBoldTextStyle().copyWith(
                                    color: widget.tailor.availableToWork
                                        ? Colors.green
                                        : Colors.red,
                                    locale: context.locale),
                              ),
                      ],
                    ),
                    Divider(
                      thickness: 0.2,
                      indent: 20,
                      endIndent: 20,
                      color: kOrangeColor,
                    ),
                    buildQualityItemsRow(),
                    Divider(
                      thickness: 0.2,
                      indent: 20,
                      endIndent: 20,
                      color: kOrangeColor,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    buildTailorInfoCard(),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    buildShopInfoCard(),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    buildContactInfoCard(),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    buildReviewsCard(),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  ],
                ),
              ),
              if (!isEditMode)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18.0, vertical: 10),
                  child: RectangularRoundedButton(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    buttonName: 'Continue',
                    onPressed: !widget.tailor.availableToWork
                        ? null
                        : () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        DressSewingChoiceScreen(
                                            chosenTailor: widget.tailor)));
                          },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Align buildTopRow() {
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: isEditMode
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    navigateToScreen(const TailorEditProfile()).then(
                      (val) => loadCurrentTailor(() {
                        if (mounted) setState(() {});
                      }),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(FontAwesomeIcons.userPen, size: 16),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          getTranslatedText("ایڈٹ", "Edit"),
                          style: kBoldTextStyle()
                              .copyWith(decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    FontAwesomeIcons.arrowRightFromBracket,
                    color: kOrangeColor,
                  ),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    currentTailor = null;
                    currentCustomer = null;
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setBool(Login.isLoggedInText, false);
                    Navigator.pushReplacementNamed(context, Login.id);
                  },
                )
              ],
            )
          : IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                isUrduActivated
                    ? FontAwesomeIcons.arrowRight
                    : FontAwesomeIcons.arrowLeft,
                color: Theme.of(context).primaryColor,
              )),
    );
  }

  Row buildQualityItemsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: MyPieChart(
            title: 'On-time delivery',
            chartValue: widget.tailor.onTimeDelivery.toDouble(),
          ),
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.1),
        Flexible(
          child: Padding(
            padding: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.07),
            child: MyPieChart(
              title: 'Rating',
              chartValue: widget.tailor.rating,
              isRatingChart: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildTailorInfoCard() {
    return Card(
      elevation: 1.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${isEditMode ? getTranslatedText("میری", "My") : getTranslatedText("درزی کی", "Tailor")} ${getTranslatedText("معلومات", "Info.")}',
                  style: kInputStyle.copyWith(color: Colors.grey),
                ),
                if (isEditMode)
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      size: 18,
                      color: kOrangeColor,
                    ),
                    onPressed: () {
                      navigateToScreen(const EditMyInfoCardItems())
                          .then((value) => loadCurrentTailor(() {
                                if (mounted) setState(() {});
                              }));
                    },
                  )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildHorizontalCardItem(
                    'experience: ',
                    getTranslatedText(
                        "تقریباً ${widget.tailor.experience} سال ",
                        '${widget.tailor.experience} years approximately.'),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  buildHorizontalCardItem(
                    'stitching type: ',
                    widget.tailor.stitchingType == StitchingType.both
                        ? getTranslatedText(
                            "مردانہ، زنانہ۔", capitalizeText("Gents, Ladies."))
                        : widget.tailor.stitchingType.name == "Gents"
                            ? getTranslatedText(
                                "مردانہ۔", capitalizeText("Gents."))
                            : getTranslatedText(
                                "زنانہ۔", capitalizeText("Ladies.")),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.tailor.stitchingType == StitchingType.both
                          ? Column(
                              children: [
                                buildExpertiseList("Gents", true),
                                buildExpertiseList("Ladies", false),
                              ],
                            )
                          : buildExpertiseList(
                              widget.tailor.stitchingType.name,
                              widget.tailor.stitchingType ==
                                  StitchingType.gents),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  if (widget.tailor.customizes)
                    buildHorizontalCardItem(
                        'extra: ',
                        capitalizeText(!isEditMode
                            ? getTranslatedText(
                                "یہ درزی لباس کی تخصیص بھی پیش کرتا ہے۔",
                                "This tailor also offer dress customization.")
                            : getTranslatedText(
                                ".میں لباس کی تخصیص بھی پیش کرتا ہوں",
                                "I also offer dress customization."))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildShopInfoCard() {
    return Card(
      elevation: 1.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shop Info.',
              style: kInputStyle.copyWith(color: Colors.grey),
            ).tr(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildHorizontalCardItem(
                    'name: ',
                    widget.tailor.shop!.name,
                    translateSecondText: true,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  buildHorizontalCardItem(
                    'address: ',
                    widget.tailor.shop!.address,
                    // translateSecondText: true,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  buildHorizontalCardItem(
                    'city: ',
                    '${widget.tailor.shop!.city}.',
                    translateSecondText: true,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  buildHorizontalCardItem(
                    'postal code: ',
                    '${widget.tailor.shop!.postalCode}.',
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  buildHorizontalCardItem(
                    'via agent option charges: ',
                    getTranslatedText(
                        "${widget.tailor.shop!.viaAgentCharges} روپے",
                        'Rs. ${widget.tailor.shop!.viaAgentCharges}'),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "shop images:",
                        style: kInputStyle,
                      ).tr(),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildShopImageItem(
                              widget.tailor.shop!.shopImage1Url!),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.03),
                          buildShopImageItem(widget.tailor.shop!.shopImage2Url!)
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildContactInfoCard() {
    return Card(
      elevation: 1.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Info.',
              style: kInputStyle.copyWith(color: Colors.grey),
            ).tr(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildHorizontalCardItem(
                    'phone: ',
                    zeroedPhoneNumber(widget.tailor.phoneNumber),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  buildHorizontalCardItem(
                    'email: ',
                    widget.tailor.email,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildShopImageItem(String url) {
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
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
                      heroTag: url,
                      mini: true,
                      key: Key(url),
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

  ExpansionTile buildExpertiseList(String listTitle, bool isForMen) {
    final catgOverallMap =
        categorizeExpertise(widget.tailor.expertise, isForMen);
    // print(catgOverallMap);
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      initiallyExpanded: true,
      title: Text(
        capitalizeText(listTitle),
        style: kBoldTextStyle(size: 15),
      ).tr(),
      children: catgOverallMap.keys.map((key) {
        return ListTile(
          title: Text(
            key,
            style: kBoldTextStyle().copyWith(
              fontSize: 13,
              color: kOrangeColor,
            ),
          ).tr(),
          subtitle: Wrap(
            spacing: 5,
            children: [
              ...List.generate(
                catgOverallMap[key]!.length,
                (index) {
                  final initialRate = widget.tailor.rates.firstWhere(
                      (element) =>
                          element.category.toLowerCase() ==
                          catgOverallMap[key]![index].toLowerCase());
                  final rate = RateItem(
                    category: initialRate.category,
                    price: initialRate.price,
                    dressImage: initialRate.dressImage,
                    customizationPrice: initialRate.customizationPrice,
                  );
                  return InputChip(
                    label: Text(
                            initialRate.category.contains('l-')
                                ? initialRate.category.substring(2)
                                : initialRate.category,
                            style: kTextStyle.copyWith(fontSize: 12))
                        .tr(),
                    onSelected: (val) async {
                      await showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            //main dialog shown when a chip is tapped
                            return StatefulBuilder(
                                builder: (context, setState) {
                              return LoadingOverlay(
                                isLoading: isUpdatingDress,
                                child: Card(
                                  margin: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.05,
                                    vertical:
                                        MediaQuery.of(context).size.height *
                                            0.12,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.05,
                                            child: Align(
                                              alignment: Alignment.topRight,
                                              child: IconButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  icon:
                                                      const Icon(Icons.close)),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              final decoration = BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                image: DecorationImage(
                                                  image: (rate.dressImage
                                                              .contains('/data/')
                                                          ? FileImage(File(rate
                                                              .dressImage))
                                                          : rate.dressImage
                                                                  .contains(
                                                                      'assets')
                                                              ? AssetImage(rate
                                                                  .dressImage)
                                                              : NetworkImage(rate
                                                                  .dressImage))
                                                      as ImageProvider,
                                                  fit: BoxFit.fill,
                                                ),
                                              );
                                              //showing dress of image in full sreen mode
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    StatefulBuilder(builder:
                                                        (context, setState) {
                                                  return Card(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                      vertical:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.15,
                                                      horizontal:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.04,
                                                    ),
                                                    child: Stack(
                                                      children: [
                                                        Container(
                                                          decoration:
                                                              decoration,
                                                        ),
                                                        Positioned(
                                                          right: 0,
                                                          child: SizedBox(
                                                            child:
                                                                FloatingActionButton(
                                                              mini: true,
                                                              heroTag:
                                                                  rate.category,
                                                              key: Key(rate
                                                                  .category),
                                                              isExtended: false,
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: const Icon(
                                                                  Icons.close),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                              );
                                            },
                                            child: CircleAvatar(
                                              radius: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.25,
                                              backgroundColor: kOrangeColor,
                                              child: Center(
                                                child: CircleAvatar(
                                                    radius: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.25 -
                                                        1,
                                                    backgroundColor: Colors
                                                        .white,
                                                    backgroundImage: (rate
                                                                .dressImage
                                                                .contains('/data/')
                                                            ? FileImage(File(rate
                                                                .dressImage))
                                                            : rate.dressImage
                                                                    .contains(
                                                                        'assets')
                                                                ? AssetImage(rate
                                                                    .dressImage)
                                                                : NetworkImage(rate
                                                                    .dressImage))
                                                        as ImageProvider),
                                              ),
                                            ),
                                          ),
                                          if (isEditMode)
                                            buildChangeDressImageButton(
                                                MediaQuery.of(context).size,
                                                rate,
                                                setState),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.01),
                                          Text(
                                            getCategory(rate.category),
                                            style: kTitleStyle.copyWith(
                                              fontSize: 25,
                                            ),
                                          ).tr(),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.01),
                                          //edit price of dress item
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                getTranslatedText(
                                                    "قیمت:  ${rate.price} روپے۔",
                                                    "price: Rs. ${rate.price}"),
                                                textAlign: TextAlign.center,
                                                style: kInputStyle.copyWith(
                                                    fontSize: 16),
                                              ),
                                              if (isEditMode)
                                                IconButton(
                                                  style: IconButton.styleFrom(
                                                      padding: EdgeInsets.zero),
                                                  onPressed: () async {
                                                    showModalBottomSheet(
                                                      context: context,
                                                      shape:
                                                          const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  25.0),
                                                          topRight:
                                                              Radius.circular(
                                                                  25.0),
                                                        ),
                                                      ),
                                                      builder: (context) {
                                                        final priceController =
                                                            TextEditingController(
                                                                text: rate.price
                                                                    .toString());
                                                        priceController
                                                            .addListener(() {
                                                          if (mounted) {
                                                            setState(() {});
                                                          }
                                                        });
                                                        return SizedBox(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.37,
                                                          child: Card(
                                                            shape:
                                                                const RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                              topLeft: Radius
                                                                  .circular(25),
                                                              topRight: Radius
                                                                  .circular(25),
                                                            )),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                    getTranslatedText(
                                                                        "قیمت ایڈٹ کریں",
                                                                        'Edit Price'),
                                                                    style: kInputStyle.copyWith(
                                                                        fontSize:
                                                                            25),
                                                                  ),
                                                                  SizedBox(
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          0.002),
                                                                  Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Text(
                                                                        getTranslatedText(
                                                                            "", // " کے لئے",
                                                                            'for '),
                                                                        style: kInputStyle.copyWith(
                                                                            fontSize:
                                                                                16),
                                                                      ),
                                                                      Text(
                                                                        getCategory(
                                                                            rate.category),
                                                                        style: kInputStyle.copyWith(
                                                                            fontSize:
                                                                                16),
                                                                      ).tr(),
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          0.03),
                                                                  TextField(
                                                                    controller:
                                                                        priceController,
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .number,
                                                                    decoration:
                                                                        kTextFieldDecoration,
                                                                  ),
                                                                  SizedBox(
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          0.01),
                                                                  Center(
                                                                      child: ElevatedButton(
                                                                          onPressed: () async {
                                                                            final val =
                                                                                double.parse(priceController.text.trim()).toInt();
                                                                            if (val !=
                                                                                rate.price) {
                                                                              rate.price = val;
                                                                              if (context.mounted) {
                                                                                setState(() {});
                                                                              }
                                                                            }
                                                                            Navigator.pop(context);
                                                                          },
                                                                          child: Text(
                                                                            getTranslatedText('قیمت مقرر کریں',
                                                                                'Set price'),
                                                                            style:
                                                                                kTextStyle.copyWith(color: Colors.white),
                                                                          )))
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        setState(() {}));
                                                  },
                                                  icon: Icon(Icons.edit,
                                                      color: kOrangeColor,
                                                      size: 18),
                                                )
                                            ],
                                          ),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.01),
                                          ElevatedButton.icon(
                                            onPressed: isUpdatingDress
                                                ? null
                                                : () async {
                                                    print(
                                                        "${rate.price} ${initialRate.price}");
                                                    //only tailor himself can edit fields of dress(image,rate)
                                                    if (isEditMode) {
                                                      //if rate changed
                                                      final modified = rate
                                                                  .price !=
                                                              initialRate
                                                                  .price ||
                                                          rate.dressImage !=
                                                              initialRate
                                                                  .dressImage;
                                                      if (rate.price !=
                                                          initialRate.price) {
                                                        initialRate.price =
                                                            rate.price;
                                                      }
                                                      //if dress image changed
                                                      if (rate.dressImage !=
                                                          initialRate
                                                              .dressImage) {
                                                        final url =
                                                            await uploadImageToFirestore(
                                                                rate.dressImage,
                                                                rate.category,
                                                                setState);
                                                        rate.dressImage = url;
                                                        initialRate.dressImage =
                                                            url;
                                                      }
                                                      if (modified) {
                                                        await FireStoreHelper()
                                                            .updateTailor(
                                                                currentTailor!)
                                                            .then((value) =>
                                                                Fluttertoast
                                                                    .showToast(
                                                                  msg: getTranslatedText(
                                                                      'لباس اپ ڈیٹ کیا گیا ہے۔',
                                                                      'dress item updated.'),
                                                                  textColor:
                                                                      Colors
                                                                          .white,
                                                                  backgroundColor:
                                                                      kOrangeColor,
                                                                ));
                                                        setState(() {
                                                          isUpdatingDress =
                                                              false;
                                                        });
                                                      }
                                                    }
                                                    Navigator.pop(context);
                                                  },
                                            icon: const Icon(Icons.check),
                                            label: Text(
                                              isEditMode ? 'Done' : 'Ok',
                                              style: kTextStyle.copyWith(
                                                  color: Colors.white),
                                            ).tr(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            });
                          });
                    },
                    backgroundColor: kLightSkinColor,
                    avatar: CircleAvatar(
                        backgroundColor: kOrangeColor, //Colors.grey.shade200,
                        backgroundImage:
                            (initialRate.dressImage.contains("assets")
                                ? AssetImage(initialRate.dressImage)
                                : NetworkImage(initialRate.dressImage)
                                    as ImageProvider)),
                  );
                },
              )
            ],
          ),
        );
      }).toList(),
    );
  }

  Row buildHorizontalCardItem(String firstItemText, String secondItemText,
      {bool translateSecondText = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            firstItemText,
            style: kInputStyle,
          ).tr(),
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.01),
        Flexible(
          flex: 2,
          child: FutureBuilder(
              future: ApiHelper.translateText(secondItemText),
              builder: (_, st) {
                return Text(
                  translateSecondText
                      ? getTranslatedText(st.data ?? '..', secondItemText)
                      : secondItemText,
                  style: kTextStyle,
                  textAlign: TextAlign.start,
                );
              }),
        ),
      ],
    );
  }

  Widget buildReviewsCard() {
    return Card(
      elevation: 1.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  getTranslatedText("جائزے(${widget.tailor.reviews.length})",
                      'Reviews(${widget.tailor.reviews.length})'),
                  style: kInputStyle.copyWith(color: Colors.grey),
                ),
                if (widget.tailor.reviews.length > 2)
                  TextButton(
                    onPressed: () {
                      navigateToScreen(
                          ViewAllReviews(reviews: widget.tailor.reviews));
                    },
                    child: Text(
                      getTranslatedText('سب دیکھیں', 'View all'),
                      style: reminderButtonStyle,
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(
                  widget.tailor.reviews.length > 2
                      ? 2
                      : widget.tailor.reviews.length,
                  (index) => Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 26,
                          backgroundColor: kOrangeColor,
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(widget
                                .tailor.reviews[index].customerProfileUrl),
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
                                    future: ApiHelper.translateText(widget
                                        .tailor.reviews[index].customerName),
                                    builder: (_, st) {
                                      return Text(
                                        getTranslatedText(
                                            st.data ?? '..',
                                            widget.tailor.reviews[index]
                                                .customerName),
                                        style: kInputStyle,
                                      );
                                    }),
                                FittedBox(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        getTranslatedText("لباس: ", 'dress: '),
                                        style:
                                            kInputStyle.copyWith(fontSize: 12),
                                      ),
                                      Text(
                                        getCategory(widget
                                            .tailor.reviews[index].category),
                                        style:
                                            kInputStyle.copyWith(fontSize: 12),
                                      ).tr(),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.005),
                              ],
                            ),
                            Column(
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.22,
                                  child: FittedBox(
                                    child: RatingBarIndicator(
                                      unratedColor: Colors.grey.shade400,
                                      rating:
                                          widget.tailor.reviews[index].rating,
                                      itemBuilder: (context, index) =>
                                          const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      itemCount: 5,
                                      itemSize: 15.0,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${widget.tailor.reviews[index].rating}',
                                  style: kTextStyle.copyWith(fontSize: 12),
                                  textAlign: TextAlign.center,
                                )
                              ],
                            )
                          ],
                        ),
                        subtitle: FutureBuilder(
                            future: ApiHelper.translateText(
                                widget.tailor.reviews[index].reviewText),
                            builder: (_, st) {
                              return widget.tailor.reviews[index].reviewText
                                          .length >=
                                      180
                                  ? ExpandableText(getTranslatedText(
                                      st.data ?? '..',
                                      widget.tailor.reviews[index].reviewText))
                                  : Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Text(
                                        getTranslatedText(
                                            st.data ?? '..',
                                            widget.tailor.reviews[index]
                                                .reviewText),
                                        style:
                                            kTextStyle.copyWith(fontSize: 12),
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
                            widget
                                .tailor.reviews[index].reviewsImageUrls.length,
                            (index2) => buildShopImageItem(widget.tailor
                                .reviews[index].reviewsImageUrls[index2]),
                          ),
                        ),
                      ),
                      Divider(thickness: 0.2, color: kOrangeColor),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future navigateToScreen(Widget screen) async {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => screen,
      ),
    ).then((value) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future changeAvailabilityStatus(size) async {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      builder: (context) {
        bool value = widget.tailor.availableToWork;
        return StatefulBuilder(builder: (context, setState) {
          return SizedBox(
            height: size.height * 0.35,
            child: Card(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              )),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      getTranslatedText("دستیابی سیٹ کریں", 'Set Availability'),
                      style: kInputStyle.copyWith(fontSize: 25),
                    ),
                    SizedBox(height: size.height * 0.03),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DropdownButton<bool>(
                        value: value,
                        onChanged: (newValue) {
                          setState(() {
                            value = newValue!;
                          });
                        },
                        iconEnabledColor: kOrangeColor,
                        items: [
                          getTranslatedText('دستیاب ہے', 'Available'),
                          getTranslatedText('دستیاب نہیں ہے', 'Not available')
                        ].map<DropdownMenuItem<bool>>((value) {
                          return DropdownMenuItem<bool>(
                              value:
                                  value == 'Available' || value == 'دستیاب ہے'
                                      ? true
                                      : false,
                              child: Text(
                                value,
                                style: TextStyle(
                                  color: value == 'Available' ||
                                          value == 'دستیاب ہے'
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                ),
                              ));
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: size.height * 0.01),
                    Center(
                        child: ElevatedButton.icon(
                            onPressed: () async {
                              if (value == widget.tailor.availableToWork) {
                                Navigator.pop(context);
                                return;
                              }
                              currentTailor!.availableToWork = value;
                              Navigator.pop(context);
                              await FireStoreHelper()
                                  .updateTailor(currentTailor!)
                                  .then((value) {
                                if (value) {
                                  Fluttertoast.showToast(
                                      textColor: Colors.white,
                                      backgroundColor: kOrangeColor,
                                      msg: getTranslatedText(
                                          "دستیابی کی صورتحال کو اپ ڈیٹ کیا گیا",
                                          "Availability status updated"));
                                  widget.tailor.availableToWork = value;
                                }
                              });
                              if (context.mounted) setState(() {});
                            },
                            icon: const Icon(Icons.check),
                            label: Text(
                              getTranslatedText("ٹھيک ہے", 'OK'),
                              style: kTextStyle.copyWith(
                                  color: Colors.white, fontSize: 18),
                            )))
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Widget buildAvailabilityBtn(Size size) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.032,
      child: TextButton(
        style: TextButton.styleFrom(padding: EdgeInsets.zero),
        onPressed: () async {
          changeAvailabilityStatus(size).then((value) {
            if (mounted) setState(() {});
          });
        },
        child: Text(
          widget.tailor.availableToWork
              ? getTranslatedText('دستیاب ہے', 'Available')
              : getTranslatedText('دستیاب نہیں ہے', 'Not available'),
          style: kBoldTextStyle().copyWith(
            decoration: TextDecoration.underline,
            color: widget.tailor.availableToWork
                ? Colors.green.shade700
                : Colors.red.shade700,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Container buildChangeDressImageButton(
      Size size, RateItem rate, StateSetter setState) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: size.width * 0.25, vertical: size.height * 0.005),
      child: SizedBox(
        height: size.height * 0.04,
        child: RectangularRoundedButton(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          fontSize: 15,
          color: kOrangeColor,
          buttonName: "Change",
          onPressed: () async {
            final file =
                await ImagePicker().pickImage(source: ImageSource.gallery);
            if (file != null) {
              rate.dressImage = file.path;
              print("picked image");
            }
            setState(() {});
          },
        ),
      ),
    );
  }

  Future<String> uploadImageToFirestore(
      String localPath, String firebaseName, StateSetter setState) async {
    bool successful = false;
    setState(() {
      isUpdatingDress = true;
    });
    Future.delayed(const Duration(seconds: 10)).then((val) {
      if (!successful && isUpdatingDress) {
        setState(() {
          isUpdatingDress = false;
        });
        showMyBanner(context, getTranslatedText("ٹائم آؤٹ", "Timed out"));
        return;
      }
    });
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('${currentTailor!.email}/$firebaseName.png');
    final uploadTask = await storageRef.putFile(File(localPath));
    print('$firebaseName uploaded.');
    final downloadUrl = await uploadTask.ref.getDownloadURL();

    return downloadUrl;
  }
}
