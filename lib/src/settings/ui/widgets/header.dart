import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:mobile/src/base/ui/cubit/auth/auth_cubit.dart';
import 'package:mobile/src/base/ui/widgets/base/badged_icon.dart';
import 'package:mobile/src/base/ui/widgets/base/icon_badge.dart';
import 'package:mobile/src/settings/ui/pages/settings_page.dart';
import 'package:mobile/src/settings/ui/widgets/search_modal.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../../../common/style/colors.dart';

class Header extends StatelessWidget {
  const Header({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          "assets/images/logo/logo_outline.svg",
          width: 48,
          height: 48,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: BlocBuilder<AuthCubit, AuthCubitState>(
            builder: (context, state) {
              if (state.user == null) {
                return const SizedBox();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.user?.name ?? "n/d",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.user?.email ?? "n/d",
                    style: TextStyle(
                      fontSize: 14,
                      color: ColorsExt.grey3(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          child: SvgPicture.asset(
            "assets/images/icons/_common/search.svg",
            height: 25,
            color: ColorsExt.grey3(context),
          ),
          onTap: () {
            showCupertinoModalBottomSheet(
              context: context,
              builder: (context) => const SearchModal(),
            );
          },
        ),
        const SizedBox(width: 12),
        InkWell(
          child: BadgedIcon(
            icon: "assets/images/icons/_common/gear_alt.svg",
            color: Colors.transparent,
            badge: FutureBuilder<dynamic>(
                future: Intercom.instance.unreadConversationCount(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return IconBadge(
                      snapshot.data,
                      offset: const Offset(12, -9),
                    );
                  }
                  return const SizedBox();
                }),
          ),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
          },
        ),
      ],
    );
  }
}
