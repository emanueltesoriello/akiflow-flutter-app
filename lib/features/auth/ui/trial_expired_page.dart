import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/action_button.dart';
import 'package:mobile/features/auth/cubit/auth_cubit.dart';
import 'package:mobile/features/auth/ui/auth_page.dart';
import 'package:mobile/style/colors.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../assets.dart';

class TrialExpiredPage extends StatelessWidget {
  const TrialExpiredPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: ListView(
            padding: const EdgeInsets.all(16),
            shrinkWrap: true,
            children: [
              Align(
                alignment: Alignment.center,
                child:  SvgPicture.asset(
                Assets.images.logo.logoOutlineSVG,
                  height: 56,
                  width: 56,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                t.expiry.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: ColorsExt.grey1(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t.expiry.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  color: ColorsExt.grey2_5(context),
                ),
              ),
              const SizedBox(height: 60),
              ActionButton(
                child: Text(
                  t.expiry.button,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                onPressed: () {
                  launchUrlString('https://app.akiflow.com/en/checkout/billing');
                },
              ),
              const SizedBox(height: 20),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 13,
                    color: ColorsExt.grey2_5(context),
                  ),
                  children: [
                    TextSpan(
                      text: t.expiry.or,
                      style: TextStyle(
                        fontSize: 13,
                        color: ColorsExt.grey2_5(context),
                      ),
                    ),
                    TextSpan(
                      text: t.expiry.logout,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: ColorsExt.grey2_5(context),
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          context.read<AuthCubit>().logout();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AuthPage(),
                            ),
                          );
                        },
                    ),
                    TextSpan(
                      text: t.expiry.alternate,
                      style: TextStyle(
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
    );
  }
}
