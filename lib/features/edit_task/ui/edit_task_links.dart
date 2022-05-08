import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/components/base/separator.dart';
import 'package:mobile/features/edit_task/cubit/edit_task_cubit.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:url_launcher/url_launcher.dart';

class EditTaskLinks extends StatelessWidget {
  const EditTaskLinks({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditTaskCubit, EditTaskCubitState>(
      builder: (context, state) {
        List<String> links = state.newTask.links?.toList() ?? [];

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

                String iconAsset = TaskExt.iconAssetFromUrl(link);

                return Row(
                  children: [
                    InkWell(
                      onTap: () {
                        launch(link);
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
                            SvgPicture.asset(
                              iconAsset,
                              width: 22,
                              height: 22,
                            ),
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
                      onTap: () =>
                          context.read<EditTaskCubit>().removeLink(link),
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
            const Separator(),
          ],
        );
      },
    );
  }
}