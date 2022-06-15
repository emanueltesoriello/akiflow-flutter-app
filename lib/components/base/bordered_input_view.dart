import 'package:flutter/material.dart';
import 'package:mobile/style/colors.dart';

class BorderedInputView extends StatefulWidget {
  final String hint;
  final Function(String)? onChanged;
  final FocusNode? focus;
  final String? initialValue;
  final bool enabled;
  final Widget? leading;
  final TextEditingController? controller;

  const BorderedInputView({
    Key? key,
    required this.hint,
    this.onChanged,
    this.focus,
    this.initialValue,
    this.enabled = true,
    this.leading,
    this.controller,
  }) : super(key: key);

  @override
  State<BorderedInputView> createState() => _BorderedInputViewState();
}

class _BorderedInputViewState extends State<BorderedInputView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = widget.controller ?? TextEditingController();

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
        child: Row(
          children: [
            if (widget.leading != null)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: widget.leading!,
              ),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: widget.focus,
                enabled: widget.enabled,
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
          ],
        ),
      ),
    );
  }
}
