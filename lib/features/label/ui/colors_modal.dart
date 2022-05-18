import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/scroll_chip.dart';
import 'package:mobile/style/colors.dart';

class ColorsModal extends StatelessWidget {
  const ColorsModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
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
                  itemCount: ColorsExt.paletteColorsDisplayName.keys.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          t.label.color,
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20, color: ColorsExt.grey2(context)),
                        ),
                      );
                    }

                    index -= 1;

                    String rawColorName = ColorsExt.paletteColorsDisplayName.keys.toList()[index];
                    String colorText = ColorsExt.paletteColorsDisplayName.values.toList()[index];

                    Color color = ColorsExt.getFromName(rawColorName);

                    return InkWell(
                      onTap: () {
                        Navigator.pop(context, rawColorName);
                      },
                      child: SizedBox(
                        height: 46,
                        child: Row(
                          children: [
                            CircleAvatar(radius: 11, backgroundColor: color),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Text(
                              colorText,
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
