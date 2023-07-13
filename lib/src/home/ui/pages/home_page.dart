import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/core/services/navigation_service.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/base/models/mark_as_done_type.dart';
import 'package:mobile/src/base/ui/cubit/main/main_cubit.dart';
import 'package:mobile/src/base/ui/cubit/sync/sync_cubit.dart';
import 'package:mobile/src/integrations/ui/cubit/integrations_cubit.dart';
import 'package:mobile/src/integrations/ui/pages/reconnect_integrations.dart';
import 'package:mobile/src/integrations/ui/widgets/mark_done_modal.dart';
import 'package:mobile/src/label/ui/cubit/labels_cubit.dart';
import 'package:mobile/src/onboarding/ui/cubit/onboarding_cubit.dart';
import 'package:mobile/src/tasks/ui/cubit/doc_action.dart';
import 'package:mobile/src/tasks/ui/cubit/edit_task_cubit.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';
import 'package:mobile/src/tasks/ui/pages/create_task/create_task_modal.dart';
import 'package:mobile/src/tasks/ui/pages/edit_task/recurring_edit_modal.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/account/account.dart';
import 'package:share_handler/share_handler.dart';
import 'package:flutter/services.dart';

import 'home_body.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  StreamSubscription? streamSubscription;
  StreamSubscription? periodicStreamSubscription;
  SharedMedia? media;
  final handler = ShareHandlerPlatform.instance;

  handleDeeplinks(String path) {
    if (path.isEmpty) {
      return;
    } else if (path.toLowerCase().contains('inbox')) {
      print('deeplink inbox');
      context.read<MainCubit>().changeHomeView(HomeViewType.inbox);
    } else if (path.toLowerCase().contains('calendar')) {
      print('deeplink calendar');
      context.read<MainCubit>().changeHomeView(HomeViewType.calendar);
    } else if (path.toLowerCase().contains('today')) {
      print('deeplink today page');
      context.read<MainCubit>().changeHomeView(HomeViewType.today);
    } else if (path.toLowerCase().contains('createtask')) {
      print('deeplink create task');
      context.read<MainCubit>().changeHomeView(HomeViewType.today);
      showCupertinoModalBottomSheet(
        context: context,
        builder: (context) => const CreateTaskModal(),
      ).then((value) => context.read<EditTaskCubit>().onModalClose());
    } else if (path.toLowerCase().contains('shareavailability')) {
      print('deeplink share availability');
      context.read<MainCubit>().changeHomeView(HomeViewType.availability);
    }
  }

  Future<void> initPlatformState() async {
    print('started initPlatformState');
    try {
      var media = await handler.getInitialSharedMedia();
      if (!mounted) return;
      if (media != null) {
        if (media.content!.contains('link.akiflow.com') && Platform.isAndroid) {
          String path = Uri.parse(media.content!).path;
          handleDeeplinks(path);
        } else {
          showCupertinoModalBottomSheet(
            context: context,
            builder: (context) => CreateTaskModal(
              sharedText: media.content,
            ),
          ).then((value) async {
            context.read<EditTaskCubit>().onModalClose();
            await Future.delayed(const Duration(milliseconds: 700));

            SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          });
        }
      }

      handler.sharedMediaStream.listen((SharedMedia? media) {
        if (!mounted) return;
        if (media != null) {
          if (media.content!.contains('link.akiflow.com') && Platform.isAndroid) {
            String path = Uri.parse(media.content!).path;
            handleDeeplinks(path);
          } else {
            showCupertinoModalBottomSheet(
              context: context,
              builder: (context) => CreateTaskModal(
                sharedText: media.content,
              ),
            ).then((value) async {
              context.read<EditTaskCubit>().onModalClose();
              await Future.delayed(const Duration(milliseconds: 700));
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            });
          }
        }
      });
      if (!mounted) return;
    } catch (e) {
      print('Erorr on initPlatformState\n');
      print(e);
    }
  }

  initiOSAppLinks() async {
    final appLinks = AppLinks();
//Get the initial/first link.
// This is useful when app was terminated (i.e. not started)
    final uri = await appLinks.getInitialAppLink();
    if (Platform.isIOS) {
      BuildContext? context = NavigationService.navigatorKey.currentContext;
      if (context != null && uri != null && uri.host.contains('link.akiflow.com')) {
        // Do something (navigation, ...)
        print('deeplink');
        String path = uri.path;
        handleDeeplinks(path);
      }
    }

// Subscribe to further events when app is started.
// (Use stringLinkStream to get it as [String])
    appLinks.uriLinkStream.listen((uri) {
      if (Platform.isIOS) {
        BuildContext? context = NavigationService.navigatorKey.currentContext;
        if (context != null && uri.host.contains('link.akiflow.com')) {
          // Do something (navigation, ...)
          print('deeplink');
          String path = uri.path;
          handleDeeplinks(path);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initPlatformState();
    initiOSAppLinks();

    TasksCubit tasksCubit = context.read<TasksCubit>();

    if (streamSubscription != null) {
      streamSubscription!.cancel();
    }

    streamSubscription = tasksCubit.editRecurringTasksDialog.listen((allSelected) {
      showCupertinoModalBottomSheet(
          context: context,
          builder: (context) => RecurringEditModal(
                onlyThisTap: () {
                  tasksCubit.update(allSelected);
                },
                allTap: () {
                  tasksCubit.update(allSelected, andFutureTasks: true);
                },
              ));
    });

    tasksCubit.docActionsStream.listen((List<GmailDocAction> actions) async {
      for (final action in actions) {
        MarkAsDoneType? selectedType = await showCupertinoModalBottomSheet(
          context: context,
          builder: (context) => MarkDoneModal(
            askBehavior: true,
            initialType: MarkAsDoneType.doNothing,
            account: action.account,
          ),
        );
        if (selectedType != null) {
          switch (selectedType) {
            case MarkAsDoneType.unstarTheEmail:
              tasksCubit.unstarGmail(action);
              break;
            case MarkAsDoneType.goTo:
              tasksCubit.goToUrl(action.task.doc?['url']);
              break;
            default:
          }
        }
      }
    });

    context.read<MainCubit>().onLoggedAppStart();

    context.read<SyncCubit>().syncCompletedStream.listen((_) {
      bool reconnectPageSkipped = context.read<IntegrationsCubit>().reconnectPageSkipped;

      if (reconnectPageSkipped == false) {
        _checkIfHasAccountsToReconnect();
      }
    });

    if (periodicStreamSubscription != null) {
      periodicStreamSubscription!.cancel();
    }
    periodicStreamSubscription =
        Stream.periodic(const Duration(seconds: 30)).listen((_) => context.read<SyncCubit>().checkConnectivity());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    streamSubscription?.cancel();
    periodicStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkIfHasAccountsToReconnect() async {
    context.read<IntegrationsCubit>().refresh().then((_) {
      bool reconnectPageVisible = context.read<IntegrationsCubit>().state.reconnectPageVisible;
      bool tutorialVisible = context.read<OnboardingCubit>().state.show;

      if (reconnectPageVisible || tutorialVisible) {
        return;
      }

      List<Account> accounts = context.read<IntegrationsCubit>().state.accounts;

      if (accounts.any((account) => !context.read<IntegrationsCubit>().isLocalActive(account)) &&
          !locator<PreferencesRepository>().reconnectPageSkipped) {
        context.read<IntegrationsCubit>().reconnectPageVisible(true);

        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ReconnectIntegrations())).then((_) {
            context.read<IntegrationsCubit>().reconnectPageVisible(false);
          });
        });
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    bool isAuthenticatingOAuth = context.read<IntegrationsCubit>().state.isAuthenticatingOAuth;
    if (state == AppLifecycleState.resumed && isAuthenticatingOAuth == false) {
      try {
        context.read<SyncCubit>().sync(loading: true);
        periodicStreamSubscription =
            Stream.periodic(const Duration(seconds: 30)).listen((_) => context.read<SyncCubit>().checkConnectivity());
      } catch (e) {
        print(e);
      }
    } else {
      periodicStreamSubscription?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if (TaskExt.isSelectMode(context.read<TasksCubit>().state)) {
            context.read<TasksCubit>().clearSelected();
            return false;
          } else if (context.read<LabelsCubit>().state.selectedLabel != null) {
            context.read<MainCubit>().changeHomeView(context.read<MainCubit>().state.lastHomeViewType);
            return false;
          } else {
            if (ModalRoute.of(context)?.settings.name != "/") {
              return false;
            }
            return true;
          }
        },
        child: HomeBody(
            bottomBarHeight: Dimension.bottomBarHeight,
            homeViewType: context.watch<MainCubit>().state.homeViewType.index));
  }
}
