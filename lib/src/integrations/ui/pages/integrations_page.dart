import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
// import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
// import 'package:mobile/features/integrations/ui/gmail/gmail_instruction_integration_page.dart';
// import 'package:mobile/features/integrations/ui/integration_list_item.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/core/services/sync_controller_service.dart';
import 'package:mobile/src/base/ui/cubit/sync/sync_cubit.dart';
import 'package:mobile/src/base/ui/widgets/base/app_bar.dart';
import 'package:mobile/src/integrations/ui/cubit/integrations_cubit.dart';
import 'package:mobile/src/integrations/ui/pages/gmail_details_integration_page.dart';
import 'package:mobile/src/integrations/ui/widgets/integrations_list.dart';
import 'package:models/account/account.dart';
import 'package:models/extensions/account_ext.dart';

class IntegrationsPage extends StatefulWidget {
  const IntegrationsPage({Key? key}) : super(key: key);

  @override
  State<IntegrationsPage> createState() => _IntegrationsPageState();
}

class _IntegrationsPageState extends State<IntegrationsPage> {
  void rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComp(
        title: t.settings.integrations.title,
        showBack: true,
      ),
      body: RefreshIndicator(
        backgroundColor: ColorsExt.background(context),
        onRefresh: () async {
          await context.read<SyncCubit>().sync(entities: [Entity.accounts]);
          rebuildAllChildren(context);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: Dimension.padding),
                children: [
                  BlocBuilder<IntegrationsCubit, IntegrationsCubitState>(
                    builder: (context, state) {
                      List<Account> accounts = state.accounts.toList();
                      accounts.removeWhere((element) => element.connectorId == "akiflow" || element.deletedAt != null);

                      accounts
                          .removeWhere((element) => !AccountExt.acceptedAccountsOrigin.contains(element.connectorId));
                      return Visibility(
                        visible: accounts.isNotEmpty,
                        replacement: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 200),
                              SvgPicture.asset(Assets.images.akiflow.thatsItnothingSVG),
                              const SizedBox(height: Dimension.padding),
                              Text('Nothing to reconnect',
                                  style:
                                      Theme.of(context).textTheme.subtitle1?.copyWith(color: ColorsExt.grey2(context))),
                              const SizedBox(height: Dimension.padding),
                              Text('You have no active integrations, check your desktop app to add more',
                                  textAlign: TextAlign.center,
                                  style:
                                      Theme.of(context).textTheme.subtitle1?.copyWith(color: ColorsExt.grey3(context))),
                            ],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            Text(
                              t.settings.integrations.connected.toUpperCase(),
                              style:
                                  TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: ColorsExt.grey3(context)),
                            ),
                            IntegrationsList(
                              accounts,
                              onTap: (Account account) async {
                                if (context.read<IntegrationsCubit>().isLocalActive(account) &&
                                    account.connectorId == 'gmail') {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => GmailDetailsIntegrationsPage(
                                          account: account,
                                          onDisconnect: () {
                                            rebuildAllChildren(context);
                                          })));
                                  super.dispose();
                                } else if (account.connectorId == 'gmail') {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => GmailDetailsIntegrationsPage(
                                          account: account,
                                          onDisconnect: () {
                                            rebuildAllChildren(context);
                                          })));
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
