import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';

class RecurringEditModal extends StatelessWidget {
  final Function() onlyThisTap;
  final Function() allTap;
  const RecurringEditModal({super.key, required this.onlyThisTap, required this.allTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).backgroundColor,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Dimension.radiusM),
            topRight: Radius.circular(Dimension.radiusM),
          ),
        ),
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              const ScrollChip(),
              const SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.only(top: Dimension.padding, bottom: Dimension.padding),
                child: Row(
                  children: [
                    SvgPicture.asset(Assets.images.icons.common.pencilSVG,
                        width: 28, height: 28, color: ColorsExt.grey2(context)),
                    const SizedBox(width: 8.0),
                    Text(
                      t.editTask.repeatingEditDialog.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: ColorsExt.grey2(context),
                          ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: Dimension.padding, bottom: Dimension.padding),
                child: Text(
                  t.editTask.repeatingEditDialog.description,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1
                      ?.copyWith(fontWeight: FontWeight.w400, color: ColorsExt.grey3(context)),
                ),
              ),
              const SizedBox(height: Dimension.paddingM),
              InkWell(
                onTap: () {
                  onlyThisTap();
                  Navigator.pop(context);
                },
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 46,
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimension.radius),
                      border: Border.all(color: ColorsExt.grey5(context))),
                  child: Center(
                    child: Text(
                      t.editTask.repeatingEditDialog.onlyThis,
                      style: Theme.of(context).textTheme.subtitle1?.copyWith(
                            fontWeight: FontWeight.w400,
                            color: ColorsExt.grey3(context),
                          ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Dimension.padding),
              InkWell(
                onTap: () {
                  allTap();
                  Navigator.pop(context);
                },
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 46,
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimension.radius),
                      border: Border.all(color: ColorsExt.grey4(context))),
                  child: Center(
                    child: Text(
                      t.editTask.repeatingEditDialog.thisAndAllFuture,
                      style: Theme.of(context).textTheme.subtitle1?.copyWith(
                            fontWeight: FontWeight.w400,
                            color: ColorsExt.grey2(context),
                          ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Dimension.padding),
            ],
          ),
        ),
      ),
    );
  }
}
