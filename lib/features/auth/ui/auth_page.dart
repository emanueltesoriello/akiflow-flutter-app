import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:mobile/components/button.dart';
import 'package:mobile/components/social/google_button.dart';
import 'package:mobile/components/space.dart';
import 'package:mobile/i18n/strings.g.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/style/text_style.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key}) : super(key: key);

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
                style: Theme.of(context).textTheme.headline1,
              ),
              const Space(8),
              Text(
                t.onboarding.welcome_to_akiflow_subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline2,
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
                  t.onboarding.register,
                  style: TextStyleExt.button(context),
                ),
                onPressed: () {},
              ),
              const Space(8),
              Text(t.onboarding.or.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: ColorsExt.textBrightnessBased(context),
                  )),
              const Space(8),
              GoogleButton(
                onPressed: () {},
              ),
              const Space(24),
              HtmlWidget(
                t.onboarding.continuing_accept_terms_privacy,
                enableCaching: false,
                textStyle: TextStyle(
                  fontSize: 13,
                  color: ColorsExt.textBrightnessBased(context),
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
                          color: ColorsExt.textBrightnessBased(context),
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
                          color: ColorsExt.textBrightnessBased(context),
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
    );
  }
}
