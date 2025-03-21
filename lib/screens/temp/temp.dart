// import 'package:test/models/app_user.dart';
// import 'package:test/networking/firestore_helper.dart';
// import 'package:test/screens/customer/customer_home.dart';
// import 'package:test/screens/customer/customer_main_screen.dart';
// import 'package:test/screens/customer/customer_registration.dart';
// import 'package:test/screens/forgot_password.dart';
// import 'package:test/screens/login.dart';
// import 'package:test/screens/sign_up.dart';
// import 'package:test/screens/tailor/tailor_main_screen.dart';
// import 'package:test/screens/tailor/tailor_registration.dart';
// import 'package:test/screens/temp/temp.dart';  // Ensure this file exists
// import 'package:test/utilities/constants.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// bool? isLoggedIn;
// AppUser? appUser;
// bool isUrduActivated = false;

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();  // 🔹 Ensuring Firebase is initialized
//   await EasyLocalization.ensureInitialized();

//   runApp(
//     EasyLocalization(
//       supportedLocales: const [Locale('en', 'US'), Locale('ur', 'PK')],
//       path: 'assets/translations/', 
//       fallbackLocale: const Locale('en', 'US'),
//       child: const DressSewApp(),  // 🔹 Now using `DressSewApp`
//     ),
//   );
// }

// class DressSewApp extends StatelessWidget {
//   const DressSewApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData(
//         primarySwatch: createMaterialColor(kOrangeColor),
//       ),
//       localizationsDelegates: context.localizationDelegates,
//       supportedLocales: context.supportedLocales,
//       locale: context.locale,
//       debugShowCheckedModeBanner: false,
//       home: const TempScreen(),  // 🔹 Ensuring `TempScreen` loads
//     );
//   }
// }

// /// 🔹 Ensure TempScreen is properly structured
// class TempScreen extends StatelessWidget {
//   const TempScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     print("TempScreen is being built");  // 🔹 Debugging print statement
//     return Scaffold(
//       appBar: AppBar(title: const Text("Temp Screen")),
//       body: const Center(
//         child: Text(
//           "This is Temp Screen",
//           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//       ),
//     );
//   }
// }

// /// 🔹 Helper function to create MaterialColor
// MaterialColor createMaterialColor(Color color) {
//   List<double> strengths = <double>[.05];
//   Map<int, Color> swatch = <int, Color>{};
//   final int r = color.red, g = color.green, b = color.blue;

//   for (int i = 1; i < 10; i++) {
//     strengths.add(0.1 * i);
//   }

//   for (final double strength in strengths) {
//     final double ds = 0.5 - strength;
//     swatch[(strength * 1000).round()] = Color.fromRGBO(
//       r + ((ds < 0 ? r : (255 - r)) * ds).round(),
//       g + ((ds < 0 ? g : (255 - g)) * ds).round(),
//       b + ((ds < 0 ? b : (255 - b)) * ds).round(),
//       1,
//     );
//   }

//   return MaterialColor(color.value, swatch);
// }
