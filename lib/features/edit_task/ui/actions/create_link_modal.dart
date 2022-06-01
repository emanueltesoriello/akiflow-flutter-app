import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/style/colors.dart';

class CreateLinkModal extends StatefulWidget {
  const CreateLinkModal({Key? key}) : super(key: key);

  @override
  State<CreateLinkModal> createState() => _CreateLinkModalState();
}

class _CreateLinkModalState extends State<CreateLinkModal> {
  final FocusNode titleFocus = FocusNode();
  late final ValueNotifier<String?> link = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    titleFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Wrap(
        children: [
          Container(
            decoration: const BoxDecoration(color: Colors.transparent),
            constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height * 0.1),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
              child: Container(
                color: Theme.of(context).backgroundColor,
                margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                focusNode: titleFocus,
                                keyboardType: TextInputType.url,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                  hintText: t.task.link.addLink,
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
                                onChanged: (value) {
                                  link.value = value;
                                },
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(context, link.value);
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Material(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(8),
                                  child: SizedBox(
                                    height: 36,
                                    width: 36,
                                    child: Center(
                                      child: SvgPicture.asset(
                                        "assets/images/icons/_common/arrow_up.svg",
                                        width: 24,
                                        height: 24,
                                        color: Theme.of(context).backgroundColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
