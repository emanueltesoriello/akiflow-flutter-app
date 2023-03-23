import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/widgets/base/bordered_input_view.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';
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
        topLeft: Radius.circular(Dimension.radiusM),
        topRight: Radius.circular(Dimension.radiusM),
      ),
      child: Wrap(
        children: [
          Container(
            color: Theme.of(context).backgroundColor,
            margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimension.radiusM),
                child: Column(
                  children: [
                    const SizedBox(height: Dimension.radiusM),
                    const ScrollChip(),
                    const SizedBox(height: Dimension.radiusM),
                    BorderedInputView(
                      focus: titleFocus,
                      hint: "",
                      onChanged: (String value) {
                        folder.value = folder.value.copyWith(title: value);
                      },
                    ),
                    const SizedBox(height: Dimension.paddingM),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context, folder.value);
                      },
                      style: Theme.of(context).outlinedButtonTheme.style?.copyWith(
                          backgroundColor: MaterialStateProperty.all(Colors.transparent),
                          minimumSize: MaterialStateProperty.all(const Size(0, 48))),
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
                            const SizedBox(width: Dimension.paddingS),
                            Text(
                              t.label.createFolder,
                              style: TextStyle(color: ColorsExt.grey2(context)),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimension.padding),
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
