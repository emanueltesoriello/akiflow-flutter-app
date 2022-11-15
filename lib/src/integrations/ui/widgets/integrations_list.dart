import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/theme.dart';
import 'package:mobile/extensions/doc_extension.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/integrations/ui/cubit/integrations_cubit.dart';
import 'package:mobile/src/integrations/ui/widgets/circle_account_picture.dart';
import 'package:mobile/src/integrations/ui/widgets/integration_list_item.dart';
import 'package:models/account/account.dart';

class IntegrationsList extends StatelessWidget {
  final List<Account> accounts;
  final Function(Account) onTap;
  final bool isReconnectPage;

  const IntegrationsList(this.accounts, {Key? key, required this.onTap, this.isReconnectPage = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 5),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        Account account = accounts[index];
        String? title = DocExt.titleFromConnectorId(account.connectorId);
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
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  t.onboarding.reconnect.toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: ColorsExt.akiflow(context)),
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
          enabled: account.connectorId == 'gmail',
          onPressed: () {
            onTap(account);
          },
        );
      },
    );
  }

  BorderRadius _getBorderRadius(int index, int accountsLength) {
    if (index == 0) {
      return const BorderRadius.only(topLeft: Radius.circular(radius), topRight: Radius.circular(radius));
    } else if (index == accountsLength - 1) {
      return const BorderRadius.only(bottomLeft: Radius.circular(radius), bottomRight: Radius.circular(radius));
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
