import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/app_bar.dart';
import 'package:mobile/style/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class LicensesPage extends StatelessWidget {
  const LicensesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppBarComp(
            title: t.settings.about.licensesInfo,
            showBack: true,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                _LicenseItem(name: "build_runner", type: "MIT"),
                _LicenseItem(name: "built_value", type: "MIT"),
                _LicenseItem(name: "built_value_generator", type: "MIT"),
                _LicenseItem(name: "equatable", type: "MIT"),
                _LicenseItem(name: "fast_i18n", type: "MIT"),
                _LicenseItem(name: "flutter_appauth", type: "MIT"),
                _LicenseItem(name: "flutter_bloc", type: "MIT"),
                _LicenseItem(name: "flutter_slidable", type: "MIT"),
                _LicenseItem(name: "flutter_svg", type: "MIT"),
                _LicenseItem(name: "flutter_widget_from_html", type: "MIT"),
                _LicenseItem(name: "get_it", type: "MIT"),
                _LicenseItem(name: "http", type: "MIT"),
                _LicenseItem(name: "intl", type: "MIT"),
                _LicenseItem(name: "jiffy", type: "MIT"),
                _LicenseItem(name: "modal_bottom_sheet", type: "MIT"),
                _LicenseItem(name: "package_info_plus", type: "MIT"),
                _LicenseItem(name: "path", type: "MIT"),
                _LicenseItem(name: "path_provider", type: "MIT"),
                _LicenseItem(name: "pusher_beams", type: "MIT"),
                _LicenseItem(name: "reorderables", type: "MIT"),
                _LicenseItem(name: "rrule", type: "MIT"),
                _LicenseItem(name: "sentry_flutter", type: "MIT"),
                _LicenseItem(name: "shared_preferences", type: "MIT"),
                _LicenseItem(name: "sqflite", type: "MIT"),
                _LicenseItem(name: "table_calendar", type: "MIT"),
                _LicenseItem(name: "timeago", type: "MIT"),
                _LicenseItem(name: "url_launcher", type: "MIT"),
                _LicenseItem(name: "uuid", type: "MIT"),
                SizedBox(height: 16),
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
      onTap: () => launchUrl(Uri.parse("https://pub.dev/packages/$name")),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: ColorsExt.grey3(context),
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
