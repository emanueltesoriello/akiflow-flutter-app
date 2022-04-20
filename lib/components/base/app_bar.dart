import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/components/base/space.dart';
import 'package:mobile/style/colors.dart';

class AppBarComp extends StatelessWidget {
  final bool showBack;
  final String title;
  final List<Widget> actions;
  final Function()? onBackClick;
  final bool showLogo;
  final Widget? leading;

  const AppBarComp({
    Key? key,
    required this.title,
    this.showBack = false,
    this.actions = const [],
    this.onBackClick,
    this.showLogo = false,
    this.leading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Column(
          children: [
            Space(MediaQuery.of(context).padding.top),
            Row(
              children: [
                const Space(16),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildLeading(context),
                      _buildTitle(context),
                      const Spacer(),
                      _buildActions(context),
                    ],
                  ),
                ),
                const Space(16),
              ],
            ),
            const Space(2),
          ],
        ),
      ],
    );
  }

  Widget _buildLeading(BuildContext context) {
    return Row(
      children: [
        Builder(builder: (context) {
          if (showBack) {
            return Row(
              children: [
                InkWell(
                  onTap: (() => Navigator.pop(context)),
                  child: SvgPicture.asset(
                    "assets/images/icons/_common/arrow_left.svg",
                    height: 26,
                    width: 26,
                    color: ColorsExt.grey2(context),
                  ),
                ),
                Container(width: 10),
              ],
            );
          } else {
            return const SizedBox();
          }
        }),
        Builder(builder: (context) {
          if (leading == null) return Container();

          return Column(
            children: [
              Row(
                children: [
                  leading!,
                  Container(width: 10),
                ],
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.start,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 24,
          color: ColorsExt.grey2(context)),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [Container(width: 16), ...actions],
    );
  }
}
