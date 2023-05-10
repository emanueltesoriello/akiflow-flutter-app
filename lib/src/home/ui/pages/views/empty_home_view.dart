import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/cubit/main/main_cubit.dart';

class EmptyHomeViewPlaceholder extends StatelessWidget {
  const EmptyHomeViewPlaceholder({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      // mainAxisAlignment: MainAxisAlignment.center,
      // crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height / 3.5,
        ),
        SvgPicture.asset(
          Assets.images.akiflow.inboxZeroSVG,
          height: Dimension.pagesImageSize,
        ),
        const SizedBox(height: Dimension.paddingM),
        Text(
          t.task.awesomeInboxZero,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(fontWeight: FontWeight.w500, color: ColorsExt.grey800(context)),
        ),
        const SizedBox(height: Dimension.padding),
        Center(
          child: OutlinedButton(
            onPressed: () {
              context.read<MainCubit>().changeHomeView(HomeViewType.today);
            },
            child: Text(
              t.calendar.goToToday,
              style: Theme.of(context).textTheme.subtitle1?.copyWith(color: ColorsExt.grey800(context)),
            ),
          ),
        ),
      ],
    );
  }
}
