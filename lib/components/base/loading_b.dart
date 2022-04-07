import 'package:flutter/material.dart';

class LoadingB extends StatelessWidget {
  final double height;
  final bool loading;

  final ValueNotifier<bool> visibleNotifier = ValueNotifier(false);

  // ignore: use_key_in_widget_constructors
  LoadingB(this.loading, [this.height = 250]);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: loading ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 500),
        child: Center(
          child: SizedBox(
            height: height,
            width: height,
            child: const CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
