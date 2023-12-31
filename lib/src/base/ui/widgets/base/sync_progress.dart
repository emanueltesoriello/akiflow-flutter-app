import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/src/base/ui/cubit/sync/sync_cubit.dart';

class SyncProgress extends StatefulWidget {
  const SyncProgress({Key? key}) : super(key: key);

  @override
  State<SyncProgress> createState() => _SyncProgressState();
}

class _SyncProgressState extends State<SyncProgress> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _controller.addListener(() {
      if (_controller.isCompleted) {
        _controller.repeat();
      }
    });

    bool loading = context.read<SyncCubit>().state.loading;

    if (loading) {
      _controller.forward();
    }

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SyncCubit, SyncCubitState>(
      listener: (context, state) {
        if (state.loading) {
          _controller.forward();
        } else {
          _controller.reset();
        }
      },
      builder: (context, state) {
        return RotationTransition(
          turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
          child: SvgPicture.asset(
            Assets.images.icons.common.arrow2CirclepathSVG,
            width: 24,
            height: 24,
            color: state.loading ? ColorsExt.akiflow(context) : ColorsExt.grey3(context),
          ),
        );
      },
    );
  }
}
