import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:i18n/strings.g.dart';
import 'package:mobile/features/auth/cubit/auth_cubit.dart';
import 'package:mobile/features/auth/ui/login_button.dart';
import 'package:mobile/features/main/ui/main_page.dart';
import 'package:mobile/main_com.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/style/text_style.dart';
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
                builder: (context) => Stack(
                  children: const [
                    MainPage(),
                    UndoBottomView(),
                  ],
                ),
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
                    child: Image.asset(
                      "assets/images/logo/logo_full_256x256.png",
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
                        "assets/images/akiflow/planner-empty-engage.svg",
                        height: 128,
                        width: 128,
                      ),
                    ),
                  ),
                  LoginButton(
                    child: Text(
                      t.onboarding.login,
                      style: TextStyleExt.button(context),
                    ),
                    onPressed: () {
                      context.read<AuthCubit>().loginClick();
                    },
                  ),
                  const SizedBox(height: 32),
                  HtmlWidget(
                    t.onboarding.continuingAcceptTermsPrivacy,
                    enableCaching: false,
                    textStyle: TextStyle(
                      fontSize: 13,
                      color: ColorsExt.grey2_5(context),
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
                              color: ColorsExt.grey2_5(context),
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launchUrl(Uri.parse(node.attributes["url"]!));
                              },
                          ));
                        } else {
                          textSpans.add(TextSpan(
                            text: node.text,
                            style: TextStyle(
                              fontSize: 13,
                              color: ColorsExt.grey2_5(context),
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
      ),
    );
  }
}
