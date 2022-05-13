import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/style/colors.dart';

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

    bool loading = context.read<TasksCubit>().state.loading;

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
    return BlocConsumer<TasksCubit, TasksCubitState>(
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
            "assets/images/icons/_common/arrow_2_circlepath.svg",
            width: 24,
            height: 24,
            color: state.loading ? ColorsExt.akiflow(context) : ColorsExt.grey3(context),
          ),
        );
      },
    );
  }
}
