import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:html/parser.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/common/utils/time_format_utils.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/extensions/event_extension.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';
import 'package:mobile/src/base/ui/widgets/base/separator.dart';
import 'package:mobile/src/base/ui/widgets/calendar/calendar_color_circle.dart';
import 'package:mobile/src/base/ui/widgets/custom_snackbar.dart';
import 'package:mobile/src/base/ui/widgets/interactive_webview.dart';
import 'package:mobile/src/events/ui/cubit/events_cubit.dart';
import 'package:mobile/src/events/ui/widgets/bottom_button.dart';
import 'package:mobile/src/events/ui/widgets/confirmation_modals/delete_event_confirmation_modal.dart';
import 'package:mobile/src/events/ui/widgets/edit_event/event_edit_modal.dart';
import 'package:mobile/src/events/ui/widgets/confirmation_modals/recurrent_event_edit_modal.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/event/event.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class EventModal extends StatefulWidget {
  const EventModal({
    Key? key,
    required this.event,
    required this.tappedDate,
  }) : super(key: key);
  final Event event;
  final DateTime? tappedDate;

  @override
  State<EventModal> createState() => _EventModalState();
}

class _EventModalState extends State<EventModal> {
  late Event selectedEvent;
  late String? originalStartTime;
  late String? location;
  late String transparency;
  late FocusNode descriptionFocusNode;
  late TextEditingController descriptionController;
  StreamSubscription? streamSubscription;
  ValueNotifier<quill.QuillController> quillController = ValueNotifier<quill.QuillController>(
      quill.QuillController(document: quill.Document(), selection: const TextSelection.collapsed(offset: 0)));

  final _preferencesRepository = locator<PreferencesRepository>();

  int timeFormat = -1;
  bool use24hFormat = true;

  @override
  void initState() {
    context.read<EventsCubit>().fetchUnprocessedEventModifiers();
    selectedEvent = context.read<EventsCubit>().patchEventWithEventModifier(widget.event);
    location = selectedEvent.content?["location"] ?? '';
    transparency = selectedEvent.content['transparency'] ?? EventExt.transparencyOpaque;

    if (selectedEvent.attendees != null) {
      selectedEvent.attendees!.sort((a, b) => b.organizer ?? false ? 1 : -1);
    }

    DateTime? eventStartTime =
        widget.event.startTime != null ? DateTime.parse(widget.event.startTime!).toLocal() : null;
    originalStartTime = eventStartTime != null
        ? DateTime(widget.tappedDate!.year, widget.tappedDate!.month, widget.tappedDate!.day, eventStartTime.hour,
                eventStartTime.minute, eventStartTime.second, eventStartTime.millisecond)
            .toUtc()
            .toIso8601String()
        : null;

    descriptionFocusNode = FocusNode();
    descriptionController = TextEditingController()..text = widget.event.description ?? '';
    initDescription().whenComplete(() {
      streamSubscription = quillController.value.changes.listen((change) async {
        List<dynamic> delta = quillController.value.document.toDelta().toJson();
        String html = await InteractiveWebView.deltaToHtml(delta);
        descriptionController.text = html;
      });
    });

    timeFormat = _preferencesRepository.timeFormat;

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
    use24hFormat = TimeFormatUtils.use24hFormat(timeFormat: timeFormat, context: context);

    return BlocBuilder<EventsCubit, EventsCubitState>(
      builder: (context, state) {
        return Material(
          color: ColorsExt.background(context),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(Dimension.padding),
            topRight: Radius.circular(Dimension.padding),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  children: [
                    const SizedBox(height: Dimension.padding),
                    const ScrollChip(),
                    ListView(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: Dimension.padding),
                      children: [
                        _titleRow(context),
                        const Separator(),
                        _datetimeRow(context),
                        if (selectedEvent.meetingUrl != null) _conferenceRow(context),
                        const Separator(),
                        _transparencyRow(context),
                        if (location != null && location!.isNotEmpty) _locationRow(context),
                        if (selectedEvent.attendees != null) _attendeesRow(context),
                        if (descriptionController.text.isNotEmpty &&
                            parse(descriptionController.text).body!.text.trim() != EventExt.akiflowSignature)
                          _descriptionRow(context),
                      ],
                    ),
                  ],
                ),
              ),
              _bottomButtonsRow(context),
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
            child: Text(selectedEvent.title ?? t.noTitle,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: ColorsExt.grey900(context), fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: Dimension.paddingS),
          SizedBox(
            width: Dimension.defaultIconSize + 6,
            height: Dimension.defaultIconSize + 6,
            child: CalendarColorCircle(
                calendarColor: EventExt.computeColor(selectedEvent), size: Dimension.defaultIconSize + 6),
          ),
        ],
      ),
    );
  }

  Padding _datetimeRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimension.padding),
      child: Row(
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
                if (selectedEvent.startTime != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          selectedEvent.recurringId == null
                              ? DateFormat("EEE dd MMM").format(DateTime.parse(selectedEvent.startTime!))
                              : DateFormat("EEE dd MMM").format(widget.tappedDate!),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: ColorsExt.grey800(context), fontWeight: FontWeight.w400)),
                      const SizedBox(height: Dimension.padding),
                      Text(
                          DateFormat(use24hFormat ? "HH:mm" : "h:mm a")
                              .format(DateTime.parse(selectedEvent.startTime!).toLocal()),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: ColorsExt.grey800(context), fontWeight: FontWeight.w600)),
                    ],
                  ),
                if (selectedEvent.startDate != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          selectedEvent.recurringId == null
                              ? DateFormat("EEE dd MMM").format(DateTime.parse(selectedEvent.startDate!))
                              : DateFormat("EEE dd MMM").format(widget.tappedDate!),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: ColorsExt.grey800(context), fontWeight: FontWeight.w400)),
                    ],
                  ),
                SvgPicture.asset(Assets.images.icons.common.arrowRightSVG,
                    width: Dimension.defaultIconSize,
                    height: Dimension.defaultIconSize,
                    color: ColorsExt.grey600(context)),
                if (selectedEvent.endTime != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                          selectedEvent.recurringId == null
                              ? DateFormat("EEE dd MMM").format(DateTime.parse(selectedEvent.endTime!))
                              : DateFormat("EEE dd MMM").format(widget.tappedDate!),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: ColorsExt.grey800(context), fontWeight: FontWeight.w400)),
                      const SizedBox(height: Dimension.padding),
                      Text(
                          DateFormat(use24hFormat ? "HH:mm" : "h:mm a")
                              .format(DateTime.parse(selectedEvent.endTime!).toLocal()),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: ColorsExt.grey800(context), fontWeight: FontWeight.w600)),
                    ],
                  ),
                if (selectedEvent.endDate != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          selectedEvent.recurringId == null
                              ? DateFormat("EEE dd MMM").format(DateTime.parse(selectedEvent.endDate!))
                              : DateFormat("EEE dd MMM").format(widget.tappedDate!),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: ColorsExt.grey800(context), fontWeight: FontWeight.w400)),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Column _conferenceRow(BuildContext context) {
    return Column(
      children: [
        const Separator(),
        Padding(
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
                      selectedEvent.meetingSolution == 'meet'
                          ? Assets.images.icons.google.meetSVG
                          : selectedEvent.meetingSolution == 'zoom'
                              ? Assets.images.icons.zoom.zoomSVG
                              : Assets.images.icons.common.videocamSVG,
                    ),
                  ),
                  const SizedBox(width: Dimension.padding),
                  Text(
                    selectedEvent.meetingSolution == 'meet'
                        ? t.event.googleMeet
                        : selectedEvent.meetingSolution == 'zoom'
                            ? t.event.zoom
                            : 'Conference',
                    style: selectedEvent.meetingSolution == 'meet' || selectedEvent.meetingSolution == 'zoom'
                        ? TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500, color: ColorsExt.grey800(context))
                        : TextStyle(fontSize: 17.0, fontWeight: FontWeight.w400, color: ColorsExt.grey600(context)),
                  ),
                ],
              ),
              if (selectedEvent.meetingUrl != null && selectedEvent.meetingSolution != null)
                InkWell(
                  onTap: () {
                    if (selectedEvent.meetingUrl != null) {
                      selectedEvent.joinConference();
                    }
                  },
                  child: Text(t.event.join.toUpperCase(),
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: ColorsExt.akiflow500(context), fontWeight: FontWeight.w500)),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Padding _transparencyRow(BuildContext context) {
    return Padding(
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
                  ?.copyWith(color: ColorsExt.grey800(context), fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }

  Column _locationRow(BuildContext context) {
    return Column(
      children: [
        const Separator(),
        InkWell(
          onTap: () {
            selectedEvent.launchMapsUrl();
          },
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: location)).then((value) => ScaffoldMessenger.of(context).showSnackBar(
                CustomSnackbar.get(
                    context: context, type: CustomSnackbarType.success, message: t.snackbar.copiedToYourClipboard)));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimension.padding),
            child: Row(
              children: [
                SizedBox(
                  width: Dimension.defaultIconSize,
                  height: Dimension.defaultIconSize,
                  child: SvgPicture.asset(Assets.images.icons.common.mapSVG, color: ColorsExt.grey800(context)),
                ),
                const SizedBox(width: Dimension.padding),
                Expanded(
                  child: Text('${selectedEvent.content?["location"]}',
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: ColorsExt.grey800(context), fontWeight: FontWeight.w400)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Column _attendeesRow(BuildContext context) {
    return Column(
      children: [
        const Separator(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimension.padding),
          child: Row(
            children: [
              SizedBox(
                width: Dimension.defaultIconSize,
                height: Dimension.defaultIconSize,
                child: SvgPicture.asset(
                  Assets.images.icons.common.personCropCircleSVG,
                  color: ColorsExt.grey800(context),
                ),
              ),
              const SizedBox(width: Dimension.padding),
              Text(t.event.guests,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: ColorsExt.grey800(context), fontWeight: FontWeight.w400)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: Dimension.padding),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemCount: selectedEvent.attendees?.length ?? 0,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                child: Row(
                  children: [
                    selectedEvent.attendees![index].responseStatus == AtendeeResponseStatus.accepted.id
                        ? SizedBox(
                            width: Dimension.defaultIconSize,
                            height: Dimension.defaultIconSize,
                            child: SvgPicture.asset(
                              Assets.images.icons.common.checkmarkAltCircleFillSVG,
                              color: ColorsExt.yorkGreen400(context),
                            ),
                          )
                        : selectedEvent.attendees![index].responseStatus == AtendeeResponseStatus.declined.id
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
                          selectedEvent.attendees![index].email!.contains('group')
                              ? '${selectedEvent.attendees![index].displayName}'
                              : '${selectedEvent.attendees![index].email}',
                          style:
                              TextStyle(fontSize: 17.0, fontWeight: FontWeight.w400, color: ColorsExt.grey800(context)),
                        ),
                        if (selectedEvent.attendees![index].organizer ?? false)
                          Text(
                            ' - ${t.event.organizer}',
                            style: TextStyle(
                                fontSize: 17.0, fontWeight: FontWeight.w400, color: ColorsExt.grey600(context)),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Column _descriptionRow(BuildContext context) {
    return Column(
      children: [
        const Separator(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimension.padding),
          child: Row(
            children: [
              SizedBox(
                width: Dimension.defaultIconSize,
                height: Dimension.defaultIconSize,
                child:
                    SvgPicture.asset(Assets.images.icons.common.textJustifyLeftSVG, color: ColorsExt.grey800(context)),
              ),
              const SizedBox(width: Dimension.padding),
              Expanded(
                child: _descriptionContent(context),
              ),
            ],
          ),
        ),
      ],
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
          readOnly: true,
          enableInteractiveSelection: false,
          scrollController: ScrollController(),
          scrollable: true,
          focusNode: descriptionFocusNode,
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
                null),
          ),
        ),
      ),
    );
  }

  Container _bottomButtonsRow(BuildContext context) {
    return Container(
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
          if (selectedEvent.attendees != null && selectedEvent.attendees!.isNotEmpty) _responseStatusRow(context),
          const Separator(),
          SafeArea(child: _eventActionButtonsRow(context)),
        ],
      ),
    );
  }

  Padding _responseStatusRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimension.padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(t.event.going,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: ColorsExt.grey800(context), fontWeight: FontWeight.w400)),
          Row(
            children: [
              InkWell(
                onTap: () async {
                  _responseTap(AtendeeResponseStatus.accepted);
                },
                child: SizedBox(
                  height: 50,
                  width: 40,
                  child: Center(
                    child: Text(t.event.yes,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: selectedEvent.isLoggedUserAttndingEvent == AtendeeResponseStatus.accepted
                                ? ColorsExt.yorkGreen400(context)
                                : ColorsExt.grey600(context),
                            fontWeight: FontWeight.w500)),
                  ),
                ),
              ),
              const SizedBox(width: Dimension.paddingM),
              InkWell(
                onTap: () async {
                  _responseTap(AtendeeResponseStatus.declined);
                },
                child: SizedBox(
                  height: 50,
                  width: 40,
                  child: Center(
                    child: Text(t.event.no,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: selectedEvent.isLoggedUserAttndingEvent == AtendeeResponseStatus.declined
                                ? ColorsExt.cosmos400(context)
                                : ColorsExt.grey600(context))),
                  ),
                ),
              ),
              const SizedBox(width: Dimension.paddingM),
              InkWell(
                onTap: () async {
                  _responseTap(AtendeeResponseStatus.tentative);
                },
                child: SizedBox(
                  height: 50,
                  child: Center(
                    child: Text(t.event.maybe,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: selectedEvent.isLoggedUserAttndingEvent == AtendeeResponseStatus.tentative
                                ? ColorsExt.grey800(context)
                                : ColorsExt.grey600(context))),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _responseTap(AtendeeResponseStatus response) async {
    if (selectedEvent.recurringId != null) {
      await showCupertinoModalBottomSheet(
        context: context,
        builder: (context) {
          EventsCubit eventsCubit = context.read<EventsCubit>();
          return RecurrentEventEditModal(
            showThisAndFutureButton: selectedEvent.canModify(),
            onlyThisTap: () {
              setState(() {
                selectedEvent.setLoggedUserAttendingResponse(response);
              });
              if (selectedEvent.id == selectedEvent.recurringId) {
                eventsCubit
                    .createEventException(
                        context: context,
                        tappedDate: widget.tappedDate!,
                        originalStartTime: originalStartTime,
                        parentEvent: selectedEvent,
                        atendeesToAdd: const [],
                        atendeesToRemove: const [],
                        addMeeting: false,
                        removeMeeting: false,
                        rsvpChanged: true,
                        rsvpResponse: response.id)
                    .then(
                  (exceptionEvent) {
                    if (exceptionEvent != null) {
                      _processPatchEventModifier(eventsCubit, exceptionEvent);
                      eventsCubit.refreshAllEvents(context);
                      _showEventEditedSnackbar();
                    }
                  },
                );
              } else {
                eventsCubit.updateAtend(event: selectedEvent, response: response.id).then(
                  (value) async {
                    _processPatchEventModifier(eventsCubit, selectedEvent);
                    _showEventEditedSnackbar();
                  },
                );
              }
            },
            thisAndFutureTap: () {
              context
                  .read<EventsCubit>()
                  .updateThisAndFuture(
                      tappedDate: widget.tappedDate!, selectedEvent: selectedEvent, response: response.id)
                  .then(
                (newParent) {
                  if (newParent != null) {
                    _processPatchEventModifier(eventsCubit, newParent);
                    eventsCubit.refreshAllEvents(context);
                    _showEventEditedSnackbar();
                  }
                },
              );
              setState(() {
                selectedEvent.setLoggedUserAttendingResponse(response);
              });
            },
            allTap: () {
              setState(() {
                selectedEvent.setLoggedUserAttendingResponse(response);
              });
              if (selectedEvent.id == selectedEvent.recurringId) {
                eventsCubit.updateAtend(event: selectedEvent, response: response.id).then(
                  (value) async {
                    _processPatchEventModifier(eventsCubit, selectedEvent);
                    _showEventEditedSnackbar();
                  },
                );
              } else {
                eventsCubit.updateAtend(event: selectedEvent, response: response.id, updateParent: true).then(
                  (value) async {
                    _processPatchEventModifier(eventsCubit, selectedEvent);
                    _showEventEditedSnackbar();
                  },
                );
              }
            },
          );
        },
      );
    } else {
      context.read<EventsCubit>().updateAtend(event: selectedEvent, response: response.id).then(
        (value) async {
          EventsCubit eventsCubit = context.read<EventsCubit>();
          _processPatchEventModifier(eventsCubit, selectedEvent);
          _showEventEditedSnackbar();
        },
      );
      setState(() {
        selectedEvent.setLoggedUserAttendingResponse(response);
      });
    }
  }

  Padding _eventActionButtonsRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimension.paddingS),
      child: selectedEvent.canModify()
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (selectedEvent.attendees != null)
                  BottomButton(
                    title: t.event.mailGuests,
                    image: Assets.images.icons.common.envelopeSVG,
                    onTap: () {
                      selectedEvent.sendEmail();
                    },
                  ),
                BottomButton(
                  title: t.event.edit,
                  image: Assets.images.icons.common.pencilSVG,
                  onTap: () {
                    showCupertinoModalBottomSheet(
                      context: context,
                      builder: (context) => EventEditModal(
                        event: selectedEvent,
                        tappedDate: widget.tappedDate!,
                        originalStartTime: originalStartTime,
                        use24hFormat: use24hFormat,
                      ),
                    ).whenComplete(
                      () {
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
                BottomButton(
                  title: t.event.delete,
                  image: Assets.images.icons.common.trashSVG,
                  onTap: () {
                    _onDeleteTap();
                  },
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                BottomButton(
                  title: t.event.mailGuests,
                  image: Assets.images.icons.common.envelopeSVG,
                  onTap: () {
                    selectedEvent.sendEmail();
                  },
                ),
                BottomButton(
                  title: t.event.delete,
                  image: Assets.images.icons.common.trashSVG,
                  onTap: () {},
                ),
              ],
            ),
    );
  }

  _onDeleteTap() {
    if (selectedEvent.recurringId != null) {
      showCupertinoModalBottomSheet(
        context: context,
        builder: (context) => RecurrentEventEditModal(
          deleteEvent: true,
          onlyThisTap: () {
            Navigator.of(context).pop();
            if (selectedEvent.recurringId == selectedEvent.id) {
              context.read<EventsCubit>().createEventException(
                  context: context,
                  tappedDate: widget.tappedDate!,
                  originalStartTime: originalStartTime,
                  parentEvent: selectedEvent,
                  atendeesToAdd: const [],
                  atendeesToRemove: const [],
                  addMeeting: false,
                  removeMeeting: false,
                  rsvpChanged: false,
                  deleteEvent: true);
            } else {
              context.read<EventsCubit>().deleteEvent(selectedEvent).then((value) {
                context.read<EventsCubit>().refreshAllEvents(context);
                _showEventDeletedSnackbar();
              });
            }
          },
          thisAndFutureTap: () {
            Navigator.of(context).pop();
            context
                .read<EventsCubit>()
                .endParentAtSelectedEvent(tappedDate: widget.tappedDate!, selectedEvent: selectedEvent)
                .then((value) {
              _showEventDeletedSnackbar();
            });
          },
          allTap: () {
            Navigator.of(context).pop();
            context.read<EventsCubit>().deleteEvent(selectedEvent, deleteExceptions: true).then((value) {
              context.read<EventsCubit>().refreshAllEvents(context);
              _showEventDeletedSnackbar();
            });
          },
        ),
      );
    } else {
      showCupertinoModalBottomSheet(
        context: context,
        builder: (context) => DeleteEventConfirmationModal(
          eventName: selectedEvent.title ?? '',
          onTapDelete: () {
            Navigator.of(context).pop();
            context.read<EventsCubit>().deleteEvent(selectedEvent).then((value) {
              context.read<EventsCubit>().refreshAllEvents(context);
              _showEventDeletedSnackbar();
            });
          },
        ),
      );
    }
  }

  _processPatchEventModifier(EventsCubit eventsCubit, Event selectedEvent) async {
    await eventsCubit.fetchUnprocessedEventModifiers();
    eventsCubit.saveToStatePatchedEvent(eventsCubit.patchEventWithEventModifier(selectedEvent));
  }

  _showEventEditedSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackbar.get(context: context, type: CustomSnackbarType.eventEdited, message: t.event.snackbar.edited));
  }

  _showEventDeletedSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackbar.get(context: context, type: CustomSnackbarType.eventDeleted, message: t.event.snackbar.deleted));
  }
}
