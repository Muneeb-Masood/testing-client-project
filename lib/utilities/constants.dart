import 'package:test/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../networking/api_helper.dart';

const kSkinColor = Color(0xFFf4e5d4);
const kLightSkinColor = Color(0xFFfdf6eb);
final kOrangeColor = const Color(0xFFf47d32).withOpacity(0.8);
const kDarkOrange = Color(0xFFf47d32);

const kThresholdDeliveryDays = 1;
TextStyle get reminderButtonStyle {
  return kBoldTextStyle(size: isUrduActivated ? 15 : 13).copyWith(
    decoration: isUrduActivated ? null : TextDecoration.underline,
  );
}

Widget translatedTextWidget(text, {TextStyle? style}) {
  return FutureBuilder(
    future: ApiHelper.translateText(text),
    builder: (_, st) {
      return Text(
        getTranslatedText(st.data ?? '..', text),
        style: style,
      );
    },
  );
}

const kTitleStyle =
    TextStyle(fontSize: 50, fontFamily: 'Georgia', color: Colors.black);
const kInputStyle =
    TextStyle(fontFamily: 'Georgia', height: 1.6, color: Colors.black);
TextStyle kBoldTextStyle({double size = 12.2}) => TextStyle(
      fontFamily: 'Georgia',
      height: 1.4,
      fontSize: size,
      fontWeight: FontWeight.bold,
      color: kDarkOrange,
    );

final kOutlinedButtonStyle = ButtonStyle(
  padding: MaterialStateProperty.resolveWith<EdgeInsetsGeometry?>(
      (_) => EdgeInsets.zero),
  shape: MaterialStateProperty.all<OutlinedBorder>(
    RoundedRectangleBorder(
      borderRadius:
          BorderRadius.circular(8.0), // Adjust the border radius as needed
    ),
  ),
  side: MaterialStateProperty.all<BorderSide>(
    const BorderSide(
      color: kDarkOrange, // Replace with your desired outline color
      width: 1.0, // Adjust the border width as needed
    ),
  ),
);

const kTextStyle = TextStyle(
    color: Colors.black54, fontFamily: 'Courier', fontWeight: FontWeight.w700);
const dummyNumber = "3XXXXXXXXX";

final kTextFieldDecoration = InputDecoration(
  // hintText: getTranslatedText('کچھ اِنپُٹ درج کریں', 'enter a value'),
  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: kOrangeColor, width: 2.0),
    borderRadius: const BorderRadius.all(Radius.circular(30)),
  ),
  focusedErrorBorder: const OutlineInputBorder(
    borderSide: BorderSide(color: Colors.red, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(30)),
  ),
  border: const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(30)),
  ),
  enabledBorder: const OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(30)),
  ),
);

String zeroedPhoneNumber(String? accountNumber) =>
    accountNumber == null ? "" : '0${accountNumber.substring(3)}';

final catgKeyVals = {
  "Formal": "فارمل",
  "Dress Shirts": "ڈریس شرٹس",
  "Dress Pants": "ڈریس پینٹس",
  "Two Piece": "ٹُو پِیس",
  "Three-Piece": "تھری پِیس",
  "Vase Coats": "ویس کوٹس",
  "Coats": "کوٹس",
  "Shervaani": "شیروانی",
  "Casual": "آرام دہ لباس",
  "Tailors": "درزی",
  "Shalwar Kameez": "شلوار قمیض",
  "Cultural": "ثقافتی",
  "Sindhi": "سندھی",
  "Punjabi": "پنجابی",
  "Balochi": "بلوچی",
  "Pakhtun": "پختون",
  "Others": "دیگر",
  "Costumes": "ملبوسات",
  "Lehanga": "لہنگا",
  "Frock": "فراک",
  "Ghaghra Choli": "گھاگھرا چولی",
  "Gharara": "غرارہ",
  "Sharara": "شرارہ",
  "Maxi": "میکسی",
  "Fishtail": "فش ٹیل",
  "Sari": "ساڑی",
  "Kurti": "کڑتی",
  "Short Frock": "شارٹ فراک",
};

Map<String, List<String>> getLadiesCatg() {
  return _ladiesCategories;
}

Map<String, List<String>> getMenCatg() {
  return _menCategories;
}

final Map<String, List<String>> _menCategories = {
  "Formal": [
    "Dress Shirts",
    "Dress Pants",
    "Two Piece",
    "Three-Piece",
    "Vase Coats",
    "Coats",
    "Shervaani"
  ],
  "Casual": ["Shalwar Kameez"],
  "Cultural": ["Sindhi", "Punjabi", "Balochi", "Pakhtun"],
  "Others": ["Costumes"],
};

final Map<String, List<String>> _ladiesCategories = {
  "Formal": [
    "Lehanga",
    "Frock",
    "Ghaghra Choli",
    "Gharara",
    "Sharara",
    "Maxi",
    "Fishtail",
    "Sari"
  ],
  "Casual": ["Kurti", "l-Shalwar Kameez", "Short Frock"],
  "Cultural": ["l-Sindhi", "l-Punjabi", "l-Balochi", "l-Pakhtun"],
  "Others": ["l-Costumes"],
};
String capitalizeText(String text) {
  text = text.trim();
  if (text.isEmpty) return "";
  return text[0].toUpperCase() + text.substring(1);
}

const dummyImage =
    "https://th.bing.com/th/id/R.a34b7ac8ed93ef82f495d21841d80c68?rik=LNaecccGzJesnA&riu=http%3a%2f%2fwww.fashionglint.com%2fwp-content%2fuploads%2f2017%2f12%2fLatest-Pakistani-Sherwani-Designs-2018-to-Look-Dapper-5.jpeg&ehk=z0PZYrXakypAZkm16iCU8qWunJr0OF5YW4rTKS5IlBg%3d&risl=&pid=ImgRaw&r=0";
const dressImages = {
  "Balochi": "assets/dressImages/men-balochi.jpeg",
  "l-Balochi": "assets/dressImages/men-balochi.jpeg",
  "Coats": "assets/dressImages/coat.jpeg",
  "Costumes": "assets/dressImages/men-costumes.jpeg",
  "l-Costumes": "assets/dressImages/ladies-costumes.jpeg",
  "Dress Pants": "assets/dressImages/dress pants.jpeg",
  "Dress Shirts": "assets/dressImages/dress shirts.jpeg",
  "Fishtail": "assets/dressImages/fish tail.jpeg",
  "Frock": "assets/dressImages/long frock.jpeg",
  "Ghaghra Choli": "assets/dressImages/ghaghra chouli.jpeg",
  "Gharara": "assets/dressImages/gharara.jpeg",
  "Kurti": "assets/dressImages/kurti.jpeg",
  "Lehanga": "assets/dressImages/lehanga.jpeg",
  "Maxi": "assets/dressImages/maxi.jpeg",
  "Pakhtun": "assets/dressImages/men-pakhtun.jpeg",
  "l-Pakhtun": "assets/dressImages/female-pakhtun.jpeg",
  "Punjabi": "assets/dressImages/men-punjabi.jpeg",
  "l-Punjabi": "assets/dressImages/female-punjabi.jpeg",
  "Sari": "assets/dressImages/saree.jpeg",
  "Shalwar Kameez": "assets/dressImages/men-Shalwar kameez.jpeg",
  "l-Shalwar Kameez": "assets/dressImages/female-shalwar kameez.jpeg",
  "Sharara": "assets/dressImages/sharara.jpeg",
  "Shervaani": "assets/dressImages/shervani.jpeg",
  "Short Frock": "assets/dressImages/short frock.jpeg",
  "Sindhi": "assets/dressImages/men-sindhi.jpeg",
  "l-Sindhi": "assets/dressImages/female-sindhi.jpeg",
  "Three-Piece": "assets/dressImages/three piece.jpeg",
  "Two Piece": "assets/dressImages/two piece.jpeg",
  "Vase Coats": "assets/dressImages/vase-coat.jpeg",
};

Widget kSpinner(context, {double ratioFactor = 0.5}) => const Center(
      child: SpinKitDualRing(color: Colors.blue),
    );

///gives category regardless of language
String getCategory(String dressCategory) {
  return (dressCategory.contains('l-')
      ? _menCategories['Cultural']!.contains(dressCategory) ||
              _ladiesCategories['Cultural']!.contains(dressCategory)
          ? //if its urdu then don't show it
          getTranslatedText(dressCategory.substring(2),
              '${dressCategory.substring(2)}(cultural dress)')
          : dressCategory.substring(2)
      : dressCategory);
}

String getTranslatedText(String urduText, String engText) =>
    isUrduActivated ? urduText : engText;
urduMeasurement(String text) {
  final map = {
    "online": "آن لائن",
    "physical": "ذاتی طور پر",
    "viaAgent": "ایجنٹ کے ذریعے",
  };
  if (isUrduActivated) {
    return map[text];
  }
  return spaceSeparatedText(text);
}

urduClothOption(String? text) {
  final map = {
    "mySelf": "خود ہی",
    "viaAgent": "ایجنٹ کے ذریعے",
  };
  if (isUrduActivated) {
    return map[text];
  }
  return text == null ? null : spaceSeparatedText(text);
}

String spaceSeparatedText(String title) {
  String str = "";
  for (int i = 0; i < title.length; i++) {
    if (title[i] == title[i].toUpperCase()) {
      str += " ${title[i].toLowerCase()}";
    } else {
      str += title[i];
    }
  }
  return str;
}

urduOrderStatus(String status) {
  final map = {
    "notStartedYet": "ابھی شروع نہیں ہوا",
    "inProgress": "ابھی جاری ہے",
    "justStarted": "ابھی شروع ہوا",
    "completed": "مکمل ہو گیا",
  };
  if (isUrduActivated) {
    return map[status];
  }
  return spaceSeparatedText(status);
}
