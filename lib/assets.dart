
class Assets {
  Assets._();

  static final config = _AssetsConfig._();
  static final fonts = _AssetsFonts._();
  static final html = _AssetsHtml._();
  static final images = _AssetsImages._();

}

class _AssetsConfig {
  _AssetsConfig._();


  final devJSON = 'assets/config/dev.json';
  final prodJSON = 'assets/config/prod.json';
}

class _AssetsFonts {
  _AssetsFonts._();


  final interMediumTTF = 'assets/fonts/Inter-Medium.ttf';
  final interRegularTTF = 'assets/fonts/Inter-Regular.ttf';
  final robotoMonoBoldTTF = 'assets/fonts/RobotoMono-Bold.ttf';
  final robotoMonoMediumTTF = 'assets/fonts/RobotoMono-Medium.ttf';
  final robotoMonoRegularTTF = 'assets/fonts/RobotoMono-Regular.ttf';
}

class _AssetsHtml {
  _AssetsHtml._();


  final indexHTML = 'assets/html/index.html';
}

class _AssetsImages {
  _AssetsImages._();

  final akiflow = _AssetsImagesAkiflow._();
  final appIcon = _AssetsImagesAppIcon._();
  final favicons = _AssetsImagesFavicons._();
  final icons = _AssetsImagesIcons._();
  final logo = _AssetsImagesLogo._();
  final onboarding = _AssetsImagesOnboarding._();

  final akiflowIconPNG = 'assets/images/akiflow_icon.png';
}

class _AssetsImagesAkiflow {
  _AssetsImagesAkiflow._();


  final thatsItnothingSVG = 'assets/images/akiflow/Thats-itnothing.svg';
  final calendarPlaceholderSVG = 'assets/images/akiflow/calendar-placeholder.svg';
  final inboxNiceSVG = 'assets/images/akiflow/inbox-nice.svg';
  final plannerEmptyEngageSVG = 'assets/images/akiflow/planner-empty-engage.svg';
  final searchSVG = 'assets/images/akiflow/search.svg';
}

class _AssetsImagesAppIcon {
  _AssetsImagesAppIcon._();


  final topPNG = 'assets/images/app_icon/top.png';
}

class _AssetsImagesFavicons {
  _AssetsImagesFavicons._();


  final googleDocumentPNG = 'assets/images/favicons/google-document.png';
  final googleFormsPNG = 'assets/images/favicons/google-forms.png';
  final googlePresentationPNG = 'assets/images/favicons/google-presentation.png';
  final googleSpreadsheetsPNG = 'assets/images/favicons/google-spreadsheets.png';
}

class _AssetsImagesIcons {
  _AssetsImagesIcons._();

  final common = _AssetsImagesIconsCommon._();
  final akiflow = _AssetsImagesIconsAkiflow._();
  final asana = _AssetsImagesIconsAsana._();
  final clickup = _AssetsImagesIconsClickup._();
  final dropbox = _AssetsImagesIconsDropbox._();
  final google = _AssetsImagesIconsGoogle._();
  final jira = _AssetsImagesIconsJira._();
  final notion = _AssetsImagesIconsNotion._();
  final slack = _AssetsImagesIconsSlack._();
  final superhuman = _AssetsImagesIconsSuperhuman._();
  final todoist = _AssetsImagesIconsTodoist._();
  final trello = _AssetsImagesIconsTrello._();
  final twitter = _AssetsImagesIconsTwitter._();
  final web = _AssetsImagesIconsWeb._();
  final zapier = _AssetsImagesIconsZapier._();
  final zoom = _AssetsImagesIconsZoom._();

}

class _AssetsImagesIconsCommon {
  _AssetsImagesIconsCommon._();


  final checkDoneOutlineSVG = 'assets/images/icons/_common/Check-done-outline.svg';
  final checkDoneSVG = 'assets/images/icons/_common/Check-done.svg';
  final checkEmptyGoalSVG = 'assets/images/icons/_common/Check-empty-goal.svg';
  final checkEmptySVG = 'assets/images/icons/_common/Check-empty.svg';
  final clockAlertSVG = 'assets/images/icons/_common/Clock_alert.svg';
  final archiveboxSVG = 'assets/images/icons/_common/archivebox.svg';
  final arrow2CirclepathSVG = 'assets/images/icons/_common/arrow_2_circlepath.svg';
  final arrowLeftSVG = 'assets/images/icons/_common/arrow_left.svg';
  final arrowTurnDownRightSVG = 'assets/images/icons/_common/arrow_turn_down_right.svg';
  final arrowUpSVG = 'assets/images/icons/_common/arrow_up.svg';
  final arrowUpArrowDownSVG = 'assets/images/icons/_common/arrow_up_arrow_down.svg';
  final arrowUpRightSquareSVG = 'assets/images/icons/_common/arrow_up_right_square.svg';
  final availabilitySVG = 'assets/images/icons/_common/availability.svg';
  final bellSVG = 'assets/images/icons/_common/bell.svg';
  final calendarSVG = 'assets/images/icons/_common/calendar.svg';
  final chatBubbleSVG = 'assets/images/icons/_common/chat_bubble.svg';
  final checkDoneGoalSVG = 'assets/images/icons/_common/check_done_goal.svg';
  final checkmarkSVG = 'assets/images/icons/_common/checkmark.svg';
  final chevronDownSVG = 'assets/images/icons/_common/chevron_down.svg';
  final chevronRightSVG = 'assets/images/icons/_common/chevron_right.svg';
  final chevronUpSVG = 'assets/images/icons/_common/chevron_up.svg';
  final circleSVG = 'assets/images/icons/_common/circle.svg';
  final clockSVG = 'assets/images/icons/_common/clock.svg';
  final crownSVG = 'assets/images/icons/_common/crown.svg';
  final curlybracesSVG = 'assets/images/icons/_common/curlybraces.svg';
  final ellipsisSVG = 'assets/images/icons/_common/ellipsis.svg';
  final envelopeSVG = 'assets/images/icons/_common/envelope.svg';
  final exclamationmarkSVG = 'assets/images/icons/_common/exclamationmark.svg';
  final exclamationmark1SVG = 'assets/images/icons/_common/exclamationmark_1.svg';
  final exclamationmark2SVG = 'assets/images/icons/_common/exclamationmark_2.svg';
  final exclamationmark3SVG = 'assets/images/icons/_common/exclamationmark_3.svg';
  final exclamationmarkTriangleFillSVG = 'assets/images/icons/_common/exclamationmark_triangle_fill.svg';
  final flagsSVG = 'assets/images/icons/_common/flags.svg';
  final folderSVG = 'assets/images/icons/_common/folder.svg';
  final gearAltSVG = 'assets/images/icons/_common/gear_alt.svg';
  final giftSVG = 'assets/images/icons/_common/gift.svg';
  final guidebookSVG = 'assets/images/icons/_common/guidebook.svg';
  final handDrawSVG = 'assets/images/icons/_common/hand_draw.svg';
  final hourglassSVG = 'assets/images/icons/_common/hourglass.svg';
  final importanceGreySVG = 'assets/images/icons/_common/importance-grey.svg';
  final importanceSVG = 'assets/images/icons/_common/importance.svg';
  final infoSVG = 'assets/images/icons/_common/info.svg';
  final infoCircleSVG = 'assets/images/icons/_common/info_circle.svg';
  final largecircleFillCircleSVG = 'assets/images/icons/_common/largecircle_fill_circle.svg';
  final largecircleFillCircle2SVG = 'assets/images/icons/_common/largecircle_fill_circle_2.svg';
  final lineHorizontal3SVG = 'assets/images/icons/_common/line_horizontal_3.svg';
  final lineHorizontal3DecreaseSVG = 'assets/images/icons/_common/line_horizontal_3_decrease.svg';
  final linkSVG = 'assets/images/icons/_common/link.svg';
  final menuSVG = 'assets/images/icons/_common/menu.svg';
  final moneyDollarCircleSVG = 'assets/images/icons/_common/money_dollar_circle.svg';
  final noPrioritySVG = 'assets/images/icons/_common/no-priority.svg';
  final noActiveLinksSVG = 'assets/images/icons/_common/no_active_links.svg';
  final numberSVG = 'assets/images/icons/_common/number.svg';
  final paperplaneSendSVG = 'assets/images/icons/_common/paperplane_send.svg';
  final pencilSVG = 'assets/images/icons/_common/pencil.svg';
  final pencilCircleSVG = 'assets/images/icons/_common/pencil_circle.svg';
  final personCircleSVG = 'assets/images/icons/_common/person_circle.svg';
  final personCropCircleSVG = 'assets/images/icons/_common/person_crop_circle.svg';
  final plusSVG = 'assets/images/icons/_common/plus.svg';
  final plusSquareSVG = 'assets/images/icons/_common/plus_square.svg';
  final priorityHighSVG = 'assets/images/icons/_common/priority-high.svg';
  final priorityLowSVG = 'assets/images/icons/_common/priority-low.svg';
  final priorityMidSVG = 'assets/images/icons/_common/priority-mid.svg';
  final puzzleSVG = 'assets/images/icons/_common/puzzle.svg';
  final rectangleGrid1X2SVG = 'assets/images/icons/_common/rectangle_grid_1x2.svg';
  final recurrentJPG = 'assets/images/icons/_common/recurrent.jpg';
  final recurrentSVG = 'assets/images/icons/_common/recurrent.svg';
  final repeatSVG = 'assets/images/icons/_common/repeat.svg';
  final searchSVG = 'assets/images/icons/_common/search.svg';
  final slashCircleSVG = 'assets/images/icons/_common/slash_circle.svg';
  final squareSVG = 'assets/images/icons/_common/square.svg';
  final squareOnSquareSVG = 'assets/images/icons/_common/square_on_square.svg';
  final syncingSVG = 'assets/images/icons/_common/syncing.svg';
  final targetSVG = 'assets/images/icons/_common/target.svg';
  final targetActiveSVG = 'assets/images/icons/_common/target_active.svg';
  final trashSVG = 'assets/images/icons/_common/trash.svg';
  final traySVG = 'assets/images/icons/_common/tray.svg';
  final xmarkSVG = 'assets/images/icons/_common/xmark.svg';
  final xmarkSquareSVG = 'assets/images/icons/_common/xmark_square.svg';
}

class _AssetsImagesIconsAkiflow {
  _AssetsImagesIconsAkiflow._();


  final akiflowGreyDarkSVG = 'assets/images/icons/akiflow/akiflow-grey-dark.svg';
  final akiflowWhiteSVG = 'assets/images/icons/akiflow/akiflow-white.svg';
  final akiflowSVG = 'assets/images/icons/akiflow/akiflow.svg';
  final intercomWhiteSVG = 'assets/images/icons/akiflow/intercom-white.svg';
  final mobileSVG = 'assets/images/icons/akiflow/mobile.svg';
}

class _AssetsImagesIconsAsana {
  _AssetsImagesIconsAsana._();


  final asanaSVG = 'assets/images/icons/asana/asana.svg';
}

class _AssetsImagesIconsClickup {
  _AssetsImagesIconsClickup._();


  final clickupSVG = 'assets/images/icons/clickup/clickup.svg';
}

class _AssetsImagesIconsDropbox {
  _AssetsImagesIconsDropbox._();


  final dropboxSVG = 'assets/images/icons/dropbox/dropbox.svg';
}

class _AssetsImagesIconsGoogle {
  _AssetsImagesIconsGoogle._();


  final fingerSVG = 'assets/images/icons/google/finger.svg';
  final gmailSVG = 'assets/images/icons/google/gmail.svg';
  final gmailShadowSVG = 'assets/images/icons/google/gmail_shadow.svg';
  final googleSVG = 'assets/images/icons/google/google.svg';
  final searchSVG = 'assets/images/icons/google/search.svg';
  final starSVG = 'assets/images/icons/google/star.svg';
}

class _AssetsImagesIconsJira {
  _AssetsImagesIconsJira._();


  final jiraSVG = 'assets/images/icons/jira/jira.svg';
}

class _AssetsImagesIconsNotion {
  _AssetsImagesIconsNotion._();


  final notionSVG = 'assets/images/icons/notion/notion.svg';
}

class _AssetsImagesIconsSlack {
  _AssetsImagesIconsSlack._();


  final slackChannelSVG = 'assets/images/icons/slack/slack-channel.svg';
  final slackSVG = 'assets/images/icons/slack/slack.svg';
}

class _AssetsImagesIconsSuperhuman {
  _AssetsImagesIconsSuperhuman._();


  final superhumanGreyDarkSVG = 'assets/images/icons/superhuman/superhuman-grey-dark.svg';
  final superhumanWhiteSVG = 'assets/images/icons/superhuman/superhuman-white.svg';
  final superhumanPNG = 'assets/images/icons/superhuman/superhuman.png';
}

class _AssetsImagesIconsTodoist {
  _AssetsImagesIconsTodoist._();


  final todoistSVG = 'assets/images/icons/todoist/todoist.svg';
}

class _AssetsImagesIconsTrello {
  _AssetsImagesIconsTrello._();


  final trelloSVG = 'assets/images/icons/trello/trello.svg';
  final trelloBoardSVG = 'assets/images/icons/trello/trello_board.svg';
  final trelloCardSVG = 'assets/images/icons/trello/trello_card.svg';
}

class _AssetsImagesIconsTwitter {
  _AssetsImagesIconsTwitter._();


  final logoTwitterSVG = 'assets/images/icons/twitter/logo_twitter.svg';
  final twitterSVG = 'assets/images/icons/twitter/twitter.svg';
}

class _AssetsImagesIconsWeb {
  _AssetsImagesIconsWeb._();


  final faviconV2PNG = 'assets/images/icons/web/faviconV2.png';
}

class _AssetsImagesIconsZapier {
  _AssetsImagesIconsZapier._();


  final githubSVG = 'assets/images/icons/zapier/github.svg';
  final gitlabSVG = 'assets/images/icons/zapier/gitlab.svg';
  final googleTasksSVG = 'assets/images/icons/zapier/googleTasks.svg';
  final jiraServiceDeskSVG = 'assets/images/icons/zapier/jiraServiceDesk.svg';
  final jiraSoftwareCloudSVG = 'assets/images/icons/zapier/jiraSoftwareCloud.svg';
  final jiraSoftwareServerSVG = 'assets/images/icons/zapier/jiraSoftwareServer.svg';
  final linearSVG = 'assets/images/icons/zapier/linear.svg';
  final microsoftTodoSVG = 'assets/images/icons/zapier/microsoftTodo.svg';
  final office365SVG = 'assets/images/icons/zapier/office365.svg';
  final teamsSVG = 'assets/images/icons/zapier/teams.svg';
  final zapierSVG = 'assets/images/icons/zapier/zapier.svg';
}

class _AssetsImagesIconsZoom {
  _AssetsImagesIconsZoom._();


  final zoomOldSVG = 'assets/images/icons/zoom/zoom-old.svg';
  final zoomSVG = 'assets/images/icons/zoom/zoom.svg';
}

class _AssetsImagesLogo {
  _AssetsImagesLogo._();


  final logoFullSVG = 'assets/images/logo/logo_full.svg';
  final logoOutlineSVG = 'assets/images/logo/logo_outline.svg';
}

class _AssetsImagesOnboarding {
  _AssetsImagesOnboarding._();


  final arrowLeftSVG = 'assets/images/onboarding/arrow_left.svg';
  final arrowRightSVG = 'assets/images/onboarding/arrow_right.svg';
  final fingerLongMoveSVG = 'assets/images/onboarding/finger_long_move.svg';
  final fingerMoveSVG = 'assets/images/onboarding/finger_move.svg';
  final fingerMoveInvertSVG = 'assets/images/onboarding/finger_move_invert.svg';
  final gmailHeaderSVG = 'assets/images/onboarding/gmail_header.svg';
  final onboardingFingerSVG = 'assets/images/onboarding/onboarding_finger.svg';
}

// 
// Files format error:
// 
// assets/html/chrono-node@2.3.8.js
// assets/html/quill.min.js
// assets/images/icons/_common/00_square.svg
// assets/images/icons/_common/01_square.svg
// assets/images/icons/_common/02_square.svg
// assets/images/icons/_common/03_square.svg
// assets/images/icons/_common/04_square.svg
// assets/images/icons/_common/05_square.svg
// assets/images/icons/_common/06_square.svg
// assets/images/icons/_common/07_square.svg
// assets/images/icons/_common/08_square.svg
// assets/images/icons/_common/09_square.svg
// assets/images/icons/_common/10_square.svg
// assets/images/icons/_common/11_square.svg
// assets/images/icons/_common/12_square.svg
// assets/images/icons/_common/13_square.svg
// assets/images/icons/_common/14_square.svg
// assets/images/icons/_common/15_square.svg
// assets/images/icons/_common/16_square.svg
// assets/images/icons/_common/17_square.svg
// assets/images/icons/_common/18_square.svg
// assets/images/icons/_common/19_square.svg
// assets/images/icons/_common/20_square.svg
// assets/images/icons/_common/21_square.svg
// assets/images/icons/_common/22_square.svg
// assets/images/icons/_common/23_square.svg
// assets/images/icons/_common/24_square.svg
// assets/images/icons/_common/25_square.svg
// assets/images/icons/_common/26_square.svg
// assets/images/icons/_common/27_square.svg
// assets/images/icons/_common/28_square.svg
// assets/images/icons/_common/29_square.svg
// assets/images/icons/_common/30_square.svg
// assets/images/icons/_common/31_square.svg