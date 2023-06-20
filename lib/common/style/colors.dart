import 'package:flutter/material.dart';

extension ColorsExt on Colors {
  static Color grey900(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.grey900 : ColorsDark.grey900;
  }

  static Color grey800(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.grey800 : ColorsDark.grey800;
  }

  static Color grey700(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.grey700 : ColorsDark.grey700;
  }

  static Color grey600(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.grey600 : ColorsDark.grey600;
  }

  static Color grey500(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.grey500 : ColorsDark.grey500;
  }

  static Color grey400(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.grey400 : ColorsDark.grey400;
  }

  static Color grey300(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.grey300 : ColorsDark.grey300;
  }

  static Color grey200(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.grey200 : ColorsDark.grey200;
  }

  static Color grey100(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.grey100 : ColorsDark.grey100;
  }

  static Color grey50(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.grey50 : ColorsDark.grey50;
  }

  static yorkGreen400(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.yorkGreen400 : ColorsDark.yorkGreen400;
  }

  static yorkGreen200(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.yorkGreen200 : ColorsDark.yorkGreen200;
  }

  static yorkGreen100(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.yorkGreen100 : ColorsDark.yorkGreen100;
  }

  static jordyBlue400(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.jordyBlue400 : ColorsDark.jordyBlue400;
  }

  static jordyBlue200(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.jordyBlue200 : ColorsDark.jordyBlue200;
  }

  static jordyBlue100(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.jordyBlue100 : ColorsDark.jordyBlue100;
  }

  static akiflow500(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.purple500 : ColorsDark.purple500;
  }

  static akiflow100(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.purple100 : ColorsDark.purple100;
  }

  static akiflow200(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.purple200 : ColorsDark.purple200;
  }

  static rose400(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.rose400 : ColorsDark.rose400;
  }

  static rose200(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.rose200 : ColorsDark.rose200;
  }

  static buttercup400(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.buttercup400 : ColorsDark.buttercup400;
  }

  static cosmos400(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.cosmos400 : ColorsDark.cosmos400;
  }

  static cosmos200(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.cosmos200 : ColorsDark.cosmos200;
  }

  static background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.white : ColorsDark.grey900;
  }

  static apricot400(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.apricot400 : ColorsDark.apricot400;
  }

  static apricot200(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.apricot200 : ColorsDark.apricot200;
  }

  static apricot100(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.apricot100 : ColorsDark.apricot100;
  }

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  ///normal label colors
  static Map<String, String> paletteColors = {
    'palette-violet': '#AF38F9',
    'palette-mauve': '#FF80C4',
    'palette-blue': '#00ABF5',
    'palette-cyan': '#47D1C1',
    'palette-green': '#24A888',
    'palette-wildwillow': '#20B65C',
    'palette-chico': '#925454',
    'palette-brown': '#C77A6B',
    'palette-orange': '#FF9F2E',
    'palette-yellow': '#F3C902',
    'palette-red': '#EE2435',
    'palette-pink': '#FA7CA2',
    'palette-purple': '#6C2B68',
    'palette-finn': '#BA3872',
    'palette-comet': '#586284',
    'palette-grey': '#A7B6BE',
  };

  ///light label colors
  static Map<String, String> paletteColorsLight = {
    'palette-violet': '#EAE1FF',
    'palette-mauve': '#FFE9F5',
    'palette-blue': '#E1F6FF',
    'palette-cyan': '#D9F7F4',
    'palette-green': '#D9F2EC',
    'palette-wildwillow': '#DAFFE9',
    'palette-chico': '#EFE5E5',
    'palette-brown': '#FAEFEC',
    'palette-orange': '#FFF1E0',
    'palette-yellow': '#FFFAE0',
    'palette-red': '#FCDEE1',
    'palette-pink': '#FEEBF1',
    'palette-purple': '#E9DFE8',
    'palette-finn': '#F5E1EA',
    'palette-comet': '#EBECF0',
    'palette-grey': '#F6F7F8',
  };

  static Map<String, String> paletteColorsDisplayName = {
    'palette-violet': 'Violet',
    'palette-mauve': 'Mauve',
    'palette-blue': 'Blue',
    'palette-cyan': 'Cyan',
    'palette-green': 'Green',
    'palette-wildwillow': 'Wildwillow',
    'palette-chico': 'Chico',
    'palette-brown': 'Brown',
    'palette-orange': 'Orange',
    'palette-yellow': 'Yellow',
    'palette-red': 'Red',
    'palette-pink': 'Pink',
    'palette-purple': 'Purple',
    'palette-finn': 'Finn',
    'palette-comet': 'Comet',
    'palette-grey': 'Grey',
  };

  static Color getFromName(String name) {
    return fromHex(paletteColors[name] ?? "#ffffff");
  }

  static Color getLightColorFromName(String name) {
    return fromHex(paletteColorsLight[name] ?? "#ffffff");
  }

  static String displayTextFromName(String name) {
    return paletteColorsDisplayName[name] ?? "";
  }

  static Color getCalendarBackgroundColor(Color color) {
    return HSLColor.fromColor(color).withLightness(0.83).toColor().withOpacity(0.5);
  }

  static Color getCalendarBackgroundColorLight(Color color) {
    return HSLColor.fromColor(color).withLightness(0.89).toColor().withOpacity(0.5);
  }
}

extension ColorsLight on Colors {
  static const Color highlightColor = Color.fromRGBO(242, 221, 255, 1);
  // primary
  static const Color purple500 = Color.fromRGBO(175, 56, 249, 1);
  static const Color purple200 = Color.fromRGBO(237, 210, 255, 1);
  static const Color purple100 = Color.fromRGBO(247, 235, 255, 1);

  static const Color yorkGreen400 = Color.fromRGBO(103, 197, 146, 1);
  static const Color yorkGreen200 = Color.fromRGBO(196, 237, 211, 1);
  static const Color yorkGreen100 = Color.fromRGBO(231, 248, 237, 1);

  static const Color jordyBlue400 = Color.fromRGBO(124, 198, 238, 1);
  static const Color jordyBlue200 = Color.fromRGBO(201, 230, 248, 1);
  static const Color jordyBlue100 = Color.fromRGBO(233, 243, 252, 1);

  static const Color cosmos400 = Color.fromRGBO(250, 86, 86, 1);
  static const Color cosmos200 = Color.fromRGBO(255, 204, 204, 1);

  static const Color apricot400 = Color.fromRGBO(249, 142, 77, 1);
  static const Color apricot200 = Color.fromRGBO(253, 207, 167, 1);
  static const Color apricot100 = Color.fromRGBO(255, 234, 213, 1);

  static const Color buttercup400 = Color.fromRGBO(248, 196, 37, 1);
  static const Color buttercup200 = Color.fromRGBO(250, 234, 183, 1);
  static const Color buttercup100 = Color.fromRGBO(255, 252, 235, 1);

  static const Color rose400 = Color.fromRGBO(254, 149, 230, 1);
  static const Color rose200 = Color.fromRGBO(251, 228, 249, 1);

  // greys
  static const Color grey900 = Color.fromRGBO(51, 65, 85, 1);
  static const Color grey800 = Color.fromRGBO(71, 85, 105, 1);
  static const Color grey700 = Color.fromRGBO(102, 121, 147, 1);
  static const Color grey600 = Color.fromRGBO(145, 158, 176, 1);
  static const Color grey500 = Color.fromRGBO(181, 192, 206, 1);
  static const Color grey400 = Color.fromRGBO(203, 213, 225, 1);
  static const Color grey300 = Color.fromRGBO(214, 227, 235, 1);
  static const Color grey200 = Color.fromRGBO(233, 240, 246, 1);
  static const Color grey100 = Color.fromRGBO(241, 245, 249, 1);
  static const Color grey50 = Color.fromRGBO(248, 250, 252, 1);
  static const Color white = Color.fromRGBO(255, 255, 255, 1);
}

extension ColorsDark on Colors {
  // primary
  static const Color purple500 = Color.fromRGBO(175, 56, 249, 1);
  static const Color purple200 = Color.fromRGBO(237, 210, 255, 1);
  static const Color purple100 = Color.fromRGBO(247, 235, 255, 1);

  static const Color yorkGreen400 = Color.fromRGBO(103, 197, 146, 1);
  static const Color yorkGreen200 = Color.fromRGBO(196, 237, 211, 1);
  static const Color yorkGreen100 = Color.fromRGBO(231, 248, 237, 1);

  static const Color jordyBlue400 = Color.fromRGBO(124, 198, 238, 1);
  static const Color jordyBlue200 = Color.fromRGBO(201, 230, 248, 1);
  static const Color jordyBlue100 = Color.fromRGBO(233, 243, 252, 1);

  static const Color cosmos400 = Color.fromRGBO(250, 86, 86, 1);
  static const Color cosmos200 = Color.fromRGBO(255, 204, 204, 1);

  static const Color apricot400 = Color.fromRGBO(249, 142, 77, 1);
  static const Color apricot200 = Color.fromRGBO(253, 207, 167, 1);
  static const Color apricot100 = Color.fromRGBO(255, 234, 213, 1);

  static const Color buttercup400 = Color.fromRGBO(248, 196, 37, 1);
  static const Color buttercup200 = Color.fromRGBO(250, 234, 183, 1);
  static const Color buttercup100 = Color.fromRGBO(255, 252, 235, 1);

  static const Color rose400 = Color.fromRGBO(254, 149, 230, 1);
  static const Color rose200 = Color.fromRGBO(251, 228, 249, 1);

  // greys
  static const Color grey900 = Color.fromRGBO(51, 65, 85, 1);
  static const Color grey800 = Color.fromRGBO(71, 85, 105, 1);
  static const Color grey700 = Color.fromRGBO(102, 121, 147, 1);
  static const Color grey600 = Color.fromRGBO(145, 158, 176, 1);
  static const Color grey500 = Color.fromRGBO(181, 192, 206, 1);
  static const Color grey400 = Color.fromRGBO(203, 213, 225, 1);
  static const Color grey300 = Color.fromRGBO(214, 227, 235, 1);
  static const Color grey200 = Color.fromRGBO(233, 240, 246, 1);
  static const Color grey100 = Color.fromRGBO(241, 245, 249, 1);
  static const Color grey50 = Color.fromRGBO(248, 250, 252, 1);
  static const Color white = Color.fromRGBO(255, 255, 255, 1);
}
