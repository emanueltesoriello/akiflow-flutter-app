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

class EventModal extends StatefulWidget {
  const EventModal({
    Key? key,
    required this.event,
    required this.tapedDate,
  }) : super(key: key);
  final Event event;
  final DateTime? tapedDate;

  @override
  State<EventModal> createState() => _EventModalState();
}

class _EventModalState extends State<EventModal> {
  late Event selectedEvent;
  @override
  void initState() {
    selectedEvent = widget.event;
    super.initState();
  }

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
                            Expanded(
                              child: Text(
                                widget.event.title ?? '',
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 20.0, fontWeight: FontWeight.w500, color: ColorsExt.grey1(context)),
                              ),
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
                                  if (widget.event.startTime != null)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.event.recurringId == null
                                              ? DateFormat("EEE dd MMM").format(DateTime.parse(widget.event.startTime!))
                                              : DateFormat("EEE dd MMM").format(widget.tapedDate!),
                                          style: TextStyle(
                                              fontSize: 17.0,
                                              fontWeight: FontWeight.w400,
                                              color: ColorsExt.grey2(context)),
                                        ),
                                        const SizedBox(height: 12.0),
                                        Text(
                                          DateFormat("HH:mm").format(DateTime.parse(widget.event.startTime!).toLocal()),
                                          style: TextStyle(
                                              fontSize: 17.0,
                                              fontWeight: FontWeight.w600,
                                              color: ColorsExt.grey2(context)),
                                        ),
                                      ],
                                    ),
                                  if (widget.event.startDate != null)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.event.recurringId == null
                                              ? DateFormat("EEE dd MMM").format(DateTime.parse(widget.event.startDate!))
                                              : DateFormat("EEE dd MMM").format(widget.tapedDate!),
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
                                  if (widget.event.endTime != null)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          widget.event.recurringId == null
                                              ? DateFormat("EEE dd MMM").format(DateTime.parse(widget.event.endTime!))
                                              : DateFormat("EEE dd MMM").format(widget.tapedDate!),
                                          style: TextStyle(
                                              fontSize: 17.0,
                                              fontWeight: FontWeight.w400,
                                              color: ColorsExt.grey2(context)),
                                        ),
                                        const SizedBox(height: 12.0),
                                        Text(
                                          DateFormat("HH:mm").format(DateTime.parse(widget.event.endTime!).toLocal()),
                                          style: TextStyle(
                                              fontSize: 17.0,
                                              fontWeight: FontWeight.w600,
                                              color: ColorsExt.grey2(context)),
                                        ),
                                      ],
                                    ),
                                  if (widget.event.endDate != null)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.event.recurringId == null
                                              ? DateFormat("EEE dd MMM").format(DateTime.parse(widget.event.endDate!))
                                              : DateFormat("EEE dd MMM").format(widget.tapedDate!),
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
                                    color: widget.event.attendees != null
                                        ? ColorsExt.grey2(context)
                                        : ColorsExt.grey3(context),
                                  ),
                                ),
                                const SizedBox(width: 16.0),
                                Text(
                                  t.event.guests,
                                  style: TextStyle(
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.w400,
                                    color: widget.event.attendees != null
                                        ? ColorsExt.grey2(context)
                                        : ColorsExt.grey3(context),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: SvgPicture.asset(
                                Assets.images.icons.common.envelopeSVG,
                                color: widget.event.attendees != null
                                    ? ColorsExt.grey2(context)
                                    : ColorsExt.grey3(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.event.attendees != null)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemCount: widget.event.attendees?.length ?? 0,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                              child: Row(
                                children: [
                                  widget.event.attendees![index].responseStatus == AtendeeResponseStatus.accepted.id
                                      ? SizedBox(
                                          width: 19,
                                          height: 19,
                                          child: SvgPicture.asset(
                                            Assets.images.icons.common.checkmarkAltCircleFillSVG,
                                            color: ColorsExt.green(context),
                                          ),
                                        )
                                      : widget.event.attendees![index].responseStatus ==
                                              AtendeeResponseStatus.declined.id
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
                                        widget.event.attendees![index].email!.contains('group')
                                            ? '${widget.event.attendees![index].displayName}'
                                            : '${widget.event.attendees![index].email}',
                                        style: TextStyle(
                                            fontSize: 17.0,
                                            fontWeight: FontWeight.w400,
                                            color: ColorsExt.grey2(context)),
                                      ),
                                      if (widget.event.attendees![index].organizer ?? false)
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
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (widget.event.attendees != null && widget.event.attendees!.isNotEmpty)
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
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedEvent.setLoggeduserAttendingResponse(AtendeeResponseStatus.accepted);
                                      });
                                      context
                                          .read<EventsCubit>()
                                          .updateAtend(widget.event, AtendeeResponseStatus.accepted.id);
                                    },
                                    child: Text(
                                      t.event.yes,
                                      style: TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              widget.event.isLoggedUserAttndingEvent == AtendeeResponseStatus.accepted
                                                  ? ColorsExt.green(context)
                                                  : ColorsExt.grey3(context)),
                                    ),
                                  ),
                                  const SizedBox(width: 32.0),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedEvent.setLoggeduserAttendingResponse(AtendeeResponseStatus.declined);
                                      });
                                      context
                                          .read<EventsCubit>()
                                          .updateAtend(widget.event, AtendeeResponseStatus.declined.id);
                                    },
                                    child: Text(
                                      t.event.no,
                                      style: TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              widget.event.isLoggedUserAttndingEvent == AtendeeResponseStatus.declined
                                                  ? ColorsExt.red(context)
                                                  : ColorsExt.grey3(context)),
                                    ),
                                  ),
                                  const SizedBox(width: 32.0),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedEvent.setLoggeduserAttendingResponse(AtendeeResponseStatus.tentative);
                                      });
                                      context
                                          .read<EventsCubit>()
                                          .updateAtend(widget.event, AtendeeResponseStatus.tentative.id);
                                    },
                                    child: Text(
                                      t.event.maybe,
                                      style: TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              widget.event.isLoggedUserAttndingEvent == AtendeeResponseStatus.tentative
                                                  ? ColorsExt.grey2(context)
                                                  : ColorsExt.grey3(context)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      const Separator(),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: widget.event.creatorId == widget.event.originCalendarId
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  if (widget.event.attendees != null)
                                    BottomButton(
                                        title: t.event.mailGuests, image: Assets.images.icons.common.envelopeSVG),
                                  BottomButton(
                                    title: t.event.edit,
                                    image: Assets.images.icons.common.pencilSVG,
                                    onTap: () {
                                      showCupertinoModalBottomSheet(
                                        context: context,
                                        builder: (context) => EventEditModal(
                                          event: widget.event,
                                          tapedDate: widget.tapedDate,
                                        ),
                                      ).whenComplete(
                                        () {
                                          Navigator.of(context).pop();
                                        },
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
