import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/style/colors.dart';
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
        borderRadius: BorderRadius.circular(4),
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
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          SvgPicture.asset("assets/images/icons/_common/exclamationmark_triangle_fill.svg",
                              width: 48, height: 48, color: ColorsExt.grey2(context)),
                          const SizedBox(height: 16),
                          Text(
                            t.label.deleteDialog.title(labelTitle: label.title ?? t.noTitle),
                            style:
                                TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: ColorsExt.grey2(context)),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            t.label.deleteDialog.description,
                            style:
                                TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: ColorsExt.grey3(context)),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          InkWell(
                            onTap: () {
                              justDeleteTheLabelClick();
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: double.infinity,
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: ColorsExt.background(context),
                                border: Border.all(color: ColorsExt.grey2(context)),
                              ),
                              child: Center(
                                child: Text(
                                  t.label.deleteDialog.justDeleteTheLabel,
                                  style: TextStyle(fontSize: 15, color: ColorsExt.grey2(context)),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () {
                              markAllTasksAsDoneClick();
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: double.infinity,
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: ColorsExt.background(context),
                                border: Border.all(color: ColorsExt.grey2(context)),
                              ),
                              child: Center(
                                child: Text(
                                  t.label.deleteDialog.markAllTasksAsDone,
                                  style: TextStyle(fontSize: 15, color: ColorsExt.grey2(context)),
                                  textAlign: TextAlign.center,
                                ),
                              ),
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
                            style: TextStyle(fontSize: 15, color: ColorsExt.grey3(context)),
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
