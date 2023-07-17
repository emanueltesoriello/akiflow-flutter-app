import 'package:flutter/material.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/widgets/base/separator.dart';

class CustomFlutterRoundedButtonAction extends StatelessWidget {
  final String? textButtonNegative;
  final String? textButtonPositive;
  final String? textActionButton;
  final VoidCallback? onTapButtonNegative; // Default is "Cancel" button.
  final VoidCallback? onTapButtonPositive; // Default is "OK" button.
  final VoidCallback? onTapButtonAction; // Default is "Action" button which will be on the left.
  final TextStyle? textStyleButtonAction;
  final TextStyle? textStyleButtonPositive;
  final TextStyle? textStyleButtonNegative;
  final MaterialLocalizations localizations;
  final double borderRadius;
  final EdgeInsets? paddingActionBar;
  final Color? background;

  const CustomFlutterRoundedButtonAction(
      {Key? key,
      required this.localizations,
      this.textButtonNegative,
      this.textButtonPositive,
      this.textActionButton,
      this.onTapButtonAction,
      this.onTapButtonPositive,
      this.onTapButtonNegative,
      this.textStyleButtonPositive,
      this.textStyleButtonNegative,
      this.textStyleButtonAction,
      required this.borderRadius,
      this.paddingActionBar,
      this.background})
      : super(key: key);

  List<Widget> _buildActionsButton(BuildContext context) {
    final Widget negativeButton = Container(
      width: MediaQuery.of(context).size.width / 3,
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(
          color: ColorsExt.grey600(context),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(Dimension.radius),
      ),
      child: InkWell(
        onTap: onTapButtonNegative,
        child: Center(
            child: Text(
          textButtonNegative ?? localizations.cancelButtonLabel,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.w400,
                color: ColorsExt.grey800(context),
              ),
        )),
      ),
    );

    final Widget positiveButton = Container(
      width: MediaQuery.of(context).size.width / 3,
      height: 48,
      decoration: BoxDecoration(
        color: ColorsExt.akiflow100(context),
        border: Border.all(
          color: ColorsExt.akiflow500(context),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(Dimension.radius),
      ),
      child: InkWell(
        onTap: onTapButtonPositive,
        child: Center(
          child: Text(
            textButtonPositive ?? localizations.okButtonLabel,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w400,
                  color: ColorsExt.akiflow500(context),
                ),
          ),
        ),
      ),
    );

    if (textActionButton != null) {
      final Widget leftButton = TextButton(
        onPressed: onTapButtonAction,
        child: Text(textActionButton!, style: textStyleButtonAction),
      );
      return [
        leftButton,
        Row(children: <Widget>[negativeButton, positiveButton])
      ];
    }

    return [negativeButton, positiveButton];
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      padding: paddingActionBar,
      decoration: BoxDecoration(
          color: background,
          borderRadius: orientation == Orientation.landscape
              ? BorderRadius.only(bottomRight: Radius.circular(borderRadius))
              : BorderRadius.vertical(bottom: Radius.circular(borderRadius))),
      child: Column(
        children: [
          const Separator(),
          const SizedBox(height: 5),
          ButtonBar(
            alignment: MainAxisAlignment.spaceEvenly,
            children: _buildActionsButton(context),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }
}
