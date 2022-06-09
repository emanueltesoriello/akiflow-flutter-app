import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/scroll_chip.dart';
import 'package:mobile/style/colors.dart';
import 'package:models/integrations/gmail.dart';

class GmailActionDialog extends StatelessWidget {
  final Function() unstarOrUnlabel;
  final Function() goToGmail;
  final GmailSyncMode syncMode;

  const GmailActionDialog({
    Key? key,
    required this.unstarOrUnlabel,
    required this.goToGmail,
    required this.syncMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
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
            child: ListView(
              shrinkWrap: true,
              children: [
                const SizedBox(height: 12),
                const ScrollChip(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    t.task.gmail.doYouAlsoWantTo,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Builder(builder: (context) {
                        if (syncMode == GmailSyncMode.useStarToImport) {
                          return _item(
                            context,
                            active: true,
                            text: t.task.gmail.unstarTheEmail,
                            click: () {
                              unstarOrUnlabel();
                              Navigator.pop(context);
                            },
                          );
                        } else {
                          return _item(
                            context,
                            active: true,
                            text: t.task.gmail.unlabelTheEmail,
                            click: () {
                              unstarOrUnlabel();
                              Navigator.pop(context);
                            },
                          );
                        }
                      }),
                      const SizedBox(height: 10),
                      _item(
                        context,
                        active: true,
                        text: t.task.gmail.goToGmail,
                        click: () {
                          goToGmail();
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(height: 10),
                      _item(
                        context,
                        active: true,
                        text: t.task.gmail.doNothing,
                        click: () {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context, {
    required bool active,
    required String text,
    required Function() click,
  }) {
    return InkWell(
      onTap: click,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          color: active ? Colors.transparent : ColorsExt.grey6(context),
          border: Border.all(
            color: ColorsExt.grey5(context),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  color: ColorsExt.grey2(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
