import 'package:flutter/material.dart';

class Space extends StatelessWidget {
  final double height;

  // ignore: use_key_in_widget_constructors
  const Space([this.height = 16]);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: height,
    );
  }
}
