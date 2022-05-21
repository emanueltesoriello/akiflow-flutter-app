import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/scroll_chip.dart';
import 'package:mobile/style/colors.dart';
import 'package:models/label/label.dart';

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
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
          child: Container(
            color: Theme.of(context).backgroundColor,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shrinkWrap: true,
              children: [
                const SizedBox(height: 12),
                const ScrollChip(),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: folders.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          t.label.folder,
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20, color: ColorsExt.grey2(context)),
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
                              style: TextStyle(color: ColorsExt.grey2(context), fontSize: 17),
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
