import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/extensions/event_extension.dart';
import 'package:mobile/extensions/string_extension.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';
import 'package:mobile/src/base/ui/widgets/base/separator.dart';
import 'package:mobile/src/base/ui/widgets/calendar/calendar_color_circle.dart';
import 'package:mobile/src/base/ui/widgets/custom_snackbar.dart';
import 'package:mobile/src/base/ui/widgets/interactive_webview.dart';
import 'package:mobile/src/events/ui/cubit/events_cubit.dart';
import 'package:mobile/src/events/ui/widgets/change_color_modal.dart';
import 'package:mobile/src/events/ui/widgets/edit_event/add_guests_modal.dart';
import 'package:mobile/src/events/ui/widgets/bottom_button.dart';
import 'package:mobile/src/events/ui/widgets/edit_event/add_location_modal.dart';
import 'package:mobile/src/base/ui/widgets/base/choose_calendar_modal.dart';
import 'package:mobile/src/events/ui/widgets/edit_event/choose_conference_modal.dart';
import 'package:mobile/src/events/ui/widgets/edit_event/edit_time_modal.dart';
import 'package:mobile/src/events/ui/widgets/edit_event/recurrence_modal.dart';
import 'package:mobile/src/events/ui/widgets/confirmation_modals/recurrent_event_edit_modal.dart';
import 'package:mobile/src/events/ui/widgets/edit_event/transparency_modal.dart';
import 'package:mobile/src/events/ui/widgets/edit_event/visibility_modal.dart';
import 'package:mobile/src/tasks/ui/widgets/time_cupertino_modal.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/calendar/calendar.dart';
import 'package:models/event/event.dart';
import 'package:models/event/event_atendee.dart';
import 'package:models/nullable.dart';
import 'package:rrule/rrule.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:uuid/uuid.dart';

class EventEditModal extends StatefulWidget {
  const EventEditModal({
    Key? key,
    required this.event,
    required this.tappedDate,
    required this.originalStartTime,
    required this.use24hFormat,
    this.createingEvent,
  }) : super(key: key);
  final Event event;
  final DateTime tappedDate;
  final String? originalStartTime;
  final bool use24hFormat;
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
  late String meetingSolution;
  late String conferenceAccountId;
  late bool addingMeeting;
  late bool removingMeeting;
  late bool timeChanged;
  late bool dateChanged;
  late String transparency;
  late String visibility;
  late String choosenCalendar;
  late Calendar newCalendar;
  late bool calendarChanged;
  late bool newCalendarIsFromDifferentAccount;
  late Event eventToBeDeleted;

  ValueNotifier<quill.QuillController> quillController = ValueNotifier<quill.QuillController>(
      quill.QuillController(document: quill.Document(), selection: const TextSelection.collapsed(offset: 0)));

  @override
  void initState() {
    titleController = TextEditingController()..text = widget.event.title ?? '';
    titleController.selection = TextSelection.collapsed(offset: titleController.text.length);

    locationController = TextEditingController()..text = widget.event.content?['location'] ?? '';
    descriptionController = TextEditingController()..text = widget.event.description ?? '';
    choosenCalendar = widget.event.organizerId ?? '';
    transparency = widget.event.content['transparency'] ?? EventExt.transparencyOpaque;
    visibility = widget.event.content['visibility'] ?? EventExt.visibilityDefault;
    newCalendar = const Calendar();
    calendarChanged = false;
    newCalendarIsFromDifferentAccount = false;
    eventToBeDeleted = const Event();

    atendeesToAdd = List.empty(growable: true);
    atendeesToRemove = List.empty(growable: true);
    addingMeeting = false;
    removingMeeting = false;

    meetingSolution = widget.event.meetingSolution ?? context.read<EventsCubit>().getDefaultConferenceSolution();
    conferenceAccountId = '';

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
          color: ColorsExt.background(context),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(Dimension.radiusM),
            topRight: Radius.circular(Dimension.radiusM),
          ),
          child: Column(
            children: [
              const SizedBox(height: Dimension.padding),
              const ScrollChip(),
              Expanded(
                child: SingleChildScrollView(
                  reverse: _descriptionFocusNode.hasFocus ? true : false,
                  child: Column(
                    children: [
                      ListView(
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.only(left: Dimension.padding, right: Dimension.padding),
                        shrinkWrap: true,
                        children: [
                          _titleRow(context),
                          const Separator(),
                          _datetimeRow(context),
                          _recurrenceRow(context),
                          _allDayRow(context),
                          const Separator(),
                          (updatedEvent.meetingSolution != null || addingMeeting) && !removingMeeting
                              ? _conferenceRow(context)
                              : _addConferenceRow(context),
                          const Separator(),
                          _locationRow(context),
                          const Separator(),
                          _chooseCalendarRow(context),
                          const Separator(),
                          _transparencyRow(context),
                          const Separator(),
                          _visibilityRow(context),
                          const Separator(),
                          _guestsRow(context),
                          if (updatedEvent.attendees != null) _attendeesList(),
                          _addGuestsRow(context),
                          const Separator(),
                          _descriptionRow(context),
                          if (updatedEvent.url != null) _viewOnGoogleCalendarRow(context),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              _bottomActionButtonsRow(context),
              SizedBox(height: space),
            ],
          ),
        );
      },
    );
  }

  Padding _titleRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimension.padding),
      child: Row(
        children: [
          Expanded(
            child: TextField(
                autofocus: widget.createingEvent ?? false,
                controller: titleController,
                decoration: InputDecoration(border: InputBorder.none, hintText: t.event.editEvent.addTitle),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: ColorsExt.grey900(context),
                    )),
          ),
          const SizedBox(width: Dimension.paddingS),
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
            child: Row(
              children: [
                SizedBox(
                  width: Dimension.defaultIconSize + 6,
                  height: Dimension.defaultIconSize + 6,
                  child: CalendarColorCircle(
                      calendarColor: EventExt.computeColor(updatedEvent), size: Dimension.defaultIconSize + 6),
                ),
                SizedBox(
                  width: Dimension.smallconSize,
                  height: Dimension.smallconSize,
                  child: SvgPicture.asset(
                    Assets.images.icons.common.chevronDownSVG,
                    color: ColorsExt.grey600(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Padding _datetimeRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimension.padding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: Dimension.defaultIconSize,
            height: Dimension.defaultIconSize,
            child: SvgPicture.asset(
              Assets.images.icons.common.calendarSVG,
            ),
          ),
          const SizedBox(width: Dimension.padding),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!isAllDay) _startDateTime(context),
                if (isAllDay) _startDateAllDay(context),
                SvgPicture.asset(Assets.images.icons.common.arrowRightSVG,
                    width: 22, height: 22, color: ColorsExt.grey600(context)),
                if (!isAllDay) _endDateTime(context),
                if (isAllDay) _endDateAllDay(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TimeOfDay _secondsToTimeOfDay(int seconds) {
    final minutes = (seconds / 60).floor();
    final hours = (minutes / 60).floor();

    return TimeOfDay(hour: hours % 24, minute: minutes % 60);
  }

  InkWell _startDateAllDay(BuildContext context) {
    return InkWell(
      onTap: () {
        showCupertinoModalBottomSheet(
          context: context,
          builder: (context) => EditTimeModal(
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
              updatedEvent.recurringId == null || timeChanged
                  ? DateFormat("EEE dd MMM").format(DateTime.parse(updatedEvent.startDate!))
                  : DateFormat("EEE dd MMM").format(widget.tappedDate),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: ColorsExt.grey800(context),
                  )),
        ],
      ),
    );
  }

  Column _startDateTime(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _startDate(context),
        const SizedBox(height: Dimension.padding),
        _startTime(context),
      ],
    );
  }

  InkWell _startDate(BuildContext context) {
    return InkWell(
      onTap: () {
        showCupertinoModalBottomSheet(
          context: context,
          builder: (context) => EditTimeModal(
            showTime: false,
            initialDate: updatedEvent.startTime != null && updatedEvent.recurringId == null
                ? DateTime.parse(updatedEvent.startTime!).toLocal()
                : widget.tappedDate,
            initialDatetime: null,
            onSelectDate: ({required DateTime? date, required DateTime? datetime}) {
              DateTime eventStartTime = DateTime.parse(updatedEvent.startTime!).toLocal();
              DateTime eventEndTime = DateTime.parse(updatedEvent.endTime!).toLocal();

              DateTime selectedStartTime = DateTime(date!.year, date.month, date.day, eventStartTime.hour,
                      eventStartTime.minute, eventStartTime.second, eventStartTime.millisecond)
                  .toUtc();
              DateTime selectedEndTime = DateTime(date.year, date.month, date.day, eventEndTime.hour,
                      eventEndTime.minute, eventEndTime.second, eventEndTime.millisecond)
                  .toUtc();

              setState(() {
                timeChanged = true;
                updatedEvent = updatedEvent.copyWith(
                  startTime: Nullable(selectedStartTime.toUtc().toIso8601String()),
                  endTime: Nullable(selectedEndTime.toUtc().toIso8601String()),
                );
              });
            },
          ),
        );
      },
      child: Text(
          DateFormat("EEE dd MMM").format(
              updatedEvent.recurringId == null ? DateTime.parse(updatedEvent.startTime!).toLocal() : widget.tappedDate),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w400,
                color: ColorsExt.grey800(context),
              )),
    );
  }

  InkWell _startTime(BuildContext context) {
    return InkWell(
      onTap: () {
        DateTime eventStartTime = DateTime.parse(updatedEvent.startTime!).toLocal();

        Duration duration = const Duration(minutes: 30);
        if (updatedEvent.startTime != null && updatedEvent.endTime != null) {
          duration = DateTime.parse(updatedEvent.endTime!).difference(DateTime.parse(updatedEvent.startTime!));
        }

        TimeOfDay initialTime = TimeOfDay(hour: eventStartTime.hour, minute: eventStartTime.minute);

        showCupertinoModalBottomSheet(
            context: context,
            builder: (context) => TimeCupertinoModal(
                  time: initialTime,
                  onConfirm: (selected) {
                    TimeOfDay selectedTime = _secondsToTimeOfDay(selected);
                    DateTime selectedStartTime = DateTime(eventStartTime.year, eventStartTime.month, eventStartTime.day,
                            selectedTime.hour, selectedTime.minute, eventStartTime.second, eventStartTime.millisecond)
                        .toUtc();

                    DateTime eventEndTime = selectedStartTime.add(duration);

                    setState(() {
                      timeChanged = true;
                      updatedEvent = updatedEvent.copyWith(
                        startTime: Nullable(selectedStartTime.toUtc().toIso8601String()),
                        endTime: Nullable(eventEndTime.toUtc().toIso8601String()),
                      );
                    });
                  },
                ));
      },
      child: Text(
          DateFormat(widget.use24hFormat ? "HH:mm" : "h:mm a")
              .format(DateTime.parse(updatedEvent.startTime!).toLocal()),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: ColorsExt.grey800(context),
              )),
    );
  }

  InkWell _endDateAllDay(BuildContext context) {
    return InkWell(
      onTap: () {
        DateTime eventStart = updatedEvent.startDate != null
            ? DateTime.parse(updatedEvent.startDate!)
            : DateTime.parse(updatedEvent.startTime!);
        showCupertinoModalBottomSheet(
          context: context,
          builder: (context) => EditTimeModal(
            showTime: false,
            initialDate: updatedEvent.endDate != null && updatedEvent.recurringId == null
                ? DateTime.parse(updatedEvent.endDate!).toLocal()
                : widget.tappedDate,
            initialDatetime: null,
            onSelectDate: ({required DateTime? date, required DateTime? datetime}) {
              setState(() {
                timeChanged = true;
                isAllDay = true;
                updatedEvent = updatedEvent.copyWith(
                    endDate: eventStart.isBefore(date!)
                        ? Nullable(DateFormat("y-MM-dd").format(date))
                        : Nullable(DateFormat("y-MM-dd").format(eventStart)));
              });
            },
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              updatedEvent.recurringId == null || timeChanged
                  ? DateFormat("EEE dd MMM").format(DateTime.parse(updatedEvent.endDate!))
                  : DateFormat("EEE dd MMM").format(widget.tappedDate),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: ColorsExt.grey800(context),
                  )),
        ],
      ),
    );
  }

  Column _endDateTime(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _endDate(context),
        const SizedBox(height: Dimension.padding),
        _endTime(context),
      ],
    );
  }

  InkWell _endDate(BuildContext context) {
    return InkWell(
      onTap: () {
        showCupertinoModalBottomSheet(
          context: context,
          builder: (context) => EditTimeModal(
            showTime: false,
            initialDate: updatedEvent.endTime != null && updatedEvent.recurringId == null
                ? DateTime.parse(updatedEvent.endTime!).toLocal()
                : widget.tappedDate,
            initialDatetime: null,
            onSelectDate: ({required DateTime? date, required DateTime? datetime}) {
              DateTime eventStartTime = DateTime.parse(updatedEvent.startTime!);
              DateTime eventEndTime = DateTime.parse(updatedEvent.endTime!).toLocal();

              DateTime selectedEndTime = DateTime(date!.year, date.month, date.day, eventEndTime.hour,
                      eventEndTime.minute, eventEndTime.second, eventEndTime.millisecond)
                  .toUtc();

              if (eventStartTime.isBefore(selectedEndTime)) {
                setState(() {
                  timeChanged = true;
                  updatedEvent = updatedEvent.copyWith(
                    endTime: Nullable(selectedEndTime.toUtc().toIso8601String()),
                  );
                });
              }
            },
          ),
        );
      },
      child: Text(
          DateFormat("EEE dd MMM").format(
              updatedEvent.recurringId == null ? DateTime.parse(updatedEvent.endTime!).toLocal() : widget.tappedDate),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w400,
                color: ColorsExt.grey800(context),
              )),
    );
  }

  InkWell _endTime(BuildContext context) {
    return InkWell(
      onTap: () {
        DateTime eventStartTime = DateTime.parse(updatedEvent.startTime!);
        DateTime eventEndTime = DateTime.parse(updatedEvent.endTime!).toLocal();

        TimeOfDay initialTime = TimeOfDay(hour: eventEndTime.hour, minute: eventEndTime.minute);

        showCupertinoModalBottomSheet(
            context: context,
            builder: (context) => TimeCupertinoModal(
                  time: initialTime,
                  onConfirm: (selected) {
                    TimeOfDay selectedTime = _secondsToTimeOfDay(selected);
                    DateTime selectedEndTime = DateTime(eventEndTime.year, eventEndTime.month, eventEndTime.day,
                            selectedTime.hour, selectedTime.minute, eventEndTime.second, eventEndTime.millisecond)
                        .toUtc();

                    if (eventStartTime.isBefore(selectedEndTime)) {
                      setState(() {
                        timeChanged = true;
                        updatedEvent = updatedEvent.copyWith(
                          endTime: Nullable(selectedEndTime.toUtc().toIso8601String()),
                        );
                      });
                    }
                  },
                ));
      },
      child: Text(
          DateFormat(widget.use24hFormat ? "HH:mm" : "h:mm a").format(DateTime.parse(updatedEvent.endTime!).toLocal()),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: ColorsExt.grey800(context),
              )),
    );
  }

  InkWell _recurrenceRow(BuildContext context) {
    return InkWell(
      onTap: () {
        _recurrenceTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimension.padding),
        child: Row(
          children: [
            SizedBox(
              width: Dimension.defaultIconSize,
              height: Dimension.defaultIconSize,
              child: SvgPicture.asset(
                Assets.images.icons.common.repeatSVG,
                color: selectedRecurrence == EventRecurrenceModalType.none
                    ? ColorsExt.grey600(context)
                    : ColorsExt.grey800(context),
              ),
            ),
            const SizedBox(width: Dimension.padding),
            Text(_recurrenceText(selectedRecurrence),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w400,
                      color: selectedRecurrence == EventRecurrenceModalType.none
                          ? ColorsExt.grey600(context)
                          : ColorsExt.grey800(context),
                    )),
          ],
        ),
      ),
    );
  }

  _recurrenceTap() {
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
  }

  String _recurrenceText(EventRecurrenceModalType? selectedRecurrence) {
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

  Padding _allDayRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimension.padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                width: Dimension.defaultIconSize,
                height: Dimension.defaultIconSize,
                child: SvgPicture.asset(Assets.images.icons.common.daySVG,
                    color: isAllDay ? ColorsExt.grey800(context) : ColorsExt.grey600(context)),
              ),
              const SizedBox(width: Dimension.padding),
              Text(t.event.editEvent.allDay,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w400,
                      color: isAllDay ? ColorsExt.grey800(context) : ColorsExt.grey600(context))),
            ],
          ),
          FlutterSwitch(
            width: 48,
            height: 24,
            toggleSize: 20,
            activeColor: ColorsExt.akiflow500(context),
            inactiveColor: ColorsExt.grey200(context),
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
                      startDate: Nullable(DateFormat("y-MM-dd").format(widget.tappedDate.toUtc())),
                      endDate: Nullable(DateFormat("y-MM-dd").format(widget.tappedDate.toUtc())));
                } else {
                  updatedEvent = updatedEvent.copyWith(
                    startTime: widget.event.startTime != null
                        ? Nullable(widget.event.startTime)
                        : Nullable(widget.tappedDate.toUtc().toIso8601String()),
                    endTime: widget.event.endTime != null
                        ? Nullable(widget.event.endTime)
                        : Nullable(widget.tappedDate.toUtc().add(const Duration(minutes: 30)).toIso8601String()),
                    startDate: Nullable(null),
                    endDate: Nullable(null),
                  );
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Padding _conferenceRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimension.padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                width: Dimension.defaultIconSize,
                height: Dimension.defaultIconSize,
                child: SvgPicture.asset(
                  meetingSolution == 'meet'
                      ? Assets.images.icons.google.meetSVG
                      : meetingSolution == 'zoom'
                          ? Assets.images.icons.zoom.zoomSVG
                          : context.read<EventsCubit>().getDefaultConferenceIcon(),
                ),
              ),
              const SizedBox(width: Dimension.padding),
              Text(
                  meetingSolution == 'meet'
                      ? t.event.googleMeet
                      : meetingSolution == 'zoom'
                          ? t.event.zoom
                          : context.read<EventsCubit>().getDefaultConferenceSolution().capitalizeFirstCharacter(),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w400, color: ColorsExt.grey800(context))),
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
                  child: Text(t.event.join.toUpperCase(),
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w500, color: ColorsExt.akiflow500(context))),
                ),
              const SizedBox(width: Dimension.paddingM),
              InkWell(
                onTap: () {
                  setState(() {
                    removingMeeting = true;
                    addingMeeting = false;
                  });
                },
                child: SizedBox(
                  width: Dimension.defaultIconSize,
                  height: Dimension.defaultIconSize,
                  child: SvgPicture.asset(Assets.images.icons.common.xmarkSVG, color: ColorsExt.grey600(context)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InkWell _addConferenceRow(BuildContext context) {
    return InkWell(
      onTap: () {
        showCupertinoModalBottomSheet(
          context: context,
          builder: (context) => ChooseConferenceModal(
            onChange: (String selectedMeetingSolution, String akiflowAccountId) {
              setState(() {
                addingMeeting = true;
                removingMeeting = false;
                meetingSolution = selectedMeetingSolution;
                conferenceAccountId = akiflowAccountId;
              });
            },
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimension.padding),
        child: Row(
          children: [
            SizedBox(
              width: Dimension.defaultIconSize,
              height: Dimension.defaultIconSize,
              child: SvgPicture.asset(
                Assets.images.icons.common.videocamSVG,
                color: ColorsExt.grey600(context),
              ),
            ),
            const SizedBox(width: Dimension.padding),
            Text(t.event.editEvent.addConference,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w400, color: ColorsExt.grey600(context))),
          ],
        ),
      ),
    );
  }

  InkWell _locationRow(BuildContext context) {
    return InkWell(
      onTap: () {
        showCupertinoModalBottomSheet(
          context: context,
          builder: (context) => AddLocationModal(
            initialLocation: updatedEvent.content?["location"],
            updateLocation: (String location) {
              setState(() {
                locationController.text = location;
              });
            },
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimension.padding),
        child: Row(
          children: [
            SizedBox(
              width: Dimension.defaultIconSize,
              height: Dimension.defaultIconSize,
              child: SvgPicture.asset(
                Assets.images.icons.common.mapSVG,
                color: locationController.text.isEmpty ? ColorsExt.grey600(context) : ColorsExt.grey800(context),
              ),
            ),
            const SizedBox(width: Dimension.padding),
            Expanded(
              child: Text(locationController.text.isEmpty ? t.event.editEvent.addLocation : locationController.text,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: locationController.text.isEmpty ? ColorsExt.grey600(context) : ColorsExt.grey800(context),
                      fontWeight: FontWeight.w400)),
            ),
          ],
        ),
      ),
    );
  }

  InkWell _chooseCalendarRow(BuildContext context) {
    return InkWell(
      onTap: () {
        showCupertinoModalBottomSheet(
          context: context,
          builder: (context) => ChooseCalendarModal(
            onChange: (Calendar calendar) {
              bool creatingEvent = widget.createingEvent ?? false;
              setState(() {
                choosenCalendar = calendar.originId!;
                newCalendar = calendar;

                //used for changing calendar account. part 1 of 2
                if (!creatingEvent && updatedEvent.akiflowAccountId != calendar.akiflowAccountId) {
                  newCalendarIsFromDifferentAccount = true;
                  calendarChanged = true;
                  eventToBeDeleted = updatedEvent;
                }
              });
              dynamic content = updatedEvent.content;

              //used when changing calendar in the same account
              if (!creatingEvent && updatedEvent.akiflowAccountId == calendar.akiflowAccountId) {
                content['previousOriginCalendarId'] = updatedEvent.originCalendarId;
                calendarChanged = true;
              }

              updatedEvent = updatedEvent.copyWith(
                creatorId: calendar.originId,
                organizerId: calendar.originId,
                calendarId: calendar.id,
                originCalendarId: calendar.originId,
                connectorId: calendar.connectorId,
                akiflowAccountId: calendar.akiflowAccountId,
                originAccountId: calendar.originAccountId,
                calendarColor: calendar.color,
                content: content,
              );
            },
            initialCalendar: choosenCalendar,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimension.padding),
        child: Row(
          children: [
            CalendarColorCircle(
                calendarColor: EventExt.calendarColor[updatedEvent.calendarColor] ?? updatedEvent.calendarColor!,
                size: Dimension.defaultIconSize),
            const SizedBox(width: Dimension.padding),
            Text(newCalendar.title ?? choosenCalendar,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w400, color: ColorsExt.grey800(context))),
          ],
        ),
      ),
    );
  }

  InkWell _transparencyRow(BuildContext context) {
    return InkWell(
      onTap: () {
        showCupertinoModalBottomSheet(
          context: context,
          builder: (context) => TransparencyModal(
            initialTransparency: transparency,
            onChange: (String newTransparency) {
              setState(() {
                transparency = newTransparency;
              });
            },
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimension.padding),
        child: Row(
          children: [
            SizedBox(
              width: Dimension.defaultIconSize,
              height: Dimension.defaultIconSize,
              child: SvgPicture.asset(
                Assets.images.icons.common.briefcaseSVG,
              ),
            ),
            const SizedBox(width: Dimension.padding),
            Text(EventExt.getTransparencyMode(transparency),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w400, color: ColorsExt.grey800(context))),
          ],
        ),
      ),
    );
  }

  InkWell _visibilityRow(BuildContext context) {
    return InkWell(
      onTap: () {
        showCupertinoModalBottomSheet(
          context: context,
          builder: (context) => VisibilityModal(
            initialVisibility: visibility,
            onChange: (String newVisibility) {
              setState(() {
                visibility = newVisibility;
              });
            },
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimension.padding),
        child: Row(
          children: [
            SizedBox(
              width: Dimension.defaultIconSize,
              height: Dimension.defaultIconSize,
              child: SvgPicture.asset(
                Assets.images.icons.common.lockSVG,
              ),
            ),
            const SizedBox(width: Dimension.padding),
            Text(EventExt.getVisibilityMode(visibility),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w400, color: ColorsExt.grey800(context))),
          ],
        ),
      ),
    );
  }

  Padding _guestsRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimension.padding),
      child: Row(
        children: [
          SizedBox(
            width: Dimension.defaultIconSize,
            height: Dimension.defaultIconSize,
            child: SvgPicture.asset(
              Assets.images.icons.common.personCropCircleSVG,
              color: updatedEvent.attendees != null ? ColorsExt.grey800(context) : ColorsExt.grey600(context),
            ),
          ),
          const SizedBox(width: Dimension.padding),
          Text(
            t.event.guests,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w400,
                color: updatedEvent.attendees != null ? ColorsExt.grey800(context) : ColorsExt.grey600(context)),
          ),
        ],
      ),
    );
  }

  ListView _attendeesList() {
    return ListView.builder(
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
                  updatedEvent.attendees![index].responseStatus == AtendeeResponseStatus.accepted.id
                      ? SizedBox(
                          width: Dimension.defaultIconSize,
                          height: Dimension.defaultIconSize,
                          child: SvgPicture.asset(
                            Assets.images.icons.common.checkmarkAltCircleFillSVG,
                            color: ColorsExt.yorkGreen400(context),
                          ),
                        )
                      : updatedEvent.attendees![index].responseStatus == AtendeeResponseStatus.declined.id
                          ? SizedBox(
                              width: Dimension.defaultIconSize,
                              height: Dimension.defaultIconSize,
                              child: SvgPicture.asset(
                                Assets.images.icons.common.xmarkCircleFillSVG,
                                color: ColorsExt.cosmos400(context),
                              ),
                            )
                          : SizedBox(
                              width: Dimension.defaultIconSize,
                              height: Dimension.defaultIconSize,
                              child: SvgPicture.asset(
                                Assets.images.icons.common.questionCircleFillSVG,
                                color: ColorsExt.grey600(context),
                              ),
                            ),
                  const SizedBox(width: Dimension.padding),
                  Row(
                    children: [
                      Text(
                          updatedEvent.attendees![index].email!.contains('group')
                              ? '${updatedEvent.attendees![index].displayName}'
                              : '${updatedEvent.attendees![index].email}',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w400, color: ColorsExt.grey800(context))),
                      if (updatedEvent.attendees![index].organizer ?? false)
                        Text(
                          ' - ${t.event.organizer}',
                          style:
                              TextStyle(fontSize: 17.0, fontWeight: FontWeight.w400, color: ColorsExt.grey600(context)),
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
                  width: Dimension.defaultIconSize,
                  height: Dimension.defaultIconSize,
                  child: SvgPicture.asset(
                    Assets.images.icons.common.xmarkSVG,
                    color: ColorsExt.grey600(context),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Padding _addGuestsRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimension.padding),
      child: InkWell(
        onTap: () {
          _addGuestsTap();
        },
        child: Row(
          children: [
            SvgPicture.asset(
              Assets.images.icons.common.plusCircleSVG,
              width: Dimension.defaultIconSize,
              height: Dimension.defaultIconSize,
              color: ColorsExt.grey600(context),
            ),
            const SizedBox(width: Dimension.padding),
            Text(t.event.editEvent.addGuests,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w400, color: ColorsExt.grey600(context))),
          ],
        ),
      ),
    );
  }

  _addGuestsTap() {
    showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => AddGuestsModal(
        updateAtendeesUi: (contact) {
          List<EventAtendee>? attendees = updatedEvent.attendees;
          EventAtendee newAtendee = EventAtendee(
            displayName: contact.name,
            email: contact.identifier,
            responseStatus: contact.identifier == choosenCalendar
                ? AtendeeResponseStatus.accepted.id
                : AtendeeResponseStatus.needsAction.id,
            organizer: contact.identifier == choosenCalendar ? true : false,
          );
          atendeesToAdd.add(newAtendee.email!);
          if (attendees == null) {
            attendees = List.from([newAtendee]);
            if (newAtendee.email! != choosenCalendar) {
              EventAtendee loggedInUserAtendee = EventAtendee(
                organizer: true,
                displayName: choosenCalendar,
                email: choosenCalendar,
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
  }

  Padding _descriptionRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimension.padding),
      child: Row(
        children: [
          SizedBox(
            width: Dimension.defaultIconSize,
            height: Dimension.defaultIconSize,
            child: SvgPicture.asset(
              Assets.images.icons.common.textJustifyLeftSVG,
            ),
          ),
          const SizedBox(width: Dimension.padding),
          Expanded(
            child: _descriptionContent(context),
          ),
        ],
      ),
    );
  }

  Widget _descriptionContent(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: quillController,
      builder: (context, quill.QuillController value, child) => Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme: TextSelectionThemeData(
            selectionColor: ColorsExt.akiflow500(context)!.withOpacity(0.1),
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
              TextStyle(fontSize: 17.0, fontWeight: FontWeight.w400, color: ColorsExt.grey600(context)),
              const quill.VerticalSpacing(0, 0),
              const quill.VerticalSpacing(0, 0),
              null,
            ),
          ),
        ),
      ),
    );
  }

  Column _viewOnGoogleCalendarRow(BuildContext context) {
    return Column(
      children: [
        const Separator(),
        InkWell(
          onTap: () {
            if (updatedEvent.url != null) {
              updatedEvent.openUrl(updatedEvent.url);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimension.padding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: Dimension.defaultIconSize,
                      height: Dimension.defaultIconSize,
                      child: SvgPicture.asset(
                        Assets.images.icons.google.calendarSVG,
                      ),
                    ),
                    const SizedBox(width: Dimension.padding),
                    Text(t.event.editEvent.viewOnGoogleCalendar,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w400, color: ColorsExt.grey800(context))),
                  ],
                ),
                SvgPicture.asset(
                  Assets.images.icons.common.arrowUpRightSquareSVG,
                  width: Dimension.defaultIconSize,
                  height: Dimension.defaultIconSize,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Container _bottomActionButtonsRow(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorsExt.background(context),
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(Dimension.paddingS),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: 100,
                    child: BottomButton(
                        title: t.cancel,
                        image: Assets.images.icons.common.arrowshapeTurnUpLeftSVG,
                        onTap: () {
                          _onCancelTap();
                        }),
                  ),
                  SizedBox(
                    width: 100,
                    child: BottomButton(
                      title: widget.createingEvent ?? false
                          ? t.event.editEvent.createEvent
                          : t.event.editEvent.saveChanges,
                      image: Assets.images.icons.common.checkmarkAltSVG,
                      containerColor: ColorsExt.yorkGreen200(context),
                      iconColor: ColorsExt.yorkGreen400(context),
                      onTap: () async {
                        _onSaveTap();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _onCancelTap() {
    if (widget.createingEvent ?? false) {
    } else {
      context.read<EventsCubit>().refetchEvent(updatedEvent);
    }
    Navigator.of(context).pop();
  }

  _onSaveTap() async {
    dynamic content = updatedEvent.content;
    content['location'] = locationController.text;
    content['transparency'] = transparency;
    content['visibility'] = visibility;

    updatedEvent = updatedEvent.copyWith(
        title: Nullable(titleController.text),
        description: Nullable(descriptionController.text),
        content: content,
        updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()));

    if (widget.createingEvent ?? false) {
      await context.read<EventsCubit>().addEventToDb(updatedEvent);
    }

    //used for changing calendar account. part 2 of 2
    if (newCalendarIsFromDifferentAccount) {
      var id = const Uuid().v4();

      if (updatedEvent.recurringId != null) {
        updatedEvent = updatedEvent.copyWith(id: id, recurringId: id);
      } else {
        updatedEvent = updatedEvent.copyWith(id: id);
      }
      await context.read<EventsCubit>().addEventToDb(updatedEvent);
      await context.read<EventsCubit>().deleteEvent(eventToBeDeleted);
    }

    if (updatedEvent.recurringId != null && widget.event.recurringId != null && !calendarChanged) {
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
                            originalStartTime: widget.originalStartTime,
                            parentEvent: updatedEvent,
                            atendeesToAdd: atendeesToAdd,
                            atendeesToRemove: atendeesToRemove,
                            addMeeting: addingMeeting,
                            selectedMeetingSolution: meetingSolution,
                            conferenceAccountId: conferenceAccountId,
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
                          removeMeeting: removingMeeting,
                          selectedMeetingSolution: meetingSolution,
                          conferenceAccountId: conferenceAccountId,
                        )
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
                        .updateThisAndFuture(tappedDate: widget.tappedDate, selectedEvent: updatedEvent)
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
                selectedMeetingSolution: meetingSolution,
                conferenceAccountId: conferenceAccountId,
                createingEvent: widget.createingEvent ?? false)
            .then(
          (value) {
            bool createdEvent = widget.createingEvent ?? false;
            if (createdEvent) {
              ScaffoldMessenger.of(context).showSnackBar(CustomSnackbar.get(
                  context: context, type: CustomSnackbarType.eventCreated, message: t.event.snackbar.created));
            } else {
              _showEventEditedSnackbar();
            }
          },
        );
      }
    }
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
            removeMeeting: removingMeeting,
            selectedMeetingSolution: meetingSolution,
            conferenceAccountId: conferenceAccountId,
          )
          .then((value) => _showEventEditedSnackbar());
    } else {
      context
          .read<EventsCubit>()
          .updateParentAndExceptions(
            exceptionEvent: updatedEvent,
            atendeesToAdd: atendeesToAdd,
            atendeesToRemove: atendeesToRemove,
            addMeeting: addingMeeting,
            removeMeeting: removingMeeting,
            selectedMeetingSolution: meetingSolution,
            conferenceAccountId: conferenceAccountId,
          )
          .then((value) => _showEventEditedSnackbar());
    }
  }

  _showEventEditedSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackbar.get(context: context, type: CustomSnackbarType.eventEdited, message: t.event.snackbar.edited));
  }
}
