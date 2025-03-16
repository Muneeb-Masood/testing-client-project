import 'package:test/models/customer.dart';
import 'package:test/models/measurement.dart';
import 'package:test/networking/api_helper.dart';
import 'package:test/screens/customer/customer_dresses_page.dart';
import 'package:test/screens/customer/customer_edit_profile.dart';
import 'package:test/screens/customer/customer_main_screen.dart';
import 'package:test/screens/customer/customer_measurements_page.dart';
import 'package:test/utilities/constants.dart';
import 'package:test/utilities/custom_widgets/rectangular_button.dart';
import 'package:test/utilities/my_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../login.dart';
import '../tailor/tailor_main_screen.dart';

class CustomerProfile extends StatefulWidget {
  const CustomerProfile({Key? key, this.customer}) : super(key: key);
  final Customer? customer;
  @override
  State<CustomerProfile> createState() => _CustomerProfileState();
}

class _CustomerProfileState extends State<CustomerProfile> {
  //if a tailor has clicked customers profile to view it
  bool isTailorView = false;
  Customer? customer = currentCustomer;
  @override
  void initState() {
    super.initState();
    if (mounted) {
      setState(() {
        isTailorView = widget.customer != null;
        if (widget.customer != null) {
          customer = widget.customer;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isTailorView) buildTopRow(),
                buildProfileColumn(size),
                SizedBox(height: size.height * 0.02),
                buildAddressCard(),
                SizedBox(height: size.height * 0.01),
                buildContactCard(),
                SizedBox(height: size.height * 0.01),
                buildMeasurementsCard(size),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAddressCard() {
    return Card(
      color: kLightSkinColor,
      elevation: 1.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${isTailorView ? "" : getTranslatedText("میرے ", "My ")}${getTranslatedText("پتے کی معلومات", "Address")}.',
              style: kInputStyle.copyWith(color: Colors.grey),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildHorizontalCardItem(
                  'address: ',
                  '${customer!.address}.',
                  translateSecondText: true,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                buildHorizontalCardItem(
                  'city: ',
                  '${customer!.city}.',
                  translateSecondText: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildContactCard() {
    return Card(
      color: kLightSkinColor,
      elevation: 1.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${isTailorView ? "" : getTranslatedText("میرے ", "my ")}${getTranslatedText("رابطے کی معلومات", "contact")}.',
              style: kInputStyle.copyWith(color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildHorizontalCardItem(
                    'phone: ',
                    zeroedPhoneNumber(customer!.phoneNumber),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  buildHorizontalCardItem(
                    'email: ',
                    customer!.email,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMeasurementsCard(size) {
    return Card(
      color: kLightSkinColor,
      elevation: 1.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${isTailorView ? "" : getTranslatedText("میری ", "my ")}${getTranslatedText("پیمائش", "measurements")}.',
              style: kInputStyle.copyWith(color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!isTailorView)
                    buildHorizontalCardItem(
                      'Submission choice: ',
                      urduMeasurement(customer!.measurementChoice.name),
                    ),
                  SizedBox(height: size.height * 0.01),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                    child: buildNavigationalButton(
                      text:
                          '${isTailorView ? getTranslatedText("دیکھیں ", "view ") : getTranslatedText("میری ", "my ")}${getTranslatedText("پیمائش", "measurements")}',
                      onPressed: () {
                        print('My measures');
                        if (customer!.measurementChoice ==
                            MeasurementChoice.online) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CustomerMeasurementsPage(
                                customer: customer!,
                                isTailorView: isTailorView,
                              ),
                            ),
                          );
                        } else {
                          showMyDialog(
                              context,
                              "Error!",
                              getTranslatedText(
                                "پیمائش دیکھنے کے لئے جمع کرنے کا انتخاب آن لائن ہونا ضروری ہے۔",
                                "Submission choice must be online to view measurements.",
                              ),
                              disposeAfterMillis: 2000);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column buildProfileColumn(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildProfileImage(size),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Text(
          customer!.name,
          style: kTitleStyle.copyWith(fontSize: 20),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        if (!isTailorView)
          buildNavigationalButton(
            text: getTranslatedText("میری ڈریسِس", 'My Dresses'),
            onPressed: () {
              print('My dresses');
              navigateToScreen(const CustomerDressesPage());
            },
          ),
      ],
    );
  }

  Widget buildNavigationalButton(
      {required String text, required VoidCallback onPressed}) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width * 0.6,
      height: size.height * 0.05,
      child: RectangularRoundedButton(
        translateText: false,
        padding: EdgeInsets.zero,
        buttonName: text,
        onPressed: onPressed,
      ),
    );
  }

  Center buildProfileImage(Size size) {
    return Center(
      child: GestureDetector(
        onTap: () {
          final decoration = BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            image: DecorationImage(
              image: NetworkImage(customer!.profileImageUrl!),
              fit: BoxFit.fill,
            ),
          );
          showDialog(
            context: context,
            builder: (context) => Container(
              margin: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.15,
                horizontal: MediaQuery.of(context).size.width * 0.04,
              ),
              decoration: decoration.copyWith(),
            ),
          );
        },
        child: CircleAvatar(
          radius: size.width * 0.2,
          backgroundColor: Colors.blue,
          child: CircleAvatar(
            backgroundImage: NetworkImage(customer!.profileImageUrl!),
            backgroundColor: Colors.white,
            radius: size.width * 0.2 - 1,
          ),
        ),
      ),
    );
  }

  TextButton buildTopRow() {
    return TextButton(
      onPressed: () {
        navigateToScreen(const CustomerEditProfile());
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(FontAwesomeIcons.userPen, size: 15),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  'Edit',
                  style: reminderButtonStyle,
                ).tr(),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              FontAwesomeIcons.arrowRightFromBracket,
              // color: Colors.blue,
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              currentTailor = null;
              currentCustomer = null;
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool(Login.isLoggedInText, false);
              Navigator.pushReplacementNamed(context, Login.id);
            },
          )
        ],
      ),
    );
  }

  Row buildHorizontalCardItem(String firstItemText, String secondItemText,
      {bool translateSecondText = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          firstItemText,
          style: kInputStyle,
        ).tr(),
        SizedBox(width: MediaQuery.of(context).size.width * 0.01),
        Flexible(
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

  void navigateToScreen(Widget screen) {
    Navigator.push(
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
}
