import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/components/base/bordered_input_view.dart';
import 'package:mobile/common/components/base/scroll_chip.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:models/label/label.dart';

/// Return new [Label] as the folder created
class CreateFolderModal extends StatefulWidget {
  final Label initialFolder;

  const CreateFolderModal({Key? key, required this.initialFolder}) : super(key: key);

  @override
  State<CreateFolderModal> createState() => _CreateFolderModalState();
}

class _CreateFolderModalState extends State<CreateFolderModal> {
  final FocusNode titleFocus = FocusNode();
  late final ValueNotifier<Label> folder;

  @override
  void initState() {
    folder = ValueNotifier<Label>(widget.initialFolder);
    titleFocus.requestFocus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16.0),
        topRight: Radius.circular(16.0),
      ),
      child: Wrap(
        children: [
          Container(
            color: Theme.of(context).backgroundColor,
            margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    const ScrollChip(),
                    const SizedBox(height: 16),
                    BorderedInputView(
                      focus: titleFocus,
                      hint: "",
                      onChanged: (String value) {
                        folder.value = folder.value.copyWith(title: value);
                      },
                    ),
                    const SizedBox(height: 24),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context, folder.value);
                      },
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: ColorsExt.grey4(context),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 22,
                                height: 22,
                                child: SvgPicture.asset(Assets.images.icons.common.checkmarkSVG,
                                    color: ColorsExt.grey1(context)),
                              ),
                              const SizedBox(width: 11),
                              Text(
                                t.label.createFolder,
                                style: TextStyle(fontSize: 15, color: ColorsExt.grey2(context)),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
