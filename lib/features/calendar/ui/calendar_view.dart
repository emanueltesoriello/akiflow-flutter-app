import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/features/main/cubit/main_cubit.dart';
import 'package:mobile/style/colors.dart';

class CalendarView extends StatelessWidget {
  const CalendarView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _View();
  }
}

class _View extends StatelessWidget {
  const _View({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            "assets/images/akiflow/calendar-placeholder.svg",
            width: 130,
            height: 130,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  t.calendar.comingSoon,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: () {
              context.read<MainCubit>().changeHomeView(2);
            },
            child: Container(
              width: 114,
              height: 36,
              decoration: BoxDecoration(
                color: ColorsExt.grey6(context),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: ColorsExt.grey4(context),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  t.calendar.goToToday,
                  style: TextStyle(
                    fontSize: 17,
                    color: ColorsExt.grey2(context),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
