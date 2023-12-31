import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:models/contact/contact.dart';

class ContactRow extends StatelessWidget {
  final Contact contact;
  const ContactRow({
    super.key,
    required this.contact,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Dimension.paddingXS),
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
            const SizedBox(width: Dimension.paddingS),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${contact.name}',
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.subtitle1?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: ColorsExt.grey2(context),
                                )),
                        Text('${contact.identifier}',
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.caption?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: ColorsExt.grey2(context),
                                )),
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
