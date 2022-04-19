import 'package:flutter/material.dart';

class ContainerInnerShadow extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const ContainerInnerShadow({
    Key? key,
    required this.child,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          const BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.06), // shadow color
          ),
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 6,
            color: backgroundColor ??
                Theme.of(context).backgroundColor, // background color
          ),
        ],
      ),
      child: child,
    );
  }
}
