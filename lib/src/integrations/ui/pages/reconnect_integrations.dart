import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/widgets/custom_snackbar.dart';
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
                padding: const EdgeInsets.all(Dimension.padding),
                child: Column(
                  children: [
                    SizedBox(height: 111 - MediaQuery.of(context).padding.top),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(Assets.images.icons.google.gmailShadowSVG, width: 56, height: 56),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimension.paddingS),
                          child: RotatedBox(
                            quarterTurns: 2,
                            child: SvgPicture.asset(Assets.images.icons.common.arrowLeftSVG,
                                color: ColorsExt.akiflow500(context)),
                          ),
                        ),
                        SvgPicture.asset(Assets.images.logo.logoFullSVG, width: 56, height: 56),
                      ],
                    ),
                    const SizedBox(height: Dimension.padding),
                    Text(t.onboarding.gmail.reconnectGmailAccount,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w500, color: ColorsExt.grey900(context))),
                    const SizedBox(height: Dimension.paddingL),
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
                                ScaffoldMessenger.of(context).showSnackBar(CustomSnackbar.get(
                                    context: context,
                                    type: CustomSnackbarType.success,
                                    message: t.snackbar.connectedSuccesfully));
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
                      child: Text(t.onboarding.gmail.skipForNow,
                          style: Theme.of(context).textTheme.bodyText1?.copyWith(color: ColorsExt.grey800(context))),
                    ),
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
