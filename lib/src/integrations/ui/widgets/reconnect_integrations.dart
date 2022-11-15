import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/src/integrations/ui/cubit/integrations_cubit.dart';
import 'package:mobile/src/integrations/ui/widgets/integrations_list.dart';
import 'package:models/account/account.dart';

class ReconnectIntegrations extends StatelessWidget {
  const ReconnectIntegrations({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(height: 111 - MediaQuery.of(context).padding.top),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset("assets/images/icons/google/gmail_shadow.svg", width: 56, height: 56),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: RotatedBox(
                            quarterTurns: 2,
                            child: SvgPicture.asset("assets/images/icons/_common/arrow_left.svg",
                                color: ColorsExt.akiflow(context)),
                          ),
                        ),
                        SvgPicture.asset("assets/images/logo/logo_full.svg", width: 56, height: 56),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      t.onboarding.gmail.reconnectGmailAccount,
                      style: TextStyle(fontSize: 20, color: ColorsExt.grey1(context), fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 48),
                    BlocBuilder<IntegrationsCubit, IntegrationsCubitState>(
                      builder: (context, state) {
                        return IntegrationsList(
                          state.accounts
                              .where((account) => account.connectorId == "gmail" && account.deletedAt == null)
                              .toList(),
                          isReconnectPage: true,
                          onTap: (Account account) async {
                            IntegrationsCubit bloc = context.read<IntegrationsCubit>();

                            if (bloc.isLocalActive(account)) {
                              return;
                            }

                            bloc.connectGmail(email: account.identifier).then((_) {
                              List<Account> accounts = bloc.state.accounts;

                              if (accounts.every((account) => bloc.isLocalActive(account))) {
                                Navigator.pop(context);
                              }
                            });
                          },
                        );
                      },
                    ),
                    const Spacer(),
                    TextButton(
                        onPressed: () {
                          context.read<IntegrationsCubit>().skipForNowTap();
                          Navigator.pop(context);
                        },
                        child: Text(
                          t.onboarding.gmail.skipForNow,
                          style: TextStyle(fontSize: 15, color: ColorsExt.grey2(context)),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
