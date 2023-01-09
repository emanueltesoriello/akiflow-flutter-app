import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/extensions/string_extension.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:models/doc/doc.dart';
import 'package:models/task/task.dart';

class Subtitle extends StatelessWidget {
  final Task task;

  const Subtitle(this.task, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Doc? doc = task.doc?.value;

    List<String> links = task.links ?? [];

    return SizedBox(
      //height: 24,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Builder(builder: (context) {
            if (doc != null) {
              return Row(
                children: [
                  SvgPicture.asset(
                    "assets/images/icons/_common/arrow_turn_down_right.svg",
                    color: ColorsExt.grey3(context),
                    width: 16,
                    height: 16,
                  ),
                  const SizedBox(width: 4.5),
                  ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 16, maxHeight: 16),
                      child: SvgPicture.asset(task.computedIcon(doc), width: 16, height: 16)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        return Text(
                          doc.getSummary.parseHtmlString ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            color: ColorsExt.grey3(context),
                            height: 1,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            } else if (task.descriptionParsed.isNotEmpty) {
              return Container(
                height: 24,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      "assets/images/icons/_common/arrow_turn_down_right.svg",
                      color: ColorsExt.grey3(context),
                      width: 16,
                      height: 16,
                    ),
                    const SizedBox(width: 4.5),
                    Expanded(
                        child: Text(
                      task.descriptionParsed,
                      maxLines: 1,
                      style: TextStyle(
                        height: 1,
                        fontSize: 15,
                        color: ColorsExt.grey3(context),
                      ),
                    )),
                  ],
                ),
              );
            } else if (links.isNotEmpty) {
              String text;

              if (links.length > 1) {
                text = "${links.length} ${t.task.links.links}";
              } else {
                text = links.first;
              }

              String? iconAsset = TaskExt.iconAssetFromUrl(links.first);
              String? networkIcon = TaskExt.iconNetworkFromUrl(links.first);

              return Row(children: [
                SvgPicture.asset(
                  "assets/images/icons/_common/arrow_turn_down_right.svg",
                  color: ColorsExt.grey3(context),
                  width: 16,
                  height: 16,
                ),
                const SizedBox(width: 4.5),
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Builder(builder: (context) {
                        if (iconAsset != null) {
                          return SvgPicture.asset(
                            iconAsset,
                            width: 16,
                            height: 16,
                          );
                        } else if (networkIcon != null) {
                          return SizedBox(
                            width: 16,
                            height: 16,
                            child: Center(
                              child: Image.network(
                                networkIcon,
                                width: 16,
                                height: 16,
                                errorBuilder: (context, error, stacktrace) => Image.asset(
                                  "assets/images/icons/web/faviconV2.png",
                                  width: 16,
                                  height: 16,
                                ),
                              ),
                            ),
                          );
                        } else {
                          return const SizedBox();
                        }
                      }),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            height: 1,
                            fontSize: 15,
                            color: ColorsExt.grey3(context),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ]);
            } else {
              return const SizedBox();
            }
          }),
        ],
      ),
    );
  }
}
