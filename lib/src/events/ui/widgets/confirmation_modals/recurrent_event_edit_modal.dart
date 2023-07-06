import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';

class RecurrentEventEditModal extends StatelessWidget {
  final Function() onlyThisTap;
  final Function() thisAndFutureTap;
  final Function() allTap;
  final bool deleteEvent;
  final bool showThisAndFutureButton;
  const RecurrentEventEditModal({
    super.key,
    required this.onlyThisTap,
    required this.thisAndFutureTap,
    required this.allTap,
    this.deleteEvent = false,
    this.showThisAndFutureButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.background,
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
                    SvgPicture.asset(
                        deleteEvent ? Assets.images.icons.common.trashSVG : Assets.images.icons.common.pencilSVG,
                        width: 28,
                        height: 28,
                        color: ColorsExt.grey800(context)),
                    const SizedBox(width: Dimension.paddingS),
                    Text(
                        deleteEvent
                            ? t.event.editEvent.repeatingEditModal.deleteTitle
                            : t.event.editEvent.repeatingEditModal.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: ColorsExt.grey800(context),
                            )),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: Dimension.padding, bottom: Dimension.padding),
                child: Text(
                  deleteEvent
                      ? t.event.editEvent.repeatingEditModal.deleteDescription
                      : t.event.editEvent.repeatingEditModal.description,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w400, color: ColorsExt.grey800(context)),
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
                      border: Border.all(color: ColorsExt.grey300(context))),
                  child: Center(
                    child: Text(
                      t.event.editEvent.repeatingEditModal.onlyThis,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w400, color: ColorsExt.grey800(context)),
                    ),
                  ),
                ),
              ),
              if (showThisAndFutureButton)
                Column(
                  children: [
                    const SizedBox(height: Dimension.padding),
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
                            borderRadius: BorderRadius.circular(Dimension.radius),
                            border: Border.all(color: ColorsExt.grey300(context))),
                        child: Center(
                          child: Text(
                            t.event.editEvent.repeatingEditModal.thisAndAllFuture,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w400, color: ColorsExt.grey800(context)),
                          ),
                        ),
                      ),
                    ),
                  ],
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
                      border: Border.all(color: ColorsExt.grey300(context))),
                  child: Center(
                    child: Text(
                      t.event.editEvent.repeatingEditModal.allEvents,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w400, color: ColorsExt.grey800(context)),
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
