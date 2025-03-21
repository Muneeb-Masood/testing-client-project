import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test/main.dart';
import 'package:test/screens/customer/customer_main_screen.dart';
import 'package:test/screens/tailor/tailor_main_screen.dart';
import 'package:test/utilities/constants.dart';
import 'package:test/utilities/my_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_zoom_drawer/config.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import '../utilities/custom_widgets/rectangular_button.dart';
import 'customer/customer_registration.dart';
import 'forgot_password.dart';
import 'sign_up.dart';
import 'tailor/tailor_registration.dart';

class Login extends StatefulWidget {
  static const String isLoggedInText = "isLoggedIn";
  static const String id = '/login';
  const Login({Key? key}) : super(key: key);
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String email = '';
  String password = '';
  bool rememberMe = false;
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final controller = ZoomDrawerController();
  String language = "English";

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 15)).then((value) {
      if (mounted) setState(() {});
    });
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
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  clearText() {
    emailController.clear();
    passwordController.clear();
    setState(() {});
  }

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return LoadingOverlay(
      progressIndicator: kSpinner(context),
      isLoading: isLoading,
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.05,
                    vertical: size.height * 0.01),
                child: SingleChildScrollView(
                  child: AutofillGroup(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                              height: MediaQuery.of(context).size.width * 0.2),
                          Text(
                            'DressSew',
                            style: kTitleStyle.copyWith(color: kOrangeColor),
                          ).tr(),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'your dress on time.',
                              style: kTextStyle.copyWith(color: kOrangeColor),
                            ).tr(),
                          ),
                          SizedBox(
                            height: size.height * 0.08,
                          ),
                          TextFormField(
                            autofillHints: const [AutofillHints.email],
                            style: kInputStyle,
                            controller: emailController,
                            onChanged: (value) {
                              email = value.trim();
                            },
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return getTranslatedText(
                                    'اپنا ای میل درج کریں', "Enter your email");
                              }
                              if (!EmailValidator.validate(val.trim())) {
                                return getTranslatedText(
                                    'ایک درست ای میل درج کریں',
                                    "Enter a valid email address");
                              }
                              return null;
                            },
                            decoration: kTextFieldDecoration.copyWith(
                              prefixIcon: IconTheme(
                                  data: IconThemeData(color: kOrangeColor),
                                  child: Icon(
                                    Icons.email,
                                    size: 22,
                                  )),
                              hintText: getTranslatedText('ای میل', 'Email'),
                              hintStyle: kTextStyle,
                              errorStyle:
                                  kTextStyle.copyWith(color: Colors.redAccent),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          TextFormField(
                            autofillHints: const [AutofillHints.password],
                            controller: passwordController,
                            style: kInputStyle,
                            onChanged: (value) {
                              password = value;
                            },
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return getTranslatedText(
                                    'اپنا پاس ورڈ درج کریں',
                                    "Enter your password");
                              }
                              if (val.length < 6) {
                                return getTranslatedText(
                                    'پاس ورڈ کی لمبائی 6 سے کم نہیں ہوسکتی',
                                    "password length can't be less than 6");
                              }
                              return null;
                            },
                            decoration: kTextFieldDecoration.copyWith(
                              prefixIcon: IconTheme(
                                  data: IconThemeData(color: kOrangeColor),
                                  child:
                                      Icon(CupertinoIcons.lock_fill, size: 22)),
                              hintText:
                                  getTranslatedText('پاس ورڈ', "Password"),
                              hintStyle: kTextStyle,
                              errorStyle:
                                  kTextStyle.copyWith(color: Colors.redAccent),
                            ),
                            obscureText: true,
                          ),
                          Align(
                            alignment: isUrduActivated
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                clearText();
                                Navigator.pushNamed(context, ForgotPassword.id);
                              },
                              child: Text(
                                'Forgot password?',
                                style: reminderButtonStyle.copyWith(
                                    fontFamily: 'Courier'),
                              ).tr(),
                            ),
                          ),
                          SizedBox(
                            height: size.height * 0.04,
                          ),
                          RectangularRoundedButton(
                            buttonName: 'Login',
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                bool successful = false;
                                try {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  Future.delayed(const Duration(seconds: 20))
                                      .then((value) {
                                    if (isLoading) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                    }
                                    if (!successful) {
                                      showMyBanner(
                                          context,
                                          getTranslatedText(
                                              "ٹائم آؤٹ", "Timed out"));
                                    }
                                    return;
                                  });
                                  final response = await FirebaseAuth.instance
                                      .signInWithEmailAndPassword(
                                          email: email, password: password);
                                  if (response.user != null) {
                                    setState(() {
                                      successful = true;
                                    });
                                  }
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.setBool(Login.isLoggedInText, true);
                                  print("Login Successful");
                                  print(response.user);
                                  final appUserData = await FirebaseFirestore
                                      .instance
                                      .collection("users")
                                      .where('email',
                                          isEqualTo: email.trim().toLowerCase())
                                      .limit(1)
                                      .get();
                                  await showMyDialog(
                                      context,
                                      'Info',
                                      getTranslatedText("لاگ ان کامیاب ہوا۔",
                                          'Login Successful.'),
                                      disposeAfterMillis: 300,
                                      isError: false);
                                  final user = AppUser.fromJson(
                                      appUserData.docs.first.data());
                                  appUser = user;
                                  print("Customer loaded: ${user.toJson()}");
                                  //if is not registered as customer or tailor but just has created account
                                  if (!user.isRegistered) {
                                    //if not registered as tailor but creaed account as  tialor
                                    if (user.isTailor) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TailorRegistration(
                                                  userData: user),
                                        ),
                                      );
                                    }
                                    //if not registered as customer but created account as customer
                                    else {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CustomerRegistration(
                                                  userData: user),
                                        ),
                                      );
                                    }
                                  }
                                  //if already registered.

                                  else {
                                    Navigator.pushReplacementNamed(
                                        context,
                                        user.isTailor
                                            ? TailorMainScreen.id
                                            : CustomerMainScreen.id);
                                  }
                                } on FirebaseAuthException catch (e) {
                                  if (e.code == "user-not-found") {
                                    showMyDialog(
                                        context,
                                        'Login Error!',
                                        getTranslatedText(
                                            "صارف رجسٹرڈ نہیں ہے۔",
                                            'User Not Registered.'),
                                        disposeAfterMillis: 1000);
                                  } else if (e.code == "wrong-password") {
                                    showMyDialog(
                                        context,
                                        'Login Error!',
                                        getTranslatedText('غلط پاس ورڈ',
                                            'Incorrect password.'));
                                  } else if (e.code ==
                                      "network-request-failed") {
                                    showMyDialog(
                                        context,
                                        'Login Error!',
                                        getTranslatedText('انٹرنیٹ کنیکشن نہیں',
                                            'No Internet Connection'),
                                        disposeAfterMillis: 700);
                                  } else if (e.code == "invalid-email") {
                                    showMyDialog(
                                        context,
                                        'Error!',
                                        getTranslatedText(
                                            "غیر قانونی ای میل داخل کی گئی ہے",
                                            'Invalid email entered.'),
                                        disposeAfterMillis: 700);
                                  }
                                  if (mounted) {
                                    setState(() {
                                      successful = true;
                                    });
                                  }
                                  print(e.code);
                                }
                                // Navigator.pushNamed(context, HomeScreen.id);
                              } else {
                                debugPrint("Validation failed!");
                              }
                              if (mounted) {
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Flexible(
                                child: Divider(
                                  height: 1,
                                  color: Colors.black54,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: const Text('Or', style: kTextStyle).tr(),
                              ),
                              const Flexible(
                                child: Divider(
                                  height: 1,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          //sign in with google
                          Card(
                            color: kLightSkinColor,
                            elevation: 5.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(60),
                              side: BorderSide(color: kOrangeColor, width: 0.2),
                            ),
                            //margin: EdgeInsets.symmetric(horizontal: 20),
                            child: InkWell(
                              onTap: () async {
                                bool successful = false;
                                try {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  Future.delayed(const Duration(seconds: 30))
                                      .then((value) {
                                    if (isLoading) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                    }
                                    if (!successful) {
                                      showMyBanner(
                                          context,
                                          getTranslatedText(
                                              "ٹائم آؤٹ", "Timed out"));
                                    }
                                    return;
                                  });
                                  final userCredentials = await FirebaseAuth
                                      .instance
                                      .signInWithProvider(GoogleAuthProvider());
                                  if (userCredentials.user != null) {
                                    setState(() {
                                      successful = true;
                                    });
                                    final userData = await FirebaseFirestore
                                        .instance
                                        .collection("users")
                                        .where("email",
                                            isEqualTo:
                                                userCredentials.user!.email)
                                        .get();

                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    prefs.setBool(Login.isLoggedInText, true);
                                    if (mounted) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                    }

                                    final user = AppUser.fromJson(
                                        userData.docs.first.data());
                                    appUser = user;
                                    await showMyDialog(
                                        context,
                                        'Info.',
                                        getTranslatedText("لاگ ان کامیاب ہوا۔",
                                            "Login Successful."),
                                        isError: false);
                                    //if is not registered as customer or tailor but just has created account
                                    if (!user.isRegistered) {
                                      print(
                                          "Going to register as customer frrom google sign in");
                                      //if not registered as tailor but creaed account as  tialor
                                      if (user.isTailor) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                TailorRegistration(
                                                    userData: user),
                                          ),
                                        );
                                      }
                                      //if not registered as customer but created account as customer
                                      else {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CustomerRegistration(
                                                    userData: user),
                                          ),
                                        );
                                      }
                                    }
                                    //if already registered.

                                    else {
                                      Navigator.pushReplacementNamed(
                                          context,
                                          user.isTailor
                                              ? TailorMainScreen.id
                                              : CustomerMainScreen.id);
                                    }
                                  } else {
                                    showMyBanner(
                                        context,
                                        getTranslatedText(
                                            "اکاؤنٹ بنانے میں ناکامی ہوئی۔",
                                            "account creation failed."));
                                  }
                                } on FirebaseAuthException catch (e) {
                                  if (e.code == "email-already-in-use") {
                                    showMyDialog(
                                      context,
                                      'Sign up error!',
                                      getTranslatedText(
                                          "یہ ای میل پہلے ہی استعمال میں ہے۔ ایک مختلف کوشش کریں.",
                                          'This email is already in use. Try a different one.'),
                                      disposeAfterMillis: 2500,
                                    );
                                  }
                                  print("Login exception: ${e.code}");
                                  if (e.code == "unknown") {
                                    showMyBanner(
                                        context,
                                        getTranslatedText("کچھ غلطی ہوئی!",
                                            'Some error occurred!'));
                                  }
                                  if (!successful) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                } catch (e) {
                                  if (!successful) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                  print('Execption: $e');
                                }
                                setState(() {
                                  isLoading = false;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.transparent,
                                      child: Icon(
                                        FontAwesomeIcons.google,
                                        color: kOrangeColor,
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        'Login with Google',
                                        style:
                                            kTextStyle.copyWith(fontSize: 18),
                                      ).tr(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'New here?',
                                style: kTextStyle,
                              ).tr(),
                              TextButton(
                                onPressed: () async {
                                  clearText();
                                  final tailorRegistered =
                                      await Navigator.pushNamed(
                                          context, SignUp.id);
                                  if (tailorRegistered != null &&
                                      tailorRegistered == 1) {
                                    // ignore: use_build_context_synchronously
                                    showMyBanner(
                                        context,
                                        getTranslatedText(
                                            "'درزی کامیابی سے رجسٹرڈ ہے۔'",
                                            'Tailor registered successfully.'));
                                  }
                                },
                                child: Text(
                                  'Create an Account',
                                  style: reminderButtonStyle.copyWith(
                                      fontFamily: 'Courier'),
                                ).tr(),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Align(
              //     alignment:
              //         getTranslatedText( Alignment.topLeft : Alignment.topRight,
              //     child: Padding(
              //       padding: const EdgeInsets.all(5),
              //       child: buildTranslateButton(context, onTranslated: () {
              //         setState(() {});
              //       }),
              //     )),
              Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: size.width * 0.3,
                  height: size.height * 0.06,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: AnimatedToggleSwitch<String>.size(
                      current: language,
                      // innerColor: kLightSkinColor,
                      // indicatorColor: kOrangeColor,
                      // borderColor: kOrangeColor,
                    
                      indicatorSize: Size(
                        size.width * 0.15,
                        size.height * 0.06,
                      ),
                      values: ["English", "اردو"],
                      iconBuilder: (value) {
                        return Center(
                          child: Text(
                            value,
                            style: kInputStyle.copyWith(
                              fontSize: language == value ? 12 : 12,
                              color: language == value
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        );
                      },
                      onChanged: (val) async {
                        if (mounted) {
                          setState(() {
                            language = val;
                            if (language == "English") {
                              isUrduActivated = false;
                            } else {
                              isUrduActivated = true;
                            }
                          });
                        }
                        await context.setLocale(language == "English"
                            ? const Locale("en", "US")
                            : const Locale("ur", "PK"));
                        if (mounted) {
                          setState(() {});
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
