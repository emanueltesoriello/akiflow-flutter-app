import 'package:flutter/material.dart';

extension TextStyleExt on TextStyle {
  static TextStyle button(BuildContext context) {
    return TextStyle(
      fontSize: 21,
      fontWeight: FontWeight.normal,
      color: Theme.of(context).primaryColor,
    );
  }
}
