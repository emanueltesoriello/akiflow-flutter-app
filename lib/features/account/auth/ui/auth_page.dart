import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/components/base/action_button.dart';
import 'package:mobile/features/account/auth/cubit/auth_cubit.dart';
import 'package:mobile/features/main/ui/main_page.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: BlocListener<AuthCubit, AuthCubitState>(
        listenWhen: (previous, current) {
          if (previous.user == null && current.user != null) {
            return true;
          } else {
            return false;
          }
        },
        listener: (context, state) {
          if (state.user != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MainPage(),
              ),
            );
          }
        },
        child: Scaffold(
          body: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: ListView(
                padding: const EdgeInsets.all(16),
                shrinkWrap: true,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      Assets.images.logo.logoFullSVG,
                      height: 56,
                      width: 56,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t.onboarding.welcomeToAkiflow,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: ColorsExt.grey1(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.onboarding.welcomeToAkiflowSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      color: ColorsExt.grey2_5(context),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Align(
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        Assets.images.akiflow.plannerEmptyEngageSVG,
                        height: 128,
                        width: 128,
                      ),
                    ),
                  ),
                  ActionButton(
                    child: Text(
                      t.onboarding.login,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    onPressed: () {
                      context.read<AuthCubit>().loginClick();
                    },
                  ),
                  const SizedBox(height: 32),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 13,
                        color: ColorsExt.grey2_5(context),
                      ),
                      children: [
                        TextSpan(
                          text: t.onboarding.termsAndPrivacy.continuingYouAcceptThe,
                          style: TextStyle(
                            fontSize: 13,
                            color: ColorsExt.grey2_5(context),
                          ),
                        ),
                        TextSpan(
                          text: t.onboarding.termsAndPrivacy.termsAndConditions,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: ColorsExt.grey2_5(context),
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launchUrl(Uri.parse("https://akiflow.com/legal/terms-of-service"),
                                  mode: LaunchMode.externalApplication);
                            },
                        ),
                        TextSpan(
                          text: t.onboarding.termsAndPrivacy.andThe,
                          style: TextStyle(
                            fontSize: 13,
                            color: ColorsExt.grey2_5(context),
                          ),
                        ),
                        TextSpan(
                          text: t.onboarding.termsAndPrivacy.privacyPolicy,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: ColorsExt.grey2_5(context),
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launchUrl(Uri.parse("https://akiflow.com/legal/privacy-policy"),
                                  mode: LaunchMode.externalApplication);
                            },
                        ),
                        TextSpan(
                          text: t.onboarding.termsAndPrivacy.ofAkiflow,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: ColorsExt.grey2_5(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
