import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/utils/no_scroll_behav.dart';
import 'package:mobile/extensions/event_extension.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';
import 'package:mobile/src/base/ui/widgets/base/separator.dart';
import 'package:mobile/src/events/ui/cubit/events_cubit.dart';
import 'package:mobile/src/events/ui/widgets/bottom_button.dart';
import 'package:mobile/src/events/ui/widgets/event_edit_modal.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/event/event.dart';

class EventModal extends StatelessWidget {
  const EventModal({
    Key? key,
    required this.event,
    required this.tapedDate,
  }) : super(key: key);
  final Event event;
  final DateTime? tapedDate;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventsCubit, EventsCubitState>(
      builder: (context, state) {
        return Material(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
          child: ScrollConfiguration(
            behavior: NoScrollBehav(),
            child: Column(
              children: [
                const SizedBox(height: 16),
                const ScrollChip(),
                Expanded(
                  child: ListView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: SvgPicture.asset(
                                Assets.images.icons.common.squareFillSVG,
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Text(
                              event.title ?? '',
                              style: TextStyle(
                                  fontSize: 20.0, fontWeight: FontWeight.w500, color: ColorsExt.grey1(context)),
                            ),
                          ],
                        ),
                      ),
                      const Separator(),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: SvgPicture.asset(
                                Assets.images.icons.common.calendarSVG,
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  if (event.startTime != null)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event.recurringId == null
                                              ? DateFormat("EEE dd MMM").format(DateTime.parse(event.startTime!))
                                              : DateFormat("EEE dd MMM").format(tapedDate!),
                                          style: TextStyle(
                                              fontSize: 17.0,
                                              fontWeight: FontWeight.w400,
                                              color: ColorsExt.grey2(context)),
                                        ),
                                        const SizedBox(height: 12.0),
                                        Text(
                                          DateFormat("HH:mm").format(DateTime.parse(event.startTime!).toLocal()),
                                          style: TextStyle(
                                              fontSize: 17.0,
                                              fontWeight: FontWeight.w600,
                                              color: ColorsExt.grey2(context)),
                                        ),
                                      ],
                                    ),
                                  if (event.startDate != null)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event.recurringId == null
                                              ? DateFormat("EEE dd MMM").format(DateTime.parse(event.startDate!))
                                              : DateFormat("EEE dd MMM").format(tapedDate!),
                                          style: TextStyle(
                                              fontSize: 17.0,
                                              fontWeight: FontWeight.w400,
                                              color: ColorsExt.grey2(context)),
                                        ),
                                      ],
                                    ),
                                  SvgPicture.asset(
                                    Assets.images.icons.common.chevronRightSVG,
                                    width: 22,
                                    height: 22,
                                  ),
                                  if (event.endTime != null)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          event.recurringId == null
                                              ? DateFormat("EEE dd MMM").format(DateTime.parse(event.endTime!))
                                              : DateFormat("EEE dd MMM").format(tapedDate!),
                                          style: TextStyle(
                                              fontSize: 17.0,
                                              fontWeight: FontWeight.w400,
                                              color: ColorsExt.grey2(context)),
                                        ),
                                        const SizedBox(height: 12.0),
                                        Text(
                                          DateFormat("HH:mm").format(DateTime.parse(event.endTime!).toLocal()),
                                          style: TextStyle(
                                              fontSize: 17.0,
                                              fontWeight: FontWeight.w600,
                                              color: ColorsExt.grey2(context)),
                                        ),
                                      ],
                                    ),
                                  if (event.endDate != null)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event.recurringId == null
                                              ? DateFormat("EEE dd MMM").format(DateTime.parse(event.endDate!))
                                              : DateFormat("EEE dd MMM").format(tapedDate!),
                                          style: TextStyle(
                                              fontSize: 17.0,
                                              fontWeight: FontWeight.w400,
                                              color: ColorsExt.grey2(context)),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Separator(),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: SvgPicture.asset(
                                    Assets.images.icons.google.meetSVG,
                                  ),
                                ),
                                const SizedBox(width: 16.0),
                                Text(
                                  t.event.googleMeet,
                                  style: TextStyle(
                                      fontSize: 17.0, fontWeight: FontWeight.w500, color: ColorsExt.grey2(context)),
                                ),
                              ],
                            ),
                            Text(
                              t.event.join.toUpperCase(),
                              style: TextStyle(
                                  fontSize: 15.0, fontWeight: FontWeight.w500, color: ColorsExt.akiflow(context)),
                            ),
                          ],
                        ),
                      ),
                      const Separator(),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: SvgPicture.asset(
                                Assets.images.icons.common.briefcaseSVG,
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Text(
                              t.event.busy,
                              style: TextStyle(
                                  fontSize: 17.0, fontWeight: FontWeight.w400, color: ColorsExt.grey2(context)),
                            ),
                          ],
                        ),
                      ),
                      const Separator(),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: SvgPicture.asset(
                                    Assets.images.icons.common.personCropCircleSVG,
                                    color:
                                        event.attendees != null ? ColorsExt.grey2(context) : ColorsExt.grey3(context),
                                  ),
                                ),
                                const SizedBox(width: 16.0),
                                Text(
                                  t.event.guests,
                                  style: TextStyle(
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.w400,
                                    color:
                                        event.attendees != null ? ColorsExt.grey2(context) : ColorsExt.grey3(context),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: SvgPicture.asset(
                                Assets.images.icons.common.envelopeSVG,
                                color: event.attendees != null ? ColorsExt.grey2(context) : ColorsExt.grey3(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (event.attendees != null)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemCount: event.attendees?.length ?? 0,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                              child: Row(
                                children: [
                                  event.attendees![index].responseStatus == AtendeeResponseStatus.accepted.id
                                      ? SizedBox(
                                          width: 19,
                                          height: 19,
                                          child: SvgPicture.asset(
                                            Assets.images.icons.common.checkmarkAltCircleFillSVG,
                                            color: ColorsExt.green(context),
                                          ),
                                        )
                                      : event.attendees![index].responseStatus == AtendeeResponseStatus.declined.id
                                          ? SizedBox(
                                              width: 19,
                                              height: 19,
                                              child: SvgPicture.asset(
                                                Assets.images.icons.common.xmarkCircleFillSVG,
                                                color: ColorsExt.red(context),
                                              ),
                                            )
                                          : SizedBox(
                                              width: 19,
                                              height: 19,
                                              child: SvgPicture.asset(
                                                Assets.images.icons.common.questionCircleFillSVG,
                                                color: ColorsExt.grey3(context),
                                              ),
                                            ),
                                  const SizedBox(width: 16.0),
                                  Row(
                                    children: [
                                      Text(
                                        event.attendees![index].email!.contains('group')
                                            ? '${event.attendees![index].displayName}'
                                            : '${event.attendees![index].email}',
                                        style: TextStyle(
                                            fontSize: 17.0,
                                            fontWeight: FontWeight.w400,
                                            color: ColorsExt.grey2(context)),
                                      ),
                                      if (event.attendees![index].organizer ?? false)
                                        Text(
                                          ' - ${t.event.organizer}',
                                          style: TextStyle(
                                              fontSize: 17.0,
                                              fontWeight: FontWeight.w400,
                                              color: ColorsExt.grey3(context)),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                    ],
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (event.attendees != null)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                t.event.going,
                                style: TextStyle(
                                    fontSize: 15.0, fontWeight: FontWeight.w400, color: ColorsExt.grey2(context)),
                              ),
                              Row(
                                children: [
                                  Text(
                                    t.event.yes,
                                    style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w500,
                                        color: event.isLoggedUserAttndingEvent == AtendeeResponseStatus.accepted
                                            ? ColorsExt.green(context)
                                            : ColorsExt.grey3(context)),
                                  ),
                                  const SizedBox(width: 32.0),
                                  Text(
                                    t.event.no,
                                    style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w500,
                                        color: event.isLoggedUserAttndingEvent == AtendeeResponseStatus.declined
                                            ? ColorsExt.red(context)
                                            : ColorsExt.grey3(context)),
                                  ),
                                  const SizedBox(width: 32.0),
                                  Text(
                                    t.event.maybe,
                                    style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w500,
                                        color: event.isLoggedUserAttndingEvent == AtendeeResponseStatus.tentative
                                            ? ColorsExt.grey2(context)
                                            : ColorsExt.grey3(context)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      const Separator(),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: event.content['organizer']['self'] == true
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  BottomButton(
                                      title: t.event.copy, image: Assets.images.icons.common.squareOnSquareSVG),
                                  BottomButton(
                                      title: t.event.share, image: Assets.images.icons.common.arrowshapeTurnUpRightSVG),
                                  BottomButton(
                                      title: t.event.mailGuests, image: Assets.images.icons.common.envelopeSVG),
                                  BottomButton(
                                    title: t.event.edit,
                                    image: Assets.images.icons.common.pencilSVG,
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      showCupertinoModalBottomSheet(
                                        context: context,
                                        builder: (context) => EventEditModal(
                                          event: event,
                                          tapedDate: tapedDate,
                                        ),
                                      );
                                    },
                                  ),
                                  BottomButton(title: t.event.delete, image: Assets.images.icons.common.trashSVG),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  BottomButton(
                                      title: t.event.share, image: Assets.images.icons.common.arrowshapeTurnUpRightSVG),
                                  BottomButton(
                                      title: t.event.mailGuests, image: Assets.images.icons.common.envelopeSVG),
                                  BottomButton(title: t.event.delete, image: Assets.images.icons.common.trashSVG),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
