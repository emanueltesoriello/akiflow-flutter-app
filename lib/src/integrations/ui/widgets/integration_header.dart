import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/theme.dart';
import 'package:mobile/extensions/task_extension.dart';

class IntegrationDetailsHeader extends StatelessWidget {
  final bool isActive;
  final String identifier;
  final String connectorId;

  const IntegrationDetailsHeader({
    Key? key,
    required this.identifier,
    required this.isActive,
    required this.connectorId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 62, maxHeight: 70),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: ColorsExt.grey5(context)),
        color: ColorsExt.background(context),
      ),
      margin: const EdgeInsets.all(1),
      child: Row(
        children: [
          const SizedBox(width: 16),
          SizedBox(width: 32, height: 32, child: SvgPicture.asset(TaskExt.iconFromConnectorId(connectorId))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    t.settings.integrations.gmail.title,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 17,
                      color: ColorsExt.grey2(context),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Visibility(
                      visible: isActive,
                      replacement: const SizedBox(),
                      child: CircleAvatar(
                        radius: 5,
                        backgroundColor: ColorsExt.green(context),
                      ),
                    ),
                    Flexible(
                        child: Text(
                      identifier,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: ColorsExt.grey3(context),
                        fontSize: 13,
                      ),
                    )),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
