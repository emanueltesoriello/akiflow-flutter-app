import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/app_bar.dart';
import 'package:mobile/features/integrations/cubit/integrations_cubit.dart';
import 'package:mobile/features/integrations/ui/gmail/gmail_details_integration_page.dart';
import 'package:mobile/features/integrations/ui/gmail/gmail_instruction_integration_page.dart';
import 'package:mobile/features/integrations/ui/integration_list_item.dart';
import 'package:mobile/features/integrations/ui/integrations_list.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/style/theme.dart';
import 'package:models/account/account.dart';
import 'package:models/extensions/account_ext.dart';

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
                BlocBuilder<IntegrationsCubit, IntegrationsCubitState>(
                  builder: (context, state) {
                    List<Account> accounts = state.accounts.toList();
                    accounts.removeWhere((element) => element.connectorId == "akiflow");
                    accounts.removeWhere((element) => !AccountExt.acceptedAccountsOrigin.contains(element.connectorId));
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
                          IntegrationsList(accounts, onTap: (Account account) {
                            if (account.connectorId == 'gmail') {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) => const GmailDetailsIntegrationsPage()));
                            }
                          }),
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
                  leading: Padding(
                    padding: const EdgeInsets.all(2),
                    child: SizedBox(
                      height: 30,
                      width: 30,
                      child: SvgPicture.asset(
                        "assets/images/icons/google/gmail.svg",
                        height: 30,
                        width: 30,
                      ),
                    ),
                  ),
                  title: t.settings.integrations.gmail.title,
                  insets: const EdgeInsets.all(1),
                  borderRadius: BorderRadius.circular(radius),
                  active: true,
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
