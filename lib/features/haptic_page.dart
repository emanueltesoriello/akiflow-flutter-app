import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/components/base/app_bar.dart';

class HapticPage extends StatelessWidget {
  const HapticPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarComp(
        title: "Haptic Feedbacks",
        showBack: true,
      ),
      body: ListView(
        children: [
          TextButton(
            onPressed: () {
              HapticFeedback.selectionClick();
            },
            child: const Text("selection"),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
            },
            child: const Text("lightImpact"),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
            },
            child: const Text("mediumImpact"),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.heavyImpact();
            },
            child: const Text("heavyImpact"),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.vibrate();
            },
            child: const Text("vibrate"),
          ),
        ],
      ),
    );
  }
}
