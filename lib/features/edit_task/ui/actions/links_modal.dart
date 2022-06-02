import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/button_list.dart';
import 'package:mobile/components/base/scroll_chip.dart';
import 'package:mobile/features/edit_task/cubit/edit_task_cubit.dart';
import 'package:mobile/features/edit_task/ui/actions/create_link_modal.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

class LinksModal extends StatelessWidget {
  const LinksModal({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        height: MediaQuery.of(context).size.height * 0.5,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
          child: Container(
            color: Theme.of(context).backgroundColor,
            child: Column(
              children: [
                const SizedBox(height: 12),
                const ScrollChip(),
                const SizedBox(height: 12),
                BlocBuilder<EditTaskCubit, EditTaskCubitState>(
                  builder: (context, state) {
                    List<String> links = state.updatedTask.links?.toList() ?? [];

                    if (links.isEmpty || links.every((element) => element.isEmpty)) {
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
                                InkWell(
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
                                const Spacer(),
                                InkWell(
                                  onTap: () => context.read<EditTaskCubit>().removeLink(link),
                                  child: SvgPicture.asset(
                                    'assets/images/icons/_common/xmark.svg',
                                    width: 22,
                                    height: 22,
                                    color: ColorsExt.grey3(context),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ButtonList(
                      leadingTextIconAsset: "assets/images/icons/_common/link.svg",
                      title: t.editTask.add,
                      onPressed: () async {
                        EditTaskCubit cubit = context.read<EditTaskCubit>();

                        String? newLink = await showCupertinoModalBottomSheet(
                          context: context,
                          builder: (context) => const CreateLinkModal(),
                        );

                        if (newLink != null) {
                          cubit.addLink(newLink);
                        }
                      }),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
