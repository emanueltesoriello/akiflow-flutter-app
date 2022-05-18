import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/button_list.dart';
import 'package:mobile/components/base/button_list_divider.dart';
import 'package:mobile/components/base/scroll_chip.dart';
import 'package:mobile/components/base/search.dart';
import 'package:mobile/features/label/cubit/label_cubit.dart';
import 'package:mobile/features/label/ui/button_list_label.dart';
import 'package:mobile/features/label/ui/colors_modal.dart';
import 'package:mobile/style/colors.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/label/label.dart';

class CreateEditLabelModal extends StatefulWidget {
  const CreateEditLabelModal({Key? key}) : super(key: key);

  @override
  State<CreateEditLabelModal> createState() => _CreateEditLabelModalState();
}

class _CreateEditLabelModalState extends State<CreateEditLabelModal> {
  final TextEditingController titleController = TextEditingController();

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
                        SearchView(
                          focus: titleFocus,
                          onChanged: (value) {},
                          hint: "",
                        ),
                        const SizedBox(height: 24),
                        BlocBuilder<LabelCubit, LabelCubitState>(
                          builder: (context, state) {
                            Label label = state.selectedLabel!;

                            Color iconBackground;
                            Color iconForeground;

                            String? colorText;

                            if (label.color != null) {
                              iconBackground = ColorsExt.getFromName(label.color!).withOpacity(0.1);
                              iconForeground = ColorsExt.getFromName(label.color!);
                              colorText = ColorsExt.displayTextFromName(label.color!);
                            } else {
                              iconBackground = ColorsExt.grey6(context);
                              iconForeground = ColorsExt.grey2(context);
                            }

                            return ButtonListLabel(
                              title: colorText ?? "",
                              position: ButtonListPosition.top,
                              leading: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: iconBackground,
                                ),
                                height: 26,
                                width: 26,
                                child: Center(
                                  child: SvgPicture.asset(
                                    "assets/images/icons/_common/number.svg",
                                    color: iconForeground,
                                    height: 20,
                                    width: 20,
                                  ),
                                ),
                              ),
                              onPressed: () async {
                                LabelCubit labelCubit = context.read<LabelCubit>();

                                String? rawColorName = await showCupertinoModalBottomSheet(
                                  context: context,
                                  builder: (context) => const ColorsModal(),
                                );

                                if (rawColorName != null) {
                                  labelCubit.setColor(rawColorName);
                                }
                              },
                            );
                          },
                        ),
                        const ButtonListDivider(),
                        ButtonListLabel(
                          title: t.settings.myAccount,
                          position: ButtonListPosition.bottom,
                          leading: SizedBox(
                            height: 26,
                            width: 26,
                            child: Center(
                              child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: SvgPicture.asset(
                                    "assets/images/icons/_common/folder.svg",
                                    color: ColorsExt.grey2(context),
                                  )),
                            ),
                          ),
                          onPressed: () {
                            // TODO SETTINGS - my account settings event
                          },
                        ),
                        const SizedBox(height: 24),
                        InkWell(
                          onTap: () {
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
                                    t.label.createLabel,
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
