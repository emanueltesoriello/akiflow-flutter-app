import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/bordered_input_view.dart';
import 'package:mobile/components/base/scroll_chip.dart';
import 'package:mobile/features/label/cubit/create_edit/label_cubit.dart';
import 'package:mobile/features/label/cubit/labels_cubit.dart';
import 'package:mobile/style/colors.dart';
import 'package:models/label/label.dart';

class CreateFolderModal extends StatefulWidget {
  const CreateFolderModal({Key? key}) : super(key: key);

  @override
  State<CreateFolderModal> createState() => _CreateFolderModalState();
}

class _CreateFolderModalState extends State<CreateFolderModal> {
  final FocusNode titleFocus = FocusNode();

  @override
  void initState() {
    titleFocus.requestFocus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Wrap(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
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
                        const ScrollChip(),
                        const SizedBox(height: 16),
                        BorderedInputView(
                          focus: titleFocus,
                          onChanged: (value) {
                            context.read<LabelCubit>().titleChanged(value);
                          },
                          hint: "",
                        ),
                        const SizedBox(height: 24),
                        InkWell(
                          onTap: () {
                            Label newFolder = context.read<LabelCubit>().state.selectedLabel!;
                            context.read<LabelsCubit>().addLabel(newFolder, labelType: LabelType.folder);
                            Navigator.pop(context);
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
                                    child: SvgPicture.asset("assets/images/icons/_common/checkmark.svg",
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
            ),
          ),
        ],
      ),
    );
  }
}
