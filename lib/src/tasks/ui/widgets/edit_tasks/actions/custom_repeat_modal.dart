import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';
import 'package:mobile/src/base/ui/widgets/base/separator.dart';

class CustomRepeatModal extends StatelessWidget {
  const CustomRepeatModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).backgroundColor,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              const SizedBox(height: 12),
              const ScrollChip(),
              const SizedBox(height: 12),
              Row(
                children: [
                  SvgPicture.asset(
                    "assets/images/icons/_common/repeat.svg",
                    width: 28,
                    height: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${t.editTask.custom} ${t.editTask.repeat}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: ColorsExt.grey2(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 12.0,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Every',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: ColorsExt.grey2(context),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                      child: InkWell(
                        onTap: () {},
                        child: Container(
                          constraints: const BoxConstraints(
                            minHeight: 40,
                            minWidth: 40,
                          ),
                          decoration: BoxDecoration(
                              color: ColorsExt.grey7(context),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: ColorsExt.grey4(context))),
                          child: Center(
                            child: Text(
                              '1',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: ColorsExt.grey2(context),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        constraints: const BoxConstraints(
                          minHeight: 40,
                          minWidth: 77,
                        ),
                        decoration: BoxDecoration(
                            color: ColorsExt.grey7(context),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: ColorsExt.grey4(context))),
                        child: Center(
                          child: Text(
                            'Week',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: ColorsExt.grey2(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Separator(),
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                child: Text(
                  'Selected days',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: ColorsExt.grey2(context),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _dayButton(context, () {}, true, 'M'),
                  _dayButton(context, () {}, false, 'T'),
                  _dayButton(context, () {}, false, 'W'),
                  _dayButton(context, () {}, false, 'T'),
                  _dayButton(context, () {}, true, 'F'),
                  _dayButton(context, () {}, false, 'S'),
                  _dayButton(context, () {}, false, 'S'),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
                child: Separator(),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Ends',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: ColorsExt.grey2(context),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        constraints: const BoxConstraints(
                          minHeight: 40,
                          minWidth: 77,
                        ),
                        decoration: BoxDecoration(
                            color: ColorsExt.grey7(context),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: ColorsExt.grey4(context))),
                        child: Center(
                          child: Text(
                            'Never',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: ColorsExt.grey2(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
                child: Separator(),
              ),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        constraints: const BoxConstraints(
                          minHeight: 46,
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: ColorsExt.grey5(context))),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              color: ColorsExt.grey3(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        constraints: const BoxConstraints(
                          minHeight: 46,
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: ColorsExt.grey4(context))),
                        child: Center(
                          child: Text(
                            'Confirm',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              color: ColorsExt.grey2(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  InkWell _dayButton(
    BuildContext context,
    Function() onTap,
    bool active,
    String text,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 40,
          minWidth: 40,
        ),
        decoration: BoxDecoration(
          color: active ? ColorsExt.grey5(context) : ColorsExt.grey6(context),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: active ? ColorsExt.grey2(context) : ColorsExt.grey3(context),
            ),
          ),
        ),
      ),
    );
  }
}
