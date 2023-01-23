import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/utils/no_scroll_behav.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';
import 'package:mobile/src/base/ui/widgets/base/separator.dart';
import 'package:mobile/src/calendar/ui/cubit/calendar_cubit.dart';
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
    return BlocBuilder<CalendarCubit, CalendarCubitState>(
      builder: (context, state) {
        return Material(
          color: Colors.transparent,
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
                            Container(
                              height: 20.0,
                              width: 20.0,
                              decoration: const BoxDecoration(
                                color: Colors.cyan,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(4.0),
                                ),
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
                            SvgPicture.asset(
                              Assets.images.icons.common.calendarSVG,
                              width: 22,
                              height: 22,
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
                                SvgPicture.asset(
                                  Assets.images.icons.google.googleSVG,
                                  width: 22,
                                  height: 22,
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
                            SvgPicture.asset(
                              Assets.images.icons.common.folderSVG,
                              width: 22,
                              height: 22,
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
                                SvgPicture.asset(
                                  Assets.images.icons.common.personCropCircleSVG,
                                  width: 22,
                                  height: 22,
                                  color: event.attendees != null ? ColorsExt.grey2(context) : ColorsExt.grey3(context),
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
                            SvgPicture.asset(
                              Assets.images.icons.common.envelopeSVG,
                              width: 22,
                              height: 22,
                              color: event.attendees != null ? ColorsExt.grey2(context) : ColorsExt.grey3(context),
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
                              padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                              child: Row(
                                children: [
                                  event.attendees![index].responseStatus == 'accepted'
                                      ? SvgPicture.asset(
                                          Assets.images.icons.common.checkDoneSVG,
                                          width: 22,
                                          height: 22,
                                          color: ColorsExt.green(context),
                                        )
                                      : event.attendees![index].responseStatus == 'declined'
                                          ? SvgPicture.asset(
                                              Assets.images.icons.common.xmarkSquareSVG,
                                              width: 22,
                                              height: 22,
                                              color: ColorsExt.red(context),
                                            )
                                          : SvgPicture.asset(
                                              Assets.images.icons.common.checkEmptySVG,
                                              width: 22,
                                              height: 22,
                                              color: ColorsExt.grey3(context),
                                            ),
                                  const SizedBox(width: 16.0),
                                  Row(
                                    children: [
                                      Text(
                                        '${event.attendees![index].email}',
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
                                      fontSize: 15.0, fontWeight: FontWeight.w400, color: ColorsExt.grey2(context)),
                                ),
                                const SizedBox(width: 32.0),
                                Text(
                                  t.event.no,
                                  style: TextStyle(
                                      fontSize: 15.0, fontWeight: FontWeight.w400, color: ColorsExt.grey2(context)),
                                ),
                                const SizedBox(width: 32.0),
                                Text(
                                  t.event.maybe,
                                  style: TextStyle(
                                      fontSize: 15.0, fontWeight: FontWeight.w400, color: ColorsExt.grey2(context)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Separator(),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _BottomButton(title: t.event.copy, image: Assets.images.icons.common.squareOnSquareSVG),
                            _BottomButton(
                                title: t.event.share, image: Assets.images.icons.common.arrowUpRightSquareSVG),
                            _BottomButton(title: t.event.mailGuests, image: Assets.images.icons.common.envelopeSVG),
                            _BottomButton(title: t.event.edit, image: Assets.images.icons.common.pencilSVG),
                            _BottomButton(title: t.event.delete, image: Assets.images.icons.common.trashSVG),
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

class _BottomButton extends StatelessWidget {
  final String title;
  final String image;
  const _BottomButton({
    Key? key,
    required this.title,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {},
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 40.0,
                width: 40.0,
                decoration: BoxDecoration(
                  color: ColorsExt.grey6(context),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(12.0),
                  ),
                ),
              ),
              SvgPicture.asset(
                image,
                width: 22,
                height: 22,
                color: ColorsExt.grey3(context),
              ),
            ],
          ),
        ),
        Text(
          title,
          style: TextStyle(fontSize: 11.0, fontWeight: FontWeight.w500, color: ColorsExt.grey2(context)),
        ),
      ],
    );
  }
}
