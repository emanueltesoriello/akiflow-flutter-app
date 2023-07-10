import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/common/utils/time_format_utils.dart';
import 'package:mobile/common/utils/user_settings_utils.dart';
import 'package:mobile/core/api/pusher.dart';
import 'package:mobile/core/api/user_api.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/core/services/analytics_service.dart';
import 'package:mobile/core/services/sentry_service.dart';
import 'package:mobile/core/services/sync_controller_service.dart';
import 'package:mobile/src/base/ui/cubit/auth/auth_cubit.dart';
import 'package:mobile/src/base/ui/cubit/sync/sync_cubit.dart';
import 'package:models/user.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

part 'main_state.dart';

bool shouldForceLogOut(DateTime? to) {
  if (to != null) {
    to = DateTime(to.year, to.month, to.day);
    return (DateTime.now().difference(to).inHours / 24) < 100;
  }
  return true;
}

class MainCubit extends Cubit<MainCubitState> {
  final SentryService _sentryService = locator<SentryService>();
  final PreferencesRepository _preferencesRepository = locator<PreferencesRepository>();
  //final IntercomService _intercomService = locator<IntercomService>();
  final UserApi _userApi = locator<UserApi>();

  final SyncCubit _syncCubit;
  final AuthCubit _authCubit;
  final SyncControllerService _syncControllerService = locator<SyncControllerService>();

  // *********************************
  // *********************************

  MainCubit(this._syncCubit, this._authCubit) : super(const MainCubitState()) {
    AnalyticsService.track("Launch");

    User? user = _preferencesRepository.user;

    if (user != null) {
      _syncCubit.sync(loading: true);
      AnalyticsService.track("Show Main Window");
      // lunch Pusher
      try {
        connect();
      } catch (e) {
        print('error on Pusher connect: $e');
      }
    }
  }

  connect() async {
    try {
      PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();

      await pusher.init(
        apiKey: "4fa6328da6969ef162ec",
        cluster: "eu",
        onConnectionStateChange: (m, s) {
          print("onConnectionStateChange m: $m \n s: $s");
        },
        onError: (m, s, t) {
          print("onError m: $m\n s: $s\n t: $t");
        },
        onSubscriptionSucceeded: (_, __) {
          print("onSubscriptionSucceeded");
        },
        onEvent: (event) {
          try {
            print("onEvent: $event");
            print(jsonDecode(event.data)["syncEntities"]);
            var syncEntities = jsonDecode(event.data)["syncEntities"];
            List<Entity>? entities = [];

            if (syncEntities != null) {
              if (syncEntities.contains("tasks")) {
                entities.add(Entity.tasks);
              }
              if (syncEntities.contains("events")) {
                entities.add(Entity.events);
              }
              if (syncEntities.contains("event_modifier")) {
                entities.add(Entity.eventModifiers);
              }
              if (syncEntities.contains("accounts")) {
                entities.add(Entity.accounts);
              }
              if (syncEntities.contains("labels")) {
                entities.add(Entity.labels);
              }
              if (syncEntities.contains("calendars")) {
                entities.add(Entity.calendars);
              }
              if (syncEntities.contains("contacts")) {
                entities.add(Entity.contacts);
              }
              if (entities.isNotEmpty) {
                locator<SyncCubit>().sync(entities: entities);
              }
            }
          } catch (e) {
            print('error on Pusher event: $e');
          }
        },
        onSubscriptionError: (String message, dynamic e) {
          print("onSubscriptionError: $message, \n Exception: $e");
        },
        onDecryptionFailure: (String event, String reason) {
          print("onDecryptionFailure event: $event \n reason: $reason");
        },
        onMemberAdded: (_, __) {
          print("onMemberAdded");
        },
        onMemberRemoved: (_, __) {
          print("onMemberRemoved");
        },
        onAuthorizer: (String channelName, String socketId, dynamic options) async {
          print("onAuthorizer");

          try {
            PusherAPI pusherApi = PusherAPI();
            var res = await pusherApi.authorizePusher(channelName: channelName, socketId: socketId);
            if (res.statusCode == 200) {
              print({
                "auth": jsonDecode(res.body)['auth'],
              });
              return {
                "auth": jsonDecode(res.body)['auth'],
              };
            } else {
              if (Platform.isAndroid) {
                return false;
              } else {
                print('No auth on iOS - Pusher');
              }
            }
          } catch (e) {
            print(e);
          }
        },
      );
      await pusher.connect();

      await pusher.subscribe(
        channelName: "private-user.${locator<PreferencesRepository>().user!.id}",
      );
    } catch (e) {
      print("ERROR: $e");
      rethrow;
    }
  }

  void changeHomeView(HomeViewType homeViewType) {
    emit(state.copyWith(lastHomeViewType: state.homeViewType));
    emit(state.copyWith(homeViewType: homeViewType));
  }

  void selectLabel() {
    emit(state.copyWith(lastHomeViewType: state.homeViewType));
    emit(state.copyWith(homeViewType: HomeViewType.label));
  }

  void onLoggedAppStart() async {
    User? user = _authCubit.state.user;

    await onFocusGained();
    print("onLoggedAppStart user: ${user?.id}");
  }

  onFocusGained() async {
    User? appUser = _preferencesRepository.user;
    User? user = await _userApi.getUserData();

    DateTime? lastAppUseAt = _preferencesRepository.lastAppUseAt;
    if (user != null && appUser != null) {
      if (shouldForceLogOut(lastAppUseAt)) {
        bool? hasValidPlan = DateTime.parse(user.planExpireDate!).isAfter(DateTime.now());
        if (hasValidPlan) {
          _preferencesRepository.saveUser(appUser.copyWith(
              intercomHashIos: user.intercomHashIos,
              intercomHashAndroid: user.intercomHashAndroid,
              status: user.status,
              planExpireDate: user.planExpireDate));
          _sentryService.authenticate(user.id.toString(), user.email);

          int? timeFormat = TimeFormatUtils.systemDefault;
          timeFormat = UserSettingsUtils.getSettingBySectionAndKey(
                  preferencesRepository: _preferencesRepository,
                  sectionName: UserSettingsUtils.calendarSection,
                  key: UserSettingsUtils.timeFormat) ??
              TimeFormatUtils.systemDefault;
          _preferencesRepository.setTimeFormat(timeFormat ?? TimeFormatUtils.systemDefault);

          //await _intercomService.authenticate(
          //   email: user.email, intercomHashAndroid: user.intercomHashAndroid, intercomHashIos: user.intercomHashIos);
          try {
            // trigger that start every time the set port is called
            // used for handling backgroundSync that update the UI
            var port = ReceivePort();
            IsolateNameServer.registerPortWithName(port.sendPort, "backgroundSync");
            port.listen((dynamic data) async {
              print('got $data on UI');
              //await _syncControllerService.sync();
              await locator<SyncCubit>().sync();
            });
          } catch (e) {
            print(e);
          }
        } else {
          await _authCubit.planExpired();
        }
      } else {
        await _authCubit.logout();
      }
    }
  }

  void onFocusLost() async {
    _preferencesRepository.setLastAppUseAt(DateTime.now());
    await _syncControllerService.sync([Entity.tasks]);
  }
}
