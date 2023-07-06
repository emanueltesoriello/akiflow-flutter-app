import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/main_com.dart';
import 'package:mobile/src/base/ui/cubit/auth/auth_cubit.dart';
import 'package:mobile/src/base/ui/widgets/base/app_bar.dart';
import 'package:mobile/src/base/ui/widgets/base/button_list.dart';
import 'package:mobile/src/base/ui/widgets/base/separator.dart';
import 'package:mobile/src/settings/ui/cubit/settings_cubit.dart';
import 'package:mobile/src/settings/ui/pages/licences_page.dart';
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
              padding: const EdgeInsets.all(Dimension.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Dimension.paddingXS),
                  Container(
                    padding: const EdgeInsets.all(Dimension.padding),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimension.radius),
                      color: ColorsExt.background(context),
                      border: Border.all(color: ColorsExt.grey200(context), width: 1),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset("assets/images/logo/logo_outline.svg", width: 42, height: 42),
                        const SizedBox(width: Dimension.padding),
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(color: ColorsExt.grey800(context), fontWeight: FontWeight.w400),
                                    ),
                                    const SizedBox(height: Dimension.paddingXS),
                                    BlocBuilder<SettingsCubit, SettingsCubitState>(
                                      builder: (context, state) {
                                        return Text(
                                          state.appVersion ?? "",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(color: ColorsExt.grey600(context), fontWeight: FontWeight.w500),
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
                  const SizedBox(height: Dimension.padding),
                  Text(
                    t.settings.about.legal.toUpperCase(),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: ColorsExt.grey600(context), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: Dimension.paddingXS),
                  ButtonList(
                    title: t.settings.about.licensesInfo,
                    position: ButtonListPosition.top,
                    showShevron: false,
                    textMainAxisAlignment: MainAxisAlignment.start,
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LicencesPage()));
                    },
                  ),
                  const Separator(),
                  ButtonList(
                    title: t.settings.about.security,
                    position: ButtonListPosition.bottom,
                    showShevron: false,
                    textMainAxisAlignment: MainAxisAlignment.start,
                    trailingWidget: SvgPicture.asset(
                      Assets.images.icons.common.arrowUpRightSquareSVG,
                      width: Dimension.defaultIconSize,
                      height: Dimension.defaultIconSize,
                    ),
                    onPressed: () {
                      launchUrl(Uri.parse("https://www.notion.so/akiflow/Security-6d61cefd8c2349b2b4d5561aa82f1832"),
                          mode: LaunchMode.externalApplication);
                    },
                  ),
                  const SizedBox(height: Dimension.padding),
                  if (kDebugMode)
                    ButtonList(
                      title: "Restart the app",
                      leading: Assets.images.icons.common.repeatSVG,
                      position: ButtonListPosition.single,
                      showShevron: false,
                      useSvgColor: true,
                      onPressed: () async {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        await mainCom();
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
