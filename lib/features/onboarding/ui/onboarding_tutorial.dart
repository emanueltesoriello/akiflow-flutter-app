import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/task/slidable_sender.dart';
import 'package:mobile/features/integrations/cubit/integrations_cubit.dart';
import 'package:mobile/features/integrations/ui/reconnect_integrations.dart';
import 'package:mobile/features/onboarding/cubit/onboarding_cubit.dart';
import 'package:mobile/features/onboarding/ui/box_with_info.dart';
import 'package:mobile/features/onboarding/ui/task_row_fake.dart';
import 'package:mobile/style/sizes.dart';
import 'package:models/account/account.dart';
import 'package:models/task/task.dart';

class OnboardingTutorial extends StatefulWidget {
  const OnboardingTutorial({Key? key}) : super(key: key);

  @override
  State<OnboardingTutorial> createState() => _OnboardingTutorialState();
}

class _OnboardingTutorialState extends State<OnboardingTutorial> with SingleTickerProviderStateMixin {
  static const int onboardingSteps = 3;

  AnimationController? controller;
  bool? swipeLeftToRight;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      upperBound: 1,
      lowerBound: 0,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          SafeArea(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(top: toolbarHeight, bottom: bottomBarHeight),
            ),
          ),
          GestureDetector(
            onPanUpdate: (details) {
              swipeLeftToRight = details.delta.dx < 0 ? false : true;
            },
            onPanEnd: (details) {
              if (swipeLeftToRight == null) {
                return;
              } else if (swipeLeftToRight!) {
                back();
              } else if (!swipeLeftToRight!) {
                next();
              }
            },
            child: Container(
              color: Colors.black.withOpacity(0.5),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: SafeArea(
                child: BlocBuilder<OnboardingCubit, OnboardingCubitState>(
                  builder: (context, state) => Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 10),
                        child: Padding(
                          padding: const EdgeInsets.only(top: toolbarHeight),
                          child: Column(children: [
                            _task(context, state.page),
                            _boxInfoAndImage(context, state.page),
                          ]),
                        ),
                      ),
                      _controls(state.page, context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Column _controls(int page, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            const SizedBox(width: 7),
            Visibility(
              visible: page != 0,
              child: Builder(builder: (context) {
                if (page == 0) {
                  return const SizedBox();
                }
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => back(),
                      child: SvgPicture.asset("assets/images/onboarding/arrow_left.svg",
                          width: 46, height: 46, color: Theme.of(context).scaffoldBackgroundColor),
                    ),
                  ],
                );
              }),
            ),
            const Spacer(),
            Visibility(
              visible: page != onboardingSteps + 1,
              child: GestureDetector(
                onTap: () => next(),
                child: SvgPicture.asset("assets/images/onboarding/arrow_right.svg",
                    width: 46, height: 46, color: Theme.of(context).scaffoldBackgroundColor),
              ),
            ),
            const SizedBox(width: 7),
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 90, right: 16),
            child: TextButton(
                onPressed: () {
                  context.read<OnboardingCubit>().skipAll();
                  _tutorialCompleted(context);
                },
                style: ButtonStyle(
                  textStyle: MaterialStateProperty.all(TextStyle(
                    fontSize: 17,
                    color: Theme.of(context).scaffoldBackgroundColor,
                  )),
                  foregroundColor: MaterialStateProperty.all(Theme.of(context).scaffoldBackgroundColor),
                ),
                child: Text(t.onboarding.skipAll)),
          ),
        ),
      ],
    );
  }

  Container _task(BuildContext context, int page) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: SlidablePlayer(
            animation: controller,
            leftToRight: page == onboardingSteps ? false : true,
            child: IgnorePointer(child: TaskRowFake(Task(title: t.task.onboardingTitle))),
          )),
    );
  }

  Row _boxInfoAndImage(BuildContext context, int page) {
    String assetIcon;
    String text;
    Size size;

    switch (page) {
      case 0:
        assetIcon = "assets/images/onboarding/onboarding_finger.svg";
        text = t.onboarding.longTapMultipleSelection;
        size = const Size(47, 57);
        break;
      case 1:
        assetIcon = "assets/images/onboarding/finger_move.svg";
        text = t.onboarding.swipeLeftMoreOption;
        size = const Size(47, 40);
        break;
      case 2:
        assetIcon = "assets/images/onboarding/finger_long_move.svg";
        text = t.onboarding.swipeMorePlanTask;
        size = const Size(66, 40);
        break;
      case 3:
        assetIcon = "assets/images/onboarding/finger_move_invert.svg";
        text = t.onboarding.swipeRightToMarkAsDone;
        size = const Size(47, 40);
        break;
      default:
        assetIcon = "";
        text = "";
        size = const Size(0, 0);
        break;
    }

    List<Widget> children = [
      const SizedBox(width: 19),
      Transform.translate(
        offset: const Offset(0, 8),
        child: SvgPicture.asset(
          assetIcon,
          width: size.width,
          height: size.height,
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
      const SizedBox(width: 19),
      Flexible(child: BoxWithInfo(info: text)),
      const SizedBox(width: 19),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: page != onboardingSteps ? children : children.reversed.toList(),
    );
  }

  void back() {
    context.read<OnboardingCubit>().back();
    _animate();
  }

  Future<void> next({bool reset = false}) async {
    OnboardingNextAction action = context.read<OnboardingCubit>().next();

    switch (action) {
      case OnboardingNextAction.none:
        break;
      case OnboardingNextAction.reset:
        controller!.reset();
        break;
      case OnboardingNextAction.next:
        _animate();
        break;
      case OnboardingNextAction.close:
        _tutorialCompleted(context);
        break;
    }
  }

  Future<void> _animate() async {
    int page = context.read<OnboardingCubit>().state.page;

    if (page == 0) {
      controller!.reset();
    } else if (page == 1) {
      controller!.animateTo(0.6, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else if (page == 2) {
      controller!.animateTo(0.8, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else if (page == 3) {
      controller!.reset();
      await Future.delayed(const Duration(milliseconds: 300));
      controller!.animateTo(0.3, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _tutorialCompleted(BuildContext context) {
    context.read<OnboardingCubit>().onboardingCompleted();

    List<Account> accounts = context.read<IntegrationsCubit>().state.accounts;

    if (accounts.every((account) => context.read<IntegrationsCubit>().isLocalActive(account))) {
      return;
    } else {
      context.read<IntegrationsCubit>().reconnectPageVisible(true);

      Navigator.push(context, MaterialPageRoute(builder: (context) => const ReconnectIntegrations())).then((_) {
        context.read<IntegrationsCubit>().reconnectPageVisible(false);
      });
    }
  }
}
