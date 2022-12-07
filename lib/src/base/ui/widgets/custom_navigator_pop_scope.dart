import 'package:flutter/material.dart';

class CustomNavigatorPopScope extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorStateKey;
  final List<Page> pages;
  final PopPageCallback onPopPage;

  const CustomNavigatorPopScope({super.key, 
    required this.navigatorStateKey,
    this.pages = const <Page<dynamic>>[],
    required this.onPopPage,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Navigator(
        transitionDelegate: const DefaultTransitionDelegate(),
        key: navigatorStateKey,
        pages: pages,
        onPopPage: onPopPage,
      ),

      //TODO: Check again null error still exisiting
      onWillPop: () async {
        return await navigatorStateKey.currentState?.maybePop() ?? false;
        // final result = await navigatorStateKey.currentState?.maybePop();
        // if (result != null) return !result;
        // return false;
      },
    );
  }
}
