import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/app_bar.dart';
import 'package:mobile/components/base/button_list.dart';
import 'package:mobile/components/base/button_list_divider.dart';
import 'package:mobile/features/auth/cubit/auth_cubit.dart';
import 'package:mobile/features/settings/cubit/settings_cubit.dart';
import 'package:mobile/features/settings/ui/licences_page.dart';
import 'package:mobile/style/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComp(
        title: t.settings.about.title,
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
                              return Visibility(
                                visible: state.user != null,
                                replacement: const SizedBox(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.settings.about.version,
                                      style: TextStyle(
                                          fontSize: 17, fontWeight: FontWeight.w400, color: ColorsExt.grey2(context)),
                                    ),
                                    const SizedBox(height: 4),
                                    BlocBuilder<SettingsCubit, SettingsCubitState>(
                                      builder: (context, state) {
                                        return Text(
                                          state.appVersion ?? "",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: ColorsExt.grey3(context)),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t.settings.about.legal.toUpperCase(),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: ColorsExt.grey3(context)),
                  ),
                  const SizedBox(height: 4),
                  ButtonList(
                    title: t.settings.about.licensesInfo,
                    position: ButtonListPosition.top,
                    showShevron: false,
                    textMainAxisAlignment: MainAxisAlignment.start,
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LicencesPage()));
                    },
                  ),
                  const ButtonListDivider(),
                  ButtonList(
                    title: t.settings.about.security,
                    position: ButtonListPosition.bottom,
                    showShevron: false,
                    textMainAxisAlignment: MainAxisAlignment.start,
                    trailingWidget: SvgPicture.asset(
                      "assets/images/icons/_common/arrow_up_right_square.svg",
                      width: 22,
                      height: 22,
                    ),
                    onPressed: () {
                      launchUrl(Uri.parse("https://www.notion.so/akiflow/Security-6d61cefd8c2349b2b4d5561aa82f1832"),
                          mode: LaunchMode.externalApplication);
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
