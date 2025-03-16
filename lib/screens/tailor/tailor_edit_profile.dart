import 'dart:io';

import 'package:test/main.dart';
import 'package:test/networking/firestore_helper.dart';
import 'package:test/screens/customer/customer_main_screen.dart';
import 'package:test/screens/tailor/tailor_main_screen.dart';
import 'package:test/utilities/constants.dart';
import 'package:test/utilities/custom_widgets/rectangular_button.dart';
import 'package:test/utilities/my_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/cli_commands.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:test/extensions/capitalization.dart';

class TailorEditProfile extends StatefulWidget {
  const TailorEditProfile({Key? key}) : super(key: key);

  @override
  State<TailorEditProfile> createState() => _TailorEditProfileState();
}

class _TailorEditProfileState extends State<TailorEditProfile> {
  final formKey = GlobalKey<FormState>();
  final addressController =
      TextEditingController(text: currentTailor!.shop!.address);
  final nameController = TextEditingController(text: currentTailor!.tailorName);
  final cityController = TextEditingController(text: currentTailor!.shop!.city);
  final phoneNoController = TextEditingController(
    text: currentTailor!.phoneNumber?.substring(3),
  );
  bool isUpdatingData = false;
  String phoneNumber = currentTailor!.phoneNumber ?? "";
  String? image1 = currentTailor!.shop!.shopImage1Url;
  String? image2 = currentTailor!.shop!.shopImage2Url;
  String? profileImg = currentTailor!.profileImageUrl;

  final shopNameController =
      TextEditingController(text: currentTailor!.shop!.name);
  final postalCodeController =
      TextEditingController(text: currentTailor!.shop!.postalCode.toString());

  final picker = ImagePicker();
  final viaAgentChargesController = TextEditingController(
      text: currentTailor!.shop!.viaAgentCharges.toString());

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
    shopNameController.addListener(() {
      if (mounted) setState(() {});
    });
    postalCodeController.addListener(() {
      if (mounted) setState(() {});
    });
    viaAgentChargesController.addListener(() {
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
    shopNameController.dispose();
    postalCodeController.dispose();
    viaAgentChargesController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      progressIndicator: kSpinner(context),
      isLoading: isUpdatingData,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: SafeArea(
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Align(
                    alignment: isUrduActivated
                        ? Alignment.topRight
                        : Alignment.topLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        isUrduActivated
                            ? FontAwesomeIcons.arrowRight
                            : FontAwesomeIcons.arrowLeft,
                        color: kOrangeColor,
                      ),
                    ),
                  ),
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
        Align(alignment: Alignment.center, child: buildProfilePicture(size)),
        SizedBox(height: size.width * 0.005),
        buildChangeProfileImageButton(size),
        SizedBox(height: size.width * 0.02),
        buildTextFormField(isUrduActivated ? 'نام' : 'name', nameController,
            null, isUrduActivated ? 'اپنا نام درج کریں' : "Enter your name",
            keyboard: TextInputType.name),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.0),
          child: Divider(thickness: 0.7),
        ),
        SizedBox(height: size.height * 0.015),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'Shop Info.',
            style: kTextStyle,
          ).tr(),
        ),
        SizedBox(height: size.height * 0.025),
        buildTextFormField(isUrduActivated ? 'نام' : 'name', shopNameController,
            null, isUrduActivated ? 'اپنا نام درج کریں' : "Enter shop name",
            keyboard: TextInputType.name),
        SizedBox(height: size.height * 0.015),
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
        buildTextFormField(
          isUrduActivated ? 'پوسٹل کوڈ' : 'postal code',
          postalCodeController,
          FontAwesomeIcons.code,
          isUrduActivated ? 'پوسٹل کوڈ درج کریں' : 'enter postal code',
          keyboard: TextInputType.number,
        ),
        SizedBox(height: size.height * 0.015),
        buildTextFormField(
          isUrduActivated ? 'ایجنٹ آپشن کے چارجز' : 'charges via agent',
          viaAgentChargesController,
          FontAwesomeIcons.rupeeSign,
          isUrduActivated
              ? 'ایجنٹ آپشن کے چارجز درج کریں'
              : 'enter via agent charges',
          keyboard: TextInputType.number,
        ),
        SizedBox(height: size.height * 0.015),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'shop images:',
                style: kTextStyle,
              ).tr(),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildShopImageItem(image1, 1),
                SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                buildShopImageItem(image2, 2)
              ],
            ),
          ],
        ),
        SizedBox(height: size.height * 0.015),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'Contact Info.',
            style: kTextStyle,
          ).tr(),
        ),
        SizedBox(height: size.height * 0.02),
        buildPhoneNumberField(),
        SizedBox(height: size.height * 0.015),
        buildUpdateButton(),
        SizedBox(height: size.height * 0.025),
      ],
    );
  }

  Widget buildShopImageItem(String? url, int imageNo) {
    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(10.0),
      image: DecorationImage(
        image: (url != null
            ? url.contains('/data/')
                ? FileImage(File(url))
                : NetworkImage(url)
            : const AssetImage('assets/uploadImage.jpg')) as ImageProvider,
        fit: BoxFit.fill,
      ),
    );
    return InkWell(
      onTap: () async {
        if (url == null) {
          final file = await picker.pickImage(source: ImageSource.gallery);
          if (file != null) {
            if (imageNo == 1) {
              image1 = file.path;
            } else {
              image2 = file.path;
            }
            if (mounted) {
              setState(() {});
            }
          }
        } else {
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
                        heroTag: url, //?? 'myVal$imageNo',
                        key: Key(url), //?? 'myVal$imageNo'),
                        isExtended: false,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.close),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
      child: Stack(
        fit: StackFit.loose,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.32,
            height: MediaQuery.of(context).size.height * 0.16,
            decoration: decoration,
          ),
          if (url != null)
            Positioned(
              right: MediaQuery.of(context).size.height * 0.006,
              top: -MediaQuery.of(context).size.height * 0.015,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.06,
                child: FloatingActionButton(
                  backgroundColor: Colors.white,
                  key: Key('image$imageNo'),
                  heroTag: 'image$imageNo',
                  onPressed: () {
                    if (imageNo == 1) {
                      image1 = null;
                    } else {
                      image2 = null;
                    }
                    if (mounted) setState(() {});
                  },
                  mini: true,
                  child: Icon(
                    Icons.close,
                    size: MediaQuery.of(context).size.width * 0.05,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildProfilePicture(Size size) {
    return CircleAvatar(
      radius: size.width * 0.25,
      backgroundColor: kOrangeColor,
      child: Center(
        child: CircleAvatar(
          radius: size.width * 0.247,
          backgroundColor: kLightSkinColor,
          // isUploadingProfileImage ? Colors.white54 :
          backgroundImage: (profileImg != null
              ? profileImg!.contains('/data/')
                  ? FileImage(File(profileImg!))
                  : NetworkImage(profileImg!)
              : const AssetImage('assets/uploadImage.jpg')) as ImageProvider,
        ),
      ),
    );
  }

  Widget buildChangeProfileImageButton(Size size) {
    return Container(
      height: size.height * 0.045,
      margin: EdgeInsets.symmetric(
          horizontal: size.width * 0.3, vertical: size.height * 0.002),
      child: RectangularRoundedButton(
        padding: EdgeInsets.zero,
        fontSize: 15,
        buttonName: "Change",
        color: kOrangeColor,
        onPressed: () async {
          final file =
              await ImagePicker().pickImage(source: ImageSource.gallery);
          if (file != null) {
            profileImg = file.path;
            if (mounted) {
              setState(() {
                // isUploadingProfileImage = true;
              });
            }
          }
        },
      ),
    );
  }

  Future<String> uploadImageToFirestore(
      String localPath, String firebaseName) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('${currentTailor!.email}/$firebaseName.png');
    final uploadTask = await storageRef.putFile(File(localPath));
    print('$firebaseName uploaded.');
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    return downloadUrl;
  }

  Widget buildUpdateButton() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.1),
      child: RectangularRoundedButton(
        padding: const EdgeInsets.symmetric(vertical: 2),
        buttonName: 'Update',
        color: isSameData() ? Colors.grey : kOrangeColor,
        onPressed: isSameData() ? () {} : onUpdateButtonPressed,
      ),
    );
  }

  bool isSameData() {
    bool isSame = false;
    final sameName = nameController.text.trim().toLowerCase() ==
        currentTailor!.tailorName.toLowerCase();
    final sameShopAddress = addressController.text.trim().toLowerCase() ==
        currentTailor!.shop!.address.toLowerCase();
    final sameCity = cityController.text.trim().toLowerCase() ==
        currentTailor!.shop!.city.toLowerCase();
    final samePhone = phoneNumber == currentTailor!.phoneNumber;
    final sameShopName = shopNameController.text.trim().toLowerCase() ==
        currentTailor!.shop!.name.toLowerCase();
    final samePostalCode = postalCodeController.text.trim().toLowerCase() ==
        currentTailor!.shop!.postalCode.toString().toLowerCase();
    final sameShopImages = image1 == currentTailor!.shop!.shopImage1Url &&
        image2 == currentTailor!.shop!.shopImage2Url;
    final sameProfile = profileImg == currentTailor!.profileImageUrl;
    final sameViaAgnetCharges = viaAgentChargesController.text.trim() ==
        currentTailor!.shop!.viaAgentCharges.toString();
    if (sameName &&
        sameProfile &&
        sameShopAddress &&
        sameCity &&
        samePhone &&
        samePostalCode &&
        sameShopImages &&
        sameShopName &&
        sameViaAgnetCharges) {
      isSame = true;
    }
    return isSame;
  }

  onUpdateButtonPressed() async {
    bool taskSuccessful = false;
    if (isSameData()) {
      showMyBanner(context, 'Nothing updated.');
      return;
    }
    if (profileImg == null) {
      showMyDialog(context, 'Error!', 'Add a profile image.');
      return;
    }
    if (image1 == null || image2 == null) {
      showMyDialog(context, 'Error!', 'Add shop images.');
      return;
    }
    if (formKey.currentState!.validate()) {
      currentTailor!.shop!.address = capitalizeText(addressController.text.trim());
      currentTailor!.shop!.city = capitalizeText(cityController.text.trim());
      currentTailor!.phoneNumber = phoneNumber;
      currentTailor!.shop!.viaAgentCharges =
          int.parse(viaAgentChargesController.text.trim());
      currentTailor!.shop!.name =
          capitalizeText(shopNameController.text.trim());
      try {
        currentTailor!.shop!.postalCode =
            int.parse(postalCodeController.text.trim());
      } catch (e) {
        showMyDialog(context, 'Error!', e.toString());
        return;
      }
      if (mounted) {
        setState(() {
          isUpdatingData = true;
        });
      }
      if (image1 != currentTailor!.shop!.shopImage1Url) {
        final url = await uploadImageToFirestore(image1!, 'shopImage1');
        currentTailor!.shop!.shopImage1Url = url;
      }
      if (image2 != currentTailor!.shop!.shopImage2Url) {
        final url = await uploadImageToFirestore(image2!, 'shopImage2');
        currentTailor!.shop!.shopImage2Url = url;
      }
      //62 seconds as timeout
      Future.delayed(const Duration(seconds: 60, milliseconds: 2000))
          .then((value) {
        if (mounted && isUpdatingData) {
          setState(() => isUpdatingData = false);
          if (!taskSuccessful) showMyBanner(context, 'Timed out.');
        }
      });
      // print('customer: $currentCustomer');
      try {
        //inserting tailor data
        //if tailor's name updated then update firebase user's name & corresponding app user's name
        if (nameController.text.trim().toLowerCase() !=
            currentTailor!.tailorName.toLowerCase()) {
          currentTailor!.tailorName =
              capitalizeText(nameController.text.trim());
          FirebaseAuth.instance.currentUser!
              .updateDisplayName(currentTailor!.tailorName)
              .then((value) => print('Display name updated.'));
          final appUserData = await FireStoreHelper()
              .getAppUserWithDocId(currentTailor!.userDocId!);
          appUserData!.name = currentCustomer!.name;
          FireStoreHelper().updateAppUser(appUserData);
          print("corresponding app user Data updated.");
        }
        //if tailor's dp updated then update firebase user's dp
        if (profileImg != currentTailor!.profileImageUrl) {
          final url = await uploadImageToFirestore(profileImg!, 'profileImage');
          currentTailor!.profileImageUrl = url;
          FirebaseAuth.instance.currentUser!
              .updatePhotoURL(currentTailor!.profileImageUrl)
              .then((value) => print('Display photo url updated.'));
        }
        await FireStoreHelper().updateTailor(currentTailor!).then((val) async {
          //updating tailor id field
          if (mounted) {
            setState(() {
              taskSuccessful = val;
              isUpdatingData = false;
            });
          }
          //updating corresponding app user record in users collection
          print("tailor's user Data updated");
          Fluttertoast.showToast(
            msg: 'Profile updated',
            textColor: Colors.white,
            backgroundColor: kOrangeColor,
          );
          Navigator.pop(context);
        });
      } catch (e) {
        print('Exception while updating customer data: $e');
      }
    } else {}
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
          hintText: hint,
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
        style: kInputStyle.copyWith(
          locale: context.locale,
        ),
        keyboardType: TextInputType.phone,
        onChanged: (phone) {
          if (mounted) {
            setState(() {
              phoneNumber = phone.completeNumber;
            });
          }
          // print('Phone#: $phoneNumber');
        },
        initialCountryCode: 'PK',
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
