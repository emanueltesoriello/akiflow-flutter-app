import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/strings.g.dart';

import '../../../../../common/style/colors.dart';
import '../../../edit_task/cubit/edit_task_cubit.dart';

class TitleField extends StatelessWidget {
  const TitleField(
      {Key? key, required this.simpleTitleController, required this.isTitleEditing, required this.titleFocus})
      : super(key: key);
  final TextEditingController simpleTitleController;
  final ValueListenable<bool> isTitleEditing;
  final FocusNode titleFocus;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: isTitleEditing,
        builder: (context, bool isTitleEditing, child) {
          return TextField(
            controller: simpleTitleController,
            focusNode: titleFocus,
            textCapitalization: TextCapitalization.sentences,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              isDense: true,
              hintText: t.addTask.titleHint,
              border: InputBorder.none,
              hintStyle: TextStyle(
                color: ColorsExt.grey3(context),
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            onChanged: (String text) {
              context.read<EditTaskCubit>().updateTitle(text);
            },
            style: TextStyle(
              color: ColorsExt.grey2(context),
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          );
        });
  }
}
