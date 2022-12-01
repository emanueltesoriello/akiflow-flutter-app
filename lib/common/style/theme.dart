import 'package:flutter/material.dart';
import 'package:mobile/common/style/colors.dart';

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
const double noticeRadius = 4;
const double border = 1;

/// Light Theme
final ThemeData lightTheme = ThemeData.light().copyWith(
  primaryColor: ColorsLight.akiflow,
  primaryColorLight: ColorsLight.akiflow10,
  backgroundColor: ColorsLight.white,
  scaffoldBackgroundColor: ColorsLight.grey7,
  appBarTheme: const AppBarTheme(
    color: ColorsLight.white,
    iconTheme: IconThemeData(color: ColorsLight.grey2, size: 30),
    actionsIconTheme: IconThemeData(color: ColorsLight.grey2),
    foregroundColor: ColorsLight.grey2,
    titleTextStyle: TextStyle(color: ColorsLight.grey2, fontSize: 24, fontWeight: FontWeight.w500),
  ),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: ColorsLight.akiflow,
    selectionColor: ColorsLight.highlightColor,
    selectionHandleColor: ColorsLight.akiflow,
  ),
  textTheme: const TextTheme(
    bodyText1: TextStyle(),
    bodyText2: TextStyle(),
  ).apply(
    fontFamily: "Inter",
    bodyColor: ColorsLight.grey1,
    displayColor: ColorsLight.grey1,
  ),
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: ColorsLight.akiflow,
    secondary: ColorsLight.akiflow,
  ),
  cardTheme: CardTheme(
    margin: EdgeInsets.zero,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(0),
    ),
  ),
  checkboxTheme: CheckboxThemeData(fillColor: MaterialStateProperty.all(ColorsLight.akiflow)),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      primary: ColorsLight.akiflow,
      textStyle: const TextStyle(fontWeight: FontWeight.w400, color: ColorsLight.akiflow),
    ),
  ),
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  ),
  iconTheme: const IconThemeData(
    color: ColorsLight.grey2,
  ),
  dividerColor: ColorsLight.grey5,
  dividerTheme: const DividerThemeData(color: ColorsLight.grey5, thickness: 1),
  popupMenuTheme: const PopupMenuThemeData(
    color: ColorsLight.grey7,
    textStyle: TextStyle(
      fontWeight: FontWeight.w500,
      color: ColorsLight.grey2,
    ),
  ),
  sliderTheme: const SliderThemeData(
    activeTrackColor: ColorsLight.akiflow,
    inactiveTrackColor: Color(0x33787880),
    trackShape: RoundedRectSliderTrackShape(),
    trackHeight: 4.0,
    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12),
    thumbColor: Colors.transparent,
    overlayColor: Colors.transparent,
    activeTickMarkColor: Colors.transparent,
    inactiveTickMarkColor: Colors.transparent,
  ),
  useMaterial3: true,
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: ColorsLight.akiflow,
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
//     secondary: ColorsLight.akiflow,
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
//       primary: ColorsLight.akiflow,
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
