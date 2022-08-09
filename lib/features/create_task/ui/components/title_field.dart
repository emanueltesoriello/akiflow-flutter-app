import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';

import '../../../../style/colors.dart';

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
            style: TextStyle(
              color: ColorsExt.grey2(context),
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          );
        });
  }
}
