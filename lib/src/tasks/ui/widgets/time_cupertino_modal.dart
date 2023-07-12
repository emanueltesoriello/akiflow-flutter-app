import 'package:flutter/material.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:numberpicker/numberpicker.dart';

class TimeCupertinoModal extends StatefulWidget {
  final TimeOfDay time;
  final Function(int) onConfirm;
  const TimeCupertinoModal({super.key, required this.onConfirm, required this.time});

  @override
  State<TimeCupertinoModal> createState() => _TimeCupertinoModalState();
}

class _TimeCupertinoModalState extends State<TimeCupertinoModal> {
  TimeOfDay duration = const TimeOfDay(hour: 0, minute: 0);

  @override
  void initState() {
    duration = widget.time;
    super.initState();
  }

  int timeOfDayToSeconds(TimeOfDay timeOfDay) {
    final hoursInSeconds = timeOfDay.hour * 3600;
    final minutesInSeconds = timeOfDay.minute * 60;

    return hoursInSeconds + minutesInSeconds;
  }

  TimeOfDay secondsToTimeOfDay(int seconds) {
    final minutes = (seconds / 60).floor();
    final hours = (minutes / 60).floor();

    return TimeOfDay(hour: hours % 24, minute: minutes % 60);
  }

  onMinutesChanged(int value) {
    duration = TimeOfDay(hour: duration.hour, minute: value);
  }

  onHoursChanged(int value) {
    duration = TimeOfDay(hour: value, minute: duration.minute);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: ColorsExt.background(context),
        child: SafeArea(
          child: SizedBox(
            height: 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: Dimension.paddingM, left: Dimension.padding),
                    child: Text('Select Hour',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: ColorsExt.grey800(context))),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Hours',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: ColorsExt.grey800(context))),
                        const SizedBox(height: Dimension.padding),
                        SizedBox(
                          height: 150,
                          width: MediaQuery.of(context).size.width / 3,
                          child: NumberPicker(
                              itemWidth: 200,
                              step: 01,
                              infiniteLoop: true,
                              value: duration.hour,
                              minValue: 00,
                              itemCount: 03,
                              maxValue: 24,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(color: ColorsExt.grey400(context), fontSize: 30),
                              selectedTextStyle: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(color: ColorsExt.grey800(context), fontSize: 30),
                              onChanged: (value) {
                                setState(() {
                                  onHoursChanged(value);
                                });
                              }),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 35),
                      child: Text(':',
                          style:
                              Theme.of(context).textTheme.headlineMedium?.copyWith(color: ColorsExt.grey800(context))),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Minutes',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: ColorsExt.grey800(context))),
                        const SizedBox(height: Dimension.padding),
                        SizedBox(
                          height: 150,
                          width: MediaQuery.of(context).size.width / 3,
                          child: NumberPicker(
                              step: 5,
                              infiniteLoop: true,
                              itemWidth: 200,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(color: ColorsExt.grey400(context), fontSize: 30),
                              itemCount: 3,
                              selectedTextStyle: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(color: ColorsExt.grey800(context), fontSize: 30),
                              value: duration.minute,
                              minValue: 00,
                              maxValue: 55,
                              onChanged: (value) {
                                setState(() {
                                  onMinutesChanged(value);
                                });
                              }),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.only(
                      left: Dimension.padding, right: Dimension.padding, bottom: Dimension.paddingM),
                  child: OutlinedButton(
                    onPressed: () {
                      widget.onConfirm(
                        timeOfDayToSeconds(duration),
                      );
                      Navigator.of(context).pop();
                    },
                    style: Theme.of(context).outlinedButtonTheme.style?.copyWith(
                        side: MaterialStateProperty.all(BorderSide(color: ColorsExt.akiflow500(context))),
                        backgroundColor: MaterialStateProperty.all((ColorsExt.akiflow100(context))),
                        minimumSize: MaterialStateProperty.all(const Size(double.infinity, Dimension.buttonHeight))),
                    child: const Text('Confirm'),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
