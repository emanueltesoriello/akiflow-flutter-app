import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';
import 'package:models/label/label.dart';

// Return new section as a `Label` using `Navigator.pop(context, newSection)` to refresh sections ui
class CreateEditSectionModal extends StatefulWidget {
  final Label initialSection;

  const CreateEditSectionModal({Key? key, required this.initialSection}) : super(key: key);

  @override
  State<CreateEditSectionModal> createState() => _CreateEditSectionModalState();
}

class _CreateEditSectionModalState extends State<CreateEditSectionModal> {
  final FocusNode titleFocus = FocusNode();
  final TextEditingController titleController = TextEditingController();
  late final ValueNotifier<Label> section;

  @override
  void initState() {
    super.initState();
    section = ValueNotifier(widget.initialSection);
    titleController.text = section.value.title ?? '';
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
                topLeft: Radius.circular(Dimension.padding),
                topRight: Radius.circular(Dimension.padding),
              ),
              child: Container(
                color: Theme.of(context).backgroundColor,
                margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimension.padding),
                    child: Column(
                      children: [
                        const SizedBox(height: Dimension.padding),
                        const ScrollChip(),
                        const SizedBox(height: Dimension.padding),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                focusNode: titleFocus,
                                controller: titleController,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                  hintText: t.label.sectionTitle,
                                  border: InputBorder.none,
                                  hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: ColorsExt.grey600(context),
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: ColorsExt.grey600(context),
                                      fontWeight: FontWeight.w500,
                                    ),
                                onChanged: (value) {
                                  section.value = section.value.copyWith(title: value);
                                },
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(context, section.value);
                                },
                                borderRadius: BorderRadius.circular(Dimension.radius),
                                child: Material(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(Dimension.radius),
                                  child: SizedBox(
                                    height: Dimension.mediumIconSize,
                                    width: Dimension.mediumIconSize,
                                    child: Center(
                                      child: SvgPicture.asset(
                                        Assets.images.icons.common.arrowUpSVG,
                                        width: Dimension.chevronIconSize,
                                        height: Dimension.chevronIconSize,
                                        color: Theme.of(context).backgroundColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
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
