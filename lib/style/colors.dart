import 'package:flutter/material.dart';

extension ColorsExt on Colors {
  static Color textGrey2_5(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? ColorsLight.greyDark
        : ColorsDark.greyDark;
  }

  static Color textGrey3(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? ColorsLight.greyMedium
        : ColorsDark.greyMedium;
  }

  static Color textGrey(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? ColorsLight.greyDarker
        : ColorsDark.greyDarker;
  }

  static Color whiteButtonBorder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? ColorsLight.greyBlue
        : ColorsDark.greyBlue;
  }
}

extension ColorsLight on Colors {
  // main
  static const Color brandPurple = Color(0xFFAF38F9);
  static const Color brandMedium = Color(0xFFF5E3FF);
  static const Color brandLight = Color(0xFFF7EBFE);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color background = Color(0xFFFAFBFD);

  // greys
  static const Color greyDarker = Color(0xFF37404A);
  static const Color greyDark = Color(0xFF445B6A);
  static const Color greyMedium = Color(0xFF7C8B95);
  static const Color greyDefault = Color(0xFFB3C0C7);
  static const Color greyBlue = Color(0xFFBFD6E4);
  static const Color greyBlueLight =
      Color(0xFFE4EDF3); // in design files is called "Grey/Light blue"
  static const Color greyBlueLighter =
      Color(0xFFF1F6F9); // in design files is called "Grey/Light blue 50%"
  static const Color greyLight = Color(0xFFF2F2F2);
  static const Color greyLighter = Color(0xFFFAFBFD);
  static const Color greySelected = Color(0xFFEDF3F7);
  static const Color greyHover = Color(0xFFF8FCFF);

  // opaque greys
  static Color greyDarkerOp =
      Color.fromRGBO(greyDarker.red, greyDarker.green, greyDarker.blue, 0.6);
  static Color greyDarkOp =
      Color.fromRGBO(greyDark.red, greyDark.green, greyDark.blue, 0.6);
  static Color greyDarkOp1 =
      Color.fromRGBO(greyDark.red, greyDark.green, greyDark.blue, 0.7);
  static Color greyMediumOp =
      Color.fromRGBO(greyMedium.red, greyMedium.green, greyMedium.blue, 0.6);
  static Color greyMediumOp1 =
      Color.fromRGBO(greyMedium.red, greyMedium.green, greyMedium.blue, 0.8);
  static Color greyDefaultOp =
      Color.fromRGBO(greyDefault.red, greyDefault.green, greyDefault.blue, 0.6);
  static Color greyBlueOp =
      Color.fromRGBO(greyBlue.red, greyBlue.green, greyBlue.blue, 0.6);
  static Color greyBlueLightOp = Color.fromRGBO(
      greyBlueLight.red, greyBlueLight.green, greyBlueLight.blue, 0.6);
  static Color greyBlueLighterOp = Color.fromRGBO(
      greyBlueLighter.red, greyBlueLighter.green, greyBlueLighter.blue, 0.6);
  static Color greyLighterOp =
      Color.fromRGBO(greyLighter.red, greyLighter.green, greyLighter.blue, 0.6);

  // secondary/colors
  static const Color red = Color(0xFFEB5757);
  static const Color redLight = Color(0xFFF7BCBC);
  static const Color orange = Color(0xFFFB8822);
  static const Color orangeLight = Color(0xFFFDCFA7);
  static const Color yellow = Color(0xFFF1BA11);
  static const Color yellowLight =
      Color(0xFFF9E3A0); // in design this is yellow with 40% opacity
  static const Color yellowLighter =
      Color(0xFFFEFAEE); // only used in settings warning
  static const Color greenDark = Color(0xFF27AE60);
  static const Color green = Color(0xFF6FCF97);
  static const Color green1 = Color(0xFF7AE1A5);
  static const Color greenLightAlt =
      Color(0xFFdceee2); // in design this is green with 20% opacity
  static const Color greenLight =
      Color(0xFFC5ECD5); // in design this is green with 40% opacity
  static const Color greenLighter =
      Color(0xFFE6F5EE); // in design this is green with 85% opacity
  static const Color blueLight = Color(0xFFC8E9FC);

  // helpers/colors
  static const Color helperCyan = Color(0xFF9EDCFF);
  static const Color helperRose = Color(0xFFFFA4EB);
  static const Color helperRed = Color(0xFFFF3945);
  static Color helperRedLight =
      Color.fromRGBO(helperRed.red, helperRed.green, helperRed.blue, 0.15);

  // palettes
  static const Color paletteComet = Color(0xFF586284);
  static const Color paletteCometLight = Color(0xFFEBECF0);
  static const Color paletteGrey = Color(0xFFB3C0C7);
  static const Color paletteGreyLight = Color(0xFFF6F7F8);
  static const Color paletteOrange = Color(0xFFFF9F2E);
  static const Color paletteOrangeLight = Color(0xFFFFF3E6);
  static const Color paletteYellow = Color(0xFFFFE642);
  static const Color paletteYellowLight = Color(0xFFFFFCE8);
  static const Color paletteRed = Color(0xFFEE2435);
  static const Color paletteRedLight = Color(0xFFFDE5E7);
  static const Color palettePink = Color(0xFFFA7CA2);
  static const Color palettePinkLight = Color(0xFFFEEFF4);
  static const Color palettePurple = Color(0xFF6C2B68);
  static const Color palettePurpleLight = Color(0xFFEDE6ED);
  static const Color paletteFinn = Color(0xFFBA3872);
  static const Color paletteFinnLight = Color(0xFFF7E7EE);
  static const Color paletteViolet = Color(0xFFAF38F9);
  static const Color paletteVioletLight = Color(0xFFF5E7FE);
  static const Color paletteMauve = Color(0xFFFDA0FF);
  static const Color paletteMauveLight = Color(0xFFF5E7FE);
  static const Color paletteBlue = Color(0xFF4775C7);
  static const Color paletteBlueLight = Color(0xFFE9EEF8);
  static const Color paletteCyan = Color(0xFF5ECDDE);
  static const Color paletteCyanLight = Color(0xFFECF9FB);
  static const Color paletteGreen = Color(0xFF248C73);
  static const Color paletteGreenLight = Color(0xFFE5F1EE);
  static const Color paletteWildwillow = Color(0xFFA4C674);
  static const Color paletteWildwillowLight = Color(0xFFF4F8EE);
  static const Color paletteChico = Color(0xFF925454);
  static const Color paletteChicoLight = Color(0xFFF2EAEA);
  static const Color paletteBrown = Color(0xFFD99385);
  static const Color paletteBrownLight = Color(0xFFFAF2F0);

  // notion
  static const Color notionDefault = Color(0xFFFFFFFF);
  static const Color notionGray = Color(0xFFEBECED);
  static const Color notionBrown = Color(0xFFE9E5E3);
  static const Color notionOrange = Color(0xFFFAEBDD);
  static const Color notionYellow = Color(0xFFFBF3DB);
  static const Color notionGreen = Color(0xFFDDEDEA);
  static const Color notionBlue = Color(0xFFDDEBF1);
  static const Color notionPurple = Color(0xFFEAE4F2);
  static const Color notionPink = Color(0xFFF4DFEB);
  static const Color notionRed = Color(0xFFFBE4E4);
}

extension ColorsDark on Colors {
  // main
  static const Color brandPurple = Color(0xFFC582EE);
  static Color brandMedium = darken(brandPurple, 0.22);
  static Color brandLight = darken(brandPurple, 0.45);
  static const Color white = Color(0xFF2A292F);
  static const Color black = Color(0xFFffffff);
  static const Color background = Color(0xFFA0AEB8);

  // greys
  static const Color greyDarker = Color(0xFFffffff);
  static const Color greyDark = Color(0xFFffffff);
  static const Color greyMedium = Color(0xFFA0AEB8);
  static const Color greyDefault = Color(0xFFB3C0C7);
  static const Color greyBlue = Color(0xFF353639);
  static const Color greyBlueLight = Color(0xFF403E4B);
  static const Color greyBlueLighter = Color(0xFF1E1C23);
  static const Color greyLight = Color(0xFF26232c);
  static const Color greyLighter = Color(0xFF1E1C23);
  static const Color greySelected = Color(0xFF47474A);
  static const Color greyHover = Color(0xFF2E2C33);

  // opaque greys
  static Color greyDarkerOp =
      Color.fromRGBO(greyDarker.red, greyDarker.green, greyDarker.blue, 0.6);
  static Color greyDarkOp =
      Color.fromRGBO(greyDark.red, greyDark.green, greyDark.blue, 0.6);
  static Color greyDarkOp1 =
      Color.fromRGBO(greyDark.red, greyDark.green, greyDark.blue, 0.7);
  static Color greyMediumOp =
      Color.fromRGBO(greyMedium.red, greyMedium.green, greyMedium.blue, 0.6);
  static Color greyMediumOp1 =
      Color.fromRGBO(greyMedium.red, greyMedium.green, greyMedium.blue, 0.8);
  static Color greyDefaultOp =
      Color.fromRGBO(greyDefault.red, greyDefault.green, greyDefault.blue, 0.6);
  static Color greyBlueOp =
      Color.fromRGBO(greyBlue.red, greyBlue.green, greyBlue.blue, 0.6);
  static Color greyBlueLightOp = Color.fromRGBO(
      greyBlueLight.red, greyBlueLight.green, greyBlueLight.blue, 0.6);
  static Color greyBlueLighterOp = Color.fromRGBO(
      greyBlueLighter.red, greyBlueLighter.green, greyBlueLighter.blue, 0.6);
  static Color greyLighterOp =
      Color.fromRGBO(greyLighter.red, greyLighter.green, greyLighter.blue, 0.6);

  // secondary/colors
  static const Color red = Color(0xFFEB5757);
  static Color redLight = darken(red, 0.3);
  static Color redLighter = darken(red, 0.4);
  static const Color orange = Color(0xFFFB8822);
  static Color orangeLight = darken(orange, 0.3);
  static const Color yellow = Color(0xFFF1BA11);
  static Color yellowLight = darken(const Color(0xFFF9E3A0), 0.3);
  static Color yellowLighter = darken(const Color(0xFFF9E3A0), 0.4);
  static const Color greenDark = Color(0xFFC5ECD5);
  static const Color green = Color(0xFF6FCF97);
  static Color greenLightAlt = darken(const Color(0xFF4a8b65), 0.15);
  static Color greenLight = darken(const Color(0xFF6FCF97), 0.3);
  static const Color greenLighter = Color(0xFF324940);
  static const Color blueLight = Color(0xFF597182);

  // helpers/colors
  static const Color helperCyan = Color(0xFF9EDCFF);
  static const Color helperRose = Color(0xFFFFA4EB);
  static const Color helperRed = Color(0xFFFF3945);
  static Color helperRedLight =
      Color.fromRGBO(helperRed.red, helperRed.green, helperRed.blue, 0.15);

  // palettes
  static const Color paletteCometLight = Color(0xFF1F222E);
  static const Color paletteGreyLight = Color(0xFF3F4346);
  static const Color paletteOrangeLight = Color(0xFF593810);
  static const Color paletteYellowLight = Color(0xFF595017);
  static const Color paletteRedLight = Color(0xFF530C12);
  static const Color palettePinkLight = Color(0xFF572B39);
  static const Color palettePurpleLight = Color(0xFF260F24);
  static const Color paletteFinnLight = Color(0xFF411428);
  static const Color paletteVioletLight = Color(0xFF3D1457);
  static const Color paletteMauveLight = Color(0xFF593859);
  static const Color paletteBlueLight = Color(0xFF192946);
  static const Color paletteCyanLight = Color(0xFF21484E);
  static const Color paletteGreenLight = Color(0xFF0D3128);
  static const Color paletteWildwillowLight = Color(0xFF394529);
  static const Color paletteChicoLight = Color(0xFF331D1D);
  static const Color paletteBrownLight = Color(0xFF4C332F);

  // notion
  static const Color notionDefault = Color(0xFF2F3437);
  static const Color notionGray = Color(0xFF454B4E);
  static const Color notionBrown = Color(0xFF434040);
  static const Color notionOrange = Color(0xFF594A3A);
  static const Color notionYellow = Color(0xFF59563B);
  static const Color notionGreen = Color(0xFF354C4B);
  static const Color notionBlue = Color(0xFF364954);
  static const Color notionPurple = Color(0xFF443F57);
  static const Color notionPink = Color(0xFF533B4C);
  static const Color notionRed = Color(0xFF594141);

  static Color darken(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
