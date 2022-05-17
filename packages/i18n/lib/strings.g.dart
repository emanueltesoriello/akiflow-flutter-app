
/*
 * Generated file. Do not edit.
 *
 * Locales: 1
 * Strings: 123 
 *
 * Built on 2022-05-17 at 13:10 UTC
 */

import 'package:flutter/widgets.dart';

const AppLocale _baseLocale = AppLocale.en;
AppLocale _currLocale = _baseLocale;

/// Supported locales, see extension methods below.
///
/// Usage:
/// - LocaleSettings.setLocale(AppLocale.en) // set locale
/// - Locale locale = AppLocale.en.flutterLocale // get flutter locale from enum
/// - if (LocaleSettings.currentLocale == AppLocale.en) // locale check
enum AppLocale {
	en, // 'en' (base locale, fallback)
}

/// Method A: Simple
///
/// No rebuild after locale change.
/// Translation happens during initialization of the widget (call of t).
///
/// Usage:
/// String a = t.someKey.anotherKey;
/// String b = t['someKey.anotherKey']; // Only for edge cases!
_StringsEn _t = _currLocale.translations;
_StringsEn get t => _t;

/// Method B: Advanced
///
/// All widgets using this method will trigger a rebuild when locale changes.
/// Use this if you have e.g. a settings page where the user can select the locale during runtime.
///
/// Step 1:
/// wrap your App with
/// TranslationProvider(
/// 	child: MyApp()
/// );
///
/// Step 2:
/// final t = Translations.of(context); // Get t variable.
/// String a = t.someKey.anotherKey; // Use t variable.
/// String b = t['someKey.anotherKey']; // Only for edge cases!
class Translations {
	Translations._(); // no constructor

	static _StringsEn of(BuildContext context) {
		final inheritedWidget = context.dependOnInheritedWidgetOfExactType<_InheritedLocaleData>();
		if (inheritedWidget == null) {
			throw 'Please wrap your app with "TranslationProvider".';
		}
		return inheritedWidget.translations;
	}
}

class LocaleSettings {
	LocaleSettings._(); // no constructor

	/// Uses locale of the device, fallbacks to base locale.
	/// Returns the locale which has been set.
	static AppLocale useDeviceLocale() {
		final locale = AppLocaleUtils.findDeviceLocale();
		return setLocale(locale);
	}

	/// Sets locale
	/// Returns the locale which has been set.
	static AppLocale setLocale(AppLocale locale) {
		_currLocale = locale;
		_t = _currLocale.translations;

		// force rebuild if TranslationProvider is used
		_translationProviderKey.currentState?.setLocale(_currLocale);

		return _currLocale;
	}

	/// Sets locale using string tag (e.g. en_US, de-DE, fr)
	/// Fallbacks to base locale.
	/// Returns the locale which has been set.
	static AppLocale setLocaleRaw(String rawLocale) {
		final locale = AppLocaleUtils.parse(rawLocale);
		return setLocale(locale);
	}

	/// Gets current locale.
	static AppLocale get currentLocale {
		return _currLocale;
	}

	/// Gets base locale.
	static AppLocale get baseLocale {
		return _baseLocale;
	}

	/// Gets supported locales in string format.
	static List<String> get supportedLocalesRaw {
		return AppLocale.values
			.map((locale) => locale.languageTag)
			.toList();
	}

	/// Gets supported locales (as Locale objects) with base locale sorted first.
	static List<Locale> get supportedLocales {
		return AppLocale.values
			.map((locale) => locale.flutterLocale)
			.toList();
	}
}

/// Provides utility functions without any side effects.
class AppLocaleUtils {
	AppLocaleUtils._(); // no constructor

	/// Returns the locale of the device as the enum type.
	/// Fallbacks to base locale.
	static AppLocale findDeviceLocale() {
		final String? deviceLocale = WidgetsBinding.instance.window.locale.toLanguageTag();
		if (deviceLocale != null) {
			final typedLocale = _selectLocale(deviceLocale);
			if (typedLocale != null) {
				return typedLocale;
			}
		}
		return _baseLocale;
	}

	/// Returns the enum type of the raw locale.
	/// Fallbacks to base locale.
	static AppLocale parse(String rawLocale) {
		return _selectLocale(rawLocale) ?? _baseLocale;
	}
}

// context enums

// interfaces generated as mixins

// translation instances

late _StringsEn _translationsEn = _StringsEn.build();

// extensions for AppLocale

extension AppLocaleExtensions on AppLocale {

	/// Gets the translation instance managed by this library.
	/// [TranslationProvider] is using this instance.
	/// The plural resolvers are set via [LocaleSettings].
	_StringsEn get translations {
		switch (this) {
			case AppLocale.en: return _translationsEn;
		}
	}

	/// Gets a new translation instance.
	/// [LocaleSettings] has no effect here.
	/// Suitable for dependency injection and unit tests.
	///
	/// Usage:
	/// final t = AppLocale.en.build(); // build
	/// String a = t.my.path; // access
	_StringsEn build() {
		switch (this) {
			case AppLocale.en: return _StringsEn.build();
		}
	}

	String get languageTag {
		switch (this) {
			case AppLocale.en: return 'en';
		}
	}

	Locale get flutterLocale {
		switch (this) {
			case AppLocale.en: return const Locale.fromSubtags(languageCode: 'en');
		}
	}
}

extension StringAppLocaleExtensions on String {
	AppLocale? toAppLocale() {
		switch (this) {
			case 'en': return AppLocale.en;
			default: return null;
		}
	}
}

// wrappers

GlobalKey<_TranslationProviderState> _translationProviderKey = GlobalKey<_TranslationProviderState>();

class TranslationProvider extends StatefulWidget {
	TranslationProvider({required this.child}) : super(key: _translationProviderKey);

	final Widget child;

	@override
	_TranslationProviderState createState() => _TranslationProviderState();

	static _InheritedLocaleData of(BuildContext context) {
		final inheritedWidget = context.dependOnInheritedWidgetOfExactType<_InheritedLocaleData>();
		if (inheritedWidget == null) {
			throw 'Please wrap your app with "TranslationProvider".';
		}
		return inheritedWidget;
	}
}

class _TranslationProviderState extends State<TranslationProvider> {
	AppLocale locale = _currLocale;

	void setLocale(AppLocale newLocale) {
		setState(() {
			locale = newLocale;
		});
	}

	@override
	Widget build(BuildContext context) {
		return _InheritedLocaleData(
			locale: locale,
			child: widget.child,
		);
	}
}

class _InheritedLocaleData extends InheritedWidget {
	final AppLocale locale;
	Locale get flutterLocale => locale.flutterLocale; // shortcut
	final _StringsEn translations; // store translations to avoid switch call

	_InheritedLocaleData({required this.locale, required Widget child})
		: translations = locale.translations, super(child: child);

	@override
	bool updateShouldNotify(_InheritedLocaleData oldWidget) {
		return oldWidget.locale != locale;
	}
}

// pluralization feature not used

// helpers

final _localeRegex = RegExp(r'^([a-z]{2,8})?([_-]([A-Za-z]{4}))?([_-]?([A-Z]{2}|[0-9]{3}))?$');
AppLocale? _selectLocale(String localeRaw) {
	final match = _localeRegex.firstMatch(localeRaw);
	AppLocale? selected;
	if (match != null) {
		final language = match.group(1);
		final country = match.group(5);

		// match exactly
		selected = AppLocale.values
			.cast<AppLocale?>()
			.firstWhere((supported) => supported?.languageTag == localeRaw.replaceAll('_', '-'), orElse: () => null);

		if (selected == null && language != null) {
			// match language
			selected = AppLocale.values
				.cast<AppLocale?>()
				.firstWhere((supported) => supported?.languageTag.startsWith(language) == true, orElse: () => null);
		}

		if (selected == null && country != null) {
			// match country
			selected = AppLocale.values
				.cast<AppLocale?>()
				.firstWhere((supported) => supported?.languageTag.contains(country) == true, orElse: () => null);
		}
	}
	return selected;
}

// translations

// Path: <root>
class _StringsEn {

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_StringsEn.build();

	/// Access flat map
	dynamic operator[](String key) => _flatMap[key];

	// Internal flat map initialized lazily
	late final Map<String, dynamic> _flatMap = _buildFlatMap();

	late final _StringsEn _root = this; // ignore: unused_field

	// Translations
	String get appName => 'Akiflow';
	String get login => 'Login';
	String get typeHere => 'Type here';
	String get dismiss => 'Dismiss';
	String get ok => 'OK';
	late final _StringsOnboardingEn onboarding = _StringsOnboardingEn._(_root);
	late final _StringsBottomBarEn bottomBar = _StringsBottomBarEn._(_root);
	late final _StringsNoticeEn notice = _StringsNoticeEn._(_root);
	late final _StringsSettingsEn settings = _StringsSettingsEn._(_root);
	late final _StringsAddTaskEn addTask = _StringsAddTaskEn._(_root);
	late final _StringsTaskEn task = _StringsTaskEn._(_root);
	late final _StringsErrorsEn errors = _StringsErrorsEn._(_root);
	late final _StringsCalendarEn calendar = _StringsCalendarEn._(_root);
	late final _StringsLinkedContentEn linkedContent = _StringsLinkedContentEn._(_root);
	late final _StringsEditTaskEn editTask = _StringsEditTaskEn._(_root);
	late final _StringsTodayEn today = _StringsTodayEn._(_root);
	String get comingSoon => 'Coming soon';
	String get allTasks => 'All tasks';
}

// Path: onboarding
class _StringsOnboardingEn {
	_StringsOnboardingEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get welcomeToAkiflow => 'Welcome to Akiflow';
	String get login => 'Login';
	String get register => 'Register';
	String get welcomeToAkiflowSubtitle => 'Where your tasks and calendars\nstays together.';
	String get or => 'or';
	String get signInWithGoogle => 'Sign in with Google';
	String get continuingAcceptTermsPrivacy => '<center>Continuing you accept the <a url="https://google.com">Terms and Conditions</a><br/> and the <a url="https://google.com">Privacy Policy</a> of Akiflow</center>';
}

// Path: bottomBar
class _StringsBottomBarEn {
	_StringsBottomBarEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get menu => 'Menu';
	String get inbox => 'Inbox';
	String get today => 'Today';
	String get calendar => 'Calendar';
}

// Path: notice
class _StringsNoticeEn {
	_StringsNoticeEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get inboxTitle => 'Here is where the magic happens';
	String get inboxSubtitle => 'Inbox is where all your new tasks are collected';
}

// Path: settings
class _StringsSettingsEn {
	_StringsSettingsEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get title => 'Settings';
	String get logout => 'Log out';
	String get upgradeToPro => 'Upgrade to pro';
	String get myAccount => 'My account';
	String get general => 'General';
	String get tasks => 'Tasks';
	String get notifications => 'Notifications';
	String get integrations => 'Integrations';
	String get referYourFriends => 'Refer your friends';
	String get helpCenter => 'Help center';
	String get about => 'About';
	String get followUsOnTwitter => 'Follow Us on Twitter';
	String get joinOurCommunity => 'Join our community';
	String get bugReport => 'Bug report';
	String get labels => 'Labels';
}

// Path: addTask
class _StringsAddTaskEn {
	_StringsAddTaskEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get titleHint => 'Try: review financials today 9am';
	String get descriptionHint => 'Description';
	String get plan => 'Plan';
	String get label => 'Label';
	String get snooze => 'Snooze';
	String get today => 'Today';
	String get tmw => 'Tmw';
	String get tomorrow => 'Tomorrow';
	String get nextWeek => 'Next week';
	String get nextWeekend => 'Next weekend';
	String get remove => 'Remove';
	String get laterToday => 'Later today';
	String get noDate => 'No date';
	String get addTime => 'Add time';
	String get repeat => 'Repeat';
	String get folder => 'Folder';
}

// Path: task
class _StringsTaskEn {
	_StringsTaskEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get description => 'Description';
	String get linkedContent => 'Linked content';
	String get today => 'Today';
	String get plan => 'Plan';
	String get done => 'Done';
	String get snooze => 'Snooze';
	String get assign => 'Assign';
	String get priority => 'Priority';
	String get moveToInbox => 'Move to inbox';
	String get planForToday => 'Plan for today';
	String get setDeadline => 'Set Deadline';
	String get duplicate => 'Duplicate';
	String get markAsDone => 'Mark as done';
	String get delete => 'Delete';
	String get noTitle => '(No title)';
	String get snoozeTomorrow => 'Snooze - Tomorrow';
	String get snoozeNextWeek => 'Snooze - Next Week';
	String get someday => 'Someday';
	String get undo => 'Undo';
	String get markedAsDone => 'Marked as done';
	late final _StringsTaskUndoActionsEn undoActions = _StringsTaskUndoActionsEn._(_root);
}

// Path: errors
class _StringsErrorsEn {
	_StringsErrorsEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get noAccountsFound => 'No accounts found';
}

// Path: calendar
class _StringsCalendarEn {
	_StringsCalendarEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get comingSoon => 'Calendar is coming in the near future!';
	String get goToToday => 'Go to Today';
}

// Path: linkedContent
class _StringsLinkedContentEn {
	_StringsLinkedContentEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get subject => 'Subject:';
	String get from => 'From:';
	String get date => 'Date:';
	String get open => 'Open';
	String get parentTask => 'Parent task';
	String get project => 'Project';
	String get workspace => 'Workspace';
	String get title => 'Title';
	String get space => 'Space';
	String get folder => 'Folder';
	String get list => 'List';
	String get created => 'Created';
	String get lastEdit => 'Last edit';
	String get channel => 'Channel';
	String get message => 'Message';
	String get user => 'User';
	String get starredAt => 'Starred at';
	String get dueDate => 'Due date';
	String get board => 'Board';
}

// Path: editTask
class _StringsEditTaskEn {
	_StringsEditTaskEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get add => 'Add';
	String get assignLabel => 'Assign Label';
	String get createOrSearchALabel => 'Create or search a label';
	String get noLabel => 'No label';
	String get deadline => 'Deadline';
	String get repeat => 'Repeat';
	String get noRepeat => 'No Repeat';
	String get everyDay => 'Every Day';
	String everyCurrentDay({required Object day}) => 'Every ${day}';
	String everyFirstCurrentDayOfTheMonth({required Object day}) => 'Every first ${day} of the month';
	String everyYearOn({required Object date}) => 'Every year on ${date}';
	String get everyWeekday => 'Every weekday';
	String get custom => 'Custom';
	String get comingSoon => 'Coming soon';
	late final _StringsEditTaskRepeatingEditDialogEn repeatingEditDialog = _StringsEditTaskRepeatingEditDialogEn._(_root);
}

// Path: today
class _StringsTodayEn {
	_StringsTodayEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get toDos => 'To-dos';
	String get pinnedInCalendar => 'Pinned in calendar';
	String get done => 'Done';
}

// Path: task.undoActions
class _StringsTaskUndoActionsEn {
	_StringsTaskUndoActionsEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get markDone => 'Task marked as done';
	String get markUndone => 'Task marked as undone';
	String get deleted => 'Task deleted';
	String get restored => 'Task restored';
	String get planned => 'Task planned';
	String get snoozed => 'Task snoozed';
	String get movedToInbox => 'Task moved to inbox';
	String get updated => 'Task updated';
}

// Path: editTask.repeatingEditDialog
class _StringsEditTaskRepeatingEditDialogEn {
	_StringsEditTaskRepeatingEditDialogEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get title => 'You are changing a repeating task';
	String get description => 'Do you want to change only this occurrence or change this and all future occurrences?';
	String get onlyThis => 'Only this task';
	String get thisAndAllFuture => 'This and all future tasks';
	String get cancel => 'Cancel';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.

extension on _StringsEn {
	Map<String, dynamic> _buildFlatMap() {
		return <String, dynamic>{
			'appName': 'Akiflow',
			'login': 'Login',
			'typeHere': 'Type here',
			'dismiss': 'Dismiss',
			'ok': 'OK',
			'onboarding.welcomeToAkiflow': 'Welcome to Akiflow',
			'onboarding.login': 'Login',
			'onboarding.register': 'Register',
			'onboarding.welcomeToAkiflowSubtitle': 'Where your tasks and calendars\nstays together.',
			'onboarding.or': 'or',
			'onboarding.signInWithGoogle': 'Sign in with Google',
			'onboarding.continuingAcceptTermsPrivacy': '<center>Continuing you accept the <a url="https://google.com">Terms and Conditions</a><br/> and the <a url="https://google.com">Privacy Policy</a> of Akiflow</center>',
			'bottomBar.menu': 'Menu',
			'bottomBar.inbox': 'Inbox',
			'bottomBar.today': 'Today',
			'bottomBar.calendar': 'Calendar',
			'notice.inboxTitle': 'Here is where the magic happens',
			'notice.inboxSubtitle': 'Inbox is where all your new tasks are collected',
			'settings.title': 'Settings',
			'settings.logout': 'Log out',
			'settings.upgradeToPro': 'Upgrade to pro',
			'settings.myAccount': 'My account',
			'settings.general': 'General',
			'settings.tasks': 'Tasks',
			'settings.notifications': 'Notifications',
			'settings.integrations': 'Integrations',
			'settings.referYourFriends': 'Refer your friends',
			'settings.helpCenter': 'Help center',
			'settings.about': 'About',
			'settings.followUsOnTwitter': 'Follow Us on Twitter',
			'settings.joinOurCommunity': 'Join our community',
			'settings.bugReport': 'Bug report',
			'settings.labels': 'Labels',
			'addTask.titleHint': 'Try: review financials today 9am',
			'addTask.descriptionHint': 'Description',
			'addTask.plan': 'Plan',
			'addTask.label': 'Label',
			'addTask.snooze': 'Snooze',
			'addTask.today': 'Today',
			'addTask.tmw': 'Tmw',
			'addTask.tomorrow': 'Tomorrow',
			'addTask.nextWeek': 'Next week',
			'addTask.nextWeekend': 'Next weekend',
			'addTask.remove': 'Remove',
			'addTask.laterToday': 'Later today',
			'addTask.noDate': 'No date',
			'addTask.addTime': 'Add time',
			'addTask.repeat': 'Repeat',
			'addTask.folder': 'Folder',
			'task.description': 'Description',
			'task.linkedContent': 'Linked content',
			'task.today': 'Today',
			'task.plan': 'Plan',
			'task.done': 'Done',
			'task.snooze': 'Snooze',
			'task.assign': 'Assign',
			'task.priority': 'Priority',
			'task.moveToInbox': 'Move to inbox',
			'task.planForToday': 'Plan for today',
			'task.setDeadline': 'Set Deadline',
			'task.duplicate': 'Duplicate',
			'task.markAsDone': 'Mark as done',
			'task.delete': 'Delete',
			'task.noTitle': '(No title)',
			'task.snoozeTomorrow': 'Snooze - Tomorrow',
			'task.snoozeNextWeek': 'Snooze - Next Week',
			'task.someday': 'Someday',
			'task.undo': 'Undo',
			'task.markedAsDone': 'Marked as done',
			'task.undoActions.markDone': 'Task marked as done',
			'task.undoActions.markUndone': 'Task marked as undone',
			'task.undoActions.deleted': 'Task deleted',
			'task.undoActions.restored': 'Task restored',
			'task.undoActions.planned': 'Task planned',
			'task.undoActions.snoozed': 'Task snoozed',
			'task.undoActions.movedToInbox': 'Task moved to inbox',
			'task.undoActions.updated': 'Task updated',
			'errors.noAccountsFound': 'No accounts found',
			'calendar.comingSoon': 'Calendar is coming in the near future!',
			'calendar.goToToday': 'Go to Today',
			'linkedContent.subject': 'Subject:',
			'linkedContent.from': 'From:',
			'linkedContent.date': 'Date:',
			'linkedContent.open': 'Open',
			'linkedContent.parentTask': 'Parent task',
			'linkedContent.project': 'Project',
			'linkedContent.workspace': 'Workspace',
			'linkedContent.title': 'Title',
			'linkedContent.space': 'Space',
			'linkedContent.folder': 'Folder',
			'linkedContent.list': 'List',
			'linkedContent.created': 'Created',
			'linkedContent.lastEdit': 'Last edit',
			'linkedContent.channel': 'Channel',
			'linkedContent.message': 'Message',
			'linkedContent.user': 'User',
			'linkedContent.starredAt': 'Starred at',
			'linkedContent.dueDate': 'Due date',
			'linkedContent.board': 'Board',
			'editTask.add': 'Add',
			'editTask.assignLabel': 'Assign Label',
			'editTask.createOrSearchALabel': 'Create or search a label',
			'editTask.noLabel': 'No label',
			'editTask.deadline': 'Deadline',
			'editTask.repeat': 'Repeat',
			'editTask.noRepeat': 'No Repeat',
			'editTask.everyDay': 'Every Day',
			'editTask.everyCurrentDay': ({required Object day}) => 'Every ${day}',
			'editTask.everyFirstCurrentDayOfTheMonth': ({required Object day}) => 'Every first ${day} of the month',
			'editTask.everyYearOn': ({required Object date}) => 'Every year on ${date}',
			'editTask.everyWeekday': 'Every weekday',
			'editTask.custom': 'Custom',
			'editTask.comingSoon': 'Coming soon',
			'editTask.repeatingEditDialog.title': 'You are changing a repeating task',
			'editTask.repeatingEditDialog.description': 'Do you want to change only this occurrence or change this and all future occurrences?',
			'editTask.repeatingEditDialog.onlyThis': 'Only this task',
			'editTask.repeatingEditDialog.thisAndAllFuture': 'This and all future tasks',
			'editTask.repeatingEditDialog.cancel': 'Cancel',
			'today.toDos': 'To-dos',
			'today.pinnedInCalendar': 'Pinned in calendar',
			'today.done': 'Done',
			'comingSoon': 'Coming soon',
			'allTasks': 'All tasks',
		};
	}
}
