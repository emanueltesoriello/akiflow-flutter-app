import 'package:flutter/material.dart';
import 'package:mobile/common/style/colors.dart';

class CustomSnackbar extends SnackBar {
  const CustomSnackbar({super.key, required super.content});

  static SnackBar get(BuildContext context) {
    return SnackBar(
      backgroundColor: Colors.transparent,
      content: SizedBox(
        height: 51,
        child: Material(
          color: Colors.transparent,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 51,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              width: double.infinity,
              padding: const EdgeInsets.only(left: 16),
              decoration: BoxDecoration(
                color: ColorsExt.green20(context),
                border: Border.all(
                  color: ColorsExt.grey4(context),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Connected successfully!',
                      style: TextStyle(color: ColorsExt.grey2(context), fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
