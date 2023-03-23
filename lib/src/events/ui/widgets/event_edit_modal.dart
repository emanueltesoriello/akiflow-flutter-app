import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/extensions/event_extension.dart';
import 'package:mobile/extensions/string_extension.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';
import 'package:mobile/src/base/ui/widgets/base/separator.dart';
import 'package:mobile/src/base/ui/widgets/custom_snackbar.dart';
import 'package:mobile/src/base/ui/widgets/interactive_webview.dart';
import 'package:mobile/src/events/ui/cubit/events_cubit.dart';
import 'package:mobile/src/events/ui/widgets/add_guests_modal.dart';
import 'package:mobile/src/events/ui/widgets/bottom_button.dart';
import 'package:mobile/src/events/ui/widgets/change_color_modal.dart';
import 'package:mobile/src/events/ui/widgets/event_edit_time_modal.dart';
import 'package:mobile/src/events/ui/widgets/recurrence_modal.dart';
import 'package:mobile/src/events/ui/widgets/recurrent_event_edit_modal.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/event/event.dart';
import 'package:models/event/event_atendee.dart';
import 'package:models/nullable.dart';
import 'package:rrule/rrule.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tuple/tuple.dart' as tuple;
import 'package:flutter_quill/flutter_quill.dart' as quill;

class EventEditModal extends StatefulWidget {
  const EventEditModal({
    Key? key,
    required this.event,
    required this.tappedDate,
    required this.originalStartTime,
    this.createingEvent,
  }) : super(key: key);
  final Event event;
  final DateTime tappedDate;
  final String? originalStartTime;
  final bool? createingEvent;

  @override
  State<EventEditModal> createState() => _EventEditModalState();
}

class _EventEditModalState extends State<EventEditModal> {
  late TextEditingController titleController;
  late TextEditingController locationController;
  late TextEditingController descriptionController;
  late EventRecurrenceModalType selectedRecurrence;
  late bool isAllDay;
  late Event updatedEvent;
  final FocusNode _descriptionFocusNode = FocusNode();
  StreamSubscription? streamSubscription;
  late List<String> atendeesToAdd;
  late List<String> atendeesToRemove;
  late bool addingMeeting;
  late bool removingMeeting;
  late bool timeChanged;
  late bool dateChanged;

  ValueNotifier<quill.QuillController> quillController = ValueNotifier<quill.QuillController>(
      quill.QuillController(document: quill.Document(), selection: const TextSelection.collapsed(offset: 0)));

  @override
  void initState() {
    titleController = TextEditingController()..text = widget.event.title ?? '';
    titleController.selection = TextSelection.collapsed(offset: titleController.text.length);

    locationController = TextEditingController()..text = widget.event.content?['location'] ?? '';
    descriptionController = TextEditingController()..text = widget.event.description ?? '';

    atendeesToAdd = List.empty(growable: true);
    atendeesToRemove = List.empty(growable: true);
    addingMeeting = false;
    removingMeeting = false;

    initDescription().whenComplete(() {
      streamSubscription = quillController.value.changes.listen((change) async {
        List<dynamic> delta = quillController.value.document.toDelta().toJson();
        String html = await InteractiveWebView.deltaToHtml(delta);
        descriptionController.text = html;
      });
    });

    isAllDay = widget.event.startTime == null && widget.event.startDate != null;
    timeChanged = false;
    dateChanged = false;

    updatedEvent = widget.event;
    selectedRecurrence = updatedEvent.recurrenceComputed;
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
                                    color: ColorsExt.fromHex(EventExt.computeColor(updatedEvent)),
                                  ),
                                ),
                                const SizedBox(width: 16.0),
                                Expanded(
                                  child: TextField(
                                    autofocus: widget.createingEvent ?? false,
                                    controller: titleController,
                                    decoration: const InputDecoration(border: InputBorder.none, hintText: 'Add title'),
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
                          InkWell(
                            onTap: () {
                              showCupertinoModalBottomSheet(
                                context: context,
                                builder: (context) => EventRecurrenceModal(
                                  onChange: (RecurrenceRule? rule) {
                                    if (rule != null) {
                                      updatedEvent = updatedEvent.copyWith(
                                          recurringId: updatedEvent.recurringId ?? updatedEvent.id,
                                          recurrence: Nullable([updatedEvent.recurrenceRuleComputed(rule)]));
                                    } else {
                                      updatedEvent = updatedEvent.copyWith(recurrence: Nullable(null));
                                    }
                                  },
                                  onRecurrenceType: (EventRecurrenceModalType type) {
                                    setState(() {
                                      selectedRecurrence = type;
                                    });
                                  },
                                  selectedRecurrence: updatedEvent.recurrenceComputed,
                                  rule: updatedEvent.ruleFromStringList,
                                  eventStartTime: updatedEvent.startTime != null
                                      ? DateTime.parse(updatedEvent.startTime!)
                                      : DateTime.parse(updatedEvent.startDate!),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: SvgPicture.asset(
                                      Assets.images.icons.common.recurrentSVG,
                                      color: selectedRecurrence == EventRecurrenceModalType.none
                                          ? ColorsExt.grey3(context)
                                          : ColorsExt.grey2(context),
                                    ),
                                  ),
                                  const SizedBox(width: 16.0),
                                  Text(
                                    _recurrence(selectedRecurrence),
                                    style: TextStyle(
                                        fontSize: 17.0,
                                        fontWeight: FontWeight.w400,
                                        color: selectedRecurrence == EventRecurrenceModalType.none
                                            ? ColorsExt.grey3(context)
                                            : ColorsExt.grey2(context)),
                                  ),
                                ],
                              ),
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
                                      t.event.editEvent.allDay,
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
                                            startDate:
                                                Nullable(DateFormat("y-MM-dd").format(widget.tappedDate.toUtc())),
                                            endDate: Nullable(DateFormat("y-MM-dd").format(widget.tappedDate.toUtc())));
                                      } else {
                                        updatedEvent = updatedEvent.copyWith(
                                          startTime: widget.event.startTime != null
                                              ? Nullable(widget.event.startTime)
                                              : Nullable(widget.tappedDate.toUtc().toIso8601String()),
                                          endTime: widget.event.endTime != null
                                              ? Nullable(widget.event.endTime)
                                              : Nullable(widget.tappedDate
                                                  .toUtc()
                                                  .add(const Duration(minutes: 30))
                                                  .toIso8601String()),
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
                          (updatedEvent.meetingSolution != null || addingMeeting) && !removingMeeting
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
                                              updatedEvent.meetingSolution == 'meet' && !addingMeeting
                                                  ? Assets.images.icons.google.meetSVG
                                                  : updatedEvent.meetingSolution == 'zoom' && !addingMeeting
                                                      ? Assets.images.icons.zoom.zoomSVG
                                                      : context.read<EventsCubit>().getDefaultConferenceIcon(),
                                            ),
                                          ),
                                          const SizedBox(width: 16.0),
                                          Text(
                                            updatedEvent.meetingSolution == 'meet' && !addingMeeting
                                                ? t.event.googleMeet
                                                : updatedEvent.meetingSolution == 'zoom' && !addingMeeting
                                                    ? t.event.zoom
                                                    : context.read<EventsCubit>().getDefaultConferenceSolution() ==
                                                            'meet'
                                                        ? t.event.googleMeet
                                                        : context
                                                            .read<EventsCubit>()
                                                            .getDefaultConferenceSolution()
                                                            .capitalizeFirstCharacter(),
                                            style: TextStyle(
                                                fontSize: 17.0,
                                                fontWeight: FontWeight.w500,
                                                color: ColorsExt.grey2(context)),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          if (!addingMeeting)
                                            InkWell(
                                              onTap: () {
                                                if (updatedEvent.meetingUrl != null) {
                                                  updatedEvent.joinConference();
                                                }
                                              },
                                              child: Text(
                                                t.event.join.toUpperCase(),
                                                style: TextStyle(
                                                    fontSize: 15.0,
                                                    fontWeight: FontWeight.w500,
                                                    color: ColorsExt.akiflow(context)),
                                              ),
                                            ),
                                          const SizedBox(width: 24),
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                removingMeeting = true;
                                                addingMeeting = false;
                                              });
                                            },
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: SvgPicture.asset(Assets.images.icons.common.xmarkSVG,
                                                  color: ColorsExt.grey3(context)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              : InkWell(
                                  onTap: () {
                                    setState(() {
                                      addingMeeting = true;
                                      removingMeeting = false;
                                    });
                                  },
                                  child: Padding(
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
                                          t.event.editEvent.addConference,
                                          style: TextStyle(
                                              fontSize: 17.0,
                                              fontWeight: FontWeight.w400,
                                              color: ColorsExt.grey3(context)),
                                        ),
                                      ],
                                    ),
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
                                    color: locationController.text.isEmpty
                                        ? ColorsExt.grey3(context)
                                        : ColorsExt.grey2(context),
                                  ),
                                ),
                                const SizedBox(width: 16.0),
                                Expanded(
                                  child: TextField(
                                    controller: locationController,
                                    decoration: InputDecoration(
                                      hintText: t.event.editEvent.addLocation,
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
                                        color: updatedEvent.attendees != null
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
                                        color: updatedEvent.attendees != null
                                            ? ColorsExt.grey2(context)
                                            : ColorsExt.grey3(context),
                                      ),
                                    ),
                                  ],
                                ),
                                if (updatedEvent.attendees != null)
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: SvgPicture.asset(
                                      Assets.images.icons.common.envelopeSVG,
                                      color: updatedEvent.attendees != null
                                          ? ColorsExt.grey2(context)
                                          : ColorsExt.grey3(context),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (updatedEvent.attendees != null)
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              itemCount: updatedEvent.attendees?.length ?? 0,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          updatedEvent.attendees![index].responseStatus ==
                                                  AtendeeResponseStatus.accepted.id
                                              ? SizedBox(
                                                  width: 19,
                                                  height: 19,
                                                  child: SvgPicture.asset(
                                                    Assets.images.icons.common.checkmarkAltCircleFillSVG,
                                                    color: ColorsExt.green(context),
                                                  ),
                                                )
                                              : updatedEvent.attendees![index].responseStatus ==
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
                                                updatedEvent.attendees![index].email!.contains('group')
                                                    ? '${updatedEvent.attendees![index].displayName}'
                                                    : '${updatedEvent.attendees![index].email}',
                                                style: TextStyle(
                                                    fontSize: 17.0,
                                                    fontWeight: FontWeight.w400,
                                                    color: ColorsExt.grey2(context)),
                                              ),
                                              if (updatedEvent.attendees![index].organizer ?? false)
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
                                      InkWell(
                                        onTap: () {
                                          atendeesToRemove.add(updatedEvent.attendees![index].email!);
                                          List<EventAtendee>? atendees = updatedEvent.attendees;
                                          atendees!.removeAt(index);
                                          setState(() {
                                            updatedEvent.copyWith(attendees: Nullable(atendees));
                                          });
                                        },
                                        child: SizedBox(
                                          width: 19,
                                          height: 19,
                                          child: SvgPicture.asset(
                                            Assets.images.icons.common.xmarkSVG,
                                            color: ColorsExt.grey3(context),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                            child: InkWell(
                              onTap: () {
                                showCupertinoModalBottomSheet(
                                  context: context,
                                  builder: (context) => AddGuestsModal(
                                    updateAtendeesUi: (contact) {
                                      List<EventAtendee>? attendees = updatedEvent.attendees;
                                      EventAtendee newAtendee = EventAtendee(
                                        displayName: contact.name,
                                        email: contact.identifier,
                                        responseStatus: contact.identifier == updatedEvent.originCalendarId
                                            ? AtendeeResponseStatus.accepted.id
                                            : AtendeeResponseStatus.needsAction.id,
                                        organizer: contact.identifier == updatedEvent.originCalendarId ? true : false,
                                      );
                                      atendeesToAdd.add(newAtendee.email!);
                                      if (attendees == null) {
                                        attendees = List.from([newAtendee]);
                                        if (newAtendee.email! != updatedEvent.originCalendarId) {
                                          EventAtendee loggedInUserAtendee = EventAtendee(
                                            organizer: true,
                                            displayName: updatedEvent.originCalendarId,
                                            email: updatedEvent.originCalendarId,
                                            responseStatus: AtendeeResponseStatus.accepted.id,
                                          );
                                          atendeesToAdd.add(loggedInUserAtendee.email!);
                                          attendees.add(loggedInUserAtendee);
                                        }
                                      } else {
                                        attendees.add(newAtendee);
                                      }

                                      updatedEvent = updatedEvent.copyWith(attendees: Nullable(attendees));
                                    },
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  SvgPicture.asset(Assets.images.icons.common.plusCircleSVG,
                                      width: 20, height: 20, color: ColorsExt.grey3(context)),
                                  const SizedBox(width: 16.0),
                                  Text(
                                    t.event.editEvent.addGuests,
                                    style: TextStyle(
                                        fontSize: 17.0, fontWeight: FontWeight.w400, color: ColorsExt.grey3(context)),
                                  ),
                                ],
                              ),
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
                          InkWell(
                            onTap: () {
                              showCupertinoModalBottomSheet(
                                context: context,
                                builder: (context) => ChangeColorModal(
                                  selectedColor: updatedEvent.color ?? updatedEvent.calendarColor ?? '',
                                  onChange: (newColor) {
                                    setState(() {
                                      updatedEvent = updatedEvent.copyWith(color: newColor);
                                    });
                                  },
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: SvgPicture.asset(
                                      Assets.images.icons.common.squareFillSVG,
                                      color: ColorsExt.fromHex(EventExt.computeColor(updatedEvent)),
                                    ),
                                  ),
                                  const SizedBox(width: 16.0),
                                  Text(
                                    updatedEvent.color != null
                                        ? t.event.editEvent.customColor
                                        : t.event.editEvent.defaultColor,
                                    style: TextStyle(
                                        fontSize: 17.0, fontWeight: FontWeight.w400, color: ColorsExt.grey2(context)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (updatedEvent.url != null)
                            Column(
                              children: [
                                const Separator(),
                                InkWell(
                                  onTap: () {
                                    if (updatedEvent.url != null) {
                                      updatedEvent.openUrl(updatedEvent.url);
                                    }
                                  },
                                  child: Padding(
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
                                              t.event.editEvent.viewOnGoogleCalendar,
                                              style: TextStyle(
                                                  fontSize: 17.0,
                                                  fontWeight: FontWeight.w400,
                                                  color: ColorsExt.grey2(context)),
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
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
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
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          BottomButton(
                              title: t.cancel,
                              image: Assets.images.icons.common.arrowshapeTurnUpLeftSVG,
                              onTap: () {
                                if (widget.createingEvent ?? false) {
                                } else {
                                  context.read<EventsCubit>().refetchEvent(updatedEvent);
                                }
                                Navigator.of(context).pop();
                              }),
                          BottomButton(
                            title: widget.createingEvent ?? false
                                ? t.event.editEvent.createEvent
                                : t.event.editEvent.saveChanges,
                            image: Assets.images.icons.common.checkmarkAltSVG,
                            containerColor: ColorsExt.green20(context),
                            iconColor: ColorsExt.green(context),
                            onTap: () async {
                              dynamic content = updatedEvent.content;
                              content['location'] = locationController.text;

                              updatedEvent = updatedEvent.copyWith(
                                  title: Nullable(titleController.text),
                                  description: Nullable(descriptionController.text),
                                  content: content,
                                  updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()));

                              print(updatedEvent.content);

                              if (widget.createingEvent ?? false) {
                                await context.read<EventsCubit>().addEventToDb(updatedEvent);
                              }

                              if (updatedEvent.recurringId != null && widget.event.recurringId != null) {
                                await showCupertinoModalBottomSheet(
                                    context: context,
                                    builder: (context) => RecurrentEventEditModal(
                                          onlyThisTap: () {
                                            Navigator.of(context).pop();
                                            if (updatedEvent.recurringId == updatedEvent.id) {
                                              context
                                                  .read<EventsCubit>()
                                                  .createEventException(
                                                      context: context,
                                                      tappedDate: widget.tappedDate,
                                                      dateChanged: dateChanged,
                                                      originalStartTime: widget.originalStartTime,
                                                      timeChanged: timeChanged,
                                                      parentEvent: updatedEvent,
                                                      atendeesToAdd: atendeesToAdd,
                                                      atendeesToRemove: atendeesToRemove,
                                                      addMeeting: addingMeeting,
                                                      removeMeeting: removingMeeting,
                                                      rsvpChanged: false)
                                                  .then((value) {
                                                _showEventEditedSnackbar();
                                              });
                                            } else {
                                              context
                                                  .read<EventsCubit>()
                                                  .updateEventAndCreateModifiers(
                                                      event: updatedEvent,
                                                      atendeesToAdd: atendeesToAdd,
                                                      atendeesToRemove: atendeesToRemove,
                                                      addMeeting: addingMeeting,
                                                      removeMeeting: removingMeeting)
                                                  .then((value) {
                                                _showEventEditedSnackbar();
                                              });
                                            }
                                          },
                                          thisAndFutureTap: () {
                                            Navigator.of(context).pop();
                                            if (widget.event.startTime == widget.originalStartTime) {
                                              _allTap(
                                                  context: context,
                                                  updatedEvent: updatedEvent,
                                                  atendeesToAdd: atendeesToAdd,
                                                  atendeesToRemove: atendeesToRemove,
                                                  addingMeeting: addingMeeting,
                                                  removingMeeting: removingMeeting);
                                            } else {
                                              context
                                                  .read<EventsCubit>()
                                                  .updateThisAndFuture(
                                                      tappedDate: widget.tappedDate, selectedEvent: updatedEvent)
                                                  .then((value) {
                                                context.read<EventsCubit>().refreshAllEvents(context);
                                                _showEventEditedSnackbar();
                                              });
                                            }
                                          },
                                          allTap: () {
                                            Navigator.of(context).pop();
                                            _allTap(
                                                context: context,
                                                updatedEvent: updatedEvent,
                                                atendeesToAdd: atendeesToAdd,
                                                atendeesToRemove: atendeesToRemove,
                                                addingMeeting: addingMeeting,
                                                removingMeeting: removingMeeting);
                                          },
                                        ));
                              } else {
                                if (mounted) {
                                  Navigator.of(context).pop();
                                  await context
                                      .read<EventsCubit>()
                                      .updateEventAndCreateModifiers(
                                          event: updatedEvent,
                                          atendeesToAdd: atendeesToAdd,
                                          atendeesToRemove: atendeesToRemove,
                                          addMeeting: addingMeeting,
                                          removeMeeting: removingMeeting,
                                          createingEvent: widget.createingEvent ?? false)
                                      .then(
                                    (value) {
                                      bool createdEvent = widget.createingEvent ?? false;
                                      if (createdEvent) {
                                        context.read<EventsCubit>().refreshAllEvents(context);
                                        ScaffoldMessenger.of(context).showSnackBar(CustomSnackbar.get(
                                            context: context,
                                            type: CustomSnackbarType.eventCreated,
                                            message: t.event.snackbar.created));
                                      } else {
                                        _showEventEditedSnackbar();
                                      }
                                    },
                                  );
                                }
                              }
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

  _showEventEditedSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackbar.get(context: context, type: CustomSnackbarType.eventEdited, message: t.event.snackbar.edited));
  }

  _allTap(
      {required BuildContext context,
      required Event updatedEvent,
      required List<String> atendeesToAdd,
      required List<String> atendeesToRemove,
      required bool addingMeeting,
      required bool removingMeeting}) {
    if (updatedEvent.recurringId == updatedEvent.id) {
      if (timeChanged &&
          widget.event.startTime != null &&
          widget.event.endTime != null &&
          updatedEvent.startTime != null &&
          updatedEvent.endTime != null) {
        updatedEvent = updatedEvent.copyWith(
            startTime: Nullable(widget.event.computeStartTimeForParent(updatedEvent)),
            endTime: Nullable(widget.event.computeEndTimeForParent(updatedEvent)));
      }
      context
          .read<EventsCubit>()
          .updateEventAndCreateModifiers(
              event: updatedEvent,
              atendeesToAdd: atendeesToAdd,
              atendeesToRemove: atendeesToRemove,
              addMeeting: addingMeeting,
              removeMeeting: removingMeeting)
          .then((value) => _showEventEditedSnackbar());
    } else {
      context
          .read<EventsCubit>()
          .updateParentAndExceptions(
              exceptionEvent: updatedEvent,
              atendeesToAdd: atendeesToAdd,
              atendeesToRemove: atendeesToRemove,
              addMeeting: addingMeeting,
              removeMeeting: removingMeeting)
          .then((value) => _showEventEditedSnackbar());
    }
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
                : widget.tappedDate,
            initialDatetime: null,
            onSelectDate: ({required DateTime? date, required DateTime? datetime}) {
              setState(() {
                timeChanged = true;
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
                : DateFormat("EEE dd MMM").format(widget.tappedDate),
            style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w400, color: ColorsExt.grey2(context)),
          ),
        ],
      ),
    );
  }

  InkWell _startTime(BuildContext context) {
    return InkWell(
      onTap: () {
        Duration duration = const Duration(minutes: 30);
        if (updatedEvent.startTime != null && updatedEvent.endTime != null) {
          duration = DateTime.parse(updatedEvent.endTime!).difference(DateTime.parse(updatedEvent.startTime!));
        }
        showCupertinoModalBottomSheet(
          context: context,
          builder: (context) => EventEditTimeModal(
            initialDate: widget.tappedDate,
            initialDatetime: updatedEvent.startTime != null ? DateTime.parse(updatedEvent.startTime!).toLocal() : null,
            onSelectDate: ({required DateTime? date, required DateTime? datetime}) {
              setState(() {
                timeChanged = true;
                datetime == null ? isAllDay = true : isAllDay = false;
                updatedEvent = updatedEvent.copyWith(
                  startDate: datetime == null ? Nullable(DateFormat("y-MM-dd").format(date!.toUtc())) : Nullable(null),
                  endDate: datetime == null ? Nullable(DateFormat("y-MM-dd").format(date!.toUtc())) : Nullable(null),
                  startTime: datetime != null ? Nullable(datetime.toUtc().toIso8601String()) : Nullable(null),
                  endTime:
                      datetime != null ? Nullable(datetime.toUtc().add(duration).toIso8601String()) : Nullable(null),
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
                : DateFormat("EEE dd MMM").format(widget.tappedDate),
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
                : widget.tappedDate,
            initialDatetime: null,
            onSelectDate: ({required DateTime? date, required DateTime? datetime}) {
              setState(() {
                timeChanged = true;
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
                : DateFormat("EEE dd MMM").format(widget.tappedDate),
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
                : widget.tappedDate,
            initialDatetime: updatedEvent.endTime != null ? DateTime.parse(updatedEvent.endTime!).toLocal() : null,
            onSelectDate: ({required DateTime? date, required DateTime? datetime}) {
              setState(() {
                timeChanged = true;
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
                : DateFormat("EEE dd MMM").format(widget.tappedDate),
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

  String _recurrence(EventRecurrenceModalType? selectedRecurrence) {
    if (selectedRecurrence == null) {
      return t.event.editEvent.recurrence.setRepeat;
    }

    switch (selectedRecurrence) {
      case EventRecurrenceModalType.none:
        return t.event.editEvent.recurrence.setRepeat;
      case EventRecurrenceModalType.daily:
        return t.event.editEvent.recurrence.everyDay;
      case EventRecurrenceModalType.everyCurrentDay:
        return t.editTask.everyCurrentDay(day: DateFormat("EEEE").format(widget.tappedDate));
      case EventRecurrenceModalType.everyYearOnThisDay:
        return t.editTask.everyYearOn(date: DateFormat("MMM dd").format(widget.tappedDate));
      case EventRecurrenceModalType.everyMonthOnThisDay:
        return t.editTask.everyMonthOn(date: DateFormat("MMM dd").format(widget.tappedDate));
      case EventRecurrenceModalType.everyWeekday:
        return t.event.editEvent.recurrence.everyWeekday;
      case EventRecurrenceModalType.custom:
        return t.event.editEvent.recurrence.custom;
      default:
        return t.event.editEvent.recurrence.setRepeat;
    }
  }
}
