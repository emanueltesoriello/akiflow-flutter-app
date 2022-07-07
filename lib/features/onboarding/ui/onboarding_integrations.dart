import 'package:flutter/material.dart';

class OnboardingIntegrations extends StatelessWidget {
  const OnboardingIntegrations({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: ListView(
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              children: const [
                Text("eccolo"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
