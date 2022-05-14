import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';

class SyncStatusItem extends StatelessWidget {
  const SyncStatusItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: BlocBuilder<TasksCubit, TasksCubitState>(
        builder: (context, state) {
          if (state.loading == false) {
            return const SizedBox();
          }

          return Row(
            children: [
              Expanded(
                child: Text(
                  state.syncStatus ?? "",
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
