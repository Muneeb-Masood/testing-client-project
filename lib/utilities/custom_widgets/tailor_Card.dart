import 'dart:io';

import 'package:test/main.dart';
import 'package:test/models/tailor.dart';
import 'package:test/screens/tailor/tailor_main_screen.dart';
import 'package:test/screens/tailor/tailor_profile.dart';
import 'package:test/utilities/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../networking/api_helper.dart';

class TailorCard extends StatelessWidget {
  const TailorCard({Key? key, required this.tailor}) : super(key: key);
  final Tailor tailor;
  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: kInputStyle.copyWith(locale: context.locale, fontSize: 20),
      child: Card(
        color: kSkinColor,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: kOrangeColor, width: 0.2),
        ),
        elevation: 3.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.green,
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(tailor.profileImageUrl!),
                    backgroundColor: kLightSkinColor,
                    radius: 25,
                  ),
                ),
                title: FutureBuilder(
                    future: ApiHelper.translateText(tailor.shop!.name),
                    builder: (_, st) {
                      return Text(
                        getTranslatedText(st.data ?? '..', tailor.shop!.name),
                        // tailor.tailorName,
                        style: kInputStyle,
                      );
                    }),
                subtitle: FutureBuilder(
                    future: ApiHelper.translateText(
                        "${tailor.tailorName}(${tailor.shop!.city})"),
                    builder: (_, st) {
                      return Text(
                        getTranslatedText(st.data ?? '..',
                            "${tailor.tailorName}(${tailor.shop!.city})"),
                        style: kTextStyle.copyWith(fontSize: 12),
                        textAlign: TextAlign.start,
                      );
                    }),
                trailing: IconButton(
                  style: IconButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: () {
                    print("Tailor card tapped");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TailorProfile(
                          tailor: tailor,
                        ),
                      ),
                    );
                  },
                  icon: currentTailor?.email == tailor.email
                      ? const Text('')
                      : Icon(
                          isUrduActivated
                              ? FontAwesomeIcons.arrowLeft
                              : FontAwesomeIcons.arrowRight,
                          size: 20,
                          color: Theme.of(context).primaryColor),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(isUrduActivated ? 0 : 15.0, 10,
                    isUrduActivated ? 15.0 : 0, 0),
                child: Row(
                  children: [
                    Text(
                      "stitching type: ",
                      style: kInputStyle.copyWith(
                          fontSize: 14, color: Colors.grey.shade700),
                    ).tr(),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                    Text(
                      tailor.stitchingType == StitchingType.both
                          ? getTranslatedText("مردانہ، زنانہ۔",
                              capitalizeText("Gents, Ladies."))
                          : tailor.stitchingType.name == "Gents"
                              ? getTranslatedText(
                                  "مردانہ۔", capitalizeText("Gents."))
                              : getTranslatedText(
                                  "زنانہ۔", capitalizeText("Ladies.")),
                      style: kTextStyle.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),
              // Padding(
              //   padding: EdgeInsets.fromLTRB(15.0, 5, 0, 0),
              //   child: Text(
              //     'Expertise:',
              //     style: kInputStyle.copyWith(fontSize: 15),
              //   ),
              // ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.01),
              tailor.stitchingType == StitchingType.both
                  ? Column(
                      children: [
                        buildExpertiseList(context, "Gents", true),
                        buildExpertiseList(context, "Ladies", false),
                      ],
                    )
                  : buildExpertiseList(context, tailor.stitchingType.name,
                      tailor.stitchingType == StitchingType.gents),
            ],
          ),
        ),
      ),
    );
  }

  ExpansionTile buildExpertiseList(context, String listTitle, bool isForMen) {
    return ExpansionTile(
      title: Text(
        capitalizeText(listTitle),
        style: kBoldTextStyle(size: 15),
      ).tr(),
      children: categorizeExpertise(tailor.expertise, isForMen).keys.map((key) {
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
                categorizeExpertise(tailor.expertise, isForMen)[key]!.length,
                (index) {
                  final rate = tailor.rates.firstWhere((element) =>
                      element.category.toLowerCase() ==
                      categorizeExpertise(
                              tailor.expertise, isForMen)[key]![index]
                          .toLowerCase());

                  return InputChip(
                    surfaceTintColor: kOrangeColor,
                    label: Text(
                            rate.category.contains('l-')
                                ? rate.category.substring(2)
                                : rate.category,
                            style: kTextStyle.copyWith(fontSize: 12))
                        .tr(),
                    onSelected: (val) async {
                      await showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            return StatefulBuilder(
                                builder: (context, setState) {
                              return Card(
                                margin: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.05,
                                  vertical:
                                      MediaQuery.of(context).size.height * 0.18,
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
                                            alignment: isUrduActivated
                                                ? Alignment.topLeft
                                                : Alignment.topRight,
                                            child: IconButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                icon: Icon(
                                                  Icons.close,
                                                  color: kOrangeColor,
                                                )),
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
                                                        ? FileImage(File(
                                                            rate.dressImage))
                                                        : rate.dressImage
                                                                .contains('assets')
                                                            ? AssetImage(
                                                                rate.dressImage)
                                                            : NetworkImage(rate
                                                                .dressImage))
                                                    as ImageProvider,
                                                fit: BoxFit.fill,
                                              ),
                                            );
                                            showDialog(
                                              context: context,
                                              builder: (context) => Card(
                                                margin: EdgeInsets.symmetric(
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
                                                      decoration: decoration,
                                                    ),
                                                    Positioned(
                                                      right: 0,
                                                      child: SizedBox(
                                                        child:
                                                            FloatingActionButton(
                                                          mini: true,
                                                          heroTag:
                                                              rate.category,
                                                          key: Key(
                                                              rate.category),
                                                          isExtended: false,
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          backgroundColor:
                                                              kSkinColor,
                                                          child: Icon(
                                                            Icons.close,
                                                            color: kOrangeColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                          child: CircleAvatar(
                                            radius: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.25,
                                            backgroundColor: Colors.blue,
                                            child: Center(
                                                child: CircleAvatar(
                                                    radius: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width *
                                                        0.25,
                                                    backgroundColor: Colors
                                                        .white,
                                                    // isUploadingProfileImage ? Colors.white54 :
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
                                                        as ImageProvider)),
                                          ),
                                        ),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.01),
                                        //also we can do ladiesCtaegories['Cultural...
                                        Text(getCategory(rate.category),
                                            style: kTitleStyle.copyWith(
                                              fontSize: 25,
                                            )).tr(),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.01),
                                        Text(
                                          getTranslatedText(
                                              "قیمت:  ${rate.price} روپے۔",
                                              "price: Rs. ${rate.price}"),
                                          textAlign: TextAlign.center,
                                          style: kInputStyle.copyWith(
                                              fontSize: 16),
                                        ),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.03),
                                        ElevatedButton.icon(
                                          onPressed: () async {
                                            Navigator.pop(context);
                                          },
                                          icon: const Icon(Icons.check),
                                          label: const Text(
                                            'OK',
                                          ).tr(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            });
                          });
                    },
                    backgroundColor: kLightSkinColor,
                    avatar: CircleAvatar(
                      backgroundColor: kOrangeColor,
                      backgroundImage: (rate.dressImage.contains("assets")
                          ? AssetImage(rate.dressImage)
                          : NetworkImage(rate.dressImage) as ImageProvider),
                    ),
                  );
                },
              )
            ],
          ),
        );
      }).toList(),
    );
  }
}

///returns the skills of tailor formatted in format
///formal: [Dress Shirts]
///Casual: [Shalwar Kameez]
Map<String, List<String>> categorizeExpertise(
    List<String> expertise, bool isForMen) {
  Map<String, List<String>> finalMap = {};
  switch (isForMen) {
    case true:
      for (String element in expertise) {
        for (String key in getMenCatg().keys) {
          if (getMenCatg()[key]!.contains(element)) {
            if (!finalMap.containsKey(key)) {
              finalMap[key] = [];
            }
            finalMap[key]!.add(element);
            break;
          }
        }
      }
      break;
    case false:
      for (String element in expertise) {
        for (String key in getLadiesCatg().keys) {
          if (getLadiesCatg()[key]!.contains(element)) {
            if (!finalMap.containsKey(key)) {
              finalMap[key] = [];
            }
            finalMap[key]!.add(element);
            break;
          }
        }
      }
      break;
  }
  return finalMap;
}
