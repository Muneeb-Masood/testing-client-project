// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test/models/app_user.dart';
import 'package:test/models/customer.dart';
import 'package:test/models/shop.dart';
import 'package:test/models/tailor.dart';
import 'package:test/models/user_location.dart';
import 'package:test/networking/location_helper.dart';
import 'package:test/screens/login.dart';
import 'package:test/screens/tailor/tailor_main_screen.dart';
import 'package:test/utilities/constants.dart';
import 'package:test/utilities/custom_widgets/expandable_list_tile.dart';
import 'package:test/utilities/custom_widgets/item_rate_input_tile.dart';
import 'package:test/utilities/custom_widgets/rectangular_button.dart';
import 'package:test/utilities/my_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

class TailorRegistration extends StatefulWidget {
  final AppUser userData;
  //from which screen user has navigated to this screen if its signup then pop back to login
  //or if its login then push to home
  final String fromScreen;

  const TailorRegistration(
      {super.key, required this.userData, this.fromScreen = Login.id});
  @override
  _TailorRegistrationState createState() => _TailorRegistrationState();
}

class _TailorRegistrationState extends State<TailorRegistration> {
  Customer? data;
  ImagePicker picker = ImagePicker();
  final formKey = GlobalKey<FormState>();
  final shopFormKey = GlobalKey<FormState>();
  final shopNameController = TextEditingController();
  final shopAddressController = TextEditingController();
  final cityController = TextEditingController();
  final postalCodeController = TextEditingController();
  Gender? gender;
  bool isVerifyingPhoneNumber = false;
  bool isNextBtnPressed = false;
  bool phoneNumberVerified = false;
  bool isUploadingShop1Image = false;
  bool isUploadingShop2Image = false;
  bool isUploadingProfileImage = false;
  bool isRegisterBtnPressed = false;
  String? profileImageUrl;

  // String? logoImageUrl;
  List<String?> shopImagesList = [];
  String? initialImageUrl;
  StitchingType? stitchingType;
  List<String> selectedExpertise = [];
  List<RateItem> expertiseRatesList = [];
  Map<String, List<String>> unSelectedExpertise = {};

  final experienceController = TextEditingController();
  List<TextEditingController> ratesFieldsController = [];
  List<TextEditingController> customizationRatesFieldsController = [];
  bool customizesDresses = false;
  Tailor? tailor;

  bool isSavingDataInFirebase = false;

  final storage = FirebaseStorage.instance.ref();

  int selectedUnselectedExpertiseCategoryIndex = -1;

  final nameController = TextEditingController(
      text: FirebaseAuth.instance.currentUser?.displayName);

  UserLocation? location;

  int viaAgentCharges = 0;

  final viaAgentChargesController = TextEditingController();

  String? phoneNumber;

  @override
  void initState() {
    super.initState();
    checkPhoneNumberLink();
    Future.delayed(const Duration(milliseconds: 2), () {
      //setting urdu
      if (context.locale == const Locale("ur", "PK")) {
        isUrduActivated = true;
      } else {
        isUrduActivated = false;
      }
      if (mounted) {
        setState(() {});
      }
    });
    initialImageUrl = 'assets/user.png';
    if (widget.userData.name.isNotEmpty) {
      nameController.text = widget.userData.name;
    }
    LocationHelper().getUserLocation().then((value) {
      if (value != null) {
        location = value;
        if (mounted) setState(() {});
      }
      print(value?.toJson().toString());
    });
    Future.delayed(const Duration(milliseconds: 20)).then((value) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void checkPhoneNumberLink() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null && user.phoneNumber != null) {
      print('Current user has a phone number linked: ${user.phoneNumber}');
      setState(() {
        phoneNumberVerified = true;
        phoneNumber = user.phoneNumber;
      });
    } else {
      phoneNumberVerified = false;
      print('Current user does not have a phone number linked.');
    }
  }

  @override
  void dispose() {
    super.dispose();
    experienceController.dispose();
    nameController.dispose();
    shopAddressController.dispose();
    shopNameController.dispose();
    cityController.dispose();
    postalCodeController.dispose();
    viaAgentChargesController.dispose();
    for (var element in ratesFieldsController) {
      element.dispose();
    }
    for (var element in customizationRatesFieldsController) {
      element.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return LoadingOverlay(
      progressIndicator: kSpinner(context),
      isLoading: isVerifyingPhoneNumber || isSavingDataInFirebase,
      child: Scaffold(
        appBar: AppBar(
          title: FittedBox(
            child: Text(
              'Register as Tailor',
              style: kInputStyle.copyWith(color: Colors.white),
            ).tr(),
          ),
          centerTitle: true,
          actions: [
            if (phoneNumberVerified) buildClearFormButton(context),
            IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setBool(Login.isLoggedInText, false);
                Navigator.pushReplacementNamed(context, Login.id);
              },
              icon: const Icon(FontAwesomeIcons.arrowRightFromBracket),
            ),
          ],
        ),
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05, vertical: size.height * 0.01),
              child: SingleChildScrollView(
                child: AutofillGroup(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!phoneNumberVerified)
                          buildPhoneNumberVerificationPage(size),
                        if (phoneNumberVerified && tailor == null)
                          buildPersonalInfoColumn(size, context),
                        if (phoneNumberVerified && tailor != null)
                          buildShopInfoColumn(size),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildShopInfoColumn(Size size) {
    return Form(
      key: shopFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: size.height * 0.01),
          Text(
            'Shop Info.',
            style: kTitleStyle.copyWith(fontSize: 30),
            textAlign: TextAlign.center,
          ).tr(),
          SizedBox(height: size.height * 0.02),
          buildTextFormField(
            getTranslatedText("دکان کا نام", 'shop name'),
            shopNameController,
            FontAwesomeIcons.shop,
            getTranslatedText("دکان کا نام درج کریں", 'enter shop name'),
            keyboard: TextInputType.name,
          ),
          buildTextFormField(
            getTranslatedText("پتہ", 'address'),
            shopAddressController,
            FontAwesomeIcons.locationDot,
            getTranslatedText("دکان کا پتہ درج کریں", 'enter shop address'),
            keyboard: TextInputType.streetAddress,
          ),
          buildTextFormField(
            getTranslatedText('شہر', 'city'),
            cityController,
            FontAwesomeIcons.city,
            getTranslatedText('شہر کا نام درج کریں', 'enter city name'),
          ),
          buildTextFormField(
            getTranslatedText('پوسٹل کوڈ', 'postal code'),
            postalCodeController,
            Icons.code,
            getTranslatedText('پوسٹل کوڈ درج کریں', 'enter postal code'),
            keyboard: TextInputType.number,
          ),
          buildTextFormField(
            getTranslatedText('ایجنٹ آپشن کے چارجز', 'charges via agent'),
            viaAgentChargesController,
            FontAwesomeIcons.rupeeSign,
            getTranslatedText(
                'ایجنٹ آپشن کے چارجز درج کریں', 'enter via agent charges'),
            keyboard: TextInputType.number,
          ),
          // buildShopLogoContainer(size),
          buildShopImagesContainer(size),
          SizedBox(height: size.height * 0.02),
          buildRegisterButton(),
        ],
      ),
    );
  }

  RectangularRoundedButton buildRegisterButton() {
    return RectangularRoundedButton(
      buttonName: 'Register',
      onPressed: () async {
        bool taskSuccessful = false;
        if (mounted) {
          setState(() {
            isRegisterBtnPressed = true;
          });
        }
        if (formKey.currentState!.validate() &&
            //  bcz aage barhe ga he tabhi jb phone wla process hogya hoga
            //  (phoneNumber != null && !phoneNumberVerified) &&
            shopFormKey.currentState!.validate() &&
            shopImagesList.length == 2) {
          if (mounted) {
            setState(() {
              isRegisterBtnPressed = true;
              isSavingDataInFirebase = true;
            });
          }
          //62 seconds as timeout
          Future.delayed(const Duration(seconds: 60, milliseconds: 2000))
              .then((value) {
            if (mounted) {
              setState(() => isSavingDataInFirebase = false);
              if (!taskSuccessful) {
                showMyBanner(
                    context, getTranslatedText("ٹائم آؤٹ.", "Timed out."));
              }
            }
          });
          Shop shop = Shop(
            viaAgentCharges: viaAgentCharges,
            address: shopAddressController.text.trim(),
            city: capitalizeText(cityController.text.trim()),
            name: capitalizeText(shopNameController.text.trim()),
            postalCode: int.parse(postalCodeController.text.trim()),
            shopImage1Url: shopImagesList[0],
            shopImage2Url: shopImagesList[1],
          );
          tailor!.shop = shop;
          try {
            await FirebaseFirestore.instance
                .collection('tailors')
                .add(tailor!.toJson())
                .then((doc) {
              tailor!.id = doc.id;
              tailor!.userDocId = widget.userData.id;
              FirebaseAuth.instance.currentUser!
                  .updateDisplayName(widget.userData.name)
                  .then((value) => print('Display name updated.'));
              FirebaseAuth.instance.currentUser!
                  .updatePhotoURL(tailor!.profileImageUrl)
                  .then((value) => print('Display photo url updated.'));
              doc.update(tailor!.toJson()).then((value) {
                widget.userData.isRegistered = true;
                widget.userData.isTailor = true;
                widget.userData.customerOrTailorId = doc.id;
                if (mounted) {
                  setState(() {
                    taskSuccessful = true;
                  });
                }
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.userData.id)
                    .update(widget.userData.toJson());
                print("tailor's user Data updated");
              }).then((value) {
                if (taskSuccessful) {
                  if (widget.fromScreen == Login.id) {
                    Future.delayed(const Duration(milliseconds: 20)).then(
                        (value) => Navigator.pushReplacementNamed(
                            context, TailorMainScreen.id));
                  } else {
                    //1 inidicates it was a tailor registration & was successful

                    FirebaseAuth.instance
                        .signOut()
                        .then((value) => SharedPreferences.getInstance().then(
                            (pref) =>
                                pref.setBool(Login.isLoggedInText, false)))
                        .then((value) {
                      if (mounted) {
                        setState(() {
                          isRegisterBtnPressed = false;
                          isSavingDataInFirebase = false;
                        });
                      }
                      showMyDialog(
                              context,
                              'Success',
                              getTranslatedText("درزی رجسٹریشن کامیاب ہوئ.",
                                  'Tailor registration successful.'),
                              isError: false,
                              disposeAfterMillis: 1200)
                          .then((value) => Navigator.pushReplacementNamed(
                              context, Login.id));
                    });
                  }
                }
              });
            });
          } catch (e) {
            print('Exception while saving: $e');
          }
          onClearButtonPressed();
          print('Tailor data: ${tailor!.toJson().toString()}');
        }
      },
    );
  }

  Padding buildShopImagesContainer(Size size) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Shop images',
                style: kInputStyle.copyWith(
                  fontSize: 18,
                ),
              ).tr(),
              if (shopImagesList.isNotEmpty)
                Text(
                  "(${shopImagesList.length}/2)",
                  style: kInputStyle.copyWith(
                    fontSize: 15,
                  ),
                ),
              if (shopImagesList.length < 2 && isRegisterBtnPressed)
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text('(Add at least 2 images)',
                            style: kTextStyle.copyWith(
                                color: Colors.red, fontSize: 12))
                        .tr(),
                  ),
                )
            ],
          ),
          SizedBox(height: size.height * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              //shop image 1 container(while he hasn't uploaded any image)
              shopImagesList.isNotEmpty
                  ? buildImageItem(size, shopImagesList[0], onRemove: () {
                      shopImagesList.removeWhere(
                          (element) => element == shopImagesList[0]);
                      setState(() {});
                    })
                  : buildUploadShopImageContainer(size, 1),
              shopImagesList.length > 1
                  ? buildImageItem(size, shopImagesList[1], onRemove: () {
                      shopImagesList.removeWhere(
                          (element) => element == shopImagesList[1]);
                      setState(() {});
                    })
                  : buildUploadShopImageContainer(size, 2),
            ],
          ),
        ],
      ),
    );
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
          ));

  TextButton buildClearFormButton(BuildContext context) {
    return TextButton(
      onPressed: () => {
        onClearButtonPressed(),
        showMyBanner(
            context,
            getTranslatedText(
                "فارم کامیابی سے صاف کیا گیا۔", "Form cleared successfully."))
      },
      child: Text(
        'Clear',
        style: kTextStyle.copyWith(color: Colors.white),
      ).tr(),
    );
  }

  Column buildPersonalInfoColumn(Size size, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: size.height * 0.01),
        Text(
          'Personal Info.',
          style: kTitleStyle.copyWith(fontSize: 30),
          textAlign: TextAlign.center,
        ).tr(),
        SizedBox(height: size.width * 0.01),
        Align(alignment: Alignment.center, child: buildProfilePicture(size)),
        buildSelectProfileImageButton(size),
        SizedBox(height: size.height * 0.01),
        buildTextFormField(getTranslatedText('نام', 'Name'), nameController,
            null, getTranslatedText('اپنا نام درج کریں', "Enter your name"),
            keyboard: TextInputType.name),
        SizedBox(height: size.height * 0.01),
        buildGenderRow(),
        SizedBox(height: size.height * 0.01),
        buildStitchingTypeRow(size),
        SizedBox(height: size.height * 0.01),
        buildCustomizesDressQuestionTile(),
        SizedBox(height: size.height * 0.01),
        buildTextFormField(
            getTranslatedText(
                'سالوں کی تعداد میں تجربہ', 'Experience in no of years'),
            experienceController,
            null,
            getTranslatedText('سالوں کی تعداد میں تجربہ درج کریں',
                "Enter experience in no of years"),
            keyboard: TextInputType.number),
        SizedBox(height: size.height * 0.01),
        buildExpertiseRowAndList(context, size),
        buildNextButton(),
      ],
    );
  }

  Widget buildProfilePicture(Size size) {
    return CircleAvatar(
      radius: size.width * 0.25,
      backgroundColor: kOrangeColor,
      child: Center(
        child: CircleAvatar(
          radius: size.width * 0.247,
          backgroundColor:
              isUploadingProfileImage ? Colors.white54 : Colors.white,
          backgroundImage:
              (profileImageUrl != null && profileImageUrl != initialImageUrl
                  ? NetworkImage(profileImageUrl!)
                  : AssetImage(initialImageUrl!) as ImageProvider),
          child: isUploadingProfileImage
              ? kSpinner(context, ratioFactor: 0.25)
              : null,
        ),
      ),
    );
  }

  Container buildSelectProfileImageButton(Size size) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: size.width * 0.25, vertical: size.height * 0.002),
      child: RectangularRoundedButton(
        padding: EdgeInsets.zero,
        fontSize: 15,
        buttonName: profileImageUrl == null ||
                isUploadingProfileImage ||
                profileImageUrl == initialImageUrl
            ? 'Select'
            : "Change",
        onPressed: isUploadingProfileImage
            ? null
            : () async {
                bool taskSuccessful = false;
                final file =
                    await picker.pickImage(source: ImageSource.gallery);
                if (file != null) {
                  setState(() {
                    isUploadingProfileImage = true;
                  });
                  Future.delayed(
                    const Duration(seconds: 30),
                  ).then((value) => setState(() {
                        isUploadingProfileImage = false;
                        if (!taskSuccessful) {
                          showMyBanner(context,
                              getTranslatedText("ٹائم آؤٹ.", "Timed out."));
                        }
                      }));
                  final storageRef = storage
                      .child('${widget.userData.email}/profileImage.png');
                  final uploadTask = await storageRef.putFile(File(file.path));
                  final downloadUrl = await uploadTask.ref.getDownloadURL();
                  FirebaseAuth.instance.currentUser
                      ?.updatePhotoURL(downloadUrl)
                      .then((value) => print("Photo url updated."));
                  setState(() {
                    profileImageUrl = downloadUrl;
                    taskSuccessful = true;
                    isUploadingProfileImage = false;
                  });
                }
              },
      ),
    );
  }

  CheckboxListTile buildCustomizesDressQuestionTile() {
    return CheckboxListTile(
      activeColor: kOrangeColor,
      contentPadding: const EdgeInsets.only(left: 10),
      title: Text(
        'Do you customize dresses?',
        style: kInputStyle.copyWith(fontSize: 18),
      ).tr(),
      subtitle: !isNextBtnPressed
          ? null
          : RichText(
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

  Padding buildExpertiseRowAndList(BuildContext context, Size size) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          buildAddExpertiseRow(context),
          SizedBox(height: size.height * 0.005),
          buildExpertiseRatesTextFields(size),
          // buildExpertiseWrappedList(size),
        ],
      ),
    );
  }

  Row buildAddExpertiseRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Expertise',
          style: kInputStyle.copyWith(
              fontSize: 18,
              color: selectedExpertise.isEmpty && isNextBtnPressed
                  ? Colors.red
                  : Colors.black),
        ).tr(),
        RectangularRoundedButton(
          buttonName: 'Add',
          fontSize: 15,
          onPressed: () {
            if (stitchingType == null) {
              showMyBanner(
                  context,
                  getTranslatedText("براہ کرم سلائی کی قسم منتخب کریں",
                      'Please select a stitching type.'));
            } else {
              onAddYourSkillsPressed();
            }
          },
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }

  RectangularRoundedButton buildNextButton() {
    return RectangularRoundedButton(
      buttonName: 'Next',
      onPressed: () async {
        setState(() {
          isNextBtnPressed = true;
          if (formKey.currentState!.validate() &&
              gender != null &&
              stitchingType != null &&
              selectedExpertise.isNotEmpty) {
            if (profileImageUrl == null ||
                profileImageUrl == initialImageUrl && location != null) {
              showMyDialog(
                  context,
                  'Error!',
                  getTranslatedText(
                      "پروفائل تصویر شامل کریں", "add a profile picture."),
                  disposeAfterMillis: 1500);
              return;
            }
            print("Validation successful");
            if (location == null) {
              showMyDialog(
                  context,
                  'Error!',
                  getTranslatedText(
                      "براہ کرم سیٹنگس میں جائیں اور لوکیشن کی اجازت دیں۔",
                      "please go to settings and give location permission."),
                  disposeAfterMillis: 3000);
              return;
            }
            tailor = Tailor(
              location: location!,
              tailorName: capitalizeText(nameController.text.trim()),
              email: widget.userData.email,
              userDocId: widget.userData.id,
              gender: gender!,
              stitchingType: stitchingType!,
              expertise: selectedExpertise,
              phoneNumber: phoneNumber,
              profileImageUrl: profileImageUrl,
              customizes: customizesDresses,
              rates: expertiseRatesList,
              experience: int.parse(experienceController.text.trim()),
            );
            widget.userData.name = capitalizeText(nameController.text.trim());
            print("Rates: $expertiseRatesList");
            isNextBtnPressed = false;
          }
        });
      },
    );
  }

  Container buildPhoneNumberVerificationPage(Size size) {
    return Container(
      margin: EdgeInsets.only(top: size.height * 0.2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Verify phone number',
            style: kTitleStyle.copyWith(fontSize: 30),
            textAlign: TextAlign.center,
          ).tr(),
          SizedBox(height: size.height * 0.05),
          buildPhoneNumberField(setState),
          buildSendCodeButton(setState),
        ],
      ),
    );
  }

  Widget buildExpertiseWrappedList(Size size) {
    return Wrap(
      children: List.generate(selectedExpertise.length,
          (index) => buildExpertiseItem(selectedExpertise[index])),
    );
  }

  Card buildExpertiseItem(String text) {
    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: 7.0,
        horizontal: 3,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
        side: const BorderSide(
          color: Colors.grey,
          width: 0.3,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15.0,
          vertical: 5,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'CenturyGothic',
            fontSize: 13,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Padding buildStitchingTypeRow(Size size) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            'Select Stitching type',
            style: kInputStyle.copyWith(
                fontSize: 18,
                color: stitchingType == null && isNextBtnPressed
                    ? Colors.red
                    : Colors.black),
          ).tr(),
          SizedBox(
            width: size.width * 0.3,
            child: DropdownButton<StitchingType>(
              value: stitchingType,
              borderRadius: BorderRadius.circular(10),
              icon: const Icon(FontAwesomeIcons.chevronDown, size: 15),
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

  Row buildGenderRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          'Gender',
          style: kInputStyle.copyWith(
              fontSize: 18,
              color: gender == null && isNextBtnPressed
                  ? Colors.red
                  : Colors.black),
        ).tr(),
        buildRadioTile('Male', Gender.male),
        buildRadioTile('Female', Gender.female),
      ],
    );
  }

  Row buildRadioTile(String text, Gender value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<Gender>(
          activeColor: kOrangeColor,
          value: value,
          groupValue: gender,
          onChanged: (val) {
            setState(() {
              gender = val;
            });
          },
        ),
        Text(text, style: kTextStyle.copyWith(fontSize: 15)).tr(),
      ],
    );
  }

  Align buildSendCodeButton(StateSetter setState) {
    return Align(
      alignment: Alignment.centerRight,
      child: RectangularRoundedButton(
        buttonName: 'Send code',
        fontSize: 13,
        padding: const EdgeInsets.symmetric(vertical: 2),
        onPressed: phoneNumber == null || phoneNumber!.trim().length < 13
            ? null
            : () {
                setState(() {
                  isVerifyingPhoneNumber = true;
                });
                sendCodeToNumber(setState);
              },
      ),
    );
  }

  IntlPhoneField buildPhoneNumberField(StateSetter setState) {
    return IntlPhoneField(
      readOnly: phoneNumberVerified,
      enabled: !phoneNumberVerified,
      // countries: const ["PK"],
      onChanged: (number) {
        phoneNumber = number.completeNumber;
        setState(() {});
      },
      flagsButtonPadding: const EdgeInsets.all(10),
      style: kInputStyle.copyWith(
        locale: context.locale,
      ),
      decoration: kTextFieldDecoration.copyWith(
        suffixIcon: phoneNumberVerified
            ? const Icon(Icons.check, color: Colors.green)
            : null,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        hintText: dummyNumber,
        hintStyle: kInputStyle,
        labelText: getTranslatedText("فون نمبر", 'phone#'),
        // labelStyle: kInputStyle,
      ),
      initialCountryCode: 'PK',
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
          if (val == null || val.isEmpty) {
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
          hintText: hint,
          labelText: hint.substring(
              0, hint.contains(" ") ? hint.indexOf(" ") : hint.length),
          hintStyle: kTextStyle.copyWith(
              fontSize: 13,
              locale: context.locale,
              overflow: TextOverflow.visible),
          errorStyle:
              kTextStyle.copyWith(color: Colors.red, locale: context.locale),
        ),
        keyboardType: keyboard,
      ),
    );
  }

  void sendCodeToNumber(StateSetter setState) async {
    final overallContext = context;
    final pincodeController = TextEditingController();
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(minutes: 2),
      verificationCompleted: (userCredential) {
        print("verification auto completed");
      },
      verificationFailed: (e) {
        showMyDialog(overallContext, e.code, e.message ?? 'Error!');
      },
      codeSent: (verId, codeSent) async {
        showMyBanner(
            overallContext,
            getTranslatedText(
                "پن کوڈ کامیابی سے بھیجا گیا۔", 'pin code sent successfully.'));

        await showDialog(
          context: context,
          builder: (context) => StatefulBuilder(builder: (context, setState) {
            return LoadingOverlay(
              isLoading: isVerifyingPhoneNumber,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                margin: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.26,
                  horizontal: MediaQuery.of(context).size.width * 0.05,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          getTranslatedText(
                              " '${zeroedPhoneNumber(phoneNumber)}' پر بھیجا گیا پن کوڈ درج کریں ",
                              'Enter pin code sent to ${zeroedPhoneNumber(phoneNumber)}'),
                          style:
                              kInputStyle.copyWith(fontSize: 20, height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.07,
                        ),
                        FittedBox(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Center(
                              child: PinCodeTextField(
                                autofocus: true,
                                controller: pincodeController,
                                maxLength: 6,
                                pinTextStyle: kInputStyle,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05,
                        ),
                        RectangularRoundedButton(
                          buttonName: 'Submit',
                          onPressed: () async {
                            if (pincodeController.text.isNotEmpty) {
                              setState(() {
                                isVerifyingPhoneNumber = true;
                              });
                              try {
                                await FirebaseAuth.instance.currentUser!
                                    .linkWithCredential(
                                  PhoneAuthProvider.credential(
                                    verificationId: verId,
                                    smsCode: pincodeController.text.trim(),
                                  ),
                                );
                                setPhoneStatusVerified();
                                showMyBanner(
                                    overallContext,
                                    getTranslatedText("تصدیق کامیاب ہوئی.",
                                        'Verification successful.'));

                                Future.delayed(const Duration(seconds: 1))
                                    .then((value) {
                                  Navigator.pop(context);
                                });
                              } on FirebaseAuthException catch (e) {
                                print('Exception : ${e.code}');
                                showMyBanner(
                                    overallContext,
                                    getTranslatedText(
                                        'غلطی: ${e.code}', 'Error: ${e.code}'));
                              } catch (e) {
                                print(
                                    'Exception other than firebase auth in otp: $e');
                                showMyBanner(
                                    overallContext,
                                    getTranslatedText("تصدیق ناکام ہوئی.",
                                        'Verification failed.'));
                              }
                            }
                            setState(() {
                              isVerifyingPhoneNumber = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
      codeAutoRetrievalTimeout: (verificationId) {
        // print("Timout: ");
      },
    );
    if (isVerifyingPhoneNumber) {
      setState(() {
        isVerifyingPhoneNumber = false;
      });
    }
  }

  String capitalizeText(String text) {
    return text[0].toUpperCase() + text.substring(1);
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
                              getCategory(selectedExpertise[index]),
                              style:
                                  kTextStyle.copyWith(locale: context.locale),
                            ).tr(),
                            deleteIconColor: Colors.red,
                            onSelected: (isSelected) {},
                            backgroundColor: kLightSkinColor,
                            elevation: 1,
                            avatar: CircleAvatar(
                              backgroundColor: kOrangeColor,
                              backgroundImage: AssetImage(
                                  dressImages[selectedExpertise[index]]
                                      as String),
                            ),
                            onDeleted: () {
                              String text = selectedExpertise[index];
                              selectedExpertise.removeAt(index);
                              ratesFieldsController.removeAt(index);
                              customizationRatesFieldsController
                                  .removeAt(index);
                              expertiseRatesList.removeAt(index);
                              setState(() {});
                              Fluttertoast.showToast(
                                  msg: getTranslatedText(
                                      "$text ہٹا دیا گیا۔", "removed $text."),
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  textColor: Colors.white,
                                  backgroundColor: kOrangeColor,
                                  fontSize: 16.0);
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
              customizationPrice: customizesDresses ? 0 : null,
            ),
          );
        } else {
          Fluttertoast.showToast(
              msg: getTranslatedText("$itemValue پہلے ہی شامل کیا جا چکا ہے.",
                  "$itemValue is already added."),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              textColor: Colors.white,
              backgroundColor: kOrangeColor,
              fontSize: 16.0);
        }
        if (mounted) setState(() {});
      },
    );
  }

  buildUploadImageContainer(size, bool isUploading,
          {required VoidCallback onPressed, String text = 'Upload'}) =>
      Container(
        width: size.width * 0.4,
        height: size.width * 0.38,
        decoration: BoxDecoration(
          color: kLightSkinColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(blurRadius: 2, offset: Offset(1, 1), color: Colors.grey),
          ],
        ),
        child: isUploading
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
                    Text(text, style: kTextStyle.copyWith(fontSize: 18)).tr()
                  ],
                ),
                onPressed: onPressed,
              ),
      );

  void onClearButtonPressed() {
    setState(() {
      isNextBtnPressed = false;
      stitchingType = null;
      gender = null;
      profileImageUrl = initialImageUrl;
      shopNameController.clear();
      experienceController.clear();
      nameController.clear();
      postalCodeController.clear();
      cityController.clear();
      shopAddressController.clear();
      customizesDresses = false;
      selectedExpertise.clear();
      unSelectedExpertise.clear();
      // logoImageUrl = null;
      shopImagesList.clear();
      formKey.currentState?.reset();
      shopFormKey.currentState?.reset();
    });
  }

  buildUploadShopImageContainer(size, int imageNo) => buildUploadImageContainer(
        size,
        imageNo == 1 ? isUploadingShop1Image : isUploadingShop2Image,
        onPressed: () async {
          if (shopImagesList.length < 2) {
            final file = await picker.pickImage(source: ImageSource.gallery);
            if (file != null) {
              setState(() {
                if (imageNo == 1) {
                  isUploadingShop1Image = true;
                } else {
                  isUploadingShop2Image = true;
                }
              });

              final storageRef = storage
                  .child('${widget.userData.email}/shopImage$imageNo.png');
              final uploadTask = await storageRef.putFile(File(file.path));
              final downloadUrl = await uploadTask.ref.getDownloadURL();
              setState(() {
                shopImagesList.add(downloadUrl);
                if (imageNo == 1) {
                  isUploadingShop1Image = false;
                } else {
                  isUploadingShop2Image = false;
                }
              });
            }
          }
        },
      );

  Widget buildExpertiseRatesTextFields(Size size) {
    return Column(
        children: List.generate(
      selectedExpertise.length,
      (index) {
        return Column(
          children: [
            ItemRateInputTile(
              title: getCategory(selectedExpertise[index]),
              suffixText: getTranslatedText("روپے.", 'Rs'),
              controller: ratesFieldsController[index],
              onChanged: (val) {
                setState(() {
                  if (val != null && val.isNotEmpty) {
                    expertiseRatesList[index].price = int.parse(val);
                  }
                });
              },
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

  void setPhoneStatusVerified() {
    setState(() {
      phoneNumberVerified = true;
    });
  }
}
