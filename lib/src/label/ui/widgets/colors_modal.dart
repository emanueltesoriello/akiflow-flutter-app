import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';

class ColorsModal extends StatelessWidget {
  const ColorsModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(Dimension.padding),
              topRight: Radius.circular(Dimension.padding),
            ),
          ),
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: Dimension.padding),
            shrinkWrap: true,
            children: [
              const SizedBox(height: Dimension.padding),
              const ScrollChip(),
              const SizedBox(height: Dimension.padding),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Dimension.padding),
                child: Text(
                  t.label.color,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w500, color: ColorsExt.grey2(context)),
                ),
              ),
              const SizedBox(height: Dimension.padding),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                ),
                itemCount: ColorsExt.paletteColorsDisplayName.keys.length,
                itemBuilder: (BuildContext context, int index) {
                  String rawColorName = ColorsExt.paletteColorsDisplayName.keys.toList()[index];
                  return InkWell(
                    onTap: () {
                      Navigator.pop(context, rawColorName);
                    },
                    child: Center(
                      child: SizedBox(
                        height: Dimension.mediumIconSize,
                        child: CircleAvatar(backgroundColor: ColorsExt.getFromName(rawColorName)),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: Dimension.padding),
            ],
          )),
    );
  }
}
