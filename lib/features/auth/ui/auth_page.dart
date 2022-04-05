import 'package:flutter/material.dart';
import 'package:mobile/components/button.dart';
import 'package:mobile/i18n/strings.g.dart';
import 'package:mobile/style/text_style.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                      onPressed: (() => Navigator.pop(context)),
                      icon: const Icon(Icons.arrow_back)),
                ),
                // Align(
                //   alignment: Alignment.center,
                //   child:
                //       Image.asset("assets/images/logo/logo.png"),
                // )
              ],
            ),
            Text(t.onboarding.welcome_to_akiflow),
            Text(t.onboarding.welcome_to_akiflow_subtitle),
            ButtonComp(
              child: Text(
                t.onboarding.register,
                style: TextStyleExt.button(context),
              ),
              onPressed: () {},
            ),
            Text(t.onboarding.or),
            ButtonComp(
              child: Text(
                t.onboarding.sign_in_with_google,
                style: TextStyleExt.button(context),
              ),
              onPressed: () {},
            ),
            Text(t.onboarding.continuing_accept_terms_privacy),
          ],
        ),
      ),
    );
  }
}
