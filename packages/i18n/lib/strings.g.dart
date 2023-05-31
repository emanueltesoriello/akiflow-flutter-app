
/*
 * Generated file. Do not edit.
 *
 * Locales: 1
 * Strings: 337 
 *
 * Built on 2023-05-23 at 11:45 UTC
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
	late final _StringsExpiryEn expiry = _StringsExpiryEn._(_root);
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
	late final _StringsLabelEn label = _StringsLabelEn._(_root);
	late final _StringsEventEn event = _StringsEventEn._(_root);
	late final _StringsAvailabilityEn availability = _StringsAvailabilityEn._(_root);
	late final _StringsSnackbarEn snackbar = _StringsSnackbarEn._(_root);
	String get confirm => 'Confirm';
	String get cancel => 'Cancel';
	String get noTitle => '(No title)';
	String get connect => 'Connect';
	String get more => 'More';
	String get view => 'View';
	late final _StringsIntegrationsEn integrations = _StringsIntegrationsEn._(_root);
}

// Path: onboarding
class _StringsOnboardingEn {
	_StringsOnboardingEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get welcomeToAkiflow => 'Welcome to Akiflow';
	String get login => 'Login';
	String get register => 'Register';
	String get welcomeToAkiflowSubtitle => 'The journey to improve your productivity starts here.';
	String get or => 'or';
	String get signInWithGoogle => 'Sign in with Google';
	late final _StringsOnboardingTermsAndPrivacyEn termsAndPrivacy = _StringsOnboardingTermsAndPrivacyEn._(_root);
	String get longTapMultipleSelection => 'Long Tap to make multiple selection';
	String get skipAll => 'Skip all';
	String get swipeLeftMoreOption => 'Swipe left to show more options';
	String get swipeMorePlanTask => 'Swipe more to directly plan your task';
	String get swipeRightToMarkAsDone => 'Swipe right to mark a task as done';
	late final _StringsOnboardingGmailEn gmail = _StringsOnboardingGmailEn._(_root);
	String get reconnect => 'Reconnect';
	String get allAccountsConnected => 'All accounts connected';
	String get startAkiflow => 'Start Akiflow';
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

// Path: expiry
class _StringsExpiryEn {
	_StringsExpiryEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get or => 'or ';
	String get logout => 'Log out ';
	String get title => 'Your Free Trial has Expired';
	String get description => 'Upgrade your plan to pick up where you left off.';
	String get button => 'Upgrade your plan';
	String get alternate => 'and delete all data.';
}

// Path: settings
class _StringsSettingsEn {
	_StringsSettingsEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get title => 'Settings';
	String get upgradeToPro => 'Upgrade to pro';
	String get general => 'General';
	String get tasks => 'Tasks';
	String get notifications => 'Notifications';
	String get referYourFriends => 'Refer your friends';
	String get helpCenter => 'Help center';
	String get followUsOnTwitter => 'Follow Us on Twitter';
	String get joinOurCommunity => 'Join our community';
	String get labels => 'Labels';
	String get searchComingSoon => 'Search is coming soon in the near future!';
	String get changeLog => 'Change log';
	String get chatWithUs => 'Chat with us';
	String get sendUsAnEmail => 'Send us an Email';
	late final _StringsSettingsMyAccountEn myAccount = _StringsSettingsMyAccountEn._(_root);
	late final _StringsSettingsAboutEn about = _StringsSettingsAboutEn._(_root);
	late final _StringsSettingsLearnAkiflowEn learnAkiflow = _StringsSettingsLearnAkiflowEn._(_root);
	late final _StringsSettingsIntegrationsEn integrations = _StringsSettingsIntegrationsEn._(_root);
	String get connected => 'Connected';
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
	String get snoozed => 'Snoozed';
	String get assign => 'Assign';
	late final _StringsTaskPriorityEn priority = _StringsTaskPriorityEn._(_root);
	String get moveToInbox => 'Move to inbox';
	String get planForToday => 'Plan for today';
	String get setDeadline => 'Set Deadline';
	String get duplicate => 'Duplicate';
	String get markAsDone => 'Mark as done';
	String get delete => 'Delete';
	String get snoozeTomorrow => 'Snooze - Tomorrow';
	String get snoozeNextWeek => 'Snooze - Next Week';
	String get someday => 'Someday';
	String get undo => 'Undo';
	String get markedAsDone => 'Marked as done';
	late final _StringsTaskUndoActionsEn undoActions = _StringsTaskUndoActionsEn._(_root);
	String get sort => 'Sort';
	String get filter => 'Filter';
	late final _StringsTaskLinksEn links = _StringsTaskLinksEn._(_root);
	String get taskCreatedSuccessfully => 'Task created successfully';
	String nSelected({required Object count}) => '$count selected';
	String get yesterday => 'Yesterday';
	String get awesomeInboxZero => 'Awesome! You reached Inbox Zero!';
	late final _StringsTaskGmailEn gmail = _StringsTaskGmailEn._(_root);
	String get onboardingTitle => 'Hello I am a task 👋';
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
	String get calendarView => 'Calendar View';
	late final _StringsCalendarViewEn view = _StringsCalendarViewEn._(_root);
	String get groupOverlappingTasks => 'Group overlapping tasks';
	String get hideWeekends => 'Hide Weekends';
	String get hideDeclinedEvents => 'Hide Declined events';
	String get hideTasksFromCalendar => 'Hide Tasks from calendar';
	String get calendars => 'Calendars';
	String get refresh => 'Refresh';
}

// Path: linkedContent
class _StringsLinkedContentEn {
	_StringsLinkedContentEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get subject => 'Subject';
	String get from => 'From';
	String get date => 'Date';
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
	String get savedOn => 'Saved on';
	String get status => 'Status';
	String get done => 'Done';
	String get toDo => 'To do';
	String get section => 'Section';
	String get scheduledDate => 'Scheduled Date';
	String get duration => 'Duration';
	String get team => 'Team';
}

// Path: editTask
class _StringsEditTaskEn {
	_StringsEditTaskEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get add => 'Add';
	String get assignLabel => 'Assign Label';
	String get searchALabel => 'Search a label';
	String get noLabel => 'No label';
	String get addLabel => 'Add label';
	String get removeLabel => 'Remove label';
	String get deadline => 'Deadline';
	String get repeat => 'Repeat';
	String get noRepeat => 'No Repeat';
	String get everyDay => 'Every Day';
	String everyCurrentDay({required Object day}) => 'Every ${day}';
	String everyFirstCurrentDayOfTheMonth({required Object day}) => 'Every first ${day} of the month';
	String everyYearOn({required Object date}) => 'Every year on ${date}';
	String everyMonthOn({required Object date}) => 'Every month on ${date}';
	String get everyLastDayOfTheMonth => 'Every last day of the month';
	String get everyWeekday => 'Every weekday';
	String get custom => 'Custom';
	String get comingSoon => 'Coming soon';
	late final _StringsEditTaskRepeatingEditDialogEn repeatingEditDialog = _StringsEditTaskRepeatingEditDialogEn._(_root);
	late final _StringsEditTaskRecurrenceEn recurrence = _StringsEditTaskRecurrenceEn._(_root);
}

// Path: today
class _StringsTodayEn {
	_StringsTodayEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get title => 'Today';
	String get toDos => 'To-dos';
	String get pinnedInCalendar => 'Scheduled on calendar';
	String get done => 'Done';
}

// Path: label
class _StringsLabelEn {
	_StringsLabelEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get addLabel => 'Add Label';
	String get addFolder => 'Add Folder';
	String get createLabel => 'Create Label';
	String get save => 'Save';
	String get noFolder => 'No Folder';
	String get color => 'Color';
	String get folder => 'Folder';
	String get createFolder => 'Create Folder';
	String get editLabel => 'Edit Label';
	String get order => 'Order';
	String get newSection => 'New Section';
	String get showDone => 'Show Done';
	String get deleteLabel => 'Delete Label';
	String get hideDone => 'Hide Done';
	String get createSection => 'Create Section';
	String get sectionTitle => 'Section Title';
	String get addTask => 'Add Task';
	String get rename => 'Rename';
	String get delete => 'Delete';
	String get hideSnoozed => 'Hide Snoozed';
	String get hideSomeday => 'Hide Someday';
	late final _StringsLabelDeleteDialogEn deleteDialog = _StringsLabelDeleteDialogEn._(_root);
	String get sortComingSoon => 'Sort (Coming soon)';
}

// Path: event
class _StringsEventEn {
	_StringsEventEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get googleMeet => 'Google Meet';
	String get zoom => 'Zoom';
	String get join => 'Join';
	String get busy => 'Busy';
	String get conference => 'Conference';
	String get guests => 'Guests';
	String get organizer => 'Organizer';
	String get going => 'Going?';
	String get yes => 'Yes';
	String get no => 'No';
	String get maybe => 'Maybe';
	String get copy => 'Copy';
	String get share => 'Share';
	String get mailGuests => 'Mail Guests';
	String get edit => 'Edit';
	String get delete => 'Delete';
	late final _StringsEventEditEventEn editEvent = _StringsEventEditEventEn._(_root);
	late final _StringsEventSnackbarEn snackbar = _StringsEventSnackbarEn._(_root);
}

// Path: availability
class _StringsAvailabilityEn {
	_StringsAvailabilityEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get availabilities => 'Availabilities';
	String get shareAvailabilities => 'Share availabilities';
	String get activeRecurrentSlots => 'Recurrent slots';
	String get activeManualSlots => 'Active manual slots';
	String get noActiveLinksToShow => 'No active links to show';
	String get toCreateLinkUseDesktop => 'To create a link use the desktop app';
	String get linkCopiedToClipboard => 'Link copied to clipboard!';
}

// Path: snackbar
class _StringsSnackbarEn {
	_StringsSnackbarEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get connectedSuccesfully => 'Connected successfully!';
	String get cannotMoveThisEvent => 'You cannot move this event!';
	String get copiedToYourClipboard => 'Copied to your clipboard';
}

// Path: integrations
class _StringsIntegrationsEn {
	_StringsIntegrationsEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get todoist => 'Todoist';
	String get slack => 'Slack';
}

// Path: onboarding.termsAndPrivacy
class _StringsOnboardingTermsAndPrivacyEn {
	_StringsOnboardingTermsAndPrivacyEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get continuingYouAcceptThe => 'Continuing you accept the ';
	String get termsAndConditions => 'Terms and Conditions';
	String get andThe => ' and the ';
	String get privacyPolicy => 'Privacy Policy';
	String get ofAkiflow => ' of Akiflow';
}

// Path: onboarding.gmail
class _StringsOnboardingGmailEn {
	_StringsOnboardingGmailEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get skipForNow => 'Skip for now';
	String get reconnectGmailAccount => 'Reconnect Gmail account';
}

// Path: settings.myAccount
class _StringsSettingsMyAccountEn {
	_StringsSettingsMyAccountEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get title => 'My account';
	String get connectedAs => 'Connected as';
	String get manageAccount => 'Manage account';
	String get manageSubscriptionAndBillingPreferences => 'Manage subscription & billing preferences';
	String get logout => 'Log out';
}

// Path: settings.about
class _StringsSettingsAboutEn {
	_StringsSettingsAboutEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get title => 'About';
	String get version => 'Version';
	String get legal => 'Legal';
	String get licensesInfo => 'Licenses Info';
	String get security => 'Security';
}

// Path: settings.learnAkiflow
class _StringsSettingsLearnAkiflowEn {
	_StringsSettingsLearnAkiflowEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get title => 'Learn Akiflow';
	String get useGuide => 'Use guide';
}

// Path: settings.integrations
class _StringsSettingsIntegrationsEn {
	_StringsSettingsIntegrationsEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get title => 'Integrations';
	String get connected => 'Connected';
	late final _StringsSettingsIntegrationsGmailEn gmail = _StringsSettingsIntegrationsGmailEn._(_root);
	late final _StringsSettingsIntegrationsSlackEn slack = _StringsSettingsIntegrationsSlackEn._(_root);
	late final _StringsSettingsIntegrationsCalendarEn calendar = _StringsSettingsIntegrationsCalendarEn._(_root);
}

// Path: task.priority
class _StringsTaskPriorityEn {
	_StringsTaskPriorityEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get title => 'Priority';
	String get high => 'High';
	String get medium => 'Medium';
	String get low => 'Low';
	String get noPriority => 'No priority';
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

// Path: task.links
class _StringsTaskLinksEn {
	_StringsTaskLinksEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get links => 'links';
	String get addLink => 'Add link';
}

// Path: task.gmail
class _StringsTaskGmailEn {
	_StringsTaskGmailEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get doYouAlsoWantTo => 'Do you also want to unstar the email on Gmail?';
	String get unstarTheEmail => 'Unstar the email';
	String get goToGmail => 'Go to Gmail';
	String get doNothing => 'Do nothing';
	String get unlabelTheEmail => 'Unlabel the email';
}

// Path: calendar.view
class _StringsCalendarViewEn {
	_StringsCalendarViewEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get agenda => 'Agenda';
	String get oneDay => '1 Day';
	String get threeDays => '3 Days';
	String get week => 'Week';
	String get month => 'Month';
}

// Path: editTask.repeatingEditDialog
class _StringsEditTaskRepeatingEditDialogEn {
	_StringsEditTaskRepeatingEditDialogEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get title => 'Editing repeating task';
	String get description => 'Do you want to change only this occurrence or change this and all future occurrences?';
	String get onlyThis => 'Only this task';
	String get thisAndAllFuture => 'This and all future tasks';
}

// Path: editTask.recurrence
class _StringsEditTaskRecurrenceEn {
	_StringsEditTaskRecurrenceEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get every => 'Every';
	String get day => 'Day';
	String get days => 'Day(s)';
	String get week => 'Week';
	String get weeks => 'Week(s)';
	String get month => 'Month';
	String get months => 'Month(s)';
	String get year => 'Year';
	String get years => 'Year(s)';
	String get selectedDays => 'Selected days';
	String get ends => 'Ends';
	String get never => 'Never';
	String get until => 'Until';
	String get repeatUntil => 'Repeat until';
	String get after => 'After';
	String get repeatEvery => 'Repeat every';
	String get times => 'time(s)';
}

// Path: label.deleteDialog
class _StringsLabelDeleteDialogEn {
	_StringsLabelDeleteDialogEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String title({required Object labelTitle}) => 'You are deleting ${labelTitle}';
	String get description => 'What do you want to do with the tasks assigned to this label?';
	String get justDeleteTheLabel => 'Just delete the label';
	String get markAllTasksAsDone => 'Mark all tasks as Done';
}

// Path: event.editEvent
class _StringsEventEditEventEn {
	_StringsEventEditEventEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get addTitle => 'Add title';
	String get allDay => 'All Day';
	String get addConference => 'Add Conference';
	String get addLocation => 'Add Location';
	String get chooseCalendar => 'Choose Calendar';
	String get addGuests => 'Add guests';
	String get addDescription => 'Add Description';
	String get defaultColor => 'Default Color';
	String get customColor => 'Custom color';
	String get eventColor => 'Event color';
	String get viewOnGoogleCalendar => 'View on Google Calendar';
	String get createEvent => 'Create event';
	String get saveChanges => 'Save Changes';
	late final _StringsEventEditEventRepeatingEditModalEn repeatingEditModal = _StringsEventEditEventRepeatingEditModalEn._(_root);
	late final _StringsEventEditEventDeleteModalEn deleteModal = _StringsEventEditEventDeleteModalEn._(_root);
	late final _StringsEventEditEventRecurrenceEn recurrence = _StringsEventEditEventRecurrenceEn._(_root);
	late final _StringsEventEditEventAddGuestModalEn addGuestModal = _StringsEventEditEventAddGuestModalEn._(_root);
	late final _StringsEventEditEventAddLocationModalEn addLocationModal = _StringsEventEditEventAddLocationModalEn._(_root);
}

// Path: event.snackbar
class _StringsEventSnackbarEn {
	_StringsEventSnackbarEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get created => 'Event created successfully';
	String get edited => 'Event updated successfully';
	String get deleted => 'Event has been deleted';
}

// Path: settings.integrations.gmail
class _StringsSettingsIntegrationsGmailEn {
	_StringsSettingsIntegrationsGmailEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get title => 'Gmail';
	String get description => 'Communication';
	late final _StringsSettingsIntegrationsGmailStep1En step1 = _StringsSettingsIntegrationsGmailStep1En._(_root);
	String get step2 => 'Check your new task in your Akiflow Inbox';
	String get importOptions => 'Import options';
	String get useAkiflowLabel => 'Use Akiflow label';
	String get star => 'Star';
	String get behavior => 'Behavior';
	String get communication => 'Communication';
	late final _StringsSettingsIntegrationsGmailOnMarkAsDoneEn onMarkAsDone = _StringsSettingsIntegrationsGmailOnMarkAsDoneEn._(_root);
	late final _StringsSettingsIntegrationsGmailToImportTaskEn toImportTask = _StringsSettingsIntegrationsGmailToImportTaskEn._(_root);
	String get clientSettings => 'Client settings';
	String get useSuperhuman => 'Use superhuman';
	String get openYourEmailsInSuperhumanInsteadOfGmail => 'Open your emails in superhuman instead of Gmail';
}

// Path: settings.integrations.slack
class _StringsSettingsIntegrationsSlackEn {
	_StringsSettingsIntegrationsSlackEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get title => 'Slack';
}

// Path: settings.integrations.calendar
class _StringsSettingsIntegrationsCalendarEn {
	_StringsSettingsIntegrationsCalendarEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get title => 'Google Calendar';
}

// Path: event.editEvent.repeatingEditModal
class _StringsEventEditEventRepeatingEditModalEn {
	_StringsEventEditEventRepeatingEditModalEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get title => 'Editing repeating event';
	String get deleteTitle => 'You are deleting a recurrent event';
	String get description => 'Do you want to change only this occurrence or change this and all future occurrences?';
	String get deleteDescription => 'Do you want to delete only this occurrence or delete this and all future occurrences?';
	String get onlyThis => 'Only this event';
	String get thisAndAllFuture => 'This and all future events';
	String get allEvents => 'All events';
}

// Path: event.editEvent.deleteModal
class _StringsEventEditEventDeleteModalEn {
	_StringsEventEditEventDeleteModalEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String title({required Object eventName}) => 'Are you sure you want to delete ${eventName}';
	String get description => 'You can\'t undo this action!';
}

// Path: event.editEvent.recurrence
class _StringsEventEditEventRecurrenceEn {
	_StringsEventEditEventRecurrenceEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get noRepeat => 'No repeat';
	String get setRepeat => 'Set Repeat';
	String get everyDay => 'Every day';
	String get everyWeekday => 'Every weekday';
	String get custom => 'Custom';
}

// Path: event.editEvent.addGuestModal
class _StringsEventEditEventAddGuestModalEn {
	_StringsEventEditEventAddGuestModalEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get addGuest => 'Add guest';
	String get searchContact => 'Search contact';
}

// Path: event.editEvent.addLocationModal
class _StringsEventEditEventAddLocationModalEn {
	_StringsEventEditEventAddLocationModalEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get addLocation => 'Add Location';
	String get search => 'Search';
}

// Path: settings.integrations.gmail.step1
class _StringsSettingsIntegrationsGmailStep1En {
	_StringsSettingsIntegrationsGmailStep1En._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get t1 => 'Star an email or activate the ';
	String get t2 => 'Akiflow label';
	String get t3 => ' on Gmail.';
}

// Path: settings.integrations.gmail.onMarkAsDone
class _StringsSettingsIntegrationsGmailOnMarkAsDoneEn {
	_StringsSettingsIntegrationsGmailOnMarkAsDoneEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get title => 'On mark as done';
	String get unstarTheEmail => 'Unstar the email';
	String get unlabelTheEmail => 'Unlabel the email';
	String get goToGmail => 'Go to Gmail';
	String get doNothing => 'Do nothing';
	String get askMeEveryTime => 'Ask me every time';
}

// Path: settings.integrations.gmail.toImportTask
class _StringsSettingsIntegrationsGmailToImportTaskEn {
	_StringsSettingsIntegrationsGmailToImportTaskEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get title => 'To import tasks';
	String get useAkiflowLabel => 'Use Akiflow label';
	String get useStarToImport => 'Use star to import';
	String get doNothing => 'Do nothing';
	String get askMeEveryTime => 'Ask me every time';
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
			'onboarding.welcomeToAkiflowSubtitle': 'The journey to improve your productivity starts here.',
			'onboarding.or': 'or',
			'onboarding.signInWithGoogle': 'Sign in with Google',
			'onboarding.termsAndPrivacy.continuingYouAcceptThe': 'Continuing you accept the ',
			'onboarding.termsAndPrivacy.termsAndConditions': 'Terms and Conditions',
			'onboarding.termsAndPrivacy.andThe': ' and the ',
			'onboarding.termsAndPrivacy.privacyPolicy': 'Privacy Policy',
			'onboarding.termsAndPrivacy.ofAkiflow': ' of Akiflow',
			'onboarding.longTapMultipleSelection': 'Long Tap to make multiple selection',
			'onboarding.skipAll': 'Skip all',
			'onboarding.swipeLeftMoreOption': 'Swipe left to show more options',
			'onboarding.swipeMorePlanTask': 'Swipe more to directly plan your task',
			'onboarding.swipeRightToMarkAsDone': 'Swipe right to mark a task as done',
			'onboarding.gmail.skipForNow': 'Skip for now',
			'onboarding.gmail.reconnectGmailAccount': 'Reconnect Gmail account',
			'onboarding.reconnect': 'Reconnect',
			'onboarding.allAccountsConnected': 'All accounts connected',
			'onboarding.startAkiflow': 'Start Akiflow',
			'bottomBar.menu': 'Menu',
			'bottomBar.inbox': 'Inbox',
			'bottomBar.today': 'Today',
			'bottomBar.calendar': 'Calendar',
			'notice.inboxTitle': 'Here is where the magic happens',
			'notice.inboxSubtitle': 'Inbox is where all your new tasks are collected',
			'expiry.or': 'or ',
			'expiry.logout': 'Log out ',
			'expiry.title': 'Your Free Trial has Expired',
			'expiry.description': 'Upgrade your plan to pick up where you left off.',
			'expiry.button': 'Upgrade your plan',
			'expiry.alternate': 'and delete all data.',
			'settings.title': 'Settings',
			'settings.upgradeToPro': 'Upgrade to pro',
			'settings.general': 'General',
			'settings.tasks': 'Tasks',
			'settings.notifications': 'Notifications',
			'settings.referYourFriends': 'Refer your friends',
			'settings.helpCenter': 'Help center',
			'settings.followUsOnTwitter': 'Follow Us on Twitter',
			'settings.joinOurCommunity': 'Join our community',
			'settings.labels': 'Labels',
			'settings.searchComingSoon': 'Search is coming soon in the near future!',
			'settings.changeLog': 'Change log',
			'settings.chatWithUs': 'Chat with us',
			'settings.sendUsAnEmail': 'Send us an Email',
			'settings.myAccount.title': 'My account',
			'settings.myAccount.connectedAs': 'Connected as',
			'settings.myAccount.manageAccount': 'Manage account',
			'settings.myAccount.manageSubscriptionAndBillingPreferences': 'Manage subscription & billing preferences',
			'settings.myAccount.logout': 'Log out',
			'settings.about.title': 'About',
			'settings.about.version': 'Version',
			'settings.about.legal': 'Legal',
			'settings.about.licensesInfo': 'Licenses Info',
			'settings.about.security': 'Security',
			'settings.learnAkiflow.title': 'Learn Akiflow',
			'settings.learnAkiflow.useGuide': 'Use guide',
			'settings.integrations.title': 'Integrations',
			'settings.integrations.connected': 'Connected',
			'settings.integrations.gmail.title': 'Gmail',
			'settings.integrations.gmail.description': 'Communication',
			'settings.integrations.gmail.step1.t1': 'Star an email or activate the ',
			'settings.integrations.gmail.step1.t2': 'Akiflow label',
			'settings.integrations.gmail.step1.t3': ' on Gmail.',
			'settings.integrations.gmail.step2': 'Check your new task in your Akiflow Inbox',
			'settings.integrations.gmail.importOptions': 'Import options',
			'settings.integrations.gmail.useAkiflowLabel': 'Use Akiflow label',
			'settings.integrations.gmail.star': 'Star',
			'settings.integrations.gmail.behavior': 'Behavior',
			'settings.integrations.gmail.communication': 'Communication',
			'settings.integrations.gmail.onMarkAsDone.title': 'On mark as done',
			'settings.integrations.gmail.onMarkAsDone.unstarTheEmail': 'Unstar the email',
			'settings.integrations.gmail.onMarkAsDone.unlabelTheEmail': 'Unlabel the email',
			'settings.integrations.gmail.onMarkAsDone.goToGmail': 'Go to Gmail',
			'settings.integrations.gmail.onMarkAsDone.doNothing': 'Do nothing',
			'settings.integrations.gmail.onMarkAsDone.askMeEveryTime': 'Ask me every time',
			'settings.integrations.gmail.toImportTask.title': 'To import tasks',
			'settings.integrations.gmail.toImportTask.useAkiflowLabel': 'Use Akiflow label',
			'settings.integrations.gmail.toImportTask.useStarToImport': 'Use star to import',
			'settings.integrations.gmail.toImportTask.doNothing': 'Do nothing',
			'settings.integrations.gmail.toImportTask.askMeEveryTime': 'Ask me every time',
			'settings.integrations.gmail.clientSettings': 'Client settings',
			'settings.integrations.gmail.useSuperhuman': 'Use superhuman',
			'settings.integrations.gmail.openYourEmailsInSuperhumanInsteadOfGmail': 'Open your emails in superhuman instead of Gmail',
			'settings.integrations.slack.title': 'Slack',
			'settings.integrations.calendar.title': 'Google Calendar',
			'settings.connected': 'Connected',
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
			'task.snoozed': 'Snoozed',
			'task.assign': 'Assign',
			'task.priority.title': 'Priority',
			'task.priority.high': 'High',
			'task.priority.medium': 'Medium',
			'task.priority.low': 'Low',
			'task.priority.noPriority': 'No priority',
			'task.moveToInbox': 'Move to inbox',
			'task.planForToday': 'Plan for today',
			'task.setDeadline': 'Set Deadline',
			'task.duplicate': 'Duplicate',
			'task.markAsDone': 'Mark as done',
			'task.delete': 'Delete',
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
			'task.sort': 'Sort',
			'task.filter': 'Filter',
			'task.links.links': 'links',
			'task.links.addLink': 'Add link',
			'task.taskCreatedSuccessfully': 'Task created successfully',
			'task.nSelected': ({required Object count}) => '$count selected',
			'task.yesterday': 'Yesterday',
			'task.awesomeInboxZero': 'Awesome! You reached Inbox Zero!',
			'task.gmail.doYouAlsoWantTo': 'Do you also want to unstar the email on Gmail?',
			'task.gmail.unstarTheEmail': 'Unstar the email',
			'task.gmail.goToGmail': 'Go to Gmail',
			'task.gmail.doNothing': 'Do nothing',
			'task.gmail.unlabelTheEmail': 'Unlabel the email',
			'task.onboardingTitle': 'Hello I am a task 👋',
			'errors.noAccountsFound': 'No accounts found',
			'calendar.comingSoon': 'Calendar is coming in the near future!',
			'calendar.goToToday': 'Go to Today',
			'calendar.calendarView': 'Calendar View',
			'calendar.view.agenda': 'Agenda',
			'calendar.view.oneDay': '1 Day',
			'calendar.view.threeDays': '3 Days',
			'calendar.view.week': 'Week',
			'calendar.view.month': 'Month',
			'calendar.groupOverlappingTasks': 'Group overlapping tasks',
			'calendar.hideWeekends': 'Hide Weekends',
			'calendar.hideDeclinedEvents': 'Hide Declined events',
			'calendar.hideTasksFromCalendar': 'Hide Tasks from calendar',
			'calendar.calendars': 'Calendars',
			'calendar.refresh': 'Refresh',
			'linkedContent.subject': 'Subject',
			'linkedContent.from': 'From',
			'linkedContent.date': 'Date',
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
			'linkedContent.savedOn': 'Saved on',
			'linkedContent.status': 'Status',
			'linkedContent.done': 'Done',
			'linkedContent.toDo': 'To do',
			'linkedContent.section': 'Section',
			'linkedContent.scheduledDate': 'Scheduled Date',
			'linkedContent.duration': 'Duration',
			'linkedContent.team': 'Team',
			'editTask.add': 'Add',
			'editTask.assignLabel': 'Assign Label',
			'editTask.searchALabel': 'Search a label',
			'editTask.noLabel': 'No label',
			'editTask.addLabel': 'Add label',
			'editTask.removeLabel': 'Remove label',
			'editTask.deadline': 'Deadline',
			'editTask.repeat': 'Repeat',
			'editTask.noRepeat': 'No Repeat',
			'editTask.everyDay': 'Every Day',
			'editTask.everyCurrentDay': ({required Object day}) => 'Every ${day}',
			'editTask.everyFirstCurrentDayOfTheMonth': ({required Object day}) => 'Every first ${day} of the month',
			'editTask.everyYearOn': ({required Object date}) => 'Every year on ${date}',
			'editTask.everyMonthOn': ({required Object date}) => 'Every month on ${date}',
			'editTask.everyLastDayOfTheMonth': 'Every last day of the month',
			'editTask.everyWeekday': 'Every weekday',
			'editTask.custom': 'Custom',
			'editTask.comingSoon': 'Coming soon',
			'editTask.repeatingEditDialog.title': 'Editing repeating task',
			'editTask.repeatingEditDialog.description': 'Do you want to change only this occurrence or change this and all future occurrences?',
			'editTask.repeatingEditDialog.onlyThis': 'Only this task',
			'editTask.repeatingEditDialog.thisAndAllFuture': 'This and all future tasks',
			'editTask.recurrence.every': 'Every',
			'editTask.recurrence.day': 'Day',
			'editTask.recurrence.days': 'Day(s)',
			'editTask.recurrence.week': 'Week',
			'editTask.recurrence.weeks': 'Week(s)',
			'editTask.recurrence.month': 'Month',
			'editTask.recurrence.months': 'Month(s)',
			'editTask.recurrence.year': 'Year',
			'editTask.recurrence.years': 'Year(s)',
			'editTask.recurrence.selectedDays': 'Selected days',
			'editTask.recurrence.ends': 'Ends',
			'editTask.recurrence.never': 'Never',
			'editTask.recurrence.until': 'Until',
			'editTask.recurrence.repeatUntil': 'Repeat until',
			'editTask.recurrence.after': 'After',
			'editTask.recurrence.repeatEvery': 'Repeat every',
			'editTask.recurrence.times': 'time(s)',
			'today.title': 'Today',
			'today.toDos': 'To-dos',
			'today.pinnedInCalendar': 'Scheduled on calendar',
			'today.done': 'Done',
			'comingSoon': 'Coming soon',
			'allTasks': 'All tasks',
			'label.addLabel': 'Add Label',
			'label.addFolder': 'Add Folder',
			'label.createLabel': 'Create Label',
			'label.save': 'Save',
			'label.noFolder': 'No Folder',
			'label.color': 'Color',
			'label.folder': 'Folder',
			'label.createFolder': 'Create Folder',
			'label.editLabel': 'Edit Label',
			'label.order': 'Order',
			'label.newSection': 'New Section',
			'label.showDone': 'Show Done',
			'label.deleteLabel': 'Delete Label',
			'label.hideDone': 'Hide Done',
			'label.createSection': 'Create Section',
			'label.sectionTitle': 'Section Title',
			'label.addTask': 'Add Task',
			'label.rename': 'Rename',
			'label.delete': 'Delete',
			'label.hideSnoozed': 'Hide Snoozed',
			'label.hideSomeday': 'Hide Someday',
			'label.deleteDialog.title': ({required Object labelTitle}) => 'You are deleting ${labelTitle}',
			'label.deleteDialog.description': 'What do you want to do with the tasks assigned to this label?',
			'label.deleteDialog.justDeleteTheLabel': 'Just delete the label',
			'label.deleteDialog.markAllTasksAsDone': 'Mark all tasks as Done',
			'label.sortComingSoon': 'Sort (Coming soon)',
			'event.googleMeet': 'Google Meet',
			'event.zoom': 'Zoom',
			'event.join': 'Join',
			'event.busy': 'Busy',
			'event.conference': 'Conference',
			'event.guests': 'Guests',
			'event.organizer': 'Organizer',
			'event.going': 'Going?',
			'event.yes': 'Yes',
			'event.no': 'No',
			'event.maybe': 'Maybe',
			'event.copy': 'Copy',
			'event.share': 'Share',
			'event.mailGuests': 'Mail Guests',
			'event.edit': 'Edit',
			'event.delete': 'Delete',
			'event.editEvent.addTitle': 'Add title',
			'event.editEvent.allDay': 'All Day',
			'event.editEvent.addConference': 'Add Conference',
			'event.editEvent.addLocation': 'Add Location',
			'event.editEvent.chooseCalendar': 'Choose Calendar',
			'event.editEvent.addGuests': 'Add guests',
			'event.editEvent.addDescription': 'Add Description',
			'event.editEvent.defaultColor': 'Default Color',
			'event.editEvent.customColor': 'Custom color',
			'event.editEvent.eventColor': 'Event color',
			'event.editEvent.viewOnGoogleCalendar': 'View on Google Calendar',
			'event.editEvent.createEvent': 'Create event',
			'event.editEvent.saveChanges': 'Save Changes',
			'event.editEvent.repeatingEditModal.title': 'Editing repeating event',
			'event.editEvent.repeatingEditModal.deleteTitle': 'You are deleting a recurrent event',
			'event.editEvent.repeatingEditModal.description': 'Do you want to change only this occurrence or change this and all future occurrences?',
			'event.editEvent.repeatingEditModal.deleteDescription': 'Do you want to delete only this occurrence or delete this and all future occurrences?',
			'event.editEvent.repeatingEditModal.onlyThis': 'Only this event',
			'event.editEvent.repeatingEditModal.thisAndAllFuture': 'This and all future events',
			'event.editEvent.repeatingEditModal.allEvents': 'All events',
			'event.editEvent.deleteModal.title': ({required Object eventName}) => 'Are you sure you want to delete ${eventName}',
			'event.editEvent.deleteModal.description': 'You can\'t undo this action!',
			'event.editEvent.recurrence.noRepeat': 'No repeat',
			'event.editEvent.recurrence.setRepeat': 'Set Repeat',
			'event.editEvent.recurrence.everyDay': 'Every day',
			'event.editEvent.recurrence.everyWeekday': 'Every weekday',
			'event.editEvent.recurrence.custom': 'Custom',
			'event.editEvent.addGuestModal.addGuest': 'Add guest',
			'event.editEvent.addGuestModal.searchContact': 'Search contact',
			'event.editEvent.addLocationModal.addLocation': 'Add Location',
			'event.editEvent.addLocationModal.search': 'Search',
			'event.snackbar.created': 'Event created successfully',
			'event.snackbar.edited': 'Event updated successfully',
			'event.snackbar.deleted': 'Event has been deleted',
			'availability.availabilities': 'Availabilities',
			'availability.shareAvailabilities': 'Share availabilities',
			'availability.activeRecurrentSlots': 'Recurrent slots',
			'availability.activeManualSlots': 'Active manual slots',
			'availability.noActiveLinksToShow': 'No active links to show',
			'availability.toCreateLinkUseDesktop': 'To create a link use the desktop app',
			'availability.linkCopiedToClipboard': 'Link copied to clipboard!',
			'snackbar.connectedSuccesfully': 'Connected successfully!',
			'snackbar.cannotMoveThisEvent': 'You cannot move this event!',
			'snackbar.copiedToYourClipboard': 'Copied to your clipboard',
			'confirm': 'Confirm',
			'cancel': 'Cancel',
			'noTitle': '(No title)',
			'connect': 'Connect',
			'more': 'More',
			'view': 'View',
			'integrations.todoist': 'Todoist',
			'integrations.slack': 'Slack',
		};
	}
}
