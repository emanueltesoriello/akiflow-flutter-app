import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/base/ui/widgets/base/separator.dart';
import 'package:mobile/src/tasks/ui/cubit/edit_task_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

class EditTaskLinks extends StatelessWidget {
  const EditTaskLinks({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditTaskCubit, EditTaskCubitState>(
      builder: (context, state) {
        List<String> links = state.updatedTask.links?.toList() ?? [];

        if (state.updatedTask.isLinksEmpty) {
          return const SizedBox();
        }

        return Column(
          children: [
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              itemCount: links.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                String link = links[index];

                String? iconAsset = TaskExt.iconAssetFromUrl(link);
                String? networkIcon = TaskExt.iconNetworkFromUrl(link);

                return Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: ColorsExt.grey6(context),
                          ),
                          padding: const EdgeInsets.all(6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Builder(builder: (context) {
                                if (iconAsset != null) {
                                  return SvgPicture.asset(
                                    iconAsset,
                                    width: 22,
                                    height: 22,
                                  );
                                } else if (networkIcon != null) {
                                  return SizedBox(
                                    width: 22,
                                    height: 22,
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
                              const SizedBox(width: 9),
                              Flexible(
                                child: Text(
                                  link,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: ColorsExt.grey3(context),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () => context.read<EditTaskCubit>().removeLink(link),
                      child: SvgPicture.asset(
                        Assets.images.icons.common.xmarkSVG,
                        width: 22,
                        height: 22,
                        color: ColorsExt.grey3(context),
                      ),
                    ),
                  ],
                );
              },
            ),
            const Separator(),
          ],
        );
      },
    );
  }
}
