import 'package:flutter/material.dart';
import 'package:mobile/components/space.dart';
import 'package:mobile/style/colors.dart';

class AppBarComp extends StatelessWidget {
  final bool showBack;
  final String title;
  final List<Widget> actions;
  final Color? backgroundColor;
  final Function()? onBackClick;
  final bool showLogo;
  final Widget? leading;

  const AppBarComp({
    Key? key,
    required this.title,
    this.backgroundColor,
    this.showBack = false,
    this.actions = const [],
    this.onBackClick,
    this.showLogo = false,
    this.leading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color _background;

    if (backgroundColor == null) {
      _background = Theme.of(context).backgroundColor;
    } else {
      _background = backgroundColor!;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          color: _background,
          child: Column(
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
        ),
        Container(
          height: 1,
          color: Theme.of(context).dividerColor,
        ),
      ],
    );
  }

  Widget _buildLeading(BuildContext context) {
    if (leading == null) return Container();

    return Row(
      children: [
        leading!,
        Container(width: 10),
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
          color: ColorsExt.textGrey2_5(context)),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [Container(width: 16), ...actions],
    );
  }
}
