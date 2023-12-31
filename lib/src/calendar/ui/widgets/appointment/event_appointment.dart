import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/extensions/event_extension.dart';
import 'package:models/event/event.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class EventAppointment extends StatelessWidget {
  const EventAppointment({
    Key? key,
    required this.event,
    required this.calendarAppointmentDetails,
    required this.calendarController,
    required this.appointment,
    required this.context,
  }) : super(key: key);

  final CalendarAppointmentDetails calendarAppointmentDetails;
  final CalendarController calendarController;
  final Appointment appointment;
  final Event event;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    double boxHeight = calendarAppointmentDetails.bounds.height;
    double boxWidth = calendarAppointmentDetails.bounds.width;
    AtendeeResponseStatus responseStatus = event.isLoggedUserAttndingEvent;
    return Container(
      width: boxWidth,
      height: boxHeight,
      decoration: _boxDecoration(responseStatus: responseStatus, boxWidth: boxWidth),
      child: Row(
        children: [
          const SizedBox(width: Dimension.paddingXS),
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
                        : boxHeight < 15.0
                            ? 10.5
                            : 13.0,
                    fontWeight: FontWeight.w500,
                    color: responseStatus == AtendeeResponseStatus.declined
                        ? ColorsExt.grey3(context)
                        : ColorsExt.grey1(context),
                    decoration: responseStatus == AtendeeResponseStatus.declined ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (calendarController.view == CalendarView.schedule &&
                    event.startTime != null &&
                    event.endTime != null)
                  Text(
                      '${DateFormat("HH:mm").format(DateTime.parse(event.startTime!).toLocal())} - ${DateFormat("HH:mm").format(DateTime.parse(event.endTime!).toLocal())}',
                      style: Theme.of(context).textTheme.caption?.copyWith(
                            height: 1.3,
                            fontSize: 11.0,
                            fontWeight: FontWeight.w500,
                            color: ColorsExt.grey3(context),
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
            color: ColorsExt.grey6(context),
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
                HSLColor.fromColor(appointment.color).withLightness(0.83).toColor().withOpacity(0.5),
                HSLColor.fromColor(appointment.color).withLightness(0.83).toColor().withOpacity(0.5),
                HSLColor.fromColor(appointment.color).withLightness(0.89).toColor().withOpacity(0.5),
                HSLColor.fromColor(appointment.color).withLightness(0.89).toColor().withOpacity(0.5)
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
            color: HSLColor.fromColor(appointment.color).withLightness(0.83).toColor().withOpacity(0.5),
            borderRadius: const BorderRadius.all(
              Radius.circular(4.0),
            ));
      default:
        return BoxDecoration(
            color: HSLColor.fromColor(appointment.color).withLightness(0.83).toColor().withOpacity(0.5),
            borderRadius: const BorderRadius.all(
              Radius.circular(4.0),
            ));
    }
  }
}
