import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:html/parser.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/utils/no_scroll_behav.dart';
import 'package:mobile/extensions/event_extension.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';
import 'package:mobile/src/base/ui/widgets/base/separator.dart';
import 'package:mobile/src/base/ui/widgets/custom_snackbar.dart';
import 'package:mobile/src/base/ui/widgets/interactive_webview.dart';
import 'package:mobile/src/events/ui/cubit/events_cubit.dart';
import 'package:mobile/src/events/ui/widgets/bottom_button.dart';
import 'package:mobile/src/events/ui/widgets/delete_event_confirmation_modal.dart';
import 'package:mobile/src/events/ui/widgets/event_edit_modal.dart';
import 'package:mobile/src/events/ui/widgets/recurrent_event_edit_modal.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/event/event.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tuple/tuple.dart' as tuple;
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
  late FocusNode descriptionFocusNode;
  late TextEditingController descriptionController;
  StreamSubscription? streamSubscription;
  ValueNotifier<quill.QuillController> quillController = ValueNotifier<quill.QuillController>(
      quill.QuillController(document: quill.Document(), selection: const TextSelection.collapsed(offset: 0)));

  @override
  void initState() {
    context.read<EventsCubit>().fetchUnprocessedEventModifiers();
    selectedEvent = context.read<EventsCubit>().patchEventWithEventModifier(widget.event);
    location = selectedEvent.content?["location"] ?? '';

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
                                color: ColorsExt.fromHex(EventExt.computeColor(selectedEvent)),
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: Text(
                                selectedEvent.title ?? t.noTitle,
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
                                  if (selectedEvent.startTime != null)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          selectedEvent.recurringId == null
                                              ? DateFormat("EEE dd MMM")
                                                  .format(DateTime.parse(selectedEvent.startTime!))
                                              : DateFormat("EEE dd MMM").format(widget.tappedDate!),
                                          style: TextStyle(
                                              fontSize: 17.0,
                                              fontWeight: FontWeight.w400,
                                              color: ColorsExt.grey2(context)),
                                        ),
                                        const SizedBox(height: 12.0),
                                        Text(
                                          DateFormat("HH:mm")
                                              .format(DateTime.parse(selectedEvent.startTime!).toLocal()),
                                          style: TextStyle(
                                              fontSize: 17.0,
                                              fontWeight: FontWeight.w600,
                                              color: ColorsExt.grey2(context)),
                                        ),
                                      ],
                                    ),
                                  if (selectedEvent.startDate != null)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          selectedEvent.recurringId == null
                                              ? DateFormat("EEE dd MMM")
                                                  .format(DateTime.parse(selectedEvent.startDate!))
                                              : DateFormat("EEE dd MMM").format(widget.tappedDate!),
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
                                  if (selectedEvent.endTime != null)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          selectedEvent.recurringId == null
                                              ? DateFormat("EEE dd MMM").format(DateTime.parse(selectedEvent.endTime!))
                                              : DateFormat("EEE dd MMM").format(widget.tappedDate!),
                                          style: TextStyle(
                                              fontSize: 17.0,
                                              fontWeight: FontWeight.w400,
                                              color: ColorsExt.grey2(context)),
                                        ),
                                        const SizedBox(height: 12.0),
                                        Text(
                                          DateFormat("HH:mm").format(DateTime.parse(selectedEvent.endTime!).toLocal()),
                                          style: TextStyle(
                                              fontSize: 17.0,
                                              fontWeight: FontWeight.w600,
                                              color: ColorsExt.grey2(context)),
                                        ),
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
                      if (selectedEvent.meetingUrl != null)
                        Column(
                          children: [
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
                                          selectedEvent.meetingSolution == 'meet'
                                              ? Assets.images.icons.google.meetSVG
                                              : selectedEvent.meetingSolution == 'zoom'
                                                  ? Assets.images.icons.zoom.zoomSVG
                                                  : Assets.images.icons.common.videocamSVG,
                                        ),
                                      ),
                                      const SizedBox(width: 16.0),
                                      Text(
                                        selectedEvent.meetingSolution == 'meet'
                                            ? t.event.googleMeet
                                            : selectedEvent.meetingSolution == 'zoom'
                                                ? t.event.zoom
                                                : 'Conference',
                                        style: selectedEvent.meetingSolution == 'meet' ||
                                                selectedEvent.meetingSolution == 'zoom'
                                            ? TextStyle(
                                                fontSize: 17.0,
                                                fontWeight: FontWeight.w500,
                                                color: ColorsExt.grey2(context))
                                            : TextStyle(
                                                fontSize: 17.0,
                                                fontWeight: FontWeight.w400,
                                                color: ColorsExt.grey3(context)),
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
                                      child: Text(
                                        t.event.join.toUpperCase(),
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w500,
                                            color: ColorsExt.akiflow(context)),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
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
                      if (location != null && location!.isNotEmpty)
                        Column(
                          children: [
                            const Separator(),
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: SvgPicture.asset(Assets.images.icons.common.mapSVG,
                                        color: ColorsExt.grey2(context)),
                                  ),
                                  const SizedBox(width: 16.0),
                                  Expanded(
                                    child: Text(
                                      '${selectedEvent.content?["location"]}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 17.0, fontWeight: FontWeight.w400, color: ColorsExt.grey2(context)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      if (selectedEvent.attendees != null)
                        Column(
                          children: [
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
                                          color: ColorsExt.grey2(context),
                                        ),
                                      ),
                                      const SizedBox(width: 16.0),
                                      Text(
                                        t.event.guests,
                                        style: TextStyle(
                                          fontSize: 17.0,
                                          fontWeight: FontWeight.w400,
                                          color: ColorsExt.grey2(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: SvgPicture.asset(
                                      Assets.images.icons.common.envelopeSVG,
                                      color: ColorsExt.grey2(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const ClampingScrollPhysics(),
                                itemCount: selectedEvent.attendees?.length ?? 0,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                                    child: Row(
                                      children: [
                                        selectedEvent.attendees![index].responseStatus ==
                                                AtendeeResponseStatus.accepted.id
                                            ? SizedBox(
                                                width: 19,
                                                height: 19,
                                                child: SvgPicture.asset(
                                                  Assets.images.icons.common.checkmarkAltCircleFillSVG,
                                                  color: ColorsExt.green(context),
                                                ),
                                              )
                                            : selectedEvent.attendees![index].responseStatus ==
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
                                              selectedEvent.attendees![index].email!.contains('group')
                                                  ? '${selectedEvent.attendees![index].displayName}'
                                                  : '${selectedEvent.attendees![index].email}',
                                              style: TextStyle(
                                                  fontSize: 17.0,
                                                  fontWeight: FontWeight.w400,
                                                  color: ColorsExt.grey2(context)),
                                            ),
                                            if (selectedEvent.attendees![index].organizer ?? false)
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
                            ),
                          ],
                        ),
                      if (descriptionController.text.isNotEmpty &&
                          parse(descriptionController.text).body!.text.trim() != EventExt.akiflowSignature)
                        Column(
                          children: [
                            const Separator(),
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: SvgPicture.asset(Assets.images.icons.common.textJustifyLeftSVG,
                                        color: ColorsExt.grey2(context)),
                                  ),
                                  const SizedBox(width: 16.0),
                                  Expanded(
                                    child: _description(context),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
                      if (selectedEvent.attendees != null && selectedEvent.attendees!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16),
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
                                    onTap: () async {
                                      _responseTap(AtendeeResponseStatus.accepted);
                                    },
                                    child: SizedBox(
                                      height: 50,
                                      width: 40,
                                      child: Center(
                                        child: Text(
                                          t.event.yes,
                                          style: TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.w500,
                                              color: selectedEvent.isLoggedUserAttndingEvent ==
                                                      AtendeeResponseStatus.accepted
                                                  ? ColorsExt.green(context)
                                                  : ColorsExt.grey3(context)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 28.0),
                                  InkWell(
                                    onTap: () async {
                                      _responseTap(AtendeeResponseStatus.declined);
                                    },
                                    child: SizedBox(
                                      height: 50,
                                      width: 40,
                                      child: Center(
                                        child: Text(
                                          t.event.no,
                                          style: TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.w500,
                                              color: selectedEvent.isLoggedUserAttndingEvent ==
                                                      AtendeeResponseStatus.declined
                                                  ? ColorsExt.red(context)
                                                  : ColorsExt.grey3(context)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 28.0),
                                  InkWell(
                                    onTap: () async {
                                      _responseTap(AtendeeResponseStatus.tentative);
                                    },
                                    child: SizedBox(
                                      height: 50,
                                      child: Center(
                                        child: Text(
                                          t.event.maybe,
                                          style: TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.w500,
                                              color: selectedEvent.isLoggedUserAttndingEvent ==
                                                      AtendeeResponseStatus.tentative
                                                  ? ColorsExt.grey2(context)
                                                  : ColorsExt.grey3(context)),
                                        ),
                                      ),
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
                        child: selectedEvent.creatorId == selectedEvent.originCalendarId ||
                                (selectedEvent.content["guestsCanModify"] ?? false)
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
                                                    dateChanged: false,
                                                    timeChanged: false,
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
                                                  .endParentAtSelectedEvent(
                                                      tappedDate: widget.tappedDate!, selectedEvent: selectedEvent)
                                                  .then((value) {
                                                _showEventDeletedSnackbar();
                                              });
                                            },
                                            allTap: () {
                                              Navigator.of(context).pop();
                                              context
                                                  .read<EventsCubit>()
                                                  .deleteEvent(selectedEvent, deleteExceptions: true)
                                                  .then((value) {
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

  _responseTap(AtendeeResponseStatus response) async {
    if (selectedEvent.recurringId != null) {
      await showCupertinoModalBottomSheet(
        context: context,
        builder: (context) {
          EventsCubit eventsCubit = context.read<EventsCubit>();
          return RecurrentEventEditModal(
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
                        dateChanged: false,
                        timeChanged: false,
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
