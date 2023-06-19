import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/extensions/event_extension.dart';
import 'package:models/event/event.dart';
import 'package:syncfusion_calendar/calendar.dart';

class EventAppointment extends StatelessWidget {
  const EventAppointment({
    Key? key,
    required this.event,
    required this.calendarAppointmentDetails,
    required this.calendarController,
    required this.appointment,
    required this.context,
    required this.use24hFormat,
  }) : super(key: key);

  final CalendarAppointmentDetails calendarAppointmentDetails;
  final CalendarController calendarController;
  final Appointment appointment;
  final Event event;
  final BuildContext context;
  final bool use24hFormat;

  @override
  Widget build(BuildContext context) {
    double boxHeight = calendarAppointmentDetails.bounds.height;
    double boxWidth = calendarAppointmentDetails.bounds.width;
    AtendeeResponseStatus responseStatus = event.isLoggedUserAttndingEvent;
    String? rsvpIcon = event.getRsvpIcon();
    return Container(
      width: boxWidth,
      height: boxHeight,
      decoration: _boxDecoration(responseStatus: responseStatus, boxWidth: boxWidth),
      child: Row(
        children: [
          rsvpIcon == null
              ? const SizedBox(width: Dimension.paddingXS)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: calendarController.view == CalendarView.schedule
                          ? EdgeInsets.only(left: 2, right: 2, top: appointment.isAllDay ? 4 : 2)
                          : EdgeInsets.only(left: 2, right: 2, top: boxHeight < 15.0 ? 0 : 2),
                      child: SizedBox(
                        height: calendarController.view == CalendarView.month
                            ? 12
                            : boxHeight < 15.0
                                ? 13
                                : 16,
                        width: calendarController.view == CalendarView.month
                            ? 13
                            : boxHeight < 15.0
                                ? 13
                                : 16,
                        child: SvgPicture.asset(
                          rsvpIcon,
                          color: ColorsExt.grey800(context),
                        ),
                      ),
                    ),
                  ],
                ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: appointment.isAllDay ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Text(
                  appointment.subject.isEmpty ? t.noTitle : appointment.subject,
                  overflow: TextOverflow.ellipsis,
                  maxLines: boxHeight < 50.0 || appointment.isAllDay ? 1 : 2,
                  style: TextStyle(
                    height: event.attendees != null && responseStatus == AtendeeResponseStatus.needsAction ? 1.1 : 1.3,
                    fontSize: calendarController.view == CalendarView.schedule
                        ? 15.0
                        : calendarController.view == CalendarView.month
                            ? 10.5
                            : boxHeight < 15.0
                                ? 10.5
                                : 13.0,
                    fontWeight: FontWeight.w500,
                    color: responseStatus == AtendeeResponseStatus.declined
                        ? ColorsExt.grey700(context)
                        : ColorsExt.grey900(context),
                    decoration: responseStatus == AtendeeResponseStatus.declined ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (calendarController.view == CalendarView.schedule &&
                    event.startTime != null &&
                    event.endTime != null &&
                    DateUtils.isSameDay(
                        DateTime.parse(event.startTime!).toLocal(), DateTime.parse(event.endTime!).toLocal()))
                  Text(
                      '${DateFormat(use24hFormat ? "HH:mm" : "h:mm a").format(DateTime.parse(event.startTime!).toLocal())} - ${DateFormat(use24hFormat ? "HH:mm" : "h:mm a").format(DateTime.parse(event.endTime!).toLocal())}',
                      style: Theme.of(context).textTheme.caption?.copyWith(
                            height: 1.3,
                            fontSize: 11.0,
                            fontWeight: FontWeight.w500,
                            color: ColorsExt.grey600(context),
                          )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _boxDecoration({required AtendeeResponseStatus responseStatus, required double boxWidth}) {
    switch (responseStatus) {
      case AtendeeResponseStatus.declined:
        return BoxDecoration(
            color: ColorsExt.getCalendarBackgroundColorLight(appointment.color),
            borderRadius: const BorderRadius.all(
              Radius.circular(4.0),
            ));
      case AtendeeResponseStatus.tentative:
        return BoxDecoration(
            gradient: LinearGradient(
              end: Alignment(boxWidth > 300 ? -0.9 : -boxWidth / 100, 0),
              transform: const GradientRotation(3.14 / 4),
              stops: const [0.0, 0.5, 0.5, 1],
              colors: [
                ColorsExt.getCalendarBackgroundColor(appointment.color),
                ColorsExt.getCalendarBackgroundColor(appointment.color),
                ColorsExt.getCalendarBackgroundColorLight(appointment.color),
                ColorsExt.getCalendarBackgroundColorLight(appointment.color),
              ],
              tileMode: TileMode.repeated,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(4.0),
            ));
      case AtendeeResponseStatus.needsAction:
        if (event.attendees != null) {
          return BoxDecoration(
              color: Colors.white,
              border: Border.all(color: appointment.color),
              borderRadius: const BorderRadius.all(
                Radius.circular(4.0),
              ));
        }
        return BoxDecoration(
            color: ColorsExt.getCalendarBackgroundColor(appointment.color),
            borderRadius: const BorderRadius.all(
              Radius.circular(4.0),
            ));
      default:
        return BoxDecoration(
            color: ColorsExt.getCalendarBackgroundColor(appointment.color),
            borderRadius: const BorderRadius.all(
              Radius.circular(4.0),
            ));
    }
  }
}
