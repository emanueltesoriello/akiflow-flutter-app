import 'package:flutter/material.dart';
import 'package:mobile/style/colors.dart';

class SlidableContainer extends StatelessWidget {
  final Widget child;

  const SlidableContainer({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          const BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.06),
          ),
          BoxShadow(
            offset: const Offset(2, 4),
            blurRadius: 16,
            color: ColorsExt.grey7(context),
          ),
        ],
      ),
      width: double.infinity,
      height: double.infinity,
      child: child,
    );
  }
}
