import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';

enum CustomSnackbarType { success, error }

class CustomSnackbar extends SnackBar {
  const CustomSnackbar({super.key, required super.content});

  static SnackBar get({required BuildContext context, required CustomSnackbarType type, required String message}) {
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
                color: type == CustomSnackbarType.success ? ColorsExt.green20(context) : ColorsExt.orange20(context),
                border: Border.all(
                  color: ColorsExt.grey4(context),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                children: [
                  SizedBox(
                    height: 17,
                    width: 17,
                    child: SvgPicture.asset(
                        type == CustomSnackbarType.success
                            ? Assets.images.icons.common.checkDoneOutlineSVG
                            : Assets.images.icons.common.xmarkCircleSVG,
                        color: ColorsExt.grey2(context)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message,
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
