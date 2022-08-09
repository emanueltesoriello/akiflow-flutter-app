import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/components/base/app_bar.dart';
import 'package:mobile/common/components/base/button_list.dart';
import 'package:mobile/features/auth/cubit/auth_cubit.dart';
import 'package:mobile/features/auth/ui/auth_page.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class MyAccountPage extends StatelessWidget {
  const MyAccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComp(
        title: t.settings.myAccount.title,
        showBack: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    t.settings.myAccount.connectedAs.toUpperCase(),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: ColorsExt.grey3(context)),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 62,
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: ColorsExt.background(context),
                      border: Border.all(color: ColorsExt.grey5(context), width: 1),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          "assets/images/logo/logo_outline.svg",
                          width: 42,
                          height: 42,
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
                                    style: TextStyle(
                                        fontSize: 17, fontWeight: FontWeight.w400, color: ColorsExt.grey2(context)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    state.user?.email ?? "n/d",
                                    style: TextStyle(
                                        fontSize: 12, fontWeight: FontWeight.w500, color: ColorsExt.grey3(context)),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t.settings.myAccount.manageAccount.toUpperCase(),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: ColorsExt.grey3(context)),
                  ),
                  const SizedBox(height: 4),
                  ButtonList(
                    title: t.settings.myAccount.manageAccount,
                    position: ButtonListPosition.single,
                    leading: "assets/images/icons/_common/person_crop_circle.svg",
                    trailingWidget: SvgPicture.asset(
                      "assets/images/icons/_common/arrow_up_right_square.svg",
                      width: 22,
                      height: 22,
                    ),
                    onPressed: () {
                      launchUrl(Uri.parse("https://app.akiflow.com/en/dashboard/profile"),
                          mode: LaunchMode.externalApplication);
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t.settings.myAccount.manageSubscriptionAndBillingPreferences.toUpperCase(),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: ColorsExt.grey3(context)),
                  ),
                  const SizedBox(height: 4),
                  ButtonList(
                    title: t.settings.myAccount.manageAccount,
                    position: ButtonListPosition.single,
                    leading: "assets/images/icons/_common/money_dollar_circle.svg",
                    trailingWidget: SvgPicture.asset(
                      "assets/images/icons/_common/arrow_up_right_square.svg",
                      width: 22,
                      height: 22,
                    ),
                    onPressed: () {
                      launchUrl(Uri.parse("https://app.akiflow.com/en/checkout/billing"),
                          mode: LaunchMode.externalApplication);
                    },
                  ),
                  const Spacer(),
                  ButtonList(
                    title: t.settings.myAccount.logout,
                    position: ButtonListPosition.single,
                    onPressed: () {
                      context.read<AuthCubit>().logout();

                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const AuthPage()), (Route<dynamic> route) => false);
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
