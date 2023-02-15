import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/src/base/ui/widgets/base/app_bar.dart';
import 'package:mobile/src/base/ui/widgets/task/panel.dart';
import 'package:mobile/src/calendar/ui/cubit/calendar_cubit.dart';
import 'package:mobile/src/calendar/ui/widgets/calendar_settings_modal.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarAppBar extends StatelessWidget implements PreferredSizeWidget {
  final CalendarController calendarController;

  const CalendarAppBar({
    Key? key,
    required this.calendarController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBarComp(
      titleWidget: _buildTitle(context, calendarController),
      leading: SvgPicture.asset(
        Assets.images.icons.common.calendarSVG,
        width: 26,
        height: 26,
      ),
      actions: [
        TextButton(
          onPressed: () {
            DateTime now = DateTime.now().toLocal();
            calendarController.displayDate = now.hour > 2 ? now.subtract(const Duration(hours: 2)) : now;
            context.read<CalendarCubit>().closePanel();
          },
          style: ButtonStyle(
            overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
          ),
          child: Text(
            t.bottomBar.today,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: ColorsExt.akiflow(context),
            ),
          ),
        ),
        IconButton(
          icon: SvgPicture.asset(
            Assets.images.icons.common.ellipsisSVG,
            width: 24,
            height: 24,
            color: ColorsExt.grey3(context),
          ),
          onPressed: () {
            showCupertinoModalBottomSheet(
              context: context,
              builder: (context) => CalendarSettingsModal(calendarController: calendarController),
            );
            context.read<CalendarCubit>().closePanel();
          },
        )
      ],
      showSyncButton: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);

  Widget _buildTitle(BuildContext context, CalendarController calendarController) {
    return InkWell(
      overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
      onTap: () {
        context.read<CalendarCubit>().tapAppBarTextDate();
      },
      child: BlocBuilder<CalendarCubit, CalendarCubitState>(
        builder: (context, state) {
          return Row(
            children: [
              Text(
                DateFormat('MMMM').format(state.visibleDates.isEmpty
                    ? DateTime.now().toLocal()
                    : state.visibleDates.length > 29
                        ? state.visibleDates.elementAt(7)
                        : state.visibleDates.first),
                textAlign: TextAlign.start,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 22, color: ColorsExt.grey2(context)),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 16,
                height: 16,
                child: SvgPicture.asset(
                  state.panelState == PanelState.closed
                      ? Assets.images.icons.common.chevronDownSVG
                      : Assets.images.icons.common.chevronUpSVG,
                  color: ColorsExt.grey3(context),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
