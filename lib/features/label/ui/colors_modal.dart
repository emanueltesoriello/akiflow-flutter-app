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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    t.label.color,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20, color: ColorsExt.grey2(context)),
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                  ),
                  itemCount: ColorsExt.paletteColorsDisplayName.keys.length,
                  itemBuilder: (BuildContext context, int index) {
                    String rawColorName = ColorsExt.paletteColorsDisplayName.keys.toList()[index];

                    Color color = ColorsExt.getFromName(rawColorName);

                    return InkWell(
                      onTap: () {
                        Navigator.pop(context, rawColorName);
                      },
                      child: Center(
                        child: SizedBox(
                          height: 35,
                          child: CircleAvatar(backgroundColor: color),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
