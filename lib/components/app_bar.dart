import 'package:flutter/material.dart';
import 'package:mobile/components/space.dart';
import 'package:mobile/i18n/strings.g.dart';

class AppBarComp extends StatelessWidget {
  final bool showBack;
  final String? title;
  final List<Widget> actions;
  final Color? backgroundColor;
  final Function()? onBackClick;
  final bool showLogo;

  AppBarComp({
    Key? key,
    this.backgroundColor,
    this.showBack = false,
    this.actions = const [],
    this.onBackClick,
    this.showLogo = false,
  })  : title = t.appName,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    Color _background;

    if (backgroundColor == null) {
      _background = Theme.of(context).cardColor;
    } else {
      _background = backgroundColor!;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(color: _background),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildBack(context),
                    _buildLogo(context),
                    _buildTitle(context),
                    Container(width: 16),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions,
                  ),
                ],
              )
            ],
          ),
        ),
        const Space(1),
      ],
    );
  }

  Widget _buildLogo(BuildContext context) {
    if (showLogo) {
      return Row(
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: Image.asset(
              "assets/images/logo.png",
              fit: BoxFit.contain,
            ),
          ),
          const Space(16),
        ],
      );
    }
    return Container();
  }

  Widget _buildBack(BuildContext context) {
    if (!showBack) return const Space(24);

    return InkWell(
      onTap: () {
        if (onBackClick != null) {
          onBackClick!();
        } else {
          Navigator.pop(context);
        }
      },
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Icon(
          Icons.arrow_back_ios,
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
        child: Text(
          title ?? t.appName,
          textAlign: TextAlign.start,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
        ),
      ),
    );
  }
}
