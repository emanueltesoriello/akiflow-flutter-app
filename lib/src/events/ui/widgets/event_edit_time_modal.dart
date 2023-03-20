import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/base/ui/cubit/auth/auth_cubit.dart';
import 'package:mobile/src/tasks/ui/pages/create_task/create_task_calendar.dart';
import 'package:models/extensions/user_ext.dart';

class EventEditTimeModal extends StatefulWidget {
  final Function({required DateTime? date, required DateTime? datetime}) onSelectDate;
  final DateTime initialDate;
  final DateTime? initialDatetime;
  final bool? showTime;

  const EventEditTimeModal({
    Key? key,
    required this.onSelectDate,
    required this.initialDate,
    required this.initialDatetime,
    this.showTime,
  }) : super(key: key);

  @override
  State<EventEditTimeModal> createState() => _EventEditTimeModalState();
}

class _EventEditTimeModalState extends State<EventEditTimeModal> {
  final ValueNotifier<DateTime> _selectedDate = ValueNotifier(DateTime.now());
  final ValueNotifier<DateTime?> _selectedDatetime = ValueNotifier(null);

  @override
  void initState() {
    _selectedDate.value = widget.initialDate;
    _selectedDatetime.value = widget.initialDatetime;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Wrap(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SafeArea(
              child: Column(
                children: [
                  CreateTaskCalendar(
                    showTime: widget.showTime ?? true,
                    showRepeat: false,
                    initialDate: _selectedDate.value,
                    initialDateTime: _selectedDatetime.value,
                    onConfirm: (DateTime date, DateTime? datetime) {
                      if (_selectedDatetime.value == null) {
                        int defaultHour = context.read<AuthCubit>().state.user!.defaultHour;

                        datetime = DateTime(date.year, date.month, date.day, defaultHour, 0);
                      }

                      _selectedDate.value = date;
                      _selectedDatetime.value = datetime;
                      widget.onSelectDate(date: date, datetime: datetime);
                    },
                    onSelectTime: (TimeOfDay? datetime) {
                      _selectedDatetime.value = DateTime(
                        _selectedDate.value.year,
                        _selectedDate.value.month,
                        _selectedDate.value.day,
                        datetime?.hour ?? 10,
                        datetime?.minute ?? 0,
                      );
                    },
                    defaultTimeHour: () {
                      try {
                        return context.watch<AuthCubit>().state.user!.defaultHour;
                      } catch (_) {
                        return 8;
                      }
                    }(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
