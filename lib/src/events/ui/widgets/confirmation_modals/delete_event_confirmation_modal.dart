import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';

class DeleteEventConfirmationModal extends StatelessWidget {
  final String eventName;
  final Function() onTapDelete;
  const DeleteEventConfirmationModal({super.key, required this.eventName, required this.onTapDelete});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).backgroundColor,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Dimension.padding),
            topRight: Radius.circular(Dimension.padding),
          ),
        ),
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.all(Dimension.padding),
          child: ListView(
            shrinkWrap: true,
            children: [
              const ScrollChip(),
              const SizedBox(height: Dimension.paddingS),
              Padding(
                padding: const EdgeInsets.only(top: Dimension.padding, bottom: Dimension.padding),
                child: Row(
                  children: [
                    SvgPicture.asset(Assets.images.icons.common.trashSVG,
                        width: 28, height: 28, color: ColorsExt.grey2(context)),
                    const SizedBox(width: Dimension.paddingS),
                    Expanded(
                      child: Text(t.event.editEvent.deleteModal.title(eventName: eventName),
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              ?.copyWith(fontWeight: FontWeight.w500, color: ColorsExt.grey2(context))),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: Dimension.padding, bottom: Dimension.padding),
                child: Text(t.event.editEvent.deleteModal.description,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        ?.copyWith(fontWeight: FontWeight.w400, color: ColorsExt.grey3(context))),
              ),
              const SizedBox(height: Dimension.paddingM),
              InkWell(
                onTap: () {
                  onTapDelete();
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
                    child: Text(t.event.delete,
                        style: Theme.of(context).textTheme.subtitle1?.copyWith(
                              fontWeight: FontWeight.w400,
                              color: ColorsExt.grey2(context),
                            )),
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
