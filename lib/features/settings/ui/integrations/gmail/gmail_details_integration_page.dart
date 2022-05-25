import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/app_bar.dart';
import 'package:mobile/components/base/container_inner_shadow.dart';
import 'package:mobile/features/auth/cubit/auth_cubit.dart';
import 'package:mobile/features/settings/cubit/settings_cubit.dart';
import 'package:mobile/features/settings/ui/integrations/gmail/gmail_mark_done_modal.dart';
import 'package:mobile/features/settings/ui/view/integration_list_item.dart';
import 'package:mobile/features/settings/ui/view/integration_setting.dart';
import 'package:mobile/features/settings/ui/view/settings_header_text.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/style/theme.dart';
import 'package:mobile/utils/doc_extension.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/account/account.dart';
import 'package:models/user.dart';

class GmailDetailsIntegrationsPage extends StatelessWidget {
  const GmailDetailsIntegrationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppBarComp(
            title: t.settings.integrations.gmail.title,
            showBack: true,
            showSyncButton: false,
          ),
          Expanded(
            child: ContainerInnerShadow(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  BlocBuilder<SettingsCubit, SettingsCubitState>(
                    builder: (context, state) {
                      Account gmailAccount = state.accounts.firstWhere((element) => element.connectorId == "gmail");

                      return IntegrationListItem(
                        leadingWidget: Stack(
                          fit: StackFit.expand,
                          children: [
                            SvgPicture.asset(DocExt.iconFromConnectorId("gmail")),
                            Builder(builder: (context) {
                              if (gmailAccount.picture == null || gmailAccount.picture!.isEmpty) {
                                return const SizedBox();
                              }
                              return Align(
                                  alignment: Alignment.bottomRight,
                                  child: CircleAvatar(
                                      radius: 8,
                                      backgroundColor: ColorsExt.grey3(context),
                                      backgroundImage: NetworkImage(gmailAccount.picture!)));
                            })
                          ],
                        ),
                        title: DocExt.titleFromConnectorId("gmail"),
                        identifier: gmailAccount.identifier ?? 'aaa',
                        insets: const EdgeInsets.all(1),
                        borderRadius: BorderRadius.circular(radius),
                        trailingWidget: const SizedBox(),
                        onPressed: () {},
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  SettingHeaderText(text: t.settings.integrations.gmail.importOptions),
                  IntegrationSetting(
                    title: t.settings.integrations.gmail.toImportTasks,
                    subtitle: t.settings.integrations.gmail.useAkiflowLabel,
                    onPressed: () {
                      // TODO handle this action
                    },
                  ),
                  const SizedBox(height: 20),
                  SettingHeaderText(text: t.settings.integrations.gmail.behavior),
                  BlocBuilder<AuthCubit, AuthCubitState>(
                    builder: (context, authState) {
                      String? markAsDone = authState.user?.settings?['popups']['gmail.unstar'];
                      String subtitle = GmailMarkAsDoneType.titleFromKey(markAsDone);

                      return IntegrationSetting(
                        title: t.settings.integrations.gmail.onMarkAsDone.title,
                        subtitle: subtitle,
                        onPressed: () async {
                          var bloc = context.read<SettingsCubit>();

                          User user = authState.user!;

                          GmailMarkAsDoneType initialType;

                          switch (user.settings?['popups']['gmail.unstar']) {
                            case 'unstar':
                              initialType = GmailMarkAsDoneType.unstarTheEmail;
                              break;
                            case 'open':
                              initialType = GmailMarkAsDoneType.goToGmail;
                              break;
                            case 'cancel':
                              initialType = GmailMarkAsDoneType.doNothing;
                              break;
                            default:
                              initialType = GmailMarkAsDoneType.askMeEveryTime;
                              break;
                          }

                          GmailMarkAsDoneType? selectedType = await showCupertinoModalBottomSheet(
                            context: context,
                            builder: (context) => GmailMarkDoneModal(initialType: initialType),
                          );

                          if (selectedType != null) {
                            bloc.gmailBehaviorOnMarkAsDone(selectedType);
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  SettingHeaderText(text: t.settings.integrations.gmail.clientSettings),
                  IntegrationSetting(
                    title: t.settings.integrations.gmail.useSuperhuman,
                    subtitle: t.settings.integrations.gmail.openYourEmailsInSuperhumanInsteadOfGmail,
                    trailingWidget: CupertinoSwitch(
                      activeColor: ColorsExt.akiflow(context),
                      value: true,
                      onChanged: (value) {},
                    ),
                    onPressed: () {
                      // TODO handle this action
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

  Container _mailPlaceholder(BuildContext context) {
    return Container(
      height: 86,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: ColorsExt.background(context),
        border: Border.all(color: ColorsExt.grey7(context), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, -1),
            blurRadius: radius,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: CircleAvatar(radius: 19, backgroundColor: ColorsExt.grey4(context)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 18,
                        width: double.infinity,
                        margin: const EdgeInsets.only(right: 100),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: ColorsExt.grey6(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 18,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: ColorsExt.grey6(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 18,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: ColorsExt.grey6(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      height: 15,
                      width: 47,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: ColorsExt.grey6(context),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      height: 27,
                      width: 27,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ColorsExt.background(context),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x37404A40),
                            offset: Offset(0, 5),
                            blurRadius: radius,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: SvgPicture.asset("assets/images/icons/google/star.svg"),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Align(alignment: Alignment.bottomRight, child: SvgPicture.asset("assets/images/icons/google/finger.svg")),
        ],
      ),
    );
  }

  Row _step1(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 10,
          backgroundColor: ColorsExt.akiflow(context),
          child: const Text("1"),
        ),
        const SizedBox(width: 14),
        Expanded(
            child: RichText(
          text: TextSpan(
            text: t.settings.integrations.gmail.step1.t1,
            style: TextStyle(fontSize: 17, color: ColorsExt.grey2(context)),
            children: [
              TextSpan(
                  text: t.settings.integrations.gmail.step1.t2, style: const TextStyle(fontWeight: FontWeight.w500)),
              TextSpan(text: t.settings.integrations.gmail.step1.t3),
            ],
          ),
        )),
      ],
    );
  }

  Row _step2(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 10,
          backgroundColor: ColorsExt.akiflow(context),
          child: const Text("2"),
        ),
        const SizedBox(width: 14),
        Expanded(
            child: RichText(
          text: TextSpan(
            text: t.settings.integrations.gmail.step2,
            style: TextStyle(fontSize: 17, color: ColorsExt.grey2(context)),
          ),
        )),
      ],
    );
  }
}
