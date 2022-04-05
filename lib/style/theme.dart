import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/style/colors.dart';

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
const double radius = 8;
const double border = 1;

/// Light Theme
final ThemeData lightTheme = ThemeData.light().copyWith(
  primaryColor: ColorsLight.brandPurple,
  primaryColorLight: ColorsLight.brandLight,
  backgroundColor: ColorsLight.background,
  scaffoldBackgroundColor: ColorsLight.background,
  appBarTheme: const AppBarTheme(
    color: ColorsLight.brandLight,
    iconTheme: IconThemeData(color: ColorsLight.brandPurple),
    actionsIconTheme: IconThemeData(color: ColorsLight.brandPurple),
    foregroundColor: ColorsLight.brandPurple,
  ),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: ColorsLight.brandPurple,
    selectionColor: ColorsLight.brandPurple,
    selectionHandleColor: ColorsLight.brandPurple,
  ),
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: ColorsLight.brandPurple,
    secondary: ColorsLight.brandPurple,
  ),
  cardTheme: CardTheme(
    margin: EdgeInsets.zero,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(0),
    ),
  ),
  textTheme: GoogleFonts.beVietnamTextTheme(),
  checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.all(ColorsLight.brandPurple)),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      primary: ColorsLight.brandPurple,
      textStyle: const TextStyle(
          fontWeight: FontWeight.bold, color: ColorsLight.brandPurple),
    ),
  ),
  disabledColor: ColorsLight.greyDefault,
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
//     secondary: ColorsLight.brandPurple,
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
//       primary: ColorsLight.brandPurple,
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
