import 'package:test/main.dart';
import 'package:test/networking/firestore_helper.dart';
import 'package:test/screens/tailor/tailor_main_screen.dart';
import 'package:test/utilities/constants.dart';
import 'package:test/utilities/custom_widgets/rectangular_button.dart';
import 'package:test/utilities/my_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_overlay/loading_overlay.dart';

import '../../models/tailor.dart';
import '../../utilities/custom_widgets/expandable_list_tile.dart';
import '../../utilities/custom_widgets/item_rate_input_tile.dart';
import '../../utilities/custom_widgets/tailor_Card.dart';

class EditMyInfoCardItems extends StatefulWidget {
  const EditMyInfoCardItems({Key? key}) : super(key: key);

  @override
  State<EditMyInfoCardItems> createState() => _EditMyInfoCardItemsState();
}

class _EditMyInfoCardItemsState extends State<EditMyInfoCardItems> {
  final formKey = GlobalKey<FormState>();
  final experienceController =
      TextEditingController(text: currentTailor!.experience.toString());
  bool isUpdatingData = false;
  List<String> selectedExpertise = List.from(currentTailor!.expertise);
  List<RateItem> expertiseRatesList = List.from(currentTailor!.rates);
  Map<String, List<String>> unSelectedExpertise = {};
  List<TextEditingController> ratesFieldsController = [];
  List<TextEditingController> customizationRatesFieldsController = [];
  int selectedUnselectedExpertiseCategoryIndex = -1;

  StitchingType? stitchingType = currentTailor!.stitchingType;

  bool customizesDresses = currentTailor!.customizes;

  @override
  void initState() {
    super.initState();
    experienceController.addListener(() {
      if (mounted) setState(() {});
    });
    initializeRatesTextController();
    unSelectedExpertise = stitchingType == StitchingType.gents
        ? {...getMenCatg()}
        : stitchingType == StitchingType.ladies
            ? {...getLadiesCatg()}
            : {
                "Gents": ["yes"],
                "Ladies": ["Yes"]
              };
  }

  initializeRatesTextController() {
    ratesFieldsController.clear();
    customizationRatesFieldsController.clear();
    for (var value in expertiseRatesList) {
      final controller = TextEditingController(text: value.price.toString());

      ratesFieldsController.add(controller);
      final controller2 =
          TextEditingController(text: value.customizationPrice?.toString());

      customizationRatesFieldsController.add(controller2);
    }
  }

  @override
  void dispose() {
    super.dispose();
    experienceController.dispose();
    for (var element in ratesFieldsController) {
      element.dispose();
    }
    for (var element in customizationRatesFieldsController) {
      element.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isUpdatingData,
      progressIndicator: kSpinner(context),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: SafeArea(
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                            isUrduActivated
                                ? FontAwesomeIcons.arrowRight
                                : FontAwesomeIcons.arrowLeft,
                            color: kOrangeColor),
                      ),
                      if (!isSameData())
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.042,
                            child: RectangularRoundedButton(
                              buttonName: 'Reset',
                              fontSize: 15,
                              onPressed: () {
                                experienceController.text =
                                    currentTailor!.experience.toString();
                                selectedExpertise =
                                    List.from(currentTailor!.expertise);
                                expertiseRatesList =
                                    List.from(currentTailor!.rates);
                                initializeRatesTextController();
                                selectedUnselectedExpertiseCategoryIndex = -1;
                                stitchingType = currentTailor!.stitchingType;
                                unSelectedExpertise =
                                    stitchingType == StitchingType.gents
                                        ? {...getMenCatg()}
                                        : stitchingType == StitchingType.ladies
                                            ? {...getLadiesCatg()}
                                            : {
                                                "Gents": ["yes"],
                                                "Ladies": ["Yes"]
                                              };
                                if (mounted) {
                                  setState(() {});
                                }
                              },
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                            ),
                          ),
                        ),
                    ],
                  ),
                  buildMyInfoColumn(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMyInfoColumn(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: size.width * 0.01),
          buildTextFormField(
              isUrduActivated ? 'نام' : 'experience',
              experienceController,
              null,
              isUrduActivated ? 'اپنا نام درج کریں' : "Enter your experince",
              keyboard: TextInputType.number),
          SizedBox(height: size.height * 0.015),
          buildStitchingTypeRow(size),
          SizedBox(height: size.height * 0.005),
          buildHorizontalCardItem(
            'you selected: ',
            // stitchingType == StitchingType.both
            //     ? capitalizeText("Gents, Ladies.")
            //     : capitalizeText('${stitchingType!.name}.'),
            stitchingType == StitchingType.both
                ? getTranslatedText("مردانہ، زنانہ۔", "Gents, Ladies.")
                : stitchingType?.name == "Gents"
                    ? getTranslatedText("مردانہ۔", "Gents.")
                    : getTranslatedText("زنانہ۔", "Ladies."),
          ),
          SizedBox(height: size.height * 0.02),
          buildCustomizesDressQuestionTile(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: buildEditExpertiseBtnRow(context),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                stitchingType == StitchingType.both
                    ? Column(
                        children: [
                          buildExpertiseList("Gents", true),
                          buildExpertiseList("Ladies", false),
                        ],
                      )
                    : buildExpertiseList(stitchingType!.name,
                        stitchingType == StitchingType.gents),
                buildExpertiseRatesTextFields(size, setState),
              ],
            ),
          ),
          SizedBox(height: size.height * 0.015),
          buildUpdateButton(),
          SizedBox(height: size.height * 0.025),
        ],
      ),
    );
  }

  Row buildEditExpertiseBtnRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'expertise: ',
          style: kInputStyle.copyWith(
              fontSize: 16,
              color: selectedExpertise.isEmpty ? Colors.red : Colors.black),
        ).tr(),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.038,
          child: RectangularRoundedButton(
            buttonName: selectedExpertise.isEmpty ? 'Add' : 'Edit',
            fontSize: 15,
            onPressed: () {
              if (stitchingType == null) {
                showMyBanner(context, 'Please select a stitching type.');
              } else {
                onAddYourSkillsPressed();
              }
            },
            padding: const EdgeInsets.symmetric(horizontal: 5),
          ),
        ),
      ],
    );
  }

  Widget buildUpdateButton() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.1),
      child: RectangularRoundedButton(
        padding: const EdgeInsets.symmetric(vertical: 2),
        buttonName: 'Update',
        color: /*isSameData() ? Colors.grey : */ kOrangeColor,
        onPressed: /* isSameData() ? () {} :*/ onUpdateButtonPressed,
      ),
    );
  }

  ExpansionTile buildExpertiseList(String listTitle, bool isForMen) {
    final catgOverallMap = categorizeExpertise(selectedExpertise, isForMen);
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      initiallyExpanded: true,
      title: Text(
        capitalizeText(listTitle),
        style: kBoldTextStyle(size: 14),
      ).tr(),
      children: catgOverallMap.keys.map((key) {
        return ListTile(
          title: Text(
            key,
            style: kBoldTextStyle().copyWith(color: kOrangeColor),
          ).tr(),
          subtitle: Wrap(
            spacing: 5,
            children: [
              ...List.generate(
                catgOverallMap[key]!.length,
                (index) {
                  final category = catgOverallMap[key]![index];
                  return InputChip(
                    label: Text(
                            category.contains('l-')
                                ? category.substring(2)
                                : category,
                            style: kTextStyle.copyWith(fontSize: 12))
                        .tr(),
                    onSelected: (val) async {},
                    backgroundColor: kLightSkinColor,
                    avatar: CircleAvatar(
                      backgroundColor: Colors.grey,
                      backgroundImage:
                          AssetImage(dressImages[category] as String),
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

  bool isSameData() {
    bool isSame = false;
    bool sameAnswerForCustomization =
        customizesDresses == currentTailor!.customizes;
    final sameExperience = experienceController.text.trim().toLowerCase() ==
        currentTailor!.experience.toString().toLowerCase();
    final sameStitchesFor = stitchingType == currentTailor!.stitchingType;
    final sameExpertise =
        (sameSkills(selectedExpertise, currentTailor!.expertise)); //&&
    // sameRates(expertiseRatesList, currentTailor!.rates));
    // print("same rates: ${sameRates(currentTailor!.rates, expertiseRatesList)}");
    if (sameExperience &&
        sameStitchesFor &&
        sameExpertise &&
        sameRates(currentTailor!.rates, expertiseRatesList) &&
        sameAnswerForCustomization) {
      isSame = true;
    }
    return isSame;
  }

  bool sameSkills(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) {
      return false;
    }

    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) {
        return false;
      }
    }

    return true;
  }

  ExpandableListTile buildGentsLadiesCategoriesCard(
      String key, List<String> value, int index, StateSetter setState) {
    return ExpandableListTile(
      listTitle: key,
      childList: value,
      initiallyExpanded: index == selectedUnselectedExpertiseCategoryIndex,
      onChildListItemPressed: (String itemValue) {
        if (!selectedExpertise.contains(itemValue)) {
          selectedExpertise.add(itemValue);
          ratesFieldsController.add(TextEditingController(text: "0"));
          customizationRatesFieldsController
              .add(TextEditingController(text: "0"));
          expertiseRatesList.add(
            RateItem(
              category: itemValue,
              price: 0,
              dressImage: dressImages[itemValue] as String,
              customizationPrice: currentTailor!.customizes ? 0 : null,
            ),
          );
        } else {
          Fluttertoast.showToast(
              msg: getTranslatedText("پہلے ہی شامل کیا گیا ہے $itemValue.",
                  "$itemValue is already added."),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              textColor: Colors.white,
              backgroundColor: kOrangeColor,
              fontSize: 16.0);
        }
        if (mounted) setState(() {});
      },
    );
  }

  onUpdateButtonPressed() async {
    bool taskSuccessful = false;
    if (isSameData()) {
      showMyBanner(context, 'Nothing updated.');
      return;
    }
    if (formKey.currentState!.validate()) {
      if (selectedExpertise.isEmpty) {
        showMyDialog(context, 'Error!', 'Add your expertise.');
        return;
      }
      try {
        currentTailor!.experience = int.parse(experienceController.text.trim());
      } catch (e) {
        showMyDialog(context, 'Error!', e.toString());
        return;
      }
      // for (var element in expertiseRatesList) {
      //   if (element.price == 0)
      //     showMyDialog(context, 'Error!', "Add rate for '${element.category}'");
      //   return;
      // }
      if (mounted) {
        setState(() {
          isUpdatingData = true;
        });
      }
      currentTailor!.stitchingType = stitchingType!;
      currentTailor!.expertise = selectedExpertise;
      currentTailor!.rates = expertiseRatesList;
      currentTailor!.customizes = customizesDresses;

      //62 seconds as timeout
      Future.delayed(const Duration(seconds: 5)).then((value) {
        if (mounted && isUpdatingData) {
          setState(() => isUpdatingData = false);
          if (!taskSuccessful) showMyBanner(context, 'Timed out.');
        }
      });
      // print('customer: $currentCustomer');
      try {
        //inserting tailor data
        await FireStoreHelper().updateTailor(currentTailor!).then((val) async {
          //updating tailor id field
          if (mounted) {
            setState(() {
              taskSuccessful = val;
              isUpdatingData = false;
            });
          }
          print("tailor's user Data updated");
          Fluttertoast.showToast(
            msg: 'Profile updated',
            textColor: Colors.black,
            backgroundColor: kSkinColor,
          );
          Navigator.pop(context);
        });
      } catch (e) {
        print('Exception while updating customer data: $e');
      }
    } else {
      // showMyDialog(context, 'Error!', 'Validation failed.');
    }
  }

  CheckboxListTile buildCustomizesDressQuestionTile() {
    return CheckboxListTile(
      activeColor: kOrangeColor,
      contentPadding: const EdgeInsets.only(left: 10),
      title: Text(
        'Do you customize dresses?',
        style: kInputStyle.copyWith(fontSize: 18),
      ).tr(),
      subtitle: RichText(
        text: TextSpan(
          text: getTranslatedText('آپ نے جواب دیا: ', "You answered: "),
          style: kTextStyle,
          children: [
            TextSpan(
              text: customizesDresses
                  ? getTranslatedText('ہاں', 'Yes')
                  : getTranslatedText('نہيں', 'No'),
              style: kTextStyle.copyWith(
                  color: Colors.green, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
      value: customizesDresses,
      onChanged: (val) {
        customizesDresses = val ?? false;
        int i = 0;
        if (customizesDresses) {
          for (var e in expertiseRatesList) {
            e.customizationPrice ??= 0;
            if (customizationRatesFieldsController
                .elementAt(i)
                .text
                .trim()
                .isEmpty) {
              customizationRatesFieldsController.elementAt(i).text = "0";
            }
            i++;
          }
          // i = 0;
        } else {
          for (var e in expertiseRatesList) {
            e.customizationPrice = null;
            // customizationRatesFieldsController.elementAt(i).clear();
            // i++;
          }
          // i = 0;
        }
        setState(() {});
      },
    );
  }

  Widget buildTextFormField(String hint, TextEditingController controller,
      IconData? icon, String? errorText,
      {TextInputType? keyboard}) {
    return Container(
      // ignore: prefer_const_constructors
      margin: EdgeInsets.all(5),
      child: TextFormField(
        style: kInputStyle,
        controller: controller,
        validator: (val) {
          if (errorText == null) return null;
          if (val == null || val.trim().isEmpty) {
            return errorText;
          }
          return null;
        },
        decoration: kTextFieldDecoration.copyWith(
          prefixIcon: icon == null
              ? null
              : IconTheme(
                  data: const IconThemeData(color: Colors.black54),
                  child: Icon(icon, size: 18)),
          // hintText: hint,
          suffixIcon: IconButton(
            icon: const Icon(FontAwesomeIcons.xmark, size: 18),
            onPressed: () {
              controller.clear();
              if (mounted) setState(() {});
            },
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          labelText: hint.substring(
              0, hint.contains(" ") ? hint.indexOf(" ") : hint.length),
          hintStyle: kTextStyle.copyWith(fontSize: 13),
          errorStyle: kTextStyle.copyWith(color: Colors.red),
        ),
        keyboardType: keyboard,
      ),
    );
  }

  void onAddYourSkillsPressed() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        return Card(
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.07,
            vertical: MediaQuery.of(context).size.width * 0.15,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 2.0,
              vertical: 15,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Expertise',
                    style: kInputStyle.copyWith(
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ).tr(),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    children: [
                      Wrap(
                        spacing: 3,
                        children: List.generate(
                          selectedExpertise.length,
                          (index) => InputChip(
                            label: Text(
                              selectedExpertise[index].contains('l-')
                                  ? selectedExpertise[index].substring(2)
                                  : selectedExpertise[index],
                              style:
                                  kTextStyle.copyWith(locale: context.locale),
                            ).tr(),
                            deleteIconColor: Colors.red,
                            onSelected: (val) {},
                            backgroundColor: kLightSkinColor,
                            elevation: 1,
                            onDeleted: () {
                              // String text = selectedExpertise[index];
                              selectedExpertise.removeAt(index);
                              ratesFieldsController.removeAt(index);
                              customizationRatesFieldsController
                                  .removeAt(index);
                              expertiseRatesList.removeAt(index);
                              // Fluttertoast.showToast(
                              //     msg: "removed $text.",
                              //     toastLength: Toast.LENGTH_SHORT,
                              //     gravity: ToastGravity.BOTTOM,
                              //    textColor: Colors.white,
                              // backgroundColor: kOrangeColor,
                              //     fontSize: 16.0);
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                      unSelectedExpertise.length == 2
                          ? Column(
                              children: [
                                ExpansionTile(
                                  title: Text(
                                    "Gents",
                                    style: kBoldTextStyle(size: 15),
                                  ).tr(),
                                  children: List.generate(
                                    getMenCatg().length,
                                    (index) {
                                      final key =
                                          getMenCatg().keys.elementAt(index);
                                      final value =
                                          getMenCatg()[key] as List<String>;
                                      return buildGentsLadiesCategoriesCard(
                                          key, value, index, setState);
                                    },
                                  ),
                                ),
                                ExpansionTile(
                                  title: Text(
                                    "Ladies",
                                    style: kBoldTextStyle(size: 15),
                                  ).tr(),
                                  children: List.generate(
                                    getLadiesCatg().length,
                                    (index) {
                                      final key =
                                          getLadiesCatg().keys.elementAt(index);
                                      final value =
                                          getLadiesCatg()[key] as List<String>;
                                      return buildGentsLadiesCategoriesCard(
                                          key, value, index, setState);
                                    },
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              primary: false,
                              shrinkWrap: true,
                              itemCount: unSelectedExpertise.length,
                              itemBuilder: (context, index) {
                                final key =
                                    unSelectedExpertise.keys.elementAt(index);
                                final value =
                                    unSelectedExpertise[key] as List<String>;
                                return buildGentsLadiesCategoriesCard(
                                    key, value, index, setState);
                              },
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: RectangularRoundedButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 8,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      print("Skill List: $selectedExpertise");
                    },
                    buttonName: 'Done',
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
    setState(() {});
  }

  Padding buildStitchingTypeRow(Size size) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            'stitching type: ',
            style: kInputStyle.copyWith(
                fontSize: 16,
                color: stitchingType == null ? Colors.red : Colors.black),
          ).tr(),
          SizedBox(
            width: size.width * 0.3,
            child: DropdownButton<StitchingType>(
              value: stitchingType,
              borderRadius: BorderRadius.circular(10),
              icon: Icon(FontAwesomeIcons.chevronDown,
                  size: 15, color: kOrangeColor),
              isDense: true,
              isExpanded: true,
              style: kTextStyle.copyWith(fontSize: 15),
              elevation: 2,
              iconEnabledColor: kOrangeColor,
              items: List.generate(
                StitchingType.values.length,
                (index) => DropdownMenuItem(
                  value: StitchingType.values[index],
                  child: Text(
                    capitalizeText(StitchingType.values[index].name),
                    style: kBoldTextStyle(),
                  ).tr(),
                ),
              ),
              onChanged: (item) {
                setState(() {
                  if (item == stitchingType) return;
                  stitchingType = item;
                  unSelectedExpertise = stitchingType == StitchingType.gents
                      ? {...getMenCatg()}
                      : stitchingType == StitchingType.ladies
                          ? {...getLadiesCatg()}
                          : {
                              "Gents": ["yes"],
                              "Ladies": ["Yes"]
                            };
                  if (item != StitchingType.both) {
                    selectedExpertise.clear();
                    ratesFieldsController.clear();
                    customizationRatesFieldsController.clear();
                    expertiseRatesList.clear();
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHorizontalCardItem(String firstItemText, String secondItemText) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            firstItemText,
            style: kTextStyle.copyWith(fontSize: 15),
          ).tr(),
          SizedBox(width: MediaQuery.of(context).size.width * 0.01),
          Flexible(
            child: Text(
              secondItemText,
              style: kTextStyle,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildExpertiseRatesTextFields(Size size, StateSetter setState) {
    return Column(
        children: List.generate(
      selectedExpertise.length,
      (index) {
        return Column(
          children: [
            SizedBox(
              height: size.height * 0.1,
              child: ItemRateInputTile(
                title: getCategory(selectedExpertise[index]),
                suffixText: getTranslatedText("روپے.", 'Rs'),
                controller: ratesFieldsController[index],
                onChanged: (val) {
                  if (val != null && val.isNotEmpty) {
                    expertiseRatesList[index].price = int.parse(val);
                  }
                  setState(() {});
                  isSameData();
                },
              ),
            ),
            if (customizesDresses)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ItemRateInputTile(
                    textSize: 14,
                    title: "customization price",
                    suffixText: getTranslatedText("روپے.", 'Rs'),
                    controller: customizationRatesFieldsController[index],
                    onChanged: (val) {
                      setState(() {
                        if (val != null && val.isNotEmpty) {
                          try {
                            expertiseRatesList[index].customizationPrice =
                                int.parse(val);
                          } catch (e) {
                            print("Exceotion price: $e");
                          }
                          setState(() {});
                        }
                      });
                    },
                  ),
                  const Divider(color: kDarkOrange)
                ],
              ),
          ],
        );
      },
    ));
  }

  bool sameRates(List<RateItem> l1, List<RateItem> l2) {
    if (l1.length != l2.length) {
      return false;
    }
    bool isSame = true;
    for (int i = 0; i < l1.length; i++) {
      if (l1[i].category != l2[i].category ||
          l1[i].price != l2[i].price ||
          l1[i].customizationPrice != l2[i].customizationPrice) {
        isSame = false;
        break;
      }
    }
    print("isSame: $isSame");
    return isSame;
  }
}
