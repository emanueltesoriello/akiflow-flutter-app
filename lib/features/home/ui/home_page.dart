import 'package:flutter/material.dart';
import 'package:mobile/components/button.dart';
import 'package:mobile/features/auth/ui/auth_page.dart';
import 'package:mobile/i18n/strings.g.dart';
import 'package:mobile/style/text_style.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.appName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ButtonComp(
              child: Text(
                t.login,
                style: TextStyleExt.button(context),
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AuthPage(),
                    ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
