import 'package:flutter/material.dart';
import 'package:mobile/components/space.dart';
import 'package:mobile/i18n/strings.g.dart';

class Input extends StatefulWidget {
  final String? label;
  final String? hint;
  final Function(String)? change;
  final bool password;
  final TextInputType textInputType;
  final TextCapitalization? textCapitalization;
  final TextEditingController? controller;
  final Widget? leading;
  final Widget? leadingFixed;
  final Widget? trailing;
  final bool enabled;
  final Function()? click;
  final Function()? clearClick;
  final Function(String)? onSubmitted;
  final bool bold;
  final bool useEnabledStyle;
  final FocusNode? focus;
  final bool padding;
  final bool showClearButton;
  final TextAlign textAlign;
  final TextStyle? style;
  final bool? showUnderline;
  final double? height;
  final bool? enableSuggestions;

  const Input({
    Key? key,
    this.label,
    this.hint,
    this.change,
    this.password = false,
    this.textInputType = TextInputType.text,
    this.textCapitalization = TextCapitalization.words,
    this.controller,
    this.leading,
    this.leadingFixed,
    this.trailing,
    this.enabled = true,
    this.click,
    this.clearClick,
    this.onSubmitted,
    this.bold = false,
    this.useEnabledStyle = false,
    this.focus,
    this.padding = true,
    this.showClearButton = true,
    this.textAlign = TextAlign.start,
    this.style,
    this.showUnderline = true,
    this.height,
    this.enableSuggestions = false,
  }) : super(key: key);

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  final ValueNotifier<bool> showPassword = ValueNotifier(false);
  final ValueNotifier<bool> showClear = ValueNotifier(false);

  final TextEditingController defaultController = TextEditingController();

  Function()? listener;

  @override
  void initState() {
    if (widget.controller != null) {
      listener = () {
        if (widget.controller!.text.isEmpty) {
          showClear.value = false;
        } else {
          showClear.value = true;
        }
      };

      widget.controller!.addListener(listener!);
    }
    super.initState();
  }

  @override
  void dispose() {
    if (widget.controller != null) {
      widget.controller!.removeListener(listener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      child: Center(
        child: Row(
          children: [
            _buildLeading(),
            _buildLeadingFixed(context),
            Expanded(
              child: InkWell(
                onTap: widget.click,
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: widget.height ?? 0,
                  ),
                  padding: widget.padding
                      ? const EdgeInsets.fromLTRB(16, 12, 16, 12)
                      : EdgeInsets.zero,
                  child: Column(
                    children: [
                      ValueListenableBuilder(
                        valueListenable: showPassword,
                        builder: (context, bool showPasswordValue, child) =>
                            Column(
                          children: [
                            Builder(builder: (context) {
                              if (widget.label == null) {
                                return Container();
                              }

                              return Row(
                                children: [
                                  Flexible(
                                    child: Text(widget.label!),
                                  ),
                                ],
                              );
                            }),
                            TextField(
                              controller:
                                  widget.controller ?? defaultController,
                              maxLines: widget.textInputType ==
                                      TextInputType.multiline
                                  ? null
                                  : 1,
                              focusNode: widget.focus,
                              enabled: widget.enabled,
                              enableSuggestions: widget.enableSuggestions!,
                              textAlignVertical: TextAlignVertical.center,
                              obscureText:
                                  widget.password && !showPasswordValue,
                              keyboardType: widget.textInputType,
                              textCapitalization: widget.textCapitalization!,
                              textAlign: widget.textAlign,
                              style: widget.style ??
                                  TextStyle(
                                      fontWeight: widget.bold
                                          ? FontWeight.bold
                                          : FontWeight.normal),
                              onChanged: (value) {
                                if (widget.change != null) {
                                  widget.change!(value);
                                }

                                if (value.isEmpty) {
                                  showClear.value = false;
                                } else {
                                  showClear.value = true;
                                }
                              },
                              onSubmitted: widget.onSubmitted,
                              decoration: InputDecoration.collapsed(
                                  hintText: widget.hint ?? t.typeHere),
                            ),
                            Builder(builder: (context) {
                              if (!widget.showUnderline!) {
                                return Container();
                              }

                              return Column(
                                children: [
                                  const Space(8),
                                  Container(
                                    height: 1,
                                    color: const Color(0xffeeeeee),
                                  ),
                                ],
                              );
                            })
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildTrailing(),
            _buildClear(),
            showPasswordIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildLeading() {
    if (widget.leading == null) return Container();

    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: widget.leading!,
    );
  }

  Widget _buildClear() {
    if (!widget.showClearButton) {
      return Container();
    }

    return ValueListenableBuilder<bool>(
      valueListenable: showClear,
      builder: (context, value, child) => Visibility(
        visible: value,
        child: Row(
          children: [
            InkWell(
              onTap: () {
                widget.controller?.text = "";
                defaultController.text = "";

                showClear.value = false;

                if (widget.clearClick != null) {
                  widget.clearClick!();
                }
              },
              child: const Icon(Icons.close, size: 18),
            ),
            const Space(),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingFixed(BuildContext context) {
    if (widget.leadingFixed == null) return Container();

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: widget.leadingFixed!,
        ),
        Container(
          width: 1,
          color: Theme.of(context).dividerColor,
        )
      ],
    );
  }

  Widget _buildTrailing() {
    if (widget.trailing == null) return Container();

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: widget.trailing!,
    );
  }

  Widget showPasswordIcon() {
    if (!widget.password) return Container();

    return IconButton(
      icon: const Icon(Icons.remove_red_eye, size: 14),
      onPressed: () {
        showPassword.value = !showPassword.value;
      },
    );
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
