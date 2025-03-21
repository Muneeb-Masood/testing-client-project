// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test/models/app_user.dart';
import 'package:test/models/customer.dart';
import 'package:test/models/measurement.dart';
import 'package:test/networking/location_helper.dart';
import 'package:test/screens/customer/customer_main_screen.dart';
import 'package:test/utilities/constants.dart';
import 'package:test/utilities/my_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import '../../models/tailor.dart';
import '../../models/user_location.dart';
import '../../utilities/custom_widgets/rate_input_text_field.dart';
import '../../utilities/custom_widgets/rectangular_button.dart';
import '../login.dart';

class CustomerRegistration extends StatefulWidget {
  final AppUser userData;
  //from which screen user has navigated to this screen if its signup then pop back to login
  //or if its login then push to home
  final String fromScreen;

  const CustomerRegistration(
      {super.key, required this.userData, this.fromScreen = Login.id});
  @override
  _CustomerRegistrationState createState() => _CustomerRegistrationState();
}

class _CustomerRegistrationState extends State<CustomerRegistration> {
  Customer? customer;
  ImagePicker picker = ImagePicker();
  final formKey = GlobalKey<FormState>();

  final addressController = TextEditingController();
  Gender? gender;
  bool isVerifyingPhoneNumber = false;
  bool isNextBtnPressed = false;
  bool phoneNumberVerified = false;
  bool phoneVerificationSkipped = false;
  bool isUploadingProfileImage = false;
  bool isRegisterBtnPressed = false;
  String? profileImageUrl;
  String? initialImageUrl;

  final nameController = TextEditingController(
      text: FirebaseAuth.instance.currentUser?.displayName);
  final cityController = TextEditingController();
  bool isSavingDataInFirebase = false;

  final storage = FirebaseStorage.instance.ref();

  List<Measurement> measurements = List.generate(
    totalMeasurements.length,
    (index) => Measurement(
        title: capitalizeText(
            spaceSeparatedText(totalMeasurements.keys.elementAt(index))),
        measure: 0),
  );
  final measurementsControllers = List.generate(
      totalMeasurements.length, (index) => TextEditingController(text: '0'));

  MeasurementChoice? measurementChoice;

  bool measurementChoiceSelected = false;

  bool measurementsNextButtonPressed = false;

  UserLocation? location;

  String city = "";

  String? phoneNumber;

  void checkPhoneNumberLink() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null && user.phoneNumber != null) {
      print('Current user has a phone number linked: ${user.phoneNumber}');
      setState(() {
        phoneNumberVerified = true;
        phoneNumber = user.phoneNumber;
        phoneVerificationSkipped = true;
      });
    } else {
      phoneNumberVerified = false;
      print('Current user does not have a phone number linked.');
    }
  }

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

  @override
  void dispose() {
    super.dispose();
    addressController.dispose();
    nameController.dispose();
    cityController.dispose();
    measurementsControllers.forEach((element) {
      element.dispose();
    });
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
              'Register as Customer',
              style: kInputStyle.copyWith(color: Colors.white),
            ).tr(),
          ),
          centerTitle: true,
          actions: [
            if (!phoneNumberVerified && !phoneVerificationSkipped)
              buildSkipPhoneVerificationButton(),
            if (phoneNumberVerified || phoneVerificationSkipped)
              buildClearFormButton(context),
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
                        if (!phoneNumberVerified && !phoneVerificationSkipped)
                          buildPhoneNumberVerificationPage(size),
                        if ((phoneNumberVerified || phoneVerificationSkipped) &&
                            customer == null)
                          buildPersonalInfoColumn(context),
                        if ((phoneNumberVerified || phoneVerificationSkipped) &&
                            customer != null &&
                            (measurementChoiceSelected == false ||
                                measurementsNextButtonPressed == false))
                          buildMeasurementChoiceSelectionPage(size),
                        if ((phoneNumberVerified || phoneVerificationSkipped) &&
                            customer != null &&
                            measurementChoice == MeasurementChoice.online &&
                            measurementChoiceSelected &&
                            measurementsNextButtonPressed)
                          buildAddMeasurementsPage(),
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

  RectangularRoundedButton buildRegisterButton() {
    return RectangularRoundedButton(
      buttonName: 'Register',
      onPressed: onRegisterButtonPressed,
    );
  }

  onRegisterButtonPressed() async {
    bool taskSuccessful = false;
    if (mounted) {
      setState(() {
        isRegisterBtnPressed = true;
      });
    }
    if (formKey.currentState!.validate()) {
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
            showMyBanner(context, getTranslatedText("ٹائم آؤٹ.", "Timed out."));
          }
        }
      });
      customer!.measurements = measurements;
      print('customer: $customer');
      try {
        //inserting customer data
        await FirebaseFirestore.instance
            .collection('customers')
            .add(customer!.toJson())
            .then((doc) {
          customer!.id = doc.id;
          customer!.userDocId = widget.userData.id;
          //update display user name
          FirebaseAuth.instance.currentUser!
              .updateDisplayName(widget.userData.name)
              .then((value) => print('Display name updated.'));
          FirebaseAuth.instance.currentUser!
              .updatePhotoURL(customer!.profileImageUrl)
              .then((value) => print('Display photo url updated.'));
          //updating customer id field
          doc.update(customer!.toJson()).then((value) {
            widget.userData.isRegistered = true;
            if (mounted) {
              setState(() {
                taskSuccessful = true;
              });
            }
            //updating corresponding app user record in users collection
            doc.update(customer!.toJson()).then((value) {
              widget.userData.isRegistered = true;
              widget.userData.customerOrTailorId = doc.id;
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.userData.id)
                  .update(widget.userData.toJson());
              print("customer's user Data updated");
            }).then((value) async {
              if (taskSuccessful) {
                if (widget.fromScreen == Login.id) {
                  //if user comes directly from login screen
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    CustomerMainScreen.id,
                    (Route<dynamic> route) => false,
                  );
                } else {
                  //1 inidicates it was a customer registration & was successful
                  if (mounted) {
                    setState(() {
                      isRegisterBtnPressed = false;
                      isSavingDataInFirebase = false;
                    });
                  }
                  await FirebaseAuth.instance
                      .signOut()
                      .then((value) => SharedPreferences.getInstance().then(
                          (pref) => pref.setBool(Login.isLoggedInText, false)))
                      .then((value) => showMyDialog(
                          context,
                          'Success',
                          getTranslatedText(".کسٹمر رجسٹریشن کامیاب ہوئ",
                              'Customer registration successful.'),
                          isError: false,
                          disposeAfterMillis: 1200));
                  Navigator.pushNamedAndRemoveUntil(
                      context, Login.id, (val) => false);
                }
              }
            });
          });
        });
      } catch (e) {
        print('Exception while saving in customer registration: $e');
      }
      onClearButtonPressed();
      print('Customer data: ${customer!.toJson().toString()}');
    }
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

  Widget buildSkipPhoneVerificationButton() {
    return TextButton(
      onPressed: () => setState(() {
        phoneVerificationSkipped = true;
      }),
      child: Text(
        'skip',
        style: kTextStyle.copyWith(
            color: Colors.white, decoration: TextDecoration.underline),
      ).tr(),
    );
  }

  Column buildPersonalInfoColumn(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
        buildTextFormField(
          getTranslatedText('پتہ', 'address'),
          addressController,
          FontAwesomeIcons.locationDot,
          getTranslatedText('اپنا پتہ درج کریں', 'enter your address'),
          keyboard: TextInputType.streetAddress,
        ),
        SizedBox(height: size.height * 0.015),
        buildTextFormField(
          getTranslatedText('شہر', 'city'),
          cityController,
          FontAwesomeIcons.city,
          getTranslatedText('شہر کا نام درج کریں', 'enter city name'),
          keyboard: TextInputType.name,
        ),
        SizedBox(height: size.height * 0.015),
        buildNextButton(),
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
                  final storageRef = storage
                      .child('${widget.userData.email}/profileImage.png');
                  // final uploadTask = await storageRef.putFile(File(file.path));
                  // final downloadUrl = await uploadTask.ref.getDownloadURL();
                  // FirebaseAuth.instance.currentUser
                  //     ?.updatePhotoURL(downloadUrl)
                  //     .then((value) => print("Photo url updated."));
                  // if (mounted) {
                  //   setState(() {
                  //     profileImageUrl = downloadUrl;
                  //     taskSuccessful = true;
                  //     isUploadingProfileImage = false;
                  //   });
                  // }
                }
              },
      ),
    );
  }

  RectangularRoundedButton buildNextButton() {
    return RectangularRoundedButton(
      buttonName: 'Next',
      onPressed: () async {
        if (mounted) {
          setState(() {
            isNextBtnPressed = true;
            if (formKey.currentState!.validate() &&
                gender != null) {
              // if (profileImageUrl == null ||
              //     profileImageUrl == initialImageUrl) {
              //   showMyDialog(
              //       context,
              //       'Error!',
              //       getTranslatedText(
              //           "پروفائل تصویر شامل کریں", "add a profile picture."),
              //       disposeAfterMillis: 1500);
              //   return;
              // }
              print("Validation successful");
              customer = Customer(
                location: location == null ? UserLocation(longitude: 44.6, latitude: 44.7) : location!,
                city: capitalizeText(cityController.text.trim()),
                name: capitalizeText(nameController.text.trim()),
                email: widget.userData.email,
                gender: gender!,
                // TODO: 03/06/2023 can be commented one
                phoneNumber: phoneNumber, //zeroedPhoneNumber(phoneNumber)
                profileImageUrl: profileImageUrl,
                userDocId: widget.userData.id,
                address: capitalizeText(addressController.text.trim()),
              );
              widget.userData.name = capitalizeText(nameController.text.trim());
              print("customer data: $customer");
              isNextBtnPressed = false;
            }
          });
        }
      },
    );
  }

  Container buildMeasurementChoiceSelectionPage(Size size) {
    return Container(
      margin: EdgeInsets.only(top: size.height * 0.2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Choose Measurement Option.',
            style: kTitleStyle.copyWith(fontSize: 25),
            textAlign: TextAlign.center,
          ).tr(),
          SizedBox(height: size.height * 0.02),
          ...List.generate(
            MeasurementChoice.values.length,
            (index) => RadioListTile<MeasurementChoice>(
              activeColor: kOrangeColor,
              contentPadding: EdgeInsets.symmetric(
                  vertical: size.height * 0.008,
                  horizontal: size.width * 0.008),
              value: MeasurementChoice.values[index],
              groupValue: measurementChoice,
              title: Text(
                capitalizeText(
                    urduMeasurement(MeasurementChoice.values[index].name)),
                style: kInputStyle,
              ),
              subtitle: MeasurementChoice.values[index] != measurementChoice
                  ? null
                  : Text(
                      measurementChoiceSubtitles[index],
                      style: kTextStyle.copyWith(fontSize: 12),
                    ).tr(),
              onChanged: (val) {
                if (mounted) {
                  setState(() {
                    measurementChoice = val;
                    measurementChoiceSelected = true;
                  });
                }
              },
            ),
          ),
          // RadioListTile<MeasurementChoice>(
          //   contentPadding: EdgeInsets.symmetric(
          //       vertical: size.height * 0.008, horizontal: size.width * 0.008),
          //   title: Text(
          //     'Measurements via Agent',
          //     style: kInputStyle.copyWith(locale: context.locale),
          //   ),
          //   subtitle: Text(
          //     'Tailor will send an agent to take measurements.',
          //     style: kTextStyle.copyWith(locale: context.locale, fontSize: 12),
          //   ),
          //   value: MeasurementChoice.viaAgent,
          //   groupValue: measurementChoice,
          //   onChanged: (val) {
          //     setState(() {
          //       measurementChoice = val;
          //       measurementChoiceSelected = true;
          //     });
          //   },
          // ),
          SizedBox(height: size.height * 0.04),
          buildMeasurementsNextButton(size),
        ],
      ),
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
            : () => {
                  setState(() {
                    isVerifyingPhoneNumber = true;
                  }),
                  sendCodeToNumber(setState)
                },
      ),
    );
  }

  IntlPhoneField buildPhoneNumberField(StateSetter setState) {
    return IntlPhoneField(
      readOnly: phoneNumberVerified,
      enabled: !phoneNumberVerified,
      // countries: const ["PK"],
      flagsButtonPadding: const EdgeInsets.all(10),
      onChanged: (number) {
        phoneNumber = number.completeNumber;
        setState(() {});
        // print("complete number: $phoneNumber");
      },
      style: kInputStyle.copyWith(
        locale: context.locale,
      ),
      decoration: kTextFieldDecoration.copyWith(
        suffixIcon: phoneNumberVerified
            ? Icon(Icons.check, color: Colors.green.shade700)
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
          // hintText: hint,
          labelText: hint.substring(
              0, hint.contains(" ") ? hint.indexOf(" ") : hint.length),
          hintStyle: kTextStyle.copyWith(fontSize: 13),
          errorStyle: kTextStyle.copyWith(color: Colors.red),
        ),
        keyboardType: keyboard,
      ),
    );
  }

  void sendCodeToNumber(StateSetter setStatee) async {
    final overallContext = context;
    final pincodeController = TextEditingController();
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(minutes: 2),
      verificationCompleted: (userCredential) {
        print("verification auto completed");
      },
      verificationFailed: (e) {
        showMyDialog(context, e.code, e.message ?? 'Error!');
      },
      codeSent: (verId, codeSent) async {
        print("Code sent: $codeSent");
        showMyBanner(
            context,
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
                                pinTextStyle: kInputStyle.copyWith(
                                    locale: context.locale),
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
                                showMyBanner(
                                    overallContext,
                                    getTranslatedText("تصدیق کامیاب ہوئی.",
                                        'Verification successful.'));
                                setPhoneStatusVerified();
                                Future.delayed(const Duration(seconds: 1))
                                    .then((value) => Navigator.pop(context));
                              } on FirebaseAuthException catch (e) {
                                print('Exception : ${e.code}');
                                if (e.code == "credential-already-in-use") {
                                  setStatee(() {
                                    phoneNumber = "";
                                  });
                                  showMyDialog(
                                          context,
                                          getTranslatedText(
                                              'غلطی: ', 'Error: '),
                                          getTranslatedText(
                                              'یہ فون نمبر پہلے ہی استعمال میں ہے۔',
                                              'phone number is already in use.'))
                                      .then((value) =>
                                          Navigator.of(context).pop());
                                } else {
                                  showMyBanner(
                                      overallContext,
                                      getTranslatedText('غلطی: ${e.code}',
                                          'Error: ${e.code}'));
                                }
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
        print("Timout printed: ");
      },
    );
    if (isVerifyingPhoneNumber) {
      setStatee(() {
        isVerifyingPhoneNumber = false;
      });
    }
  }

  void onClearButtonPressed() {
    setState(() {
      isNextBtnPressed = false;
      gender = null;
      measurementChoice = null;
      profileImageUrl = initialImageUrl;
      addressController.clear();
      cityController.clear();
      nameController.clear();
      measurementsControllers.forEach((element) {
        element.clear();
      });
      formKey.currentState?.reset();
    });
  }

  Widget buildAddMeasurementsPage() {
    Size size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: size.width * 0.01,
        ),
        Text(
          'Add Measurements',
          textAlign: TextAlign.center,
          style: kTitleStyle.copyWith(fontSize: 30),
        ).tr(),
        SizedBox(
          height: size.width * 0.01,
        ),
        Text(
          "You can skip field(s) that you don't have measurements of, for now.",
          textAlign: TextAlign.center,
          style: kTitleStyle.copyWith(fontSize: 12, color: Colors.grey),
        ).tr(),
        SizedBox(
          height: size.width * 0.02,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(
            measurements.length,
            (i) => Container(
              margin: EdgeInsets.symmetric(
                  horizontal: 2, vertical: size.height * 0.02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: size.width * 0.4,
                    height: size.height * 0.1,
                    child: Align(
                        alignment: isUrduActivated
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.asset(
                                totalMeasurements.values.elementAt(i)))),
                  ),
                  const SizedBox(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          capitalizeText(
                            spaceSeparatedText(
                                totalMeasurements.keys.elementAt(i)),
                          ),
                          style: kInputStyle,
                        ).tr(),
                      ),
                      SizedBox(height: size.height * 0.01),
                      RateInputField(
                        onChanged: (val) {
                          if (val != null && val.isNotEmpty) {
                            try {
                              measurements[i].measure = double.parse(val);
                              if (mounted) setState(() {});
                            } catch (e) {
                              print('Exception parsing :$e');
                            }
                          }
                        },
                        suffixText: getTranslatedText("انچ", "in"),
                        validateField: false,
                        controller: measurementsControllers[i],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: size.width * 0.02),
        buildRegisterButton(),
      ],
    );
  }

  Widget buildMeasurementsNextButton(Size size) {
    return RectangularRoundedButton(
      buttonName: 'Next',
      onPressed: () async {
        if (!measurementChoiceSelected) {
          showMyDialog(
              context,
              'Error!',
              getTranslatedText(
                  "پیمائش کا آپشن منتخب کریں۔", "choose a measurement option."),
              disposeAfterMillis: 1500);
          return;
        } else {
          measurementsNextButtonPressed = true;
          customer!.measurementChoice = measurementChoice!;
          if (mounted) {
            setState(() {});
          }
          if (measurementChoice != MeasurementChoice.online) {
            onRegisterButtonPressed();
          }
        }
        print("updated customer data: $customer");
        print("Measurement button pressed.");
      },
    );
  }

  void setPhoneStatusVerified() {
    setState(() {
      phoneNumberVerified = true;
      phoneVerificationSkipped = true;
    });
  }
}
