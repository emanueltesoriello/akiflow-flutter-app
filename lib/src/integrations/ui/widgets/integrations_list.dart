import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/common/utils/integrations_utils.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/integrations/ui/cubit/integrations_cubit.dart';
import 'package:mobile/src/integrations/ui/widgets/circle_account_picture.dart';
import 'package:mobile/src/integrations/ui/widgets/integration_list_item.dart';
import 'package:models/account/account.dart';
import 'package:models/extensions/account_ext.dart';

class IntegrationsList extends StatelessWidget {
  final List<Account> accounts;
  final Function(Account) onTap;
  final bool isReconnectPage;

  const IntegrationsList(this.accounts, {Key? key, required this.onTap, this.isReconnectPage = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    accounts.sort((a, b) => a.connectorId != b.connectorId ? 1 : -1);
    accounts.sort((a, b) => AccountExt.settingsEnabled.contains(b.connectorId) ? 1 : -1);

    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 5),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        Account account = accounts[index];
        String? title = IntegrationsUtils.titleFromConnectorId(account.connectorId);
        String? iconAsset = TaskExt.iconFromConnectorId(account.connectorId);

        bool isLocalActive = context.read<IntegrationsCubit>().isLocalActive(account);

        return IntegrationListItem(
          active: context.read<IntegrationsCubit>().isLocalActive(account),
          leading: CircleAccountPicture(iconAsset: iconAsset, networkImageUrl: account.picture),
          trailing: () {
            if (isReconnectPage && isLocalActive) {
              return const SizedBox();
            } else if (isReconnectPage && isLocalActive == true) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimension.padding),
                child: Text(
                  t.onboarding.reconnect.toUpperCase(),
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: ColorsExt.akiflow500(context),
                      ),
                ),
              );
            } else {
              return null;
            }
          }(),
          title: title,
          identifier: account.identifier ?? '',
          insets: _getEdgeInsets(index, accounts.length),
          borderRadius: _getBorderRadius(index, accounts.length),
          enabled: account.connectorId == 'gmail' || AccountExt.settingsEnabled.contains(account.connectorId),
          onPressed: () {
            onTap(account);
          },
        );
      },
    );
  }

  BorderRadius _getBorderRadius(int index, int accountsLength) {
    if (index == 0) {
      return const BorderRadius.only(
          topLeft: Radius.circular(Dimension.radius), topRight: Radius.circular(Dimension.radius));
    } else if (index == accountsLength - 1) {
      return const BorderRadius.only(
          bottomLeft: Radius.circular(Dimension.radius), bottomRight: Radius.circular(Dimension.radius));
    } else {
      return BorderRadius.zero;
    }
  }

  EdgeInsets _getEdgeInsets(int index, int accountsLength) {
    if (index == 0) {
      return const EdgeInsets.only(top: 1, left: 1, right: 1, bottom: 1);
    } else if (index == accountsLength - 1) {
      return const EdgeInsets.only(left: 1, right: 1, bottom: 1);
    } else {
      return const EdgeInsets.only(left: 1, right: 1, bottom: 1);
    }
  }
}
