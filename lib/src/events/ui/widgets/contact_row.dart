import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:models/contact/contact.dart';

class ContactRow extends StatelessWidget {
  final Contact contact;
  //final Function() onTap;
  const ContactRow({
    super.key,
    required this.contact,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: SizedBox(
        height: 45,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            contact.picture != null
                ? SizedBox(
                    height: 30,
                    width: 30,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(contact.picture!),
                    ),
                  )
                : SizedBox(
                    height: 30,
                    width: 30,
                    child: SvgPicture.asset(
                      Assets.images.icons.common.personCropCircleSVG,
                      color: ColorsExt.grey2(context),
                    ),
                  ),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${contact.name}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: ColorsExt.grey2(context),
                          ),
                        ),
                        Text(
                          '${contact.identifier}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: ColorsExt.grey2(context),
                          ),
                        ),
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
