import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colors
const Color primary = Color(0xFFAF38F9);
const Color primaryLight = Color(0xFFF7EBFE);
const Color textLight = Color(0xff222222);
const Color textDark = Color(0xffeeeeee);
const Color backgroundLight = Color(0xffF2F1F6);
const Color backgroundDark = Color(0xFF121212);
const Color disabledLight = Color(0xffcccccc);

/// Styles
const double cardRadius = 10.0;
const double cardElevation = 0.0;
const double titleFontSize = 34.0;
const double subtitleFontSize = 16.0;
const double buttonFontSize = 18.0;
const double buttonSubtitleFontSize = 16.0;
const double buttonHeight = 60;

/// Sizes
const double maxWidth = 600;
const double radius = 10;

/// Light Theme
final ThemeData lightTheme = ThemeData.light().copyWith(
  primaryColor: primary,
  primaryColorLight: primaryLight,
  backgroundColor: backgroundLight,
  scaffoldBackgroundColor: backgroundLight,
  appBarTheme: const AppBarTheme(
    color: primaryLight,
    iconTheme: IconThemeData(color: primary),
    actionsIconTheme: IconThemeData(color: primary),
    foregroundColor: primary,
  ),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: primary,
    selectionColor: primary,
    selectionHandleColor: primary,
  ),
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: primary,
    secondary: primary,
  ),
  cardTheme: CardTheme(
    margin: EdgeInsets.zero,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(0),
    ),
  ),
  textTheme: GoogleFonts.beVietnamTextTheme(),
  checkboxTheme:
      CheckboxThemeData(fillColor: MaterialStateProperty.all(primary)),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      primary: primary,
      textStyle: const TextStyle(fontWeight: FontWeight.bold, color: primary),
    ),
  ),
  disabledColor: disabledLight,
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  ),
);

/// Dark Theme
// final ThemeData darkTheme = ThemeData.light().copyWith(
//   primaryColor: primaryDark,
//   backgroundColor: backgroundDark,
//   scaffoldBackgroundColor: backgroundDark,
//   appBarTheme: const AppBarTheme(
//     color: primaryDark,
//     iconTheme: IconThemeData(color: accentDark),
//     actionsIconTheme: IconThemeData(color: accentDark),
//     foregroundColor: accentDark,
//   ),
//   textSelectionTheme: const TextSelectionThemeData(
//     cursorColor: primaryDark,
//     selectionColor: primaryDark,
//     selectionHandleColor: primaryDark,
//   ),
//   colorScheme: ColorScheme.fromSwatch().copyWith(
//     primary: primaryDark,
//     secondary: primary,
//   ),
//   cardColor: cardDark,
//   cardTheme: CardTheme(
//     color: cardDark,
//     margin: EdgeInsets.zero,
//     elevation: 0,
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(0),
//     ),
//   ),
//   disabledColor: cardDark,
//   checkboxTheme:
//       CheckboxThemeData(fillColor: MaterialStateProperty.all(primary)),
//   textTheme: GoogleFonts.beVietnamTextTheme(const TextTheme(
//     bodyText1: TextStyle(color: textDark),
//     bodyText2: TextStyle(color: textDark),
//   )),
//   dialogBackgroundColor: cardDark,
//   textButtonTheme: TextButtonThemeData(
//     style: TextButton.styleFrom(
//       primary: primary,
//       textStyle:
//           const TextStyle(fontWeight: FontWeight.bold, color: primary),
//     ),
//   ),
//   pageTransitionsTheme: const PageTransitionsTheme(
//     builders: <TargetPlatform, PageTransitionsBuilder>{
//       TargetPlatform.android: ZoomPageTransitionsBuilder(),
//       TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
//     },
//   ),
// );
