import 'package:flutter/material.dart';
import 'package:mobile/style/colors.dart';

class BorderedInputView extends StatefulWidget {
  final Function(String) onChanged;
  final String hint;
  final FocusNode? focus;
  final String? initialValue;

  const BorderedInputView({
    Key? key,
    required this.onChanged,
    required this.hint,
    this.focus,
    this.initialValue,
  }) : super(key: key);

  @override
  State<BorderedInputView> createState() => _BorderedInputViewState();
}

class _BorderedInputViewState extends State<BorderedInputView> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
    super.initState();
  }

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
          controller: _controller,
          focusNode: widget.focus,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.zero,
            isDense: true,
            hintText: widget.hint,
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
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}
