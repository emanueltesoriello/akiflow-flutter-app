import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';
import 'package:mobile/src/base/ui/widgets/base/separator.dart';
import 'package:mobile/src/base/ui/widgets/interactive_webview.dart';
import 'package:mobile/src/events/ui/cubit/events_cubit.dart';
import 'package:mobile/src/events/ui/widgets/bottom_button.dart';
import 'package:mobile/src/events/ui/widgets/event_edit_time_modal.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/event/event.dart';
import 'package:models/nullable.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tuple/tuple.dart' as tuple;
import 'package:flutter_quill/flutter_quill.dart' as quill;

class EventEditModal extends StatefulWidget {
  const EventEditModal({
    Key? key,
    required this.event,
    required this.tapedDate,
  }) : super(key: key);
  final Event event;
  final DateTime? tapedDate;

  @override
  State<EventEditModal> createState() => _EventEditModalState();
}

class _EventEditModalState extends State<EventEditModal> {
  late TextEditingController titleController;
  late TextEditingController locationController;
  late TextEditingController descriptionController;
  late bool isAllDay;
  late Event updatedEvent;
  final FocusNode _descriptionFocusNode = FocusNode();
  StreamSubscription? streamSubscription;

  ValueNotifier<quill.QuillController> quillController = ValueNotifier<quill.QuillController>(
      quill.QuillController(document: quill.Document(), selection: const TextSelection.collapsed(offset: 0)));

  @override
  void initState() {
    titleController = TextEditingController()..text = widget.event.title ?? '';
    titleController.selection = TextSelection.collapsed(offset: titleController.text.length);

    locationController = TextEditingController()..text = widget.event.content['location'] ?? '';
    descriptionController = TextEditingController()..text = widget.event.description ?? '';

    initDescription().whenComplete(() {
      streamSubscription = quillController.value.changes.listen((change) async {
        List<dynamic> delta = quillController.value.document.toDelta().toJson();
        String html = await InteractiveWebView.deltaToHtml(delta);
        descriptionController.text = html;
      });
    });

    isAllDay = widget.event.startTime == null && widget.event.startDate != null;

    updatedEvent = widget.event;
    super.initState();
  }

  Future initDescription() async {
    String html = widget.event.description ?? '';
    quill.Document document = await InteractiveWebView.htmlToDelta(html);
    quillController.value =
        quill.QuillController(document: document, selection: const TextSelection.collapsed(offset: 0));
    quillController.value.moveCursorToEnd();
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var space = MediaQuery.of(context).viewInsets.bottom;
    return BlocBuilder<EventsCubit, EventsCubitState>(
      builder: (context, state) {
        return Material(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const ScrollChip(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: !_descriptionFocusNode.hasFocus && space > 86 ? space - 86 : 0),
                  reverse: _descriptionFocusNode.hasFocus ? true : false,
                  child: Column(
                    children: [
                      ListView(
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        shrinkWrap: true,
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
                                  child: TextField(
                                    controller: titleController,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w500,
                                      color: ColorsExt.grey1(context),
                                    ),
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
                                      if (!isAllDay) _startTime(context),
                                      if (isAllDay) _startDate(context),
                                      SvgPicture.asset(
                                        Assets.images.icons.common.chevronRightSVG,
                                        width: 22,
                                        height: 22,
                                      ),
                                      if (!isAllDay) _endTime(context),
                                      if (isAllDay) _endDate(context),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: SvgPicture.asset(
                                    Assets.images.icons.common.recurrentSVG,
                                    color: ColorsExt.grey3(context),
                                  ),
                                ),
                                const SizedBox(width: 16.0),
                                Text(
                                  'Set Repeat',
                                  style: TextStyle(
                                      fontSize: 17.0, fontWeight: FontWeight.w400, color: ColorsExt.grey3(context)),
                                ),
                              ],
                            ),
                          ),
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
                                      child: SvgPicture.asset(Assets.images.icons.common.daySVG,
                                          color: isAllDay ? ColorsExt.grey2(context) : ColorsExt.grey3(context)),
                                    ),
                                    const SizedBox(width: 16.0),
                                    Text(
                                      "All day",
                                      style: TextStyle(
                                          fontSize: 17.0,
                                          fontWeight: FontWeight.w400,
                                          color: isAllDay ? ColorsExt.grey2(context) : ColorsExt.grey3(context)),
                                    ),
                                  ],
                                ),
                                FlutterSwitch(
                                  width: 48,
                                  height: 24,
                                  toggleSize: 20,
                                  activeColor: ColorsExt.akiflow(context),
                                  inactiveColor: ColorsExt.grey5(context),
                                  value: isAllDay,
                                  borderRadius: 24,
                                  padding: 2,
                                  onToggle: (value) {
                                    setState(() {
                                      isAllDay = !isAllDay;

                                      if (value) {
                                        updatedEvent = updatedEvent.copyWith(
                                            startTime: Nullable(null),
                                            endTime: Nullable(null),
                                            startDate: Nullable(DateFormat("y-MM-dd").format(widget.tapedDate!)),
                                            endDate: Nullable(DateFormat("y-MM-dd").format(widget.tapedDate!)));
                                      } else {
                                        updatedEvent = updatedEvent.copyWith(
                                          startTime: Nullable(widget.tapedDate!.toIso8601String()),
                                          endTime: Nullable(
                                              widget.tapedDate!.add(const Duration(minutes: 30)).toIso8601String()),
                                          startDate: Nullable(null),
                                          endDate: Nullable(null),
                                        );
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const Separator(),
                          widget.event.meetingUrl != null
                              ? Padding(
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
                                              Assets.images.icons.google.googleSVG,
                                            ),
                                          ),
                                          const SizedBox(width: 16.0),
                                          Text(
                                            t.event.googleMeet,
                                            style: TextStyle(
                                                fontSize: 17.0,
                                                fontWeight: FontWeight.w500,
                                                color: ColorsExt.grey2(context)),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        t.event.join.toUpperCase(),
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w500,
                                            color: ColorsExt.akiflow(context)),
                                      ),
                                    ],
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: SvgPicture.asset(
                                          Assets.images.icons.common.videocamSVG,
                                          color: ColorsExt.grey3(context),
                                        ),
                                      ),
                                      const SizedBox(width: 16.0),
                                      Text(
                                        'Add conference',
                                        style: TextStyle(
                                            fontSize: 17.0,
                                            fontWeight: FontWeight.w400,
                                            color: ColorsExt.grey3(context)),
                                      ),
                                    ],
                                  ),
                                ),
                          const Separator(),
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: SvgPicture.asset(
                                    Assets.images.icons.common.mapSVG,
                                    color: widget.event.content['location'] == null
                                        ? ColorsExt.grey3(context)
                                        : ColorsExt.grey2(context),
                                  ),
                                ),
                                const SizedBox(width: 16.0),
                                Expanded(
                                  child: TextField(
                                    readOnly: true,
                                    controller: locationController,
                                    decoration: InputDecoration(
                                      hintText: 'Add location',
                                      hintStyle: TextStyle(
                                          fontSize: 17.0, fontWeight: FontWeight.w400, color: ColorsExt.grey3(context)),
                                      border: InputBorder.none,
                                    ),
                                    style: TextStyle(
                                        fontSize: 17.0, fontWeight: FontWeight.w400, color: ColorsExt.grey2(context)),
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
                                      widget.event.attendees![index].responseStatus == 'accepted'
                                          ? SizedBox(
                                              width: 19,
                                              height: 19,
                                              child: SvgPicture.asset(
                                                Assets.images.icons.common.checkmarkAltCircleFillSVG,
                                                color: ColorsExt.green(context),
                                              ),
                                            )
                                          : widget.event.attendees![index].responseStatus == 'declined'
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
                            ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                            child: Row(
                              children: [
                                SvgPicture.asset(Assets.images.icons.common.plusCircleSVG,
                                    width: 20, height: 20, color: ColorsExt.grey3(context)),
                                const SizedBox(width: 16.0),
                                Text(
                                  'Add guests',
                                  style: TextStyle(
                                      fontSize: 17.0, fontWeight: FontWeight.w400, color: ColorsExt.grey3(context)),
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
                                    Assets.images.icons.common.textJustifyLeftSVG,
                                  ),
                                ),
                                const SizedBox(width: 16.0),
                                Expanded(
                                  child: _description(context),
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
                                    Assets.images.icons.common.squareFillSVG,
                                  ),
                                ),
                                const SizedBox(width: 16.0),
                                Text(
                                  'Default color',
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
                                      width: 22,
                                      height: 22,
                                      child: SvgPicture.asset(
                                        Assets.images.icons.google.calendarSVG,
                                      ),
                                    ),
                                    const SizedBox(width: 16.0),
                                    Text(
                                      'View on Google Calendar',
                                      style: TextStyle(
                                          fontSize: 17.0, fontWeight: FontWeight.w400, color: ColorsExt.grey2(context)),
                                    ),
                                  ],
                                ),
                                SvgPicture.asset(
                                  Assets.images.icons.common.arrowUpRightSquareSVG,
                                  width: 20,
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          BottomButton(
                              title: t.cancel,
                              image: Assets.images.icons.common.arrowshapeTurnUpLeftSVG,
                              onTap: () => Navigator.pop(context)),
                          BottomButton(
                            title: 'Save changes',
                            image: Assets.images.icons.common.checkmarkAltSVG,
                            containerColor: ColorsExt.green20(context),
                            iconColor: ColorsExt.green(context),
                            onTap: () {
                              updatedEvent = updatedEvent.copyWith(
                                  title: titleController.text,
                                  description: descriptionController.text,
                                  updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()));

                              context.read<EventsCubit>().updateEvent(updatedEvent);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: _descriptionFocusNode.hasFocus && space > 36 ? space - 36 : 0),
            ],
          ),
        );
      },
    );
  }

  InkWell _startDate(BuildContext context) {
    return InkWell(
      onTap: () {
        showCupertinoModalBottomSheet(
          context: context,
          builder: (context) => EventEditTimeModal(
            showTime: false,
            initialDate: updatedEvent.startDate != null && updatedEvent.recurringId == null
                ? DateTime.parse(updatedEvent.startDate!).toLocal()
                : widget.tapedDate!,
            initialDatetime: null,
            onSelectDate: ({required DateTime? date, required DateTime? datetime}) {
              setState(() {
                isAllDay = true;
                updatedEvent = updatedEvent.copyWith(
                  startDate: Nullable(DateFormat("y-MM-dd").format(date!.toUtc())),
                  endDate: Nullable(DateFormat("y-MM-dd").format(date.toUtc())),
                );
              });
            },
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            updatedEvent.recurringId == null
                ? DateFormat("EEE dd MMM").format(DateTime.parse(updatedEvent.startDate!))
                : DateFormat("EEE dd MMM").format(widget.tapedDate!),
            style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w400, color: ColorsExt.grey2(context)),
          ),
        ],
      ),
    );
  }

  InkWell _startTime(BuildContext context) {
    return InkWell(
      onTap: () {
        showCupertinoModalBottomSheet(
          context: context,
          builder: (context) => EventEditTimeModal(
            initialDate: widget.tapedDate!,
            initialDatetime: updatedEvent.startTime != null ? DateTime.parse(updatedEvent.startTime!).toLocal() : null,
            onSelectDate: ({required DateTime? date, required DateTime? datetime}) {
              setState(() {
                datetime == null ? isAllDay = true : isAllDay = false;
                updatedEvent = updatedEvent.copyWith(
                  startDate: datetime == null ? Nullable(DateFormat("y-MM-dd").format(date!.toUtc())) : Nullable(null),
                  endDate: datetime == null ? Nullable(DateFormat("y-MM-dd").format(date!.toUtc())) : Nullable(null),
                  startTime: datetime != null ? Nullable(datetime.toUtc().toIso8601String()) : Nullable(null),
                  endTime: datetime != null
                      ? Nullable(datetime.toUtc().add(const Duration(minutes: 30)).toIso8601String())
                      : Nullable(null),
                );
              });
            },
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            updatedEvent.recurringId == null
                ? DateFormat("EEE dd MMM").format(DateTime.parse(updatedEvent.startTime!))
                : DateFormat("EEE dd MMM").format(widget.tapedDate!),
            style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w400, color: ColorsExt.grey2(context)),
          ),
          const SizedBox(height: 12.0),
          Text(
            DateFormat("HH:mm").format(DateTime.parse(updatedEvent.startTime!).toLocal()),
            style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w600, color: ColorsExt.grey2(context)),
          ),
        ],
      ),
    );
  }

  InkWell _endDate(BuildContext context) {
    return InkWell(
      onTap: () {
        showCupertinoModalBottomSheet(
          context: context,
          builder: (context) => EventEditTimeModal(
            showTime: false,
            initialDate: updatedEvent.endDate != null && updatedEvent.recurringId == null
                ? DateTime.parse(updatedEvent.endDate!).toLocal()
                : widget.tapedDate!,
            initialDatetime: null,
            onSelectDate: ({required DateTime? date, required DateTime? datetime}) {
              setState(() {
                isAllDay = true;
                updatedEvent = updatedEvent.copyWith(endDate: Nullable(DateFormat("y-MM-dd").format(date!.toUtc())));
              });
            },
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            updatedEvent.recurringId == null
                ? DateFormat("EEE dd MMM").format(DateTime.parse(updatedEvent.endDate!))
                : DateFormat("EEE dd MMM").format(widget.tapedDate!),
            style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w400, color: ColorsExt.grey2(context)),
          ),
        ],
      ),
    );
  }

  InkWell _endTime(BuildContext context) {
    return InkWell(
      onTap: () {
        showCupertinoModalBottomSheet(
          context: context,
          builder: (context) => EventEditTimeModal(
            initialDate: updatedEvent.endTime != null && updatedEvent.recurringId == null
                ? DateTime.parse(updatedEvent.endTime!).toLocal()
                : widget.tapedDate!,
            initialDatetime: updatedEvent.endTime != null ? DateTime.parse(updatedEvent.endTime!).toLocal() : null,
            onSelectDate: ({required DateTime? date, required DateTime? datetime}) {
              setState(() {
                if (datetime == null) {
                  isAllDay = true;
                }
                updatedEvent = updatedEvent.copyWith(
                  endDate: datetime == null ? Nullable(DateFormat("y-MM-dd").format(date!.toUtc())) : Nullable(null),
                  endTime: datetime != null ? Nullable(datetime.toUtc().toIso8601String()) : Nullable(null),
                );
              });
            },
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            updatedEvent.recurringId == null
                ? DateFormat("EEE dd MMM").format(DateTime.parse(updatedEvent.endTime!))
                : DateFormat("EEE dd MMM").format(widget.tapedDate!),
            style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w400, color: ColorsExt.grey2(context)),
          ),
          const SizedBox(height: 12.0),
          Text(
            DateFormat("HH:mm").format(DateTime.parse(updatedEvent.endTime!).toLocal()),
            style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w600, color: ColorsExt.grey2(context)),
          ),
        ],
      ),
    );
  }

  Widget _description(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: quillController,
      builder: (context, quill.QuillController value, child) => Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme: TextSelectionThemeData(
            selectionColor: ColorsExt.akiflow(context)!.withOpacity(0.1),
          ),
        ),
        child: quill.QuillEditor(
          controller: value,
          readOnly: false,
          scrollController: ScrollController(),
          scrollable: true,
          focusNode: _descriptionFocusNode,
          autoFocus: false,
          expands: false,
          padding: EdgeInsets.zero,
          placeholder: t.task.description,
          linkActionPickerDelegate: (BuildContext context, String link, node) async {
            launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
            return quill.LinkMenuAction.none;
          },
          customStyles: quill.DefaultStyles(
            placeHolder: quill.DefaultTextBlockStyle(
              TextStyle(fontSize: 17.0, fontWeight: FontWeight.w400, color: ColorsExt.grey3(context)),
              const tuple.Tuple2(0, 0),
              const tuple.Tuple2(0, 0),
              null,
            ),
          ),
        ),
      ),
    );
  }
}
