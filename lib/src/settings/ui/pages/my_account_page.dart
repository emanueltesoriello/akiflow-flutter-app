import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/cubit/auth/auth_cubit.dart';
import 'package:mobile/src/base/ui/pages/auth_page.dart';
import 'package:mobile/src/base/ui/widgets/base/app_bar.dart';
import 'package:mobile/src/base/ui/widgets/base/button_list.dart';
import 'package:url_launcher/url_launcher.dart';

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({Key? key}) : super(key: key);

  @override
  State<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
  final TextEditingController deleteAccountController = TextEditingController();

  _alertDialog(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: AlertDialog(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Dimension.radiusM))),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Delete account?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: ColorsExt.grey1(context))),
                const SizedBox(height: Dimension.paddingM),
                Text("Be careful, this will delete all your data from Akiflow and it cannot be restored.",
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        ?.copyWith(color: ColorsExt.grey2_5(context), fontWeight: FontWeight.normal)),
                const SizedBox(height: Dimension.paddingM),
                TextField(
                    controller: deleteAccountController,
                    decoration: InputDecoration(hintText: 'Insert CONFIRM to continue'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: ColorsExt.grey1(context),
                        )),
                const SizedBox(height: Dimension.paddingM),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      style: Theme.of(context)
                          .textButtonTheme
                          .style
                          ?.copyWith(overlayColor: MaterialStateProperty.all(ColorsExt.grey5(context))),
                      onPressed: () async {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel'.toUpperCase(),
                          style: Theme.of(context).textTheme.bodyText1?.copyWith(color: ColorsExt.grey1(context))),
                    ),
                    const SizedBox(width: Dimension.padding),
                    TextButton(
                      style: Theme.of(context)
                          .textButtonTheme
                          .style
                          ?.copyWith(overlayColor: MaterialStateProperty.all(ColorsExt.grey5(context))),
                      onPressed: () async {
                        if (deleteAccountController.text == 'CONFIRM') {
                          print('call delete apis');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Wrong text'),
                            ),
                          );
                        }
                      },
                      child: Text('Continue'.toUpperCase(),
                          style: Theme.of(context).textTheme.bodyText1?.copyWith(color: ColorsExt.grey1(context))),
                    )
                  ],
                )
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComp(
        title: t.settings.myAccount.title,
        showBack: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(Dimension.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Dimension.paddingS),
                  Text(
                    t.settings.myAccount.connectedAs.toUpperCase(),
                    style: Theme.of(context).textTheme.caption?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: ColorsExt.grey3(context),
                        ),
                  ),
                  const SizedBox(height: Dimension.paddingXS),
                  Container(
                    padding: const EdgeInsets.all(Dimension.padding),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimension.radius),
                      color: ColorsExt.background(context),
                      border: Border.all(color: ColorsExt.grey5(context), width: 1),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          Assets.images.logo.logoOutlineSVG,
                          width: 42,
                          height: 42,
                        ),
                        const SizedBox(width: Dimension.padding),
                        Expanded(
                          child: BlocBuilder<AuthCubit, AuthCubitState>(
                            builder: (context, state) {
                              if (state.user == null) {
                                return const SizedBox();
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.user?.name ?? "n/d",
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1
                                        ?.copyWith(color: ColorsExt.grey2(context), fontWeight: FontWeight.w400),
                                  ),
                                  const SizedBox(height: Dimension.paddingXS),
                                  Text(
                                    state.user?.email ?? "n/d",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        ?.copyWith(color: ColorsExt.grey3(context), fontWeight: FontWeight.w500),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Dimension.padding),
                  Text(
                    t.settings.myAccount.manageAccount.toUpperCase(),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: ColorsExt.grey3(context), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: Dimension.paddingXS),
                  ButtonList(
                    title: t.settings.myAccount.manageAccount,
                    position: ButtonListPosition.single,
                    leading: Assets.images.icons.common.personCropCircleSVG,
                    trailingWidget: SvgPicture.asset(
                      Assets.images.icons.common.arrowUpRightSquareSVG,
                      width: 22,
                      height: 22,
                    ),
                    onPressed: () {
                      launchUrl(Uri.parse("https://app.akiflow.com/en/dashboard/profile"),
                          mode: LaunchMode.externalApplication);
                    },
                  ),
                  const SizedBox(height: Dimension.padding),
                  Text(
                    'Delete account'.toUpperCase(),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: ColorsExt.grey3(context), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: Dimension.paddingXS),
                  ButtonList(
                    title: 'Delete account',
                    position: ButtonListPosition.single,
                    leading: Assets.images.icons.common.arrowRightSVG,
                    trailingWidget: SvgPicture.asset(
                      Assets.images.icons.common.arrowRightSVG,
                      width: 22,
                      height: 22,
                    ),
                    onPressed: () {
                      print('delete');
                      showDialog(context: context, builder: (_) => _alertDialog(context));
                    },
                  ),
                  const SizedBox(height: Dimension.padding),
                  const Spacer(),
                  ButtonList(
                    title: t.settings.myAccount.logout,
                    position: ButtonListPosition.single,
                    onPressed: () {
                      context.read<AuthCubit>().logout();
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const AuthPage()), (Route<dynamic> route) => false);
                    },
                  ),
                  const SizedBox(height: Dimension.paddingL),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
