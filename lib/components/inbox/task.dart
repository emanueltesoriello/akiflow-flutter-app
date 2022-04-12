import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/style/theme.dart';
import 'package:models/task/task.dart';

class TaskRow extends StatelessWidget {
  final Task task;
  final Function() completed;

  const TaskRow({
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
        borderRadius: BorderRadius.circular(noticeRadius),
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
            child: Icon(
              SFSymbols.square,
              size: 20,
              color: ColorsExt.grey3(context),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title ?? "",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Builder(builder: (context) {
                  if (task.description == null || task.description!.isEmpty) {
                    return const SizedBox();
                  }

                  return const SizedBox();

                  return Column(
                    children: [
                      const SizedBox(height: 5),
                      HtmlWidget(
                        task.description!,
                        textStyle: const TextStyle(fontSize: 15),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
