import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/cubit/auth/auth_cubit.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';
import 'package:mobile/src/base/ui/widgets/base/separator.dart';
import 'package:mobile/src/tasks/ui/pages/create_task/create_task_calendar.dart';
import 'package:models/extensions/user_ext.dart';

class UntilDateModal extends StatefulWidget {
  final DateTime? initialDate;
  final Function(DateTime?) onSelectDate;

  const UntilDateModal({
    Key? key,
    required this.initialDate,
    required this.onSelectDate,
  }) : super(key: key);

  @override
  State<UntilDateModal> createState() => _DeadlineModalState();
}

class _DeadlineModalState extends State<UntilDateModal> {
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
        child: ListView(
          shrinkWrap: true,
          children: [
            const SizedBox(height: Dimension.padding),
            const ScrollChip(),
            Padding(
              padding: const EdgeInsets.all(Dimension.padding),
              child: Row(
                children: [
                  Text(
                    t.editTask.recurrence.repeatUntil,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: ColorsExt.grey2(context),
                    ),
                  ),
                ],
              ),
            ),
            CreateTaskCalendar(
              initialDate: widget.initialDate ?? DateTime.now(),
              initialDateTime: null,
              onConfirm: (DateTime date, DateTime? datetime) {
                widget.onSelectDate(datetime ?? date);
              },
              showTime: false,
              defaultTimeHour: context.watch<AuthCubit>().state.user!.defaultHour,
            ),
            const Separator(),
            const SizedBox(height: Dimension.paddingL),
          ],
        ),
      ),
    );
  }
}
