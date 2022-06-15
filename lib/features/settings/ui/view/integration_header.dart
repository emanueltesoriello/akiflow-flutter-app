import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/style/theme.dart';
import 'package:mobile/utils/task_extension.dart';

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
    return IntrinsicHeight(
      child: Container(
        constraints: const BoxConstraints(minHeight: 62),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: ColorsExt.grey5(context),
                borderRadius: BorderRadius.circular(radius),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
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
                          ],
                        ),
                        Column(
                          children: [
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Builder(builder: (context) {
                                  if (!isActive) {
                                    return const SizedBox();
                                  }

                                  return Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 5,
                                        backgroundColor: ColorsExt.green(context),
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                  );
                                }),
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
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
