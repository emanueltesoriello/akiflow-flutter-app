import 'package:flutter/material.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';

/// Light Theme
final ThemeData lightTheme = ThemeData.light().copyWith(
  primaryColor: ColorsLight.purple500,
  primaryColorLight: ColorsLight.purple100,
  backgroundColor: ColorsLight.white,
  scaffoldBackgroundColor: ColorsLight.grey50,
  appBarTheme: const AppBarTheme(
    color: ColorsLight.white,
    iconTheme: IconThemeData(color: ColorsLight.grey800, size: 30),
    actionsIconTheme: IconThemeData(color: ColorsLight.grey800),
    foregroundColor: ColorsLight.grey800,
    titleTextStyle: TextStyle(color: ColorsLight.grey800, fontSize: 24, fontWeight: FontWeight.w500),
  ),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: ColorsLight.purple500,
    selectionColor: ColorsLight.highlightColor,
    selectionHandleColor: ColorsLight.purple500,
  ),
  textTheme: const TextTheme(
    caption: TextStyle(fontSize: 11.5),
    bodyText1: TextStyle(fontSize: 15.0),
    bodyText2: TextStyle(fontSize: 12.5),
    subtitle1: TextStyle(fontSize: 17.0),
    subtitle2: TextStyle(fontSize: 17.0),
  ).apply(
    fontFamily: "Inter",
    bodyColor: ColorsLight.grey900,
    displayColor: ColorsLight.grey900,
  ),
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: ColorsLight.purple500,
    secondary: ColorsLight.purple500,
  ),
  cardTheme: CardTheme(
    margin: EdgeInsets.zero,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(0),
    ),
  ),
  checkboxTheme: CheckboxThemeData(fillColor: MaterialStateProperty.all(ColorsLight.purple500)),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimension.radius),
      ),
      primary: ColorsLight.purple500,
      textStyle: const TextStyle(fontWeight: FontWeight.w400, color: ColorsLight.purple500),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
    textStyle: ThemeData().primaryTextTheme.button!.copyWith(fontSize: 17, color: ColorsLight.grey800),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimension.outlineBorderRadius)),
    backgroundColor: ColorsLight.grey100,
    side: const BorderSide(color: ColorsLight.grey300, width: 1),
    minimumSize: const Size(
      Dimension.minButtonWidth,
      Dimension.minButtonHeight,
    ),
  )),
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  ),
  iconTheme: const IconThemeData(
    color: ColorsLight.grey800,
  ),
  dividerColor: ColorsLight.grey200,
  dividerTheme: const DividerThemeData(color: ColorsLight.grey200, thickness: 1),
  popupMenuTheme: const PopupMenuThemeData(
    color: ColorsLight.grey50,
    textStyle: TextStyle(
      fontWeight: FontWeight.w500,
      color: ColorsLight.grey800,
    ),
  ),
  sliderTheme: const SliderThemeData(
    activeTrackColor: ColorsLight.purple500,
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
    backgroundColor: ColorsLight.purple500,
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
