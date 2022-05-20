import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/bordered_input_view.dart';
import 'package:mobile/components/base/scroll_chip.dart';
import 'package:mobile/style/colors.dart';

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
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
              child: Container(
                color: Theme.of(context).backgroundColor,
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        const ScrollChip(),
                        const SizedBox(height: 16),
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
                              color: ColorsExt.grey3(context),
                            ),
                          ),
                        ),
                        const SizedBox(height: 100),
                        SizedBox(
                          height: 120,
                          width: 120,
                          child: SvgPicture.asset(
                            'assets/images/akiflow/search.svg',
                            alignment: Alignment.center,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(t.settings.searchComingSoon,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w500, color: ColorsExt.grey1(context))),
                        ),
                        const SizedBox(height: 100),
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
