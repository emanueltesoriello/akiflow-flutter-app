import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/common/style/colors.dart';

class CircleAccountPicture extends StatelessWidget {
  final String iconAsset;
  final String? networkImageUrl;

  const CircleAccountPicture({Key? key, required this.iconAsset, required this.networkImageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      width: 30,
      child: Stack(
        children: [
          SvgPicture.asset(iconAsset, height: 30, width: 30),
          Builder(builder: (context) {
            if (networkImageUrl == null || networkImageUrl!.isEmpty) {
              return const SizedBox();
            }

            return Transform.translate(
              offset: const Offset(5, 5),
              child: Align(
                  alignment: Alignment.bottomRight,
                  child: CircleAvatar(
                      radius: 8,
                      backgroundColor: ColorsExt.grey3(context),
                      backgroundImage: NetworkImage(networkImageUrl!))),
            );
          })
        ],
      ),
    );
  }
}
