import 'package:flutter/material.dart';

extension ColorsExt on Colors {
  static Color grey1(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? ColorsLight.grey1
        : ColorsDark.grey1;
  }

  static Color grey2(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? ColorsLight.grey2
        : ColorsDark.grey2;
  }

  static Color grey2_5(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? ColorsLight.grey2_5
        : ColorsDark.grey2_5;
  }

  static Color grey3(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? ColorsLight.grey3
        : ColorsDark.grey3;
  }

  static Color grey4(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? ColorsLight.grey4
        : ColorsDark.grey4;
  }

  static Color grey5(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? ColorsLight.grey5
        : ColorsDark.grey5;
  }

  static Color grey6(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? ColorsLight.grey6
        : ColorsDark.grey6;
  }

  static Color grey7(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? ColorsLight.grey7
        : ColorsDark.grey7;
  }

  static green(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? ColorsLight.green
        : ColorsDark.green;
  }

  static green20(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? ColorsLight.green20
        : ColorsDark.green20;
  }

  static cyan(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? ColorsLight.cyan
        : ColorsDark.cyan;
  }

  static cyan25(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? ColorsLight.cyan25
        : ColorsDark.cyan25;
  }

  static akiflow(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? ColorsLight.akiflow
        : ColorsDark.akiflow;
  }

  static akiflow10(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? ColorsLight.akiflow10
        : ColorsDark.akiflow10;
  }

  static pink(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? ColorsLight.pink
        : ColorsDark.pink;
  }

  static pink30(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? ColorsLight.pink30
        : ColorsDark.pink30;
  }

  static red(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? ColorsLight.red
        : ColorsDark.red;
  }

  static background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? ColorsLight.white
        : ColorsDark.grey1;
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

  static Color getFromName(String name) {
    return fromHex(paletteColors[name] ?? "#ffffff");
  }
}

extension ColorsLight on Colors {
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
  static const Color grey1 = Color(0xFF37404A);
  static const Color grey2 = Color(0xFF445B6A);
  static const Color grey2_5 = Color(0xFF7C8B95);
  static const Color grey3 = Color(0xFFA0AEB8);
  static const Color grey4 = Color(0xFFBFD6E4);
  static const Color grey5 = Color(0xFFE4EDF3);
  static const Color grey6 = Color(0xFFF1F6F9);
  static const Color grey7 = Color(0xFFFAFBFD);
  static const Color white = Color(0xFFFFFFFF);

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
  static const Color grey1 = Color(0xFF37404A);
  static const Color grey2 = Color(0xFF445B6A);
  static const Color grey2_5 = Color(0xFF7C8B95);
  static const Color grey3 = Color(0xFFA0AEB8);
  static const Color grey4 = Color(0xFFBFD6E4);
  static const Color grey5 = Color(0xFFE4EDF3);
  static const Color grey6 = Color(0xFFF1F6F9);
  static const Color grey7 = Color(0xFFFAFBFD);

  static const Color pink = Color(0xFFF195C1);
  static const Color pink30 = Color(0xFFFFE9F0);
}
