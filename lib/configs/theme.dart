import 'package:flutter/material.dart';

import '../constants/colors.dart';

ThemeData themeNormal(BuildContext context) {
  final ThemeData base = ThemeData(brightness: Brightness.light, primaryColor: kPrimaryColor, accentColor: kAccentColor, fontFamily: 'Rubik');

  return base.copyWith(
    buttonTheme: base.buttonTheme.copyWith(
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
    ),
  );
}
