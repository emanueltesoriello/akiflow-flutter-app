import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/tasks/ui/cubit/edit_task_cubit.dart';

import '../../../../../common/style/colors.dart';

class DescriptionField extends StatelessWidget {
  const DescriptionField({Key? key, required this.descriptionController}) : super(key: key);
  final TextEditingController descriptionController;
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: descriptionController,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.only(bottom: Dimension.padding),
        isDense: true,
        hintText: t.addTask.descriptionHint,
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: ColorsExt.grey3(context),
          fontSize: 17,
        ),
      ),
      onChanged: (String text) {
        context.read<EditTaskCubit>().updateDescription(text);
      },
      style: TextStyle(
        color: ColorsExt.grey2(context),
        fontSize: 17,
      ),
    );
  }
}
