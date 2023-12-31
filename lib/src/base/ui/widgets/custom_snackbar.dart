import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';

enum CustomSnackbarType { success, error, eventCreated, eventEdited, eventDeleted }

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
              margin: const EdgeInsets.symmetric(horizontal: Dimension.padding),
              width: double.infinity,
              padding: const EdgeInsets.only(left: Dimension.padding),
              decoration: BoxDecoration(
                color: color(context, type),
                border: Border.all(
                  color: ColorsExt.grey4(context),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(Dimension.radiusS),
              ),
              child: Row(
                children: [
                  SizedBox(
                    height: Dimension.smallconSize,
                    width: Dimension.smallconSize,
                    child: SvgPicture.asset(icon(type), color: ColorsExt.grey2(context)),
                  ),
                  const SizedBox(width: Dimension.paddingS),
                  Expanded(
                    child: Text(message,
                        style: Theme.of(context).textTheme.bodyText1?.copyWith(
                              color: ColorsExt.grey2(context),
                              fontWeight: FontWeight.w500,
                            )),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Color color(BuildContext context, CustomSnackbarType type) {
    switch (type) {
      case CustomSnackbarType.success:
        return ColorsExt.green20(context);
      case CustomSnackbarType.error:
        return ColorsExt.orange20(context);
      case CustomSnackbarType.eventCreated:
        return ColorsExt.grey6(context);
      case CustomSnackbarType.eventDeleted:
        return ColorsExt.cyan25(context);
      case CustomSnackbarType.eventEdited:
        return ColorsExt.green20(context);
    }
  }

  static String icon(CustomSnackbarType type) {
    switch (type) {
      case CustomSnackbarType.success:
        return Assets.images.icons.common.checkDoneOutlineSVG;
      case CustomSnackbarType.error:
        return Assets.images.icons.common.xmarkCircleSVG;
      case CustomSnackbarType.eventCreated:
        return Assets.images.icons.common.calendarBadgePlus1SVG;
      case CustomSnackbarType.eventDeleted:
        return Assets.images.icons.common.trashSVG;
      case CustomSnackbarType.eventEdited:
        return Assets.images.icons.common.calendarBadgePlus1SVG;
    }
  }
}
