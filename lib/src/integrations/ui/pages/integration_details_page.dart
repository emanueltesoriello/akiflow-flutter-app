import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/common/utils/integrations_utils.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/base/models/mark_as_done_type.dart';
import 'package:mobile/src/base/ui/widgets/base/app_bar.dart';
import 'package:mobile/src/integrations/ui/cubit/integrations_cubit.dart';
import 'package:mobile/src/integrations/ui/widgets/circle_account_picture.dart';
import 'package:mobile/src/integrations/ui/widgets/header_trailing_action_buttons.dart';
import 'package:mobile/src/integrations/ui/widgets/integration_list_item.dart';
import 'package:mobile/src/integrations/ui/widgets/integration_setting.dart';
import 'package:mobile/src/base/ui/widgets/base/settings_header_text.dart';
import 'package:mobile/src/integrations/ui/widgets/mark_done_modal.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/account/account.dart';

class IntegrationDetailsPage extends StatefulWidget {
  final Account? account;
  const IntegrationDetailsPage({Key? key, this.account}) : super(key: key);

  @override
  State<IntegrationDetailsPage> createState() => _IntegrationDetailsPageState();
}

class _IntegrationDetailsPageState extends State<IntegrationDetailsPage> {
  bool isConnected = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IntegrationsCubit, IntegrationsCubitState>(builder: (context, state) {
      Account account = state.accounts.firstWhere((element) =>
          element.connectorId == widget.account!.connectorId &&
          element.originAccountId == widget.account!.originAccountId);
      String title = IntegrationsUtils.titleFromConnectorId(account.connectorId);
      return Scaffold(
        appBar: AppBarComp(
          title: title,
          showBack: true,
          actions: [HeaderTrailingActionButtons(account)],
        ),
        body: BlocBuilder<IntegrationsCubit, IntegrationsCubitState>(builder: (context, state) {
          Account user = state.accounts.firstWhere((account) => account.accountId == widget.account?.accountId);
          isConnected =
              context.read<IntegrationsCubit>().isLocalActive(user) && user.connectorId == widget.account!.connectorId;
          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(Dimension.padding),
                      children: [
                        _header(account),
                        IgnorePointer(
                          ignoring: !isConnected,
                          child: Opacity(
                            opacity: isConnected ? 1 : 0.5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 32),
                                SettingHeaderText(text: t.settings.integrations.gmail.behavior),
                                _behaviour(account, title),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      );
    });
  }

  IntegrationListItem _header(Account account) {
    return IntegrationListItem(
      leading: CircleAccountPicture(
        iconAsset: TaskExt.iconFromConnectorId(account.connectorId),
        networkImageUrl: account.picture,
      ),
      title: IntegrationsUtils.titleFromConnectorId(account.connectorId),
      identifier: account.identifier ?? '',
      insets: const EdgeInsets.all(1),
      borderRadius: BorderRadius.circular(Dimension.radius),
      trailing: const SizedBox(),
      onPressed: () {},
      active: context.read<IntegrationsCubit>().isLocalActive(account),
    );
  }

  Widget _behaviour(Account account, String title) {
    String? markDoneSetting = account.details?['mark_as_done_action'];
    String subtitle = MarkAsDoneType.titleFromKey(key: markDoneSetting, integrationTitle: title);
    return IntegrationSetting(
      title: t.settings.integrations.onMarkAsDone.title,
      subtitle: subtitle,
      onPressed: () async {
        MarkAsDoneType initialType;
        var integrationsCubit = context.read<IntegrationsCubit>();

        switch (markDoneSetting) {
          case 'unstar':
            initialType = MarkAsDoneType.unstarTheEmail;
            break;
          case 'markAsDone':
            initialType = MarkAsDoneType.markAsDone;
            break;
          case 'open':
            initialType = MarkAsDoneType.goTo;
            break;
          case 'cancel':
            initialType = MarkAsDoneType.doNothing;
            break;
          default:
            initialType = MarkAsDoneType.askMeEveryTime;
            break;
        }

        MarkAsDoneType? selectedType = await showCupertinoModalBottomSheet(
          context: context,
          builder: (context) => MarkDoneModal(
            initialType: initialType,
            account: account,
          ),
        );

        if (selectedType != null) {
          integrationsCubit.behaviorMarkAsDone(account, selectedType);
        }
      },
    );
  }
}
