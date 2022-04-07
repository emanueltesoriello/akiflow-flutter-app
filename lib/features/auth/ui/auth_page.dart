import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/button.dart';
import 'package:mobile/components/base/space.dart';
import 'package:mobile/features/auth/cubit/auth_cubit.dart';
import 'package:mobile/features/home/ui/home_page.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/style/text_style.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthCubitState>(
      listener: (context, state) {
        if (state.user != null) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => HomePage()),
              (Route<dynamic> route) => false);
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
                  child: Image.asset(
                    "assets/images/logo/logo_full_256x256.png",
                    height: 56,
                    width: 56,
                  ),
                ),
                const Space(16),
                Text(
                  t.onboarding.welcome_to_akiflow,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: ColorsExt.textGrey1(context),
                  ),
                ),
                const Space(8),
                Text(
                  t.onboarding.welcome_to_akiflow_subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    color: ColorsExt.textGrey2_5(context),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Align(
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      "assets/images/akiflow/planner-empty-engage.svg",
                      height: 128,
                      width: 128,
                    ),
                  ),
                ),
                ButtonComp(
                  child: Text(
                    t.onboarding.login,
                    style: TextStyleExt.button(context),
                  ),
                  onPressed: () {
                    context.read<AuthCubit>().loginClick();
                  },
                ),
                const Space(8),
                const Space(24),
                HtmlWidget(
                  t.onboarding.continuing_accept_terms_privacy,
                  enableCaching: false,
                  textStyle: TextStyle(
                    fontSize: 13,
                    color: ColorsExt.textGrey2_5(context),
                  ),
                  customWidgetBuilder: (dom.Element element) {
                    List<TextSpan> textSpans = [];

                    for (var node in element.nodes) {
                      if (node.attributes.containsKey("url")) {
                        textSpans.add(TextSpan(
                          text: node.text,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: ColorsExt.textGrey2_5(context),
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launch(node.attributes["url"]!);
                            },
                        ));
                      } else {
                        textSpans.add(TextSpan(
                          text: node.text,
                          style: TextStyle(
                            fontSize: 13,
                            color: ColorsExt.textGrey2_5(context),
                          ),
                        ));
                      }
                    }

                    return RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(children: textSpans),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
