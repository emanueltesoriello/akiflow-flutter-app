import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/widgets/base/bordered_input_view.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';

class SearchModal extends StatefulWidget {
  const SearchModal({Key? key}) : super(key: key);

  @override
  State<SearchModal> createState() => _SearchModalState();
}

class _SearchModalState extends State<SearchModal> {
  final FocusNode titleFocus = FocusNode();

  @override
  void initState() {
    titleFocus.requestFocus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Wrap(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(Dimension.radiusM),
                topRight: Radius.circular(Dimension.radiusM),
              ),
              child: Container(
                color: Theme.of(context).colorScheme.background,
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimension.padding),
                    child: Column(
                      children: [
                        const SizedBox(height: Dimension.padding),
                        const ScrollChip(),
                        const SizedBox(height: Dimension.padding),
                        BorderedInputView(
                          focus: titleFocus,
                          onChanged: (value) {},
                          hint: t.comingSoon,
                          enabled: false,
                          leading: SizedBox(
                            width: 24,
                            height: 24,
                            child: SvgPicture.asset(
                              'assets/images/icons/_common/search.svg',
                              color: ColorsExt.grey600(context),
                            ),
                          ),
                        ),
                        const SizedBox(height: Dimension.paddingXXL),
                        SizedBox(
                          height: 120,
                          width: 120,
                          child: SvgPicture.asset(
                            'assets/images/akiflow/search.svg',
                            alignment: Alignment.center,
                          ),
                        ),
                        const SizedBox(height: Dimension.padding),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimension.paddingS),
                          child: Text(t.settings.searchComingSoon,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w500, color: ColorsExt.grey900(context))),
                        ),
                        const SizedBox(height: Dimension.paddingXXL),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
