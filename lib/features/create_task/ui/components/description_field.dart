import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';

import '../../../../style/colors.dart';

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
        contentPadding: const EdgeInsets.only(bottom: 16),
        isDense: true,
        hintText: t.addTask.descriptionHint,
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: ColorsExt.grey3(context),
          fontSize: 17,
        ),
      ),
      style: TextStyle(
        color: ColorsExt.grey2(context),
        fontSize: 17,
      ),
    );
  }
}
