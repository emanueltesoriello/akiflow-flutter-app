import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/extensions/doc_extension.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/base/ui/cubit/auth/auth_cubit.dart';
import 'package:mobile/src/base/models/gmail_mark_as_done_type.dart';
import 'package:mobile/src/base/ui/widgets/base/action_button.dart';
import 'package:mobile/src/base/ui/widgets/base/app_bar.dart';
import 'package:mobile/src/integrations/ui/cubit/integrations_cubit.dart';
import 'package:mobile/src/integrations/ui/widgets/circle_account_picture.dart';
import 'package:mobile/src/integrations/ui/widgets/gmail/gmail_import_task_modal.dart';
import 'package:mobile/src/integrations/ui/widgets/gmail/gmail_mark_done_modal.dart';
import 'package:mobile/src/integrations/ui/widgets/integration_list_item.dart';
import 'package:mobile/src/integrations/ui/widgets/integration_setting.dart';
import 'package:mobile/src/base/ui/widgets/base/settings_header_text.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/account/account.dart';
import 'package:models/integrations/gmail.dart';
import 'package:models/user.dart';
import 'package:models/extensions/user_ext.dart';

class GmailDetailsIntegrationsPage extends StatefulWidget {
  final Account? account;
  final Function? onDisconnect;
  const GmailDetailsIntegrationsPage({Key? key, this.account, this.onDisconnect}) : super(key: key);

  @override
  State<GmailDetailsIntegrationsPage> createState() => _GmailDetailsIntegrationsPageState();
}

class _GmailDetailsIntegrationsPageState extends State<GmailDetailsIntegrationsPage> {
  bool isConnected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComp(
        title: t.settings.integrations.gmail.title,
        showBack: true,
      ),
      body: BlocBuilder<IntegrationsCubit, IntegrationsCubitState>(builder: (context, state) {
        Account gmailAccount = state.accounts.firstWhere(
            (element) => element.connectorId == "gmail" && element.originAccountId == widget.account!.originAccountId);
        bool? isSuperhumanEnabled = gmailAccount.details?['isSuperhumanEnabled'];
        Account user = state.accounts.firstWhere((account) => account.accountId == widget.account?.accountId);
        isConnected = context.read<IntegrationsCubit>().isLocalActive(user) && user.connectorId == 'gmail';
        return Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(Dimension.padding),
                    children: [
                      _header(),
                      IgnorePointer(
                        ignoring: !isConnected,
                        child: Opacity(
                          opacity: isConnected ? 1 : 0.5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 32),
                              SettingHeaderText(text: t.settings.integrations.gmail.importOptions),
                              _importOptions(),
                              const SizedBox(height: 20),
                              SettingHeaderText(text: t.settings.integrations.gmail.behavior),
                              _behaviour(),
                              const SizedBox(height: 20),
                              SettingHeaderText(text: t.settings.integrations.gmail.clientSettings),
                              IntegrationSetting(
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
                                        .read<IntegrationsCubit>()
                                        .updateGmailSuperHumanEnabled(gmailAccount, isSuperhumanEnabled: value);
                                  },
                                ),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(Dimension.padding),
                      width: MediaQuery.of(context).size.width,
                      child: Builder(builder: (context) {
                        return (isConnected)
                            ? ActionButton(
                                key: const Key('Disconnect'),
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  await context.read<IntegrationsCubit>().disconnectGmail(user);
                                  if (widget.onDisconnect != null) widget.onDisconnect!;
                                },
                                color: Colors.transparent,
                                splashColor: ColorsExt.grey3(context),
                                borderColor: ColorsExt.grey2_5(context),
                                child: Text(
                                  'Disconnect',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                    color: ColorsExt.grey2_5(context),
                                  ),
                                ))
                            : ActionButton(
                                key: const Key('Reconnect'),
                                onPressed: () async {
                                  context.read<IntegrationsCubit>().connectGmail(email: user.identifier);
                                },
                                color: ColorsExt.orange20(context),
                                splashColor: ColorsExt.orange(context),
                                borderColor: ColorsExt.orange(context),
                                child: const Text(
                                  'Reconnect',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ));
                      }),
                    ),
                  ),
                  const SizedBox(height: 32)
                ],
              ),
            )
          ],
        );
      }),
    );
  }

  Widget _behaviour() {
    return BlocBuilder<IntegrationsCubit, IntegrationsCubitState>(
      builder: (context, state) {
        Account gmailAccount = state.accounts.firstWhere(
            (element) => element.connectorId == "gmail" && element.originAccountId == widget.account!.originAccountId);

        return BlocBuilder<AuthCubit, AuthCubitState>(
          builder: (context, authState) {
            String? markAsDone = authState.user!.markAsDone;
            GmailSyncMode syncMode = GmailSyncMode.fromKey(gmailAccount.details?['syncMode']);
            String subtitle = GmailMarkAsDoneType.titleFromKey(markAsDone, syncMode);

            return IntegrationSetting(
              title: t.settings.integrations.gmail.onMarkAsDone.title,
              subtitle: subtitle,
              onPressed: () async {
                var bloc = context.read<IntegrationsCubit>();

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

  BlocBuilder<IntegrationsCubit, IntegrationsCubitState> _importOptions() {
    return BlocBuilder<IntegrationsCubit, IntegrationsCubitState>(
      builder: (context, state) {
        Account gmailAccount = state.accounts.firstWhere(
            (element) => element.connectorId == "gmail" && element.originAccountId == widget.account!.originAccountId);
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
            var bloc = context.read<IntegrationsCubit>();

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

  BlocBuilder<IntegrationsCubit, IntegrationsCubitState> _header() {
    return BlocBuilder<IntegrationsCubit, IntegrationsCubitState>(
      builder: (context, state) {
        Account gmailAccount = state.accounts.firstWhere(
            (element) => element.connectorId == "gmail" && element.originAccountId == widget.account!.originAccountId);

        return IntegrationListItem(
          leading: CircleAccountPicture(
            iconAsset: TaskExt.iconFromConnectorId("gmail"),
            networkImageUrl: gmailAccount.picture,
          ),
          title: DocExt.titleFromConnectorId("gmail"),
          identifier: gmailAccount.identifier ?? '',
          insets: const EdgeInsets.all(1),
          borderRadius: BorderRadius.circular(Dimension.radius),
          trailing: const SizedBox(),
          onPressed: () {},
          active: context.read<IntegrationsCubit>().isLocalActive(gmailAccount),
        );
      },
    );
  }
}
