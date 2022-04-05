import 'package:flutter/material.dart';

extension TextStyleExt on TextStyle {
  static TextStyle button(BuildContext context) {
    return TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w400,
      color: Theme.of(context).primaryColor,
    );
  }
}
