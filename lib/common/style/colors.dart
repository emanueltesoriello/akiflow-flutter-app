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

  static green(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.green : ColorsDark.green;
  }

  static green20(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.green20 : ColorsDark.green20;
  }

  static cyan(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.cyan : ColorsDark.cyan;
  }

  static cyan25(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.cyan25 : ColorsDark.cyan25;
  }

  static akiflow(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.akiflow : ColorsDark.akiflow;
  }

  static akiflow10(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.akiflow10 : ColorsDark.akiflow10;
  }

  static akiflow20(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.akiflow20 : ColorsDark.akiflow20;
  }

  static pink(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.pink : ColorsDark.pink;
  }

  static pink30(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.pink30 : ColorsDark.pink30;
  }

  static yellow(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.yellow : ColorsDark.yellow;
  }

  static red(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.red : ColorsDark.red;
  }

  static background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.white : ColorsDark.grey900;
  }

  static orange(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.orange : ColorsDark.orange;
  }

  static orange20(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? ColorsLight.orange20 : ColorsDark.orange20;
  }

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static Map<String, String> paletteColors = {
    'palette-comet': '#586284',
    'palette-grey': '#B3C0C7',
    'palette-orange': '#FF9F2E',
    'palette-yellow': '#FFE642',
    'palette-red': '#EE2435',
    'palette-pink': '#FA7CA2',
    'palette-purple': '#6C2B68',
    'palette-finn': '#BA3872',
    'palette-violet': '#AF38F9',
    'palette-mauve': '#FDA0FF',
    'palette-blue': '#4775C7',
    'palette-cyan': '#5ECDDE',
    'palette-green': '#248C73',
    'palette-wildwillow': '#A4C674',
    'palette-chico': '#925454',
    'palette-brown': '#D99385',
  };

  static Map<String, String> paletteColorsDisplayName = {
    'palette-comet': 'Comet',
    'palette-grey': 'Grey',
    'palette-orange': 'Orange',
    'palette-yellow': 'Yellow',
    'palette-red': 'Red',
    'palette-pink': 'Pink',
    'palette-purple': 'Purple',
    'palette-finn': 'Finn',
    'palette-violet': 'Violet',
    'palette-mauve': 'Mauve',
    'palette-blue': 'Blue',
    'palette-cyan': 'Cyan',
    'palette-green': 'Green',
    'palette-wildwillow': 'Wildwillow',
    'palette-chico': 'Chico',
    'palette-brown': 'Brown',
  };

  static Color getFromName(String name) {
    return fromHex(paletteColors[name] ?? "#ffffff");
  }

  static String displayTextFromName(String name) {
    return paletteColorsDisplayName[name] ?? "";
  }
}

extension ColorsLight on Colors {
  // primary
  static const Color akiflow = Color(0xFFAF38F9);
  static const Color akiflow20 = Color(0xFFEFD7FE);
  static const Color akiflow10 = Color(0xFFF7EBFE);

  static const Color highlightColor = Color(0xFFF2DDFF);

  static const Color green = Color(0xFF6FCF97);
  static const Color green20 = Color(0xFFE2F5EA);

  static const Color cyan = Color(0xFF59B6EB);
  static const Color cyan20 = Color(0xFFECF8FF);
  static const Color cyan25 = Color(0xFFD8EDFA);

  static const Color red = Color(0xFFEB5757);
  static const Color red20 = Color(0xFFFBDDDD);

  static const Color orange = Color(0xFFFB8822);
  static const Color orange20 = Color(0xFFFEE7D3);

  static const Color yellow = Color(0xFFF1BA11);
  static const Color yellow20 = Color(0xFFFCF1CF);

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

  static const Color pink = Color(0xFFF195C1);
  static const Color pink30 = Color(0xFFFFE9F0);
}

extension ColorsDark on Colors {
  // primary
  static const Color akiflow = Color(0xFFAF38F9);
  static const Color akiflow20 = Color(0xFFEFD7FE);
  static const Color akiflow10 = Color(0xFFF7EBFE);

  static const Color green = Color(0xFF6FCF97);
  static const Color green20 = Color(0xFFE2F5EA);

  static const Color cyan = Color(0xFF59B6EB);
  static const Color cyan20 = Color(0xFFECF8FF);
  static const Color cyan25 = Color(0xFFD8EDFA);

  static const Color red = Color(0xFFEB5757);
  static const Color red20 = Color(0xFFFBDDDD);

  static const Color orange = Color(0xFFFB8822);
  static const Color orange20 = Color(0xFFFEE7D3);

  static const Color yellow = Color(0xFFF1BA11);
  static const Color yellow20 = Color(0xFFFCF1CF);

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

  static const Color pink = Color(0xFFF195C1);
  static const Color pink30 = Color(0xFFFFE9F0);
}
