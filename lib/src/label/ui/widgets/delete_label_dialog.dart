import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/widgets/base/separator.dart';
import 'package:models/label/label.dart';

class DeleteLabelDialog extends StatelessWidget {
  final Label label;
  final Function() justDeleteTheLabelClick;
  final Function() markAllTasksAsDoneClick;

  const DeleteLabelDialog(
    this.label, {
    Key? key,
    required this.justDeleteTheLabelClick,
    required this.markAllTasksAsDoneClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimension.radiusS),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Dimension.radiusS),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(Dimension.padding),
                      child: Column(
                        children: [
                          const SizedBox(height: Dimension.paddingS),
                          SvgPicture.asset(Assets.images.icons.common.exclamationmarkTriangleFillSVG,
                              width: 48, height: 48, color: ColorsExt.grey2(context)),
                          const SizedBox(height: Dimension.padding),
                          Text(
                            t.label.deleteDialog.title(labelTitle: label.title ?? t.noTitle),
                            style:
                                TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: ColorsExt.grey2(context)),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: Dimension.padding),
                          Text(
                            t.label.deleteDialog.description,
                            style:
                                TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: ColorsExt.grey3(context)),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: Dimension.paddingM),
                          OutlinedButton(
                            onPressed: () {
                              justDeleteTheLabelClick();
                              Navigator.pop(context);
                            },
                            style: Theme.of(context).outlinedButtonTheme.style?.copyWith(
                                backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                minimumSize: MaterialStateProperty.all(const Size(double.infinity, 48))),
                            child: Text(
                              t.label.deleteDialog.justDeleteTheLabel,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: ColorsExt.grey2(context)),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: Dimension.paddingS),
                          OutlinedButton(
                            onPressed: () {
                              markAllTasksAsDoneClick();
                              Navigator.pop(context);
                            },
                            style: Theme.of(context).outlinedButtonTheme.style?.copyWith(
                                backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                minimumSize: MaterialStateProperty.all(const Size(double.infinity, 48))),
                            child: Text(
                              t.label.deleteDialog.markAllTasksAsDone,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: ColorsExt.grey2(context)),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Separator(),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: Center(
                          child: Text(
                            t.cancel,
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(
                                  color: ColorsExt.grey3(context),
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
