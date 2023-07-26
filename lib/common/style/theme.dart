import 'package:flutter/material.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';

/// Light Theme
final ThemeData lightTheme = ThemeData.light().copyWith(
  brightness: Brightness.light,
  primaryColor: ColorsLight.purple500,
  primaryColorLight: ColorsLight.purple100,
  scaffoldBackgroundColor: ColorsLight.grey50,
  appBarTheme: const AppBarTheme(
    backgroundColor: ColorsLight.white,
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
    bodySmall: TextStyle(fontSize: 11.5),
    bodyLarge: TextStyle(fontSize: 15.0),
    bodyMedium: TextStyle(fontSize: 12.5),
    titleMedium: TextStyle(fontSize: 17.0),
    titleSmall: TextStyle(fontSize: 17.0),
  ).apply(
    fontFamily: "Inter",
    bodyColor: ColorsLight.grey900,
    displayColor: ColorsLight.grey900,
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
      foregroundColor: ColorsLight.purple500,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimension.radius),
      ),
      textStyle: const TextStyle(fontWeight: FontWeight.w400, color: ColorsLight.purple500),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
    textStyle: ThemeData().primaryTextTheme.labelLarge!.copyWith(fontSize: 17, color: ColorsLight.grey800),
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
  colorScheme: ColorScheme.fromSwatch()
      .copyWith(
        primary: ColorsLight.purple500,
        secondary: ColorsLight.purple500,
      )
      .copyWith(background: ColorsLight.white),
);

/// Dark Theme
final ThemeData darkTheme = ThemeData.dark().copyWith(
  brightness: Brightness.dark,
  primaryColor: ColorsDark.purple500,
  primaryColorLight: ColorsDark.purple100,
  scaffoldBackgroundColor: ColorsDark.grey50,
  appBarTheme: const AppBarTheme(
    backgroundColor: ColorsDark.white,
    iconTheme: IconThemeData(color: ColorsDark.grey800, size: 30),
    actionsIconTheme: IconThemeData(color: ColorsDark.grey800),
    foregroundColor: ColorsDark.grey800,
    titleTextStyle: TextStyle(color: ColorsDark.grey800, fontSize: 24, fontWeight: FontWeight.w500),
  ),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: ColorsDark.purple500,
    selectionColor: ColorsDark.highlightColor,
    selectionHandleColor: ColorsDark.purple500,
  ),
  textTheme: const TextTheme(
    bodySmall: TextStyle(fontSize: 11.5),
    bodyLarge: TextStyle(fontSize: 15.0),
    bodyMedium: TextStyle(fontSize: 12.5),
    titleMedium: TextStyle(fontSize: 17.0),
    titleSmall: TextStyle(fontSize: 17.0),
  ).apply(
    fontFamily: "Inter",
    bodyColor: ColorsDark.grey900,
    displayColor: ColorsDark.grey900,
  ),
  cardTheme: CardTheme(
    margin: EdgeInsets.zero,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(0),
    ),
  ),
  checkboxTheme: CheckboxThemeData(fillColor: MaterialStateProperty.all(ColorsDark.purple500)),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: ColorsDark.purple500,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimension.radius),
      ),
      textStyle: const TextStyle(fontWeight: FontWeight.w400, color: ColorsDark.purple500),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
    textStyle: ThemeData().primaryTextTheme.labelLarge!.copyWith(fontSize: 17, color: ColorsDark.grey800),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimension.outlineBorderRadius)),
    backgroundColor: ColorsDark.grey100,
    side: const BorderSide(color: ColorsDark.grey300, width: 1),
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
    color: ColorsDark.grey800,
  ),
  dividerColor: ColorsDark.grey200,
  dividerTheme: const DividerThemeData(color: ColorsDark.grey200, thickness: 1),
  popupMenuTheme: const PopupMenuThemeData(
    color: ColorsDark.grey50,
    textStyle: TextStyle(
      fontWeight: FontWeight.w500,
      color: ColorsDark.grey800,
    ),
  ),
  sliderTheme: const SliderThemeData(
    activeTrackColor: ColorsDark.purple500,
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
    backgroundColor: ColorsDark.purple500,
  ),
  colorScheme: ColorScheme.fromSwatch()
      .copyWith(
        primary: ColorsDark.purple500,
        secondary: ColorsDark.purple500,
      )
      .copyWith(background: ColorsDark.white),
);
