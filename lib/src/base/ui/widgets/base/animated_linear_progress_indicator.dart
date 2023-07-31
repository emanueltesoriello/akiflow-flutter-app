import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/cubit/sync/sync_cubit.dart';

class AnimatedLinearProgressIndicator extends StatelessWidget {
  const AnimatedLinearProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncCubit, SyncCubitState>(builder: (context, state) {
      if (state.loading) {
        return PreferredSize(
          preferredSize: const Size.fromHeight(Dimension.progressIndicatorSize),
          child: LinearProgressIndicator(
            value: null,
            minHeight: Dimension.progressIndicatorSize / 2,
            backgroundColor: ColorsExt.background(context),
          ),
        );
      } else {
        return Container();
      }
    });
  }
}
