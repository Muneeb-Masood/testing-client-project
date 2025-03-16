import 'package:test/models/app_user.dart';
import 'package:test/networking/firestore_helper.dart';
import 'package:test/screens/customer/customer_home.dart';
import 'package:test/screens/customer/customer_main_screen.dart';
import 'package:test/screens/customer/customer_registration.dart';
import 'package:test/screens/forgot_password.dart';
import 'package:test/screens/login.dart';
import 'package:test/screens/sign_up.dart';
import 'package:test/screens/tailor/tailor_main_screen.dart';
import 'package:test/screens/tailor/tailor_registration.dart';
import 'package:test/screens/temp/temp.dart';
import 'package:test/utilities/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool? isLoggedIn;
AppUser? appUser;
bool isUrduActivated = false;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
try {
    await Firebase.initializeApp();
    print('Firebase initialized');
  } catch (e) {
    print("Firebase initialization skipped: $e");
  }  await EasyLocalization.ensureInitialized();
  // final prefs = await SharedPreferences.getInstance();
  // // prefs.setBool(Login.isLoggedInText, false);
  // isLoggedIn = prefs.getBool(Login.isLoggedInText);
  // print('Is Logged In: $isLoggedIn');
  // if (isLoggedIn != null && isLoggedIn!) {
  //   appUser = (await FireStoreHelper()
  //           .getAppUserWithEmail(FirebaseAuth.instance.currentUser!.email))
  //       as AppUser;
  // }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en', 'US'), Locale('ur', 'PK')],
      path:
          'assets/translations', // <-- change the path of the translation files
      fallbackLocale: const Locale('en', 'US'),
      child:  DressSewApp()
    ),
  );
}

class DressSewApp extends StatelessWidget {
  const DressSewApp({super.key});

  @override
  Widget build(BuildContext context) {
    Color primaryColor = kOrangeColor;
    Color textColor = Colors.white;

    final ThemeData theme = buildTheme(textColor, primaryColor);
    var appRoutes = {
        CustomerHomeView.id: ((context) => const CustomerHomeView()),
        CustomerMainScreen.id: ((context) => const CustomerMainScreen()),
        TailorMainScreen.id: ((context) => const TailorMainScreen()),
        Login.id: ((context) => const Login()),
        SignUp.id: ((context) => const SignUp()),
        ForgotPassword.id: ((context) => const ForgotPassword()),
      };
    return MaterialApp(
      theme: theme,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      home: isLoggedIn == null || !isLoggedIn!
          ? const Login()
          : appUser != null && appUser!.isRegistered
              ? appUser!.isTailor
                  ? const TailorMainScreen()
                  : const CustomerMainScreen()
              : appUser!.isTailor
                  ? TailorRegistration(userData: appUser!)
                  : CustomerRegistration(
                      userData: appUser!,
                    ),
      routes: appRoutes,
    );
  }

  ThemeData buildTheme(Color textColor, Color primaryColor) {
    return ThemeData(
    datePickerTheme: DatePickerThemeData(
      // backgroundColor: kOrangeColor,
      headerBackgroundColor: kOrangeColor,
      todayBackgroundColor:
          MaterialStateColor.resolveWith((states) => kSkinColor),
      todayForegroundColor:
          MaterialStateColor.resolveWith((states) => Colors.black),
      rangeSelectionBackgroundColor: Colors.white,
      todayBorder: BorderSide(
        color: kOrangeColor,
      ),
      backgroundColor: Colors.black45,
      shadowColor: kSkinColor,
      dayOverlayColor:
          MaterialStateColor.resolveWith((states) => kOrangeColor),
      dayForegroundColor:
          MaterialStateColor.resolveWith((states) => Colors.white),
      // dayBackgroundColor:
      //     MaterialStateColor.resolveWith((states) => kSkinColor),
      yearBackgroundColor:
          MaterialStateColor.resolveWith((states) => kOrangeColor),
      yearStyle: kBoldTextStyle(),
      yearForegroundColor:
          MaterialStateColor.resolveWith((states) => Colors.white),
      yearOverlayColor:
          MaterialStateColor.resolveWith((states) => kSkinColor),
      surfaceTintColor: kOrangeColor,
      dayStyle: kBoldTextStyle(), headerForegroundColor: Colors.white,
      // rangePickerBackgroundColor: kSkinColor,
      // rangePickerShadowColor: kOrangeColor,
      weekdayStyle: kBoldTextStyle(size: 16).copyWith(color: Colors.white),
      headerHeadlineStyle: kBoldTextStyle(),
      headerHelpStyle: kBoldTextStyle(),
    ),
    primarySwatch: createMaterialColor(kOrangeColor),
    tabBarTheme: TabBarTheme(
      labelColor: textColor,
      indicatorColor: textColor,
      dividerColor: textColor,
    ),
    // scaffoldBackgroundColor: kB,

    colorScheme: ColorScheme(
      primary: primaryColor,
      secondary: textColor,
      surface: textColor,
      background: textColor,
      error: Colors.red,
      onPrimary: textColor,
      onSecondary: primaryColor,
      onSurface: textColor,
      onBackground: textColor,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
  );
  }
}

buildTranslateButton(BuildContext context,
    {required VoidCallback onTranslated}) {
  if (context.locale == const Locale("ur", "PK")) {
    isUrduActivated = true;
  } else {
    isUrduActivated = false;
  }
  return OutlinedButton(
    style: OutlinedButton.styleFrom(backgroundColor: Colors.white),
    onPressed: () async {
      await context.setLocale(isUrduActivated
          ? const Locale("en", "US")
          : const Locale("ur", "PK"));
      onTranslated();
    },
    child: Text(
      isUrduActivated ? 'English' : "اردو",
      style: kTextStyle.copyWith(color: Colors.blue, fontSize: 15),
    ),
  );
}

MaterialColor createMaterialColor(Color color) {
  List<double> strengths = <double>[.05];
  Map<int, Color> swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }

  for (final double strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }

  return MaterialColor(color.value, swatch);
}
