import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/app_bar.dart';
import 'package:mobile/components/base/container_inner_shadow.dart';
import 'package:mobile/features/auth/cubit/auth_cubit.dart';
import 'package:mobile/features/settings/cubit/settings_cubit.dart';
import 'package:mobile/features/settings/ui/gmail/gmail_import_task_modal.dart';
import 'package:mobile/features/settings/ui/gmail/gmail_mark_done_modal.dart';
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
                  _header(),
                  const SizedBox(height: 32),
                  SettingHeaderText(text: t.settings.integrations.gmail.importOptions),
                  _importOptions(),
                  const SizedBox(height: 20),
                  SettingHeaderText(text: t.settings.integrations.gmail.behavior),
                  _behaviour(),
                  const SizedBox(height: 20),
                  SettingHeaderText(text: t.settings.integrations.gmail.clientSettings),
                  BlocBuilder<SettingsCubit, SettingsCubitState>(
                    builder: (context, state) {
                      Account gmailAccount = state.accounts.firstWhere((element) => element.connectorId == "gmail");

                      bool? isSuperhumanEnabled = gmailAccount.details?['isSuperhumanEnabled'];

                      return IntegrationSetting(
                        title: t.settings.integrations.gmail.useSuperhuman,
                        subtitle: t.settings.integrations.gmail.openYourEmailsInSuperhumanInsteadOfGmail,
                        trailingWidget: CupertinoSwitch(
                          activeColor: ColorsExt.akiflow(context),
                          value: isSuperhumanEnabled ?? false,
                          onChanged: (value) {
                            context
                                .read<SettingsCubit>()
                                .updateGmailSuperHumanEnabled(gmailAccount, isSuperhumanEnabled: value);
                          },
                        ),
                        onPressed: () {},
                      );
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

  BlocBuilder<AuthCubit, AuthCubitState> _behaviour() {
    return BlocBuilder<AuthCubit, AuthCubitState>(
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
    );
  }

  BlocBuilder<SettingsCubit, SettingsCubitState> _importOptions() {
    return BlocBuilder<SettingsCubit, SettingsCubitState>(
      builder: (context, state) {
        Account gmailAccount = state.accounts.firstWhere((element) => element.connectorId == "gmail");

        String subtitle = GmailImportTaskType.titleFromKey(gmailAccount.details?['syncMode']);

        return IntegrationSetting(
          title: t.settings.integrations.gmail.toImportTask.title,
          subtitle: subtitle,
          onPressed: () async {
            var bloc = context.read<SettingsCubit>();

            GmailImportTaskType initialType;

            switch (gmailAccount.details?['syncMode']) {
              case 1:
                initialType = GmailImportTaskType.useAkiflowLabel;
                break;
              case 0:
                initialType = GmailImportTaskType.useStarToImport;
                break;
              case -1:
                initialType = GmailImportTaskType.doNothing;
                break;
              default:
                initialType = GmailImportTaskType.askMeEveryTime;
                break;
            }

            GmailImportTaskType? selectedType = await showCupertinoModalBottomSheet(
              context: context,
              builder: (context) => GmaiImportTaskModal(initialType: initialType),
            );

            if (selectedType != null) {
              bloc.gmailImportOptions(gmailAccount, selectedType);
            }
          },
        );
      },
    );
  }

  BlocBuilder<SettingsCubit, SettingsCubitState> _header() {
    return BlocBuilder<SettingsCubit, SettingsCubitState>(
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
    );
  }
}
