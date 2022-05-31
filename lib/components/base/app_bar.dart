import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/style/colors.dart';

class AppBarComp extends StatelessWidget {
  final bool showBack;
  final String? title;
  final List<Widget> actions;
  final Function()? onBackClick;
  final bool showLogo;
  final Widget? leading;
  final Widget? customTitle;

  const AppBarComp({
    Key? key,
    this.title,
    this.showBack = false,
    this.actions = const [],
    this.onBackClick,
    this.showLogo = false,
    this.leading,
    this.customTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: ColorsExt.background(context),
          height: MediaQuery.of(context).padding.top + 4,
        ),
        Container(
          constraints: const BoxConstraints(maxHeight: 56),
          padding: const EdgeInsets.symmetric(vertical: 12.5),
          color: ColorsExt.background(context),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildLeading(context),
                    Expanded(child: _buildTitle(context)),
                    _buildActions(context),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
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
            mainAxisAlignment: MainAxisAlignment.center,
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
    if (customTitle != null) {
      return customTitle!;
    }

    if (title == null) {
      return const SizedBox();
    }

    return Text(
      title!,
      textAlign: TextAlign.start,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 24, color: ColorsExt.grey2(context)),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(width: 16),
        ...actions,
      ],
    );
  }
}
