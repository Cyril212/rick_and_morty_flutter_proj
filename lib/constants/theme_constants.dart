import 'package:flutter/material.dart';

const kColorPrimary = kColorPurple;
const kColorSecondary = kColorDarkPurple;
const kColorShadow = Color(0x1F000000);

const kColorTextPrimary = Colors.white;
const kColorTextSecondary = Colors.white;

const kColorPurple = Color(0xFF736AB7);
const kColorDarkPurple = Color(0xFF333366);
const kColorAmber = Colors.amber;
const kColorWhite = Colors.white;
const kColorWhite70 = Colors.white70;
const kColorBlack26 = Colors.black26;
const kMaterialColorBlue = Colors.blue;
const kColorBlue = Color(0xFF3366FF);
const kColorAqua = Color(0xFF00CCFF);

const kFontFamilyRegular = 'Schwifty';

const kPrimaryTextStyle = TextStyle(color: kColorTextPrimary);
const kPrimaryTextStyleSize16 = TextStyle(color: kColorTextPrimary, fontSize: 16);

const kAppBarTextStyle = TextStyle(color: kColorWhite, fontFamily: kFontFamilyRegular, fontWeight: FontWeight.w600, fontSize: 24.0);

const kHintTextStyle = TextStyle(
  color: kColorWhite70,
  fontStyle: FontStyle.italic,
);

const kTextTheme = TextTheme(bodyText1: kPrimaryTextStyle, bodyText2: kPrimaryTextStyle);

const kTextFieldInputDecoration = InputDecoration(
    hintText: "Email", filled: true, fillColor: Colors.white, focusColor: Colors.white, hoverColor: Colors.white, border: OutlineInputBorder());

InputDecoration kEmailTextFieldInputDecoration = kTextFieldInputDecoration.copyWith(hintText: "Email", prefixIcon: const Icon(Icons.email));
InputDecoration kPasswordTextFieldInputDecoration = kTextFieldInputDecoration.copyWith(hintText: "Password", prefixIcon: const Icon(Icons.lock));
InputDecoration kPasswordAgainTextFieldInputDecoration = kPasswordTextFieldInputDecoration.copyWith(hintText: "Confirm Password");

ButtonStyle get kPrimaryBtnStyle => ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.pressed)) return kColorDarkPurple.withOpacity(0.8);
          return kColorDarkPurple;
        },
      ),
      padding: MaterialStateProperty.all<EdgeInsets>(
        const EdgeInsets.fromLTRB(28, 14, 28, 14),
      ),
    );
