import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/widgets/base/app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class LicencesPage extends StatelessWidget {
  const LicencesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComp(
        title: t.settings.about.licensesInfo,
        showBack: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(Dimension.padding),
              children: const [
                _LicenseItem(name: "audioplayers", type: "MIT"),
                _LicenseItem(name: "async", type: "MIT"),
                _LicenseItem(name: "dio", type: "MIT"),
                _LicenseItem(name: "equatable", type: "MIT"),
                _LicenseItem(name: "extended_text_field", type: "MIT"),
                _LicenseItem(name: "firebase_core", type: "MIT"),
                _LicenseItem(name: "firebase_messaging", type: "MIT"),
                _LicenseItem(name: "flutter_appauth", type: "MIT"),
                _LicenseItem(name: "flutter_bloc", type: "MIT"),
                _LicenseItem(name: "flutter_displaymode", type: "MIT"),
                _LicenseItem(name: "flutter_js", type: "MIT"),
                _LicenseItem(name: "flutter_localizations", type: "MIT"),
                _LicenseItem(name: "flutter_local_notifications", type: "MIT"),
                _LicenseItem(name: "flutter_native_timezone", type: "MIT"),
                _LicenseItem(name: "flutter_rounded_date_picker", type: "MIT"),
                _LicenseItem(name: "flutter_segment", type: "MIT"),
                _LicenseItem(name: "flutter_slidable", type: "MIT"),
                _LicenseItem(name: "flutter_svg", type: "MIT"),
                _LicenseItem(name: "flutter_switch", type: "MIT"),
                _LicenseItem(name: "flutter_quill", type: "MIT"),
                _LicenseItem(name: "get_it", type: "MIT"),
                _LicenseItem(name: "html", type: "MIT"),
                _LicenseItem(name: "http", type: "MIT"),
                _LicenseItem(name: "i18n", type: "MIT"),
                _LicenseItem(name: "intl", type: "MIT"),
                _LicenseItem(name: "modal_bottom_sheet", type: "MIT"),
                _LicenseItem(name: "package_info_plus", type: "MIT"),
                _LicenseItem(name: "platform_device_id", type: "MIT"),
                _LicenseItem(name: "rrule", type: "MIT"),
                _LicenseItem(name: "sentry_flutter", type: "MIT"),
                _LicenseItem(name: "share_handler", type: "MIT"),
                _LicenseItem(name: "shared_preferences", type: "MIT"),
                _LicenseItem(name: "sliding_up_panel", type: "MIT"),
                _LicenseItem(name: "syncfusion_flutter_calendar", type: "MIT"),
                _LicenseItem(name: "sqflite", type: "MIT"),
                _LicenseItem(name: "table_calendar", type: "MIT"),
                _LicenseItem(name: "table_calendar", type: "MIT"),
                _LicenseItem(name: "timeago", type: "MIT"),
                _LicenseItem(name: "url_launcher", type: "MIT"),
                _LicenseItem(name: "uuid", type: "MIT"),
                _LicenseItem(name: "visibility_detector", type: "MIT"),
                _LicenseItem(name: "webview_flutter", type: "MIT"),
                _LicenseItem(name: "workmanager", type: "MIT"),
                SizedBox(height: Dimension.padding),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LicenseItem extends StatelessWidget {
  final String name;
  final String type;

  const _LicenseItem({
    Key? key,
    required this.name,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => launchUrl(Uri.parse("https://pub.dev/packages/$name"), mode: LaunchMode.externalApplication),
      child: Padding(
        padding: const EdgeInsets.all(Dimension.paddingS),
        child: Text(name,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: ColorsExt.grey600(context),
                  decoration: TextDecoration.underline,
                )),
      ),
    );
  }
}
