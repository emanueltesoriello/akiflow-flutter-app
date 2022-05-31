import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/action_button.dart';
import 'package:mobile/components/base/app_bar.dart';
import 'package:mobile/features/settings/cubit/settings_cubit.dart';
import 'package:mobile/features/settings/ui/view/integration_header.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/style/theme.dart';

class GmailInstructionIntegrationsPage extends StatelessWidget {
  const GmailInstructionIntegrationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, SettingsCubitState>(
      listenWhen: (previous, current) {
        return previous.connected == false && current.connected == true;
      },
      listener: (context, state) {
        if (state.connected) {
          Navigator.of(context).pop(true);
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            AppBarComp(
              title: t.settings.integrations.gmail.title,
              showBack: true,
            ),
            Expanded(
              child: Column(
                children: [
                  ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(16),
                    children: [
                      IntegrationDetailsHeader(
                        isActive: false,
                        identifier: t.settings.integrations.gmail.communication,
                        connectorId: 'gmail',
                      ),
                      const SizedBox(height: 32),
                      _step1(context),
                      const SizedBox(height: 16),
                      _mailPlaceholder(context),
                      const SizedBox(height: 32),
                      _step2(context),
                      const SizedBox(height: 16),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    child: ActionButton(
                      child: Text(
                        t.connect,
                        style: TextStyle(fontSize: 17, color: ColorsExt.akiflow(context)),
                      ),
                      onPressed: () {
                        context.read<SettingsCubit>().connectGmail();
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container _mailPlaceholder(BuildContext context) {
    return Container(
      height: 86,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: ColorsExt.background(context),
        border: Border.all(color: ColorsExt.grey7(context), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, -1),
            blurRadius: radius,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: CircleAvatar(radius: 19, backgroundColor: ColorsExt.grey4(context)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 18,
                        width: double.infinity,
                        margin: const EdgeInsets.only(right: 100),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: ColorsExt.grey6(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 18,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: ColorsExt.grey6(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 18,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: ColorsExt.grey6(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      height: 15,
                      width: 47,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: ColorsExt.grey6(context),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      height: 27,
                      width: 27,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ColorsExt.background(context),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x37404A40),
                            offset: Offset(0, 5),
                            blurRadius: radius,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: SvgPicture.asset("assets/images/icons/google/star.svg"),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Align(alignment: Alignment.bottomRight, child: SvgPicture.asset("assets/images/icons/google/finger.svg")),
        ],
      ),
    );
  }

  Row _step1(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 10,
          backgroundColor: ColorsExt.akiflow(context),
          child: const Text("1"),
        ),
        const SizedBox(width: 14),
        Expanded(
            child: RichText(
          text: TextSpan(
            text: t.settings.integrations.gmail.step1.t1,
            style: TextStyle(fontSize: 17, color: ColorsExt.grey2(context)),
            children: [
              TextSpan(
                  text: t.settings.integrations.gmail.step1.t2, style: const TextStyle(fontWeight: FontWeight.w500)),
              TextSpan(text: t.settings.integrations.gmail.step1.t3),
            ],
          ),
        )),
      ],
    );
  }

  Row _step2(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 10,
          backgroundColor: ColorsExt.akiflow(context),
          child: const Text("2"),
        ),
        const SizedBox(width: 14),
        Expanded(
            child: RichText(
          text: TextSpan(
            text: t.settings.integrations.gmail.step2,
            style: TextStyle(fontSize: 17, color: ColorsExt.grey2(context)),
          ),
        )),
      ],
    );
  }
}
