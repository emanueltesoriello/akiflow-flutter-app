import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/src/base/ui/cubit/main/main_cubit.dart';

class EmptyHomeViewPlaceholder extends StatelessWidget {
  const EmptyHomeViewPlaceholder({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ListView(),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              Assets.images.akiflow.inboxZeroSVG,
              height: 80,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    t.task.awesomeInboxZero,
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
                context.read<MainCubit>().changeHomeView(HomeViewType.today);
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
      ],
    );
  }
}
