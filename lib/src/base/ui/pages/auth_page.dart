import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/cubit/auth/auth_cubit.dart';
import 'package:mobile/src/base/ui/widgets/base/action_button.dart';
import 'package:mobile/src/home/ui/pages/home_page.dart';
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
        listener: (context, state) {
          if (state.user != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          }
        },
        child: Scaffold(
          body: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: ListView(
                padding: const EdgeInsets.all(Dimension.padding),
                shrinkWrap: true,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      Assets.images.logo.logoFullSVG,
                      height: Dimension.logoAuthPage,
                      width: Dimension.logoAuthPage,
                    ),
                  ),
                  const SizedBox(height: Dimension.padding),
                  Text(t.onboarding.welcomeToAkiflow,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: ColorsExt.grey900(context),
                          )),
                  const SizedBox(height: Dimension.paddingS),
                  Text(t.onboarding.welcomeToAkiflowSubtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.subtitle1?.copyWith(
                            fontWeight: FontWeight.w400,
                            color: ColorsExt.grey700(context),
                          )),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Align(
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        Assets.images.akiflow.plannerEmptyEngageSVG,
                        height: Dimension.authIllustrationSize,
                        width: Dimension.authIllustrationSize,
                      ),
                    ),
                  ),
                  ActionButton(
                    child: Text(
                      t.onboarding.login,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: ColorsExt.akiflow500(context),
                            fontWeight: FontWeight.w400,
                          ),
                    ),
                    onPressed: () {
                      context.read<AuthCubit>().loginClick();
                    },
                  ),
                  const SizedBox(height: Dimension.paddingM),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyText1?.copyWith(
                            fontWeight: FontWeight.w400,
                            color: ColorsExt.grey700(context),
                          ),
                      children: [
                        TextSpan(
                          text: t.onboarding.termsAndPrivacy.continuingYouAcceptThe,
                          style: Theme.of(context).textTheme.bodyText1?.copyWith(
                                fontWeight: FontWeight.w400,
                                color: ColorsExt.grey700(context),
                              ),
                        ),
                        TextSpan(
                          text: t.onboarding.termsAndPrivacy.termsAndConditions,
                          style: Theme.of(context).textTheme.bodyText1?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: ColorsExt.grey800(context),
                              ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launchUrl(Uri.parse("https://akiflow.com/legal/terms-of-service"),
                                  mode: LaunchMode.externalApplication);
                            },
                        ),
                        TextSpan(
                          text: t.onboarding.termsAndPrivacy.andThe,
                          style: Theme.of(context).textTheme.bodyText1?.copyWith(
                                fontWeight: FontWeight.w400,
                                color: ColorsExt.grey700(context),
                              ),
                        ),
                        TextSpan(
                          text: t.onboarding.termsAndPrivacy.privacyPolicy,
                          style: Theme.of(context).textTheme.bodyText1?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: ColorsExt.grey800(context),
                              ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launchUrl(Uri.parse("https://akiflow.com/legal/privacy-policy"),
                                  mode: LaunchMode.externalApplication);
                            },
                        ),
                        TextSpan(
                          text: t.onboarding.termsAndPrivacy.ofAkiflow,
                          style: Theme.of(context).textTheme.bodyText1?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: ColorsExt.grey800(context),
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
