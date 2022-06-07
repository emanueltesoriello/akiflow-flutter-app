
/*
 * Generated file. Do not edit.
 *
 * Locales: 1
 * Strings: 210 
 *
 * Built on 2022-06-07 at 10:21 UTC
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
	late final _StringsLabelEn label = _StringsLabelEn._(_root);
	String get cancel => 'Cancel';
	String get noTitle => '(No title)';
	String get connect => 'Connect';
	String get more => 'More';
	String get view => 'View';
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
	String get upgradeToPro => 'Upgrade to pro';
	String get general => 'General';
	String get tasks => 'Tasks';
	String get notifications => 'Notifications';
	String get referYourFriends => 'Refer your friends';
	String get helpCenter => 'Help center';
	String get followUsOnTwitter => 'Follow Us on Twitter';
	String get joinOurCommunity => 'Join our community';
	String get bugReport => 'Bug report';
	String get labels => 'Labels';
	String get searchComingSoon => 'Search is coming soon in the near future!';
	String get changeLog => 'Change log';
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
	late final _StringsTaskLinkEn link = _StringsTaskLinkEn._(_root);
	String get taskCreatedSuccessfully => 'Task created successfully';
	String nSelected({required Object count}) => '$count selected';
	String get yesterday => 'Yesterday';
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
	String get removeLabel => 'Remove label';
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
	String get title => 'Today';
	String get toDos => 'To-dos';
	String get pinnedInCalendar => 'Pinned in calendar';
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

// Path: task.link
class _StringsTaskLinkEn {
	_StringsTaskLinkEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get addLink => 'Add link';
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
			'bottomBar.menu': 'Menu',
			'bottomBar.inbox': 'Inbox',
			'bottomBar.today': 'Today',
			'bottomBar.calendar': 'Calendar',
			'notice.inboxTitle': 'Here is where the magic happens',
			'notice.inboxSubtitle': 'Inbox is where all your new tasks are collected',
			'settings.title': 'Settings',
			'settings.upgradeToPro': 'Upgrade to pro',
			'settings.general': 'General',
			'settings.tasks': 'Tasks',
			'settings.notifications': 'Notifications',
			'settings.referYourFriends': 'Refer your friends',
			'settings.helpCenter': 'Help center',
			'settings.followUsOnTwitter': 'Follow Us on Twitter',
			'settings.joinOurCommunity': 'Join our community',
			'settings.bugReport': 'Bug report',
			'settings.labels': 'Labels',
			'settings.searchComingSoon': 'Search is coming soon in the near future!',
			'settings.changeLog': 'Change log',
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
			'task.link.addLink': 'Add link',
			'task.taskCreatedSuccessfully': 'Task created successfully',
			'task.nSelected': ({required Object count}) => '$count selected',
			'task.yesterday': 'Yesterday',
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
			'editTask.removeLabel': 'Remove label',
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
			'today.title': 'Today',
			'today.toDos': 'To-dos',
			'today.pinnedInCalendar': 'Pinned in calendar',
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
			'cancel': 'Cancel',
			'noTitle': '(No title)',
			'connect': 'Connect',
			'more': 'More',
			'view': 'View',
		};
	}
}
