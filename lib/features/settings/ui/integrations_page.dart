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
      body: Column(
        children: [
          AppBarComp(
            title: t.settings.integrations.title,
            showBack: true,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                BlocBuilder<SettingsCubit, SettingsCubitState>(
                  builder: (context, state) {
                    List<Account> accounts = state.accounts.toList();

                    accounts.removeWhere((element) => element.connectorId == "akiflow");

                    if (accounts.isEmpty) {
                      return const SizedBox();
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: accounts.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.settings.integrations.connected.toUpperCase(),
                                style: TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w500, color: ColorsExt.grey3(context)),
                              ),
                              const SizedBox(height: 4),
                            ],
                          );
                        }

                        index -= 1;

                        Account account = accounts[index];

                        String? title = DocExt.titleFromConnectorId(account.connectorId);
                        String? iconAsset = TaskExt.iconFromConnectorId(account.connectorId);

                        EdgeInsets insets;
                        BorderRadius borderRadius;

                        if (index == 0) {
                          insets = const EdgeInsets.only(top: 1, left: 1, right: 1, bottom: 1);
                          borderRadius = const BorderRadius.only(
                              topLeft: Radius.circular(radius), topRight: Radius.circular(radius));
                        } else if (index == accounts.length - 1) {
                          insets = const EdgeInsets.only(left: 1, right: 1, bottom: 1);
                          borderRadius = const BorderRadius.only(
                              bottomLeft: Radius.circular(radius), bottomRight: Radius.circular(radius));
                        } else {
                          insets = const EdgeInsets.only(left: 1, right: 1, bottom: 1);
                          borderRadius = BorderRadius.zero;
                        }

                        return IntegrationListItem(
                          leadingWidget: Stack(
                            fit: StackFit.expand,
                            children: [
                              SvgPicture.asset(iconAsset),
                              Builder(builder: (context) {
                                if (account.picture == null || account.picture!.isEmpty) {
                                  return const SizedBox();
                                }
                                return Align(
                                    alignment: Alignment.bottomRight,
                                    child: CircleAvatar(
                                        radius: 8,
                                        backgroundColor: ColorsExt.grey3(context),
                                        backgroundImage: NetworkImage(account.picture!)));
                              })
                            ],
                          ),
                          title: title,
                          identifier: account.identifier ?? '',
                          insets: insets,
                          borderRadius: borderRadius,
                          enabled: account.connectorId == 'gmail',
                          trailingWidget: account.connectorId != 'gmail' ? const SizedBox() : null,
                          onPressed: () {
                            if (account.connectorId == 'gmail') {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) => const GmailDetailsIntegrationsPage()));
                            }
                          },
                        );
                      },
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
                  leadingWidget: SvgPicture.asset(
                    "assets/images/icons/google/gmail.svg",
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
