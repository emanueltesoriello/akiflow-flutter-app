import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';

class RecurrentEventEditModal extends StatelessWidget {
  final Function() onlyThisTap;
  final Function() thisAndFutureTap;
  final Function() allTap;
  const RecurrentEventEditModal(
      {super.key, required this.onlyThisTap, required this.thisAndFutureTap, required this.allTap});

  @override
  Widget build(BuildContext context) {
    print('RecurrentEventEditModal entered');
    return Material(
      color: Theme.of(context).backgroundColor,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
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
                padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                child: Row(
                  children: [
                    SvgPicture.asset(Assets.images.icons.common.pencilSVG,
                        width: 28, height: 28, color: ColorsExt.grey2(context)),
                    const SizedBox(width: 8.0),
                    Text(
                      'Editing repeating event',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: ColorsExt.grey2(context)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                child: Text(t.editTask.repeatingEditDialog.description,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400, color: ColorsExt.grey3(context))),
              ),
              const SizedBox(height: 24),
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
                      borderRadius: BorderRadius.circular(8.0), border: Border.all(color: ColorsExt.grey4(context))),
                  child: Center(
                    child: Text(
                      'Only this event',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                        color: ColorsExt.grey2(context),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  thisAndFutureTap();
                  Navigator.pop(context);
                },
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 46,
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0), border: Border.all(color: ColorsExt.grey4(context))),
                  child: Center(
                    child: Text(
                      'This and all future events',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                        color: ColorsExt.grey2(context),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
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
                      borderRadius: BorderRadius.circular(8.0), border: Border.all(color: ColorsExt.grey4(context))),
                  child: Center(
                    child: Text(
                      'All events',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                        color: ColorsExt.grey2(context),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
