import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/app_bar.dart';
import 'package:mobile/features/settings/cubit/settings_cubit.dart';
import 'package:mobile/features/settings/ui/gmail/gmail_details_integration_page.dart';
import 'package:mobile/features/settings/ui/gmail/gmail_instruction_integration_page.dart';
import 'package:mobile/features/settings/ui/view/integration_list_item.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/style/theme.dart';
import 'package:mobile/utils/doc_extension.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:models/account/account.dart';

class IntegrationsPage extends StatelessWidget {
  const IntegrationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComp(
        title: t.settings.integrations.title,
        showBack: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                BlocBuilder<SettingsCubit, SettingsCubitState>(
                  builder: (context, state) {
                    List<Account> accounts = state.accounts.toList();
                    accounts.removeWhere((element) => element.connectorId == "akiflow");
                    return Visibility(
                      visible: accounts.isNotEmpty,
                      replacement: const SizedBox(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            t.settings.integrations.connected.toUpperCase(),
                            style:
                                TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: ColorsExt.grey3(context)),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.only(top: 5),
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: accounts.length,
                            itemBuilder: (context, index) {
                              Account account = accounts[index];
                              String? title = DocExt.titleFromConnectorId(account.connectorId);
                              String? iconAsset = TaskExt.iconFromConnectorId(account.connectorId);

                              return IntegrationListItem(
                                leadingWidget: Stack(
                                  children: [
                                    SvgPicture.asset(
                                      iconAsset,
                                      height: 30,
                                      width: 30,
                                    ),
                                    Visibility(
                                      visible: account.picture == null || account.picture!.isEmpty,
                                      replacement: const SizedBox(),
                                      child: Transform.translate(
                                        offset: const Offset(5, 5),
                                        child: Align(
                                            alignment: Alignment.bottomRight,
                                            child: CircleAvatar(
                                                radius: 8,
                                                backgroundColor: ColorsExt.grey3(context),
                                                backgroundImage: NetworkImage(account.picture!))),
                                      ),
                                    )
                                  ],
                                ),
                                title: title,
                                identifier: account.identifier ?? '',
                                insets: _getEdgeInsets(index, accounts.length),
                                borderRadius: _getBorderRadius(index, accounts.length),
                                enabled: account.connectorId == 'gmail',
                                trailingWidget: account.connectorId != 'gmail' ? const SizedBox() : null,
                                onPressed: () {
                                  if (account.connectorId == 'gmail') {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) => const GmailDetailsIntegrationsPage()));
                                  }
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  t.more.toUpperCase(),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: ColorsExt.grey3(context)),
                ),
                const SizedBox(height: 4),
                IntegrationListItem(
                  leadingWidget: Padding(
                    padding: const EdgeInsets.all(2),
                    child: SvgPicture.asset(
                      "assets/images/icons/google/gmail.svg",
                    ),
                  ),
                  title: t.settings.integrations.gmail.title,
                  insets: const EdgeInsets.all(1),
                  borderRadius: BorderRadius.circular(radius),
                  onPressed: () async {
                    await Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) => const GmailInstructionIntegrationsPage()));
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
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
