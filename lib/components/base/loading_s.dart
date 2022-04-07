import 'package:flutter/material.dart';

class LoadingS extends StatelessWidget {
  final double height;
  final bool loading;

  // ignore: use_key_in_widget_constructors
  const LoadingS(this.loading, [this.height = 36]);

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      if (loading) {
        return Center(
          child: SizedBox(
            height: height,
            width: height,
            child: const Center(child: CircularProgressIndicator()),
          ),
        );
      } else {
        return const SizedBox();
      }
    });
  }
}
