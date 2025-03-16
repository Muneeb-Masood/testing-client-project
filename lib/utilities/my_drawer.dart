import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:test/main.dart';
import 'package:test/models/app_user.dart';
import 'package:test/screens/customer/customer_main_screen.dart';
import 'package:test/screens/login.dart';
import 'package:test/utilities/confirmation_dialog.dart';
import 'package:test/utilities/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/src/flutter_zoom_drawer.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../networking/firestore_helper.dart';
import '../screens/customer/customer_dresses_page.dart';
import '../screens/customer/customer_measurements_page.dart';
import '../screens/tailor/tailor_main_screen.dart';
import 'custom_widgets/rectangular_button.dart';

class MyDrawer extends StatefulWidget {
  final Widget mainScreen;
  final ZoomDrawerController controller;
  //used to setstate specially when urdu is changed
  final VoidCallback onBack;
  final AppUser userData;
  const MyDrawer(
      {Key? key,
      required this.mainScreen,
      required this.controller,
      required this.userData,
      required this.onBack})
      : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  String? language;
  //used fpr delete purpse currently
  bool isLoading = false;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 20)).then((value) {
      switch (context.locale.languageCode.toLowerCase()) {
        case "en":
          language = "English";
          break;
        case "ur":
          language = "اردو";
          break;
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      progressIndicator: kSpinner(context),
      child: ZoomDrawer(
        menuBackgroundColor: kSkinColor,
        controller: widget.controller,
        menuScreen: buildDrawerContent(),
        mainScreen: widget.mainScreen,
        borderRadius: 24.0,
        // showShadow: true,
        angle: 0,
        drawerShadowsBackgroundColor: Colors.grey.shade300,
        slideWidth: MediaQuery.of(context).size.width * 0.71,
        menuScreenWidth: MediaQuery.of(context).size.width * 0.7,
        isRtl: isUrduActivated,
        androidCloseOnBackTap: true,
        moveMenuScreen: false,
      ),
    );
  }

  buildDrawerContent() {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: kOrangeColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: size.width * 0.002),
          child: DefaultTextStyle(
            style: kInputStyle,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: size.height * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: size.width * 0.13,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                backgroundImage: (FirebaseAuth
                                            .instance.currentUser?.photoURL !=
                                        null
                                    ? NetworkImage(FirebaseAuth
                                        .instance.currentUser!.photoURL!)
                                    : const AssetImage(
                                        'assets/user.png')) as ImageProvider,
                                backgroundColor: Colors.grey.shade300,
                                radius: size.width * 0.13 - 1,
                              ),
                            ),
                            SizedBox(
                              width: size.width * 0.30,
                              height: size.height * 0.05,
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: AnimatedToggleSwitch<String>.size(
                                  current: language ??
                                      (context.locale ==
                                              const Locale("ur", "PK")
                                          ? "English"
                                          : "اردو"),
                                  values: const ["English", "اردو"],
                                  // indicatorColor: Colors.white,
                                  // indicatorBorderRadius:
                                      // BorderRadius.circular(5),
                                  // borderColor: Colors.white,
                                  borderWidth: 1,
                                  // innerColor: Colors.transparent,
                                  iconOpacity: 1,
                                  iconBuilder: (value){
                                     return Center(
                                      child: Text(
                                        value,
                                        style: kInputStyle.copyWith(
                                          fontSize: language == value ? 12 : 12,
                                          color: language == value
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                      ),);
                                  },
                                  // iconBuilder: (value, size) {
                                  //   return Center(
                                  //     child: Text(
                                  //       value,
                                  //       style: kInputStyle.copyWith(
                                  //         fontSize: language == value ? 12 : 12,
                                  //         color: language == value
                                  //             ? Colors.black
                                  //             : Colors.white,
                                  //       ),
                                  //     ),
                                  //   );
                                  // },
                                  onChanged: onLanguageChanged,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // SizedBox(height: size.height * 0.01),
                        SizedBox(height: size.height * 0.008),
                        translatedTextWidget(
                          widget.userData.name,
                          style: kInputStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                              letterSpacing: 0.5),
                        ),
                        SizedBox(height: size.height * 0.01),
                      ],
                    ),
                  ),
                  const Divider(
                    color: Colors.white,
                  ),
                  buildDrawerItem(
                    'Back',
                    isUrduActivated
                        ? FontAwesomeIcons.arrowRight
                        : FontAwesomeIcons.arrowLeft,
                    onTap: () {
                      widget.controller.close!.call();
                    },
                  ),
                  // if (currentCustomer != null)
                  if (!widget.userData.isTailor)
                    buildDrawerItem(
                      'My dresses',
                      FontAwesomeIcons.personHalfDress,
                      onTap: () {
                        navigateToScreen(const CustomerDressesPage());
                        widget.controller.close!.call();
                      },
                    ),
                  //or
                  if (!widget.userData.isTailor)
                    // if (currentCustomer != null)
                    buildDrawerItem(
                      'My measurements',
                      FontAwesomeIcons.rulerHorizontal,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CustomerMeasurementsPage(
                              customer: currentCustomer!,
                              isTailorView: false,
                            ),
                          ),
                        );
                        widget.controller.close!.call();
                      },
                    ),
                  buildDrawerItem(
                    'Rate us',
                    FontAwesomeIcons.star,
                    onTap: () {
                      widget.controller.close!.call();
                    },
                  ),
                  buildDrawerItem(
                    'Delete account',
                    Icons.delete_outline,
                    isDelete: true,
                    onTap: () async {
                      final c = context;
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ConfirmationDialog(
                            onConfirm: () async {
                              final user = FirebaseAuth.instance.currentUser!;
                              final password =
                                  await showPasswordInputDialog(context);
                              //that means delete operation was cancelled
                              if (password == null) return;
                              AuthCredential credential =
                                  EmailAuthProvider.credential(
                                email: user.email!,
                                password: password,
                              );
                              try {
                                await FirebaseAuth.instance.currentUser!
                                    .reauthenticateWithCredential(credential);
                              } catch (e) {
                                //any exception would be caught like network problem
                                //password wrong
                                print("Msla: $e");
                                Fluttertoast.showToast(
                                  msg: getTranslatedText(
                                      "کچھ غلطی ہوئی! نئے لاگ ان کی ضرورت ہے.",
                                      "Some error occurred! new login required."),
                                  textColor: Colors.white,
                                  backgroundColor: kOrangeColor,
                                );
                                return;
                              }
                              setState(() {
                                isLoading = true;
                              });
                              Future.delayed(const Duration(seconds: 15))
                                  .then((value) {
                                if (mounted && isLoading) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              });
                              bool done = await FireStoreHelper().deleteAccount(
                                  widget.userData.customerOrTailorId!,
                                  widget.userData.isTailor);
                              if (done) {
                                deleteUserDirectory(widget.userData.email);
                              }
                              currentTailor = null;
                              currentCustomer = null;
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              prefs.setBool(Login.isLoggedInText, false);
                              setState(() {
                                isLoading = false;
                              });
                              widget.controller.close!();
                              Navigator.pushReplacementNamed(c, Login.id);
                            },
                            confirmText: "Are you sure you want to delete?",
                          );
                        },
                      );
                    },
                  ),
                  buildDrawerItem(
                    'Logout',
                    FontAwesomeIcons.arrowRightFromBracket,
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      currentTailor = null;
                      currentCustomer = null;
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setBool(Login.isLoggedInText, false);
                      Navigator.pushReplacementNamed(context, Login.id);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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

  ListTile buildDrawerItem(String title, IconData icon,
      {required VoidCallback onTap, bool isDelete = false}) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
      ),
      onTap: onTap,
      title: Text(
        title,
        style: kInputStyle.copyWith(
          color: Colors.white,
        ),
      ).tr(),
    );
  }

  onLanguageChanged(val) async {
    if (mounted) {
      setState(() {
        language = val;
        if (language == "English") {
          isUrduActivated = false;
        } else {
          isUrduActivated = true;
        }
      });
      widget.onBack();
    }
    await context.setLocale(language == "English"
        ? const Locale("en", "US")
        : const Locale("ur", "PK"));
    if (mounted) {
      setState(() {});
    }
  }

  ///deletes user directory from storage bucket
  Future<void> deleteUserDirectory(String folderPath) async {
    final storage = FirebaseStorage.instance;
    final ListResult listResult =
        await storage.ref().child(folderPath).listAll();

    final List<Future<void>> deleteFutures = [];

    for (final item in listResult.items) {
      deleteFutures.add(item.delete());
    }
    // Wait for all files to be deleted
    await Future.wait(deleteFutures);

    // Delete the empty folder
    // await storage.ref().child(folderPath).delete();
    print('storage bucket deleted too.');
  }

  Future<String?> showPasswordInputDialog(BuildContext context) async {
    String? password = '';
    final formKey = GlobalKey<FormState>();
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              getTranslatedText('اپنا پاس ورڈ درج کریں', "Enter your password"),
              style: kInputStyle,
            ),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return getTranslatedText(
                          'اپنا پاس ورڈ درج کریں', "Enter your password");
                    }
                    if (val.length < 6) {
                      return getTranslatedText(
                          'پاس ورڈ کی لمبائی 6 سے کم نہیں ہوسکتی',
                          "password length can't be less than 6");
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: getTranslatedText('پاس ورڈ', 'Password'),
                    labelStyle: kTextStyle,
                  ),
                  obscureText: true,
                  style: kInputStyle,
                  onChanged: (value) {
                    password = value;
                  },
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.045,
              width: MediaQuery.of(context).size.width * 0.3,
              child: RectangularRoundedButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    debugPrint('password: $password');
                    Navigator.of(context).pop(); // Close the dialog
                  }
                },
                buttonName: 'Done',
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.046,
                child: RectangularRoundedButton(
                  fontSize: isUrduActivated ? 13 : 17,
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    password = null;
                  },
                  buttonName: 'Cancel delete',
                ),
              ),
            ),
          ],
        );
      },
    );
    return password;
  }

  void openPlayStore() async {
    final url = Uri.parse(
        'https://play.google.com/store/apps/details?id=com.your_app_package_name');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      print('Could not launch $url');
    }
  }
}
