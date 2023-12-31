import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/common/style/theme.dart';
import 'package:models/task/task.dart';

class TaskBorderedRow extends StatelessWidget {
  final Task task;
  final Function() completed;

  const TaskBorderedRow({
    Key? key,
    required this.task,
    required this.completed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        borderRadius: BorderRadius.circular(Dimension.noticeRadius),
        border: Border.all(
          color: ColorsExt.grey5(context),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              completed();
            },
            child: SvgPicture.asset(
              Assets.images.icons.common.squareSVG,
              width: 20,
              height: 20,
              color: ColorsExt.grey3(context),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title ?? '',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(height: 5),
                    Text(
                      task.createdAt != null
                          ? DateFormat("dd MMM 'at' HH:mm").format(DateTime.parse(task.createdAt!).toLocal())
                          : '',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
