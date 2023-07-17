import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';
import 'package:models/label/label.dart';

/// Return new [Label] as the folder selected
class FolderModal extends StatelessWidget {
  final List<Label> folders;

  const FolderModal({Key? key, required this.folders}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
          minHeight: MediaQuery.of(context).size.height * 0.3,
        ),
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(Dimension.radius),
            topRight: Radius.circular(Dimension.radius),
          ),
          child: Material(
            color: Theme.of(context).colorScheme.background,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: Dimension.padding),
              shrinkWrap: true,
              children: [
                const SizedBox(height: Dimension.padding),
                const ScrollChip(),
                const SizedBox(height: Dimension.padding),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: folders.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: Dimension.padding),
                        child: Text(
                          t.label.folder,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: ColorsExt.grey800(context),
                              ),
                        ),
                      );
                    }

                    index -= 1;

                    Label folder = folders[index];

                    return InkWell(
                      onTap: () {
                        Navigator.pop(context, folder);
                      },
                      child: SizedBox(
                        height: 46,
                        child: Row(
                          children: [
                            Expanded(
                                child: Text(
                              folder.title ?? t.noTitle,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: ColorsExt.grey800(context),
                                  ),
                            )),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
