import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';
import 'package:mobile/src/base/ui/widgets/base/separator.dart';
import 'package:mobile/src/tasks/ui/widgets/edit_tasks/actions/recurrence/end_selection_modal.dart';
import 'package:mobile/src/tasks/ui/widgets/edit_tasks/actions/recurrence/frequency_selection_modal.dart';
import 'package:mobile/src/tasks/ui/widgets/edit_tasks/actions/recurrence/until_date_modal.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:rrule/rrule.dart';

class CustomRecurrenceModal extends StatefulWidget {
  final RecurrenceRule? rule;
  final Function(RecurrenceRule?) onChange;
  const CustomRecurrenceModal({super.key, this.rule, required this.onChange});

  @override
  CustomRecurrenceModalState createState() => CustomRecurrenceModalState();
}

class CustomRecurrenceModalState extends State<CustomRecurrenceModal> {
  RecurrenceRule? rule;
  TextEditingController intervalController = TextEditingController();
  TextEditingController countController = TextEditingController();
  Frequency? frequency;
  List<bool> selectedDays = [false, false, false, false, false, false, false];
  List<bool> endOption = [true, false, false];
  DateTime? ends;

  @override
  void initState() {
    if (widget.rule != null) {
      rule = widget.rule!;
    }
    intervalController.text = rule != null && rule!.interval != null ? rule!.interval.toString() : '1';
    frequency = rule != null ? rule!.frequency : Frequency.weekly;

    if (rule != null && rule!.until != null) {
      ends = rule!.until;
      endOption = [false, true, false];
    } else {
      ends = DateTime.now().toUtc().add(const Duration(days: 365 * 2));
    }
    countController.text = rule != null && rule!.count != null ? rule!.count.toString() : '1';

    selectedDays = [
      _selectedDays(DateTime.monday),
      _selectedDays(DateTime.tuesday),
      _selectedDays(DateTime.wednesday),
      _selectedDays(DateTime.thursday),
      _selectedDays(DateTime.friday),
      _selectedDays(DateTime.saturday),
      _selectedDays(DateTime.sunday),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).backgroundColor,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Dimension.radiusM),
            topRight: Radius.circular(Dimension.radiusM),
          ),
        ),
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              const ScrollChip(),
              const SizedBox(height: 12),
              Row(
                children: [
                  SvgPicture.asset(
                    Assets.images.icons.common.repeatSVG,
                    width: 28,
                    height: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${t.editTask.custom} ${t.editTask.repeat}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: ColorsExt.grey2(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 12.0,
              ),
              Padding(
                padding: const EdgeInsets.only(top: Dimension.padding, bottom: Dimension.padding),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      t.editTask.recurrence.every,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: ColorsExt.grey2(context),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: Dimension.padding, right: Dimension.paddingS),
                      child: Container(
                        constraints: const BoxConstraints(
                          minHeight: 40,
                          minWidth: 40,
                          maxHeight: 40,
                          maxWidth: 40,
                        ),
                        decoration: BoxDecoration(
                            color: ColorsExt.grey7(context),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: ColorsExt.grey4(context))),
                        child: TextField(
                          controller: intervalController,
                          maxLines: 1,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(2),
                          ],
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: ColorsExt.grey2(context),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        showCupertinoModalBottomSheet(
                          context: context,
                          builder: (context) => FrequencySelectionModal(
                            onChange: (Frequency? newFrequency) {
                              setState(() {
                                frequency = newFrequency;
                              });
                            },
                            selectedFrequency: frequency,
                          ),
                        );
                      },
                      child: Container(
                        constraints: const BoxConstraints(
                          minHeight: 40,
                          minWidth: 90,
                        ),
                        decoration: BoxDecoration(
                            color: ColorsExt.grey7(context),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: ColorsExt.grey4(context))),
                        child: Center(
                          child: Text(
                            _frequency(),
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: ColorsExt.grey2(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Separator(),
              Padding(
                padding: const EdgeInsets.only(top: Dimension.padding, bottom: Dimension.paddingS),
                child: Text(
                  t.editTask.recurrence.selectedDays,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: ColorsExt.grey2(context),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _dayButton(context: context, index: 0, text: 'M'),
                  _dayButton(context: context, index: 1, text: 'T'),
                  _dayButton(context: context, index: 2, text: 'W'),
                  _dayButton(context: context, index: 3, text: 'T'),
                  _dayButton(context: context, index: 4, text: 'F'),
                  _dayButton(context: context, index: 5, text: 'S'),
                  _dayButton(context: context, index: 6, text: 'S'),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(top: Dimension.padding, bottom: Dimension.padding),
                child: Separator(),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    t.editTask.recurrence.ends,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: ColorsExt.grey2(context),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: Dimension.padding, right: Dimension.paddingS),
                    child: InkWell(
                      onTap: () {
                        showCupertinoModalBottomSheet(
                          context: context,
                          builder: (context) => EndSelectionModal(
                            onChange: (List<bool> newEndOption) {
                              setState(() {
                                endOption = newEndOption;
                              });
                            },
                            endOption: endOption,
                          ),
                        );
                      },
                      child: Container(
                        constraints: const BoxConstraints(
                          minHeight: 40,
                          minWidth: 77,
                        ),
                        decoration: BoxDecoration(
                            color: ColorsExt.grey7(context),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: ColorsExt.grey4(context))),
                        child: Center(
                          child: Text(
                            _endOption(),
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: ColorsExt.grey2(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (!endOption.elementAt(0) && endOption.elementAt(1))
                    InkWell(
                      onTap: () {
                        showCupertinoModalBottomSheet(
                          context: context,
                          builder: (context) => UntilDateModal(
                            initialDate: () {}(),
                            onSelectDate: (DateTime? date) {
                              setState(() {
                                ends = date;
                              });
                            },
                          ),
                        );
                      },
                      child: Container(
                        constraints: const BoxConstraints(
                          minHeight: 40,
                          minWidth: 130,
                        ),
                        decoration: BoxDecoration(
                            color: ColorsExt.grey7(context),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: ColorsExt.grey4(context))),
                        child: Center(
                          child: Text(
                            DateFormat("dd MMM yyyy").format(ends!.toLocal()),
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: ColorsExt.grey2(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (!endOption.elementAt(0) && endOption.elementAt(2))
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Container(
                            constraints: const BoxConstraints(
                              minHeight: 40,
                              minWidth: 40,
                              maxHeight: 40,
                              maxWidth: 40,
                            ),
                            decoration: BoxDecoration(
                                color: ColorsExt.grey7(context),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: ColorsExt.grey4(context))),
                            child: TextField(
                              controller: countController,
                              maxLines: 1,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(2),
                              ],
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: ColorsExt.grey2(context),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          t.editTask.recurrence.times,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: ColorsExt.grey2(context),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(top: Dimension.padding, bottom: Dimension.padding),
                child: Separator(),
              ),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        constraints: const BoxConstraints(
                          minHeight: 46,
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: ColorsExt.grey5(context))),
                        child: Center(
                          child: Text(
                            t.cancel,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              color: ColorsExt.grey3(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        var rule = RecurrenceRule(
                          interval: int.parse(intervalController.text),
                          frequency: frequency!,
                          byWeekDays: customSelectedDaysComputed(),
                          until: endOption.elementAt(0) == true
                              ? DateTime.now().toUtc().add(const Duration(days: 366 * 2))
                              : endOption.elementAt(1) == true
                                  ? ends
                                  : null,
                          count: endOption.elementAt(2) == true ? int.parse(countController.text) : null,
                        );
                        widget.onChange(rule);
                        Navigator.pop(context);
                      },
                      child: Container(
                        constraints: const BoxConstraints(
                          minHeight: 46,
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: ColorsExt.grey4(context))),
                        child: Center(
                          child: Text(
                            t.confirm,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              color: ColorsExt.grey2(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  String _frequency() {
    if (frequency == Frequency.daily) {
      return t.editTask.recurrence.days;
    } else if (frequency == Frequency.weekly) {
      return t.editTask.recurrence.weeks;
    } else if (frequency == Frequency.monthly) {
      return t.editTask.recurrence.months;
    } else if (frequency == Frequency.yearly) {
      return t.editTask.recurrence.years;
    }
    return t.editTask.recurrence.weeks;
  }

  bool _selectedDays(int day) {
    if (rule != null) {
      return rule!.byWeekDays.contains(ByWeekDayEntry(day));
    } else if (DateTime.now().weekday == day) {
      return true;
    }
    return false;
  }

  Set<ByWeekDayEntry> customSelectedDaysComputed() {
    Set<ByWeekDayEntry> byWeekDays = {};
    for (var i = 0; i < selectedDays.length; i++) {
      if (selectedDays.elementAt(i)) {
        byWeekDays.add(ByWeekDayEntry(i + 1));
      }
    }
    return byWeekDays;
  }

  String _endOption() {
    if (endOption.elementAt(1)) {
      return t.editTask.recurrence.until;
    } else if (endOption.elementAt(2)) {
      return t.editTask.recurrence.after;
    }
    return t.editTask.recurrence.never;
  }

  InkWell _dayButton({required BuildContext context, required int index, required String text}) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedDays[index] = !selectedDays[index];
        });
      },
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 40,
          minWidth: 40,
        ),
        decoration: BoxDecoration(
          color: selectedDays[index] ? ColorsExt.grey5(context) : ColorsExt.grey6(context),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: selectedDays[index] ? ColorsExt.grey2(context) : ColorsExt.grey3(context),
            ),
          ),
        ),
      ),
    );
  }
}
