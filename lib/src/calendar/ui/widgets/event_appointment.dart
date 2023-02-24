import 'package:flutter/material.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class EventAppointment extends StatelessWidget {
  const EventAppointment({
    Key? key,
    required this.calendarAppointmentDetails,
    required this.appointment,
    required this.context,
  }) : super(key: key);

  final CalendarAppointmentDetails calendarAppointmentDetails;
  final Appointment appointment;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    double boxHeight = calendarAppointmentDetails.bounds.height;
    return Container(
      width: calendarAppointmentDetails.bounds.width,
      height: boxHeight,
      decoration: BoxDecoration(
          color: HSLColor.fromColor(appointment.color).withLightness(0.94).toColor(),
          borderRadius: const BorderRadius.all(
            Radius.circular(3.0),
          )),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 2, 3, 2),
            child: Container(
              height: boxHeight - 4,
              width: 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: appointment.color,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.subject,
                  overflow: TextOverflow.ellipsis,
                  maxLines: boxHeight < 50.0 || appointment.isAllDay ? 1 : 2,
                  style: TextStyle(
                    height: boxHeight < 15.0 ? 1.1 : 1.3,
                    fontSize: boxHeight < 15.0 ? 11.0 : 13.0,
                    fontWeight: FontWeight.w500,
                    color: ColorsExt.grey1(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
