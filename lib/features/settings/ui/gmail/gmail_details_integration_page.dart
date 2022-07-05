import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/app_bar.dart';
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
import 'package:mobile/utils/task_extension.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/account/account.dart';
import 'package:models/extensions/user_ext.dart';
import 'package:models/integrations/gmail.dart';
import 'package:models/user.dart';

class GmailDetailsIntegrationsPage extends StatelessWidget {
  const GmailDetailsIntegrationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComp(
        title: t.settings.integrations.gmail.title,
        showBack: true,
      ),
      body: Column(
        children: [
          Expanded(
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
                      trailingWidget: FlutterSwitch(
                        width: 48,
                        height: 24,
                        toggleSize: 20,
                        activeColor: ColorsExt.akiflow(context),
                        inactiveColor: ColorsExt.grey5(context),
                        value: isSuperhumanEnabled ?? false,
                        borderRadius: 24,
                        padding: 2,
                        onToggle: (value) {
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
        ],
      ),
    );
  }

  Widget _behaviour() {
    return BlocBuilder<SettingsCubit, SettingsCubitState>(
      builder: (context, state) {
        Account gmailAccount = state.accounts.firstWhere((element) => element.connectorId == "gmail");

        return BlocBuilder<AuthCubit, AuthCubitState>(
          builder: (context, authState) {
            String? markAsDone = authState.user!.markAsDone;
            GmailSyncMode syncMode = GmailSyncMode.fromKey(gmailAccount.details?['syncMode']);
            String subtitle = GmailMarkAsDoneType.titleFromKey(markAsDone, syncMode);

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
      },
    );
  }

  BlocBuilder<SettingsCubit, SettingsCubitState> _importOptions() {
    return BlocBuilder<SettingsCubit, SettingsCubitState>(
      builder: (context, state) {
        Account gmailAccount = state.accounts.firstWhere((element) => element.connectorId == "gmail");
        String subtitle;

        switch (gmailAccount.details?['syncMode']) {
          case 1:
            subtitle = t.settings.integrations.gmail.toImportTask.useAkiflowLabel;
            break;
          case 0:
            subtitle = t.settings.integrations.gmail.toImportTask.useStarToImport;
            break;
          case -1:
            subtitle = t.settings.integrations.gmail.toImportTask.doNothing;
            break;
          default:
            subtitle = t.settings.integrations.gmail.toImportTask.askMeEveryTime;
            break;
        }

        return IntegrationSetting(
          title: t.settings.integrations.gmail.toImportTask.title,
          subtitle: subtitle,
          onPressed: () async {
            var bloc = context.read<SettingsCubit>();

            GmailSyncMode initialType;

            switch (gmailAccount.details?['syncMode']) {
              case 1:
                initialType = GmailSyncMode.useAkiflowLabel;
                break;
              case 0:
                initialType = GmailSyncMode.useStarToImport;
                break;
              case -1:
                initialType = GmailSyncMode.doNothing;
                break;
              default:
                initialType = GmailSyncMode.askMeEveryTime;
                break;
            }

            GmailSyncMode? selectedType = await showCupertinoModalBottomSheet(
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
              SvgPicture.asset(TaskExt.iconFromConnectorId("gmail")),
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
          identifier: gmailAccount.identifier ?? '',
          insets: const EdgeInsets.all(1),
          borderRadius: BorderRadius.circular(radius),
          trailingWidget: const SizedBox(),
          onPressed: () {},
        );
      },
    );
  }
}
