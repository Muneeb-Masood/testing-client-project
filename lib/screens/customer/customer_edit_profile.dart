import 'dart:io';

import 'package:test/main.dart';
import 'package:test/models/measurement.dart';
import 'package:test/networking/firestore_helper.dart';
import 'package:test/screens/customer/customer_main_screen.dart';
import 'package:test/utilities/constants.dart';
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

class CustomerEditProfile extends StatefulWidget {
  const CustomerEditProfile({Key? key}) : super(key: key);

  @override
  State<CustomerEditProfile> createState() => _CustomerEditProfileState();
}

class _CustomerEditProfileState extends State<CustomerEditProfile> {
  bool isUploadingProfileImage = false;
  final formKey = GlobalKey<FormState>();

  final addressController =
      TextEditingController(text: currentCustomer!.address);
  final nameController = TextEditingController(text: currentCustomer!.name);
  final cityController = TextEditingController(text: currentCustomer!.city);
  final phoneNoController =
      TextEditingController(text: currentCustomer!.phoneNumber?.substring(3));
  bool isUpdatingData = false;
  MeasurementChoice? measurementChoice = currentCustomer!.measurementChoice;

  String phoneNumber = currentCustomer!.phoneNumber ?? "";

  @override
  void initState() {
    super.initState();
    nameController.addListener(() {
      if (mounted) setState(() {});
    });
    cityController.addListener(() {
      if (mounted) setState(() {});
    });
    addressController.addListener(() {
      if (mounted) setState(() {});
    });
    phoneNoController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    cityController.dispose();
    addressController.dispose();
    phoneNoController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isUpdatingData,
      progressIndicator: kSpinner(context),
      child: Scaffold(
        body: SingleChildScrollView(
          child: SafeArea(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  buildPersonalInfoColumn(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Column buildPersonalInfoColumn(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: size.width * 0.01),
        Align(alignment: Alignment.center, child: buildProfilePicture(size)),
        buildSelectProfileImageButton(size),
        SizedBox(height: size.height * 0.01),
        buildTextFormField(isUrduActivated ? 'نام' : 'name', nameController,
            null, isUrduActivated ? 'اپنا نام درج کریں' : "Enter your name",
            keyboard: TextInputType.name),
        SizedBox(height: size.height * 0.02),
        buildTextFormField(
          isUrduActivated ? 'پتہ' : 'address',
          addressController,
          FontAwesomeIcons.locationDot,
          isUrduActivated ? 'اپنا پتہ درج کریں' : 'enter your address',
          keyboard: TextInputType.streetAddress,
        ),
        SizedBox(height: size.height * 0.015),
        buildTextFormField(
          isUrduActivated ? 'شہر' : 'city',
          cityController,
          FontAwesomeIcons.city,
          isUrduActivated ? 'شہر کا نام درج کریں' : 'enter city name',
          keyboard: TextInputType.name,
        ),
        SizedBox(height: size.height * 0.015),
        buildPhoneNumberField(),
        SizedBox(height: size.height * 0.015),
        buildMeasurementChoice(),
        SizedBox(height: size.height * 0.015),
        buildUpdateButton(),
        SizedBox(height: size.height * 0.025),
      ],
    );
  }

  Widget buildProfilePicture(Size size) {
    return CircleAvatar(
      radius: size.width * 0.25,
      backgroundColor: Colors.blue,
      child: Center(
        child: CircleAvatar(
          radius: size.width * 0.247,
          backgroundColor:
              isUploadingProfileImage ? Colors.white54 : Colors.white,
          backgroundImage: NetworkImage(currentCustomer!.profileImageUrl!),
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
        buttonName: "Change",
        onPressed: isUploadingProfileImage
            ? null
            : () async {
                bool taskSuccessful = false;
                final file =
                    await ImagePicker().pickImage(source: ImageSource.gallery);
                if (file != null) {
                  if (mounted) {
                    setState(() {
                      isUploadingProfileImage = true;
                    });
                  }
                  Future.delayed(
                    const Duration(seconds: 30),
                  ).then((value) {
                    if (mounted) {
                      setState(() {
                        isUploadingProfileImage = false;
                        if (!taskSuccessful) {
                          showMyBanner(context,
                              getTranslatedText("ٹائم آؤٹ.", "Timed out."));
                        }
                      });
                    }
                  });
                  final storageRef = FirebaseStorage.instance
                      .ref()
                      .child('${currentCustomer!.email}/profileImage.png');
                  final uploadTask = await storageRef.putFile(File(file.path));
                  final downloadUrl = await uploadTask.ref.getDownloadURL();
                  FirebaseAuth.instance.currentUser
                      ?.updatePhotoURL(downloadUrl)
                      .then((value) => Fluttertoast.showToast(
                          textColor: Colors.white,
                          backgroundColor: kOrangeColor,
                          msg: getTranslatedText(
                              "پروفائل تصویر کو اپ ڈیٹ کیا گیا۔",
                              "Profile picture updated.")));

                  if (mounted) {
                    setState(() {
                      currentCustomer!.profileImageUrl = downloadUrl;
                      taskSuccessful = true;
                      isUploadingProfileImage = false;
                    });
                  }
                }
              },
      ),
    );
  }

  Widget buildUpdateButton() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.1),
      child: RectangularRoundedButton(
        padding: const EdgeInsets.symmetric(vertical: 2),
        buttonName: 'Update',
        onPressed: isSameData() ? null : onUpdateButtonPressed,
      ),
    );
  }

  bool isSameData() {
    bool isSame = false;
    final sameName = nameController.text.trim().toLowerCase() ==
        currentCustomer!.name.toLowerCase();
    final sameAddress = addressController.text.trim().toLowerCase() ==
        currentCustomer!.address!.toLowerCase();
    final sameCity = cityController.text.trim().toLowerCase() ==
        currentCustomer!.city!.toLowerCase();
    final samePhone = phoneNumber == currentCustomer!.phoneNumber;
    final sameSubmissionChoice =
        measurementChoice == currentCustomer!.measurementChoice;

    if (sameName &&
        sameAddress &&
        sameCity &&
        samePhone &&
        sameSubmissionChoice) {
      isSame = true;
    }
    return isSame;
  }

  onUpdateButtonPressed() async {
    bool taskSuccessful = false;
    if (isSameData()) {
      showMyBanner(context,
          getTranslatedText("کچھ بھی اپ ڈیٹ نہیں ہوا۔", 'Nothing updated.'));
      return;
    }
    if (formKey.currentState!.validate()) {
      currentCustomer!.name = capitalizeText(nameController.text.trim());
      currentCustomer!.address = addressController.text.trim();
      currentCustomer!.city = cityController.text.trim();
      currentCustomer!.phoneNumber = phoneNumber;
      currentCustomer!.measurementChoice = measurementChoice!;
      if (mounted) {
        setState(() {
          isUpdatingData = true;
        });
      }
      //62 seconds as timeout
      Future.delayed(const Duration(seconds: 60, milliseconds: 2000))
          .then((value) {
        if (mounted) {
          setState(() => isUpdatingData = false);
          if (!taskSuccessful)
            showMyBanner(context, getTranslatedText("ٹائم آؤٹ.", "Timed out."));
        }
      });
      // print('customer: $currentCustomer');
      try {
        //inserting customer data
        FirebaseAuth.instance.currentUser!
            .updateDisplayName(currentCustomer!.name)
            .then((value) => print('Display name updated.'));
        FirebaseAuth.instance.currentUser!
            .updatePhotoURL(currentCustomer!.profileImageUrl)
            .then((value) => print('Display photo url updated.'));
        await FireStoreHelper()
            .updateCustomer(currentCustomer!)
            .then((doc) async {
          //updating customer id field
          if (mounted) {
            setState(() {
              taskSuccessful = true;
              isUpdatingData = false;
            });
          }
          //updating corresponding app user record in users collection
          print("customer's user Data updated");
          Fluttertoast.showToast(
            textColor: Colors.white,
            backgroundColor: kOrangeColor,
            msg: getTranslatedText('پروفائل اپ ڈیٹ کیا گیا', 'Profile updated'),
          );
          Navigator.pop(context);
          loadCurrentCustomer();
          final appUserData = await FireStoreHelper()
              .getAppUserWithDocId(currentCustomer!.userDocId!);
          if (appUser == null) return;
          appUserData!.name = currentCustomer!.name;
          FireStoreHelper().updateAppUser(appUserData);
          print("corresponding app user Data updated.");
        });
      } catch (e) {
        print('Exception while updating customer data: $e');
      }
    }
  }

  // SpinKitDoubleBounce buildLoadingSpinner() {
  //   return SpinKitDoubleBounce(
  //     itemBuilder: (BuildContext context, int index) {
  //       return DecoratedBox(
  //         decoration: BoxDecoration(
  //           color: index.isEven ? Colors.blue : Colors.white,
  //         ),
  //       );
  //     },
  //   );
  // }

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
          // hintText: hint,
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

  Widget buildPhoneNumberField() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: IntlPhoneField(
        controller: phoneNoController,
        // countries: ["PK"],
        flagsButtonPadding: const EdgeInsets.all(10),
        decoration: kTextFieldDecoration.copyWith(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          hintText: dummyNumber,
          hintStyle: kInputStyle,
          labelText: getTranslatedText("فون نمبر", 'phone#'),
          // labelStyle: kInputStyle,
        ),
        keyboardType: TextInputType.phone,
        style: kInputStyle.copyWith(
          locale: context.locale,
        ),
        onChanged: (phone) {
          if (mounted) {
            setState(() {
              phoneNumber = phone.completeNumber;
            });
          }
          print('Phone#: $phoneNumber');
        },
        initialCountryCode: 'PK',
      ),
    );
  }

  buildMeasurementChoice() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Measurement submission choice',
            style: kInputStyle,
          ).tr(),
          ...List.generate(
            MeasurementChoice.values.length,
            (index) => RadioListTile<MeasurementChoice>(
              contentPadding: EdgeInsets.zero,
              activeColor: kOrangeColor,
              value: MeasurementChoice.values[index],
              groupValue: measurementChoice,
              title:
                  Text(urduMeasurement(MeasurementChoice.values[index].name)),
              subtitle: MeasurementChoice.values[index] != measurementChoice
                  ? null
                  : Text(
                      measurementChoiceSubtitles[index],
                      style: kTextStyle.copyWith(fontSize: 12),
                    ).tr(),
              onChanged: (val) {
                if (mounted) {
                  setState(() {
                    measurementChoice = val!;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void loadCurrentCustomer() async {
    final customer = await FireStoreHelper()
        .getCustomerWithDocId(appUser!.customerOrTailorId!);
    if (customer != null) {
      currentCustomer = customer;
      if (mounted) {
        setState(() {});
        print('Current customer loaded successfully.');
      }
    }
  }
}
