import 'package:flutter/material.dart';
import 'package:mobile/features/integrations/ui/circle_account_picture.dart';
import 'package:mobile/features/integrations/ui/integration_list_item.dart';
import 'package:mobile/style/theme.dart';
import 'package:mobile/utils/doc_extension.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:models/account/account.dart';

class IntegrationsList extends StatelessWidget {
  final List<Account> accounts;
  final Function(Account) onTap;
  final Widget? trailing;

  const IntegrationsList(this.accounts, {Key? key, required this.onTap, this.trailing}) : super(key: key);

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

        return IntegrationListItem(
          active: true,
          leading: CircleAccountPicture(iconAsset: iconAsset, networkImageUrl: account.picture),
          trailing: trailing,
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
