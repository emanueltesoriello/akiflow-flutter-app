import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/extensions/string_extension.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:models/task/task.dart';

class Subtitle extends StatelessWidget {
  final Task task;

  const Subtitle(this.task, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    dynamic doc;
    if (task.doc != null) {
      doc = task.computedDoc();
    }

    List<String> links = task.links ?? [];

    return SizedBox(
      //height: 24,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Builder(builder: (context) {
            if (doc != null) {
              return SizedBox(
                height: 24,
                child: Row(
                  children: [
                    SvgPicture.asset(
                      Assets.images.icons.common.arrowTurnDownRightSVG,
                      color: ColorsExt.grey600(context),
                      width: 16,
                      height: 16,
                    ),
                    const SizedBox(width: 4.5),
                    ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 16, maxHeight: 16),
                        child: SvgPicture.asset(task.computedIcon(), width: 16, height: 16)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          return Text(
                            doc!.getLinkedContentSummary().toString().parseHtmlString ?? doc.url ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                ?.copyWith(color: ColorsExt.grey600(context), height: 1),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            } else if (task.descriptionParsed.isNotEmpty) {
              return SizedBox(
                height: 24,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      Assets.images.icons.common.arrowTurnDownRightSVG,
                      color: ColorsExt.grey600(context),
                      width: 16,
                      height: 16,
                    ),
                    const SizedBox(width: 4.5),
                    Expanded(
                        child: Text(
                      task.descriptionParsed,
                      maxLines: 1,
                      style:
                          Theme.of(context).textTheme.bodyText1?.copyWith(height: 1, color: ColorsExt.grey600(context)),
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
                  Assets.images.icons.common.arrowTurnDownRightSVG,
                  color: ColorsExt.grey600(context),
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
                                  Assets.images.icons.web.faviconV2PNG,
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
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              ?.copyWith(height: 1, color: ColorsExt.grey600(context)),
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
