import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SlidablePlayer extends StatefulWidget {
  const SlidablePlayer({
    Key? key,
    required this.animation,
    required this.child,
    required this.leftToRight,
  }) : super(key: key);

  final Animation<double>? animation;
  final Widget child;
  final bool leftToRight;

  @override
  SlidablePlayerState createState() => SlidablePlayerState();

  static SlidablePlayerState? of(BuildContext context) {
    return context.findAncestorStateOfType<SlidablePlayerState>();
  }
}

class SlidablePlayerState extends State<SlidablePlayer> {
  final Set<SlidableController?> controllers = <SlidableController?>{};

  @override
  void initState() {
    super.initState();
    widget.animation!.addListener(handleAnimationChanged);
  }

  @override
  void dispose() {
    widget.animation!.removeListener(handleAnimationChanged);
    super.dispose();
  }

  void handleAnimationChanged() {
    final value = widget.animation!.value;
    for (var controller in controllers) {
      controller!.ratio = widget.leftToRight ? -value : value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class SlidableControllerSender extends StatefulWidget {
  const SlidableControllerSender({
    Key? key,
    this.child,
  }) : super(key: key);

  final Widget? child;

  @override
  SlidableControllerSenderState createState() => SlidableControllerSenderState();
}

class SlidableControllerSenderState extends State<SlidableControllerSender> {
  SlidableController? controller;
  SlidablePlayerState? playerState;

  @override
  void initState() {
    super.initState();
    controller = Slidable.of(context);
    playerState = SlidablePlayer.of(context);
    playerState!.controllers.add(controller);
  }

  @override
  void dispose() {
    playerState!.controllers.remove(controller);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
