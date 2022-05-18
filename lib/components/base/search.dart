import 'package:flutter/material.dart';
import 'package:mobile/style/colors.dart';

class BorderedInputView extends StatelessWidget {
  final Function(String) onChanged;
  final String hint;
  final FocusNode? focus;

  const BorderedInputView({
    Key? key,
    required this.onChanged,
    required this.hint,
    this.focus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: ColorsExt.grey4(context),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: TextField(
          focusNode: focus,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.zero,
            isDense: true,
            hintText: hint,
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: ColorsExt.grey3(context),
              fontSize: 17,
            ),
          ),
          style: TextStyle(
            color: ColorsExt.grey2(context),
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
