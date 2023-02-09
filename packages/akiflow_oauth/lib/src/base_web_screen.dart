import 'package:flutter/material.dart';
import 'package:akiflow_oauth/src/base_web_view.dart';

class BaseWebScreen extends StatelessWidget {
  static Future? start({
    Key? key,
    GlobalKey<BaseWebViewState>? globalKey,
    required BuildContext context,
    required String initialUrl,
    required List<String> redirectUrls,
    ValueChanged<String>? onSuccess,
    ValueChanged<dynamic>? onError,
    VoidCallback? onCancel,
    CertificateValidator? onCertificateValidate,
    ThemeData? themeData,
    Map<String, String>? textLocales,
    Locale? contentLocale,
    Map<String, String>? headers,
    Stream<String>? urlStream,
    bool? goBackBtnVisible,
    bool? goForwardBtnVisible,
    bool? refreshBtnVisible,
    bool? clearCacheBtnVisible,
    bool? closeBtnVisible,
  }) =>
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseWebScreen(
                    initialUrl: initialUrl,
                    redirectUrls: redirectUrls,
                    onSuccess: onSuccess,
                    onError: onError,
                    onCancel: onCancel,
                    onCertificateValidate: onCertificateValidate,
                    themeData: themeData,
                    textLocales: textLocales,
                    contentLocale: contentLocale,
                    headers: headers,
                    urlStream: urlStream,
                    goBackBtnVisible: goBackBtnVisible,
                    goForwardBtnVisible: goForwardBtnVisible,
                    refreshBtnVisible: refreshBtnVisible,
                    clearCacheBtnVisible: clearCacheBtnVisible,
                    closeBtnVisible: closeBtnVisible,
                  )));

  final String initialUrl;
  final List<String> redirectUrls;
  final ValueChanged<String>? onSuccess;
  final ValueChanged<dynamic>? onError;
  final VoidCallback? onCancel;
  final CertificateValidator? onCertificateValidate;
  final ThemeData? themeData;
  final Map<String, String>? textLocales;
  final Locale? contentLocale;
  final Map<String, String>? headers;
  final Stream<String>? urlStream;
  final bool? goBackBtnVisible;
  final bool? goForwardBtnVisible;
  final bool? refreshBtnVisible;
  final bool? clearCacheBtnVisible;
  final bool? closeBtnVisible;

  late final BuildContext context;
  final GlobalKey<BaseWebViewState> globalKey;

  BaseWebScreen({
    Key? key,
    GlobalKey<BaseWebViewState>? globalKey,
    required this.initialUrl,
    required this.redirectUrls,
    this.onSuccess,
    this.onError,
    this.onCancel,
    this.onCertificateValidate,
    this.themeData,
    this.textLocales,
    this.contentLocale,
    this.headers,
    this.urlStream,
    this.goBackBtnVisible,
    this.goForwardBtnVisible,
    this.refreshBtnVisible,
    this.clearCacheBtnVisible,
    this.closeBtnVisible,
  })  : globalKey = globalKey ?? GlobalKey<BaseWebViewState>(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        this.context = context;
        return Scaffold(
          body: SafeArea(
            bottom: false,
            left: false,
            right: false,
            child: WillPopScope(
              onWillPop: onBackPressed,
              child: BaseWebView(
                key: globalKey,
                initialUrl: initialUrl,
                redirectUrls: redirectUrls,
                onSuccessRedirect: _onSuccess,
                onError: _onError,
                onCancel: _onCancel,
                onCertificateValidate: onCertificateValidate,
                themeData: themeData,
                textLocales: textLocales,
                headers: headers,
                contentLocale: contentLocale,
                urlStream: urlStream,
                goBackBtnVisible: goBackBtnVisible,
                goForwardBtnVisible: goForwardBtnVisible,
                refreshBtnVisible: refreshBtnVisible,
                clearCacheBtnVisible: clearCacheBtnVisible,
                closeBtnVisible: closeBtnVisible,
              ),
            ),
          ),
        );
      },
    );
  }

  void _onSuccess(String responseRedirect) {
    Navigator.pop(context, true);
    onSuccess?.call(responseRedirect);
  }

  void _onError(dynamic error) {
    Navigator.pop(context, error);
    onError?.call(error);
  }

  void _onCancel() {
    Navigator.pop(context);
    onCancel?.call();
  }

  Future<bool> onBackPressed() async {
    if (!((await globalKey.currentState?.onBackPressed()) ?? false)) {
      return false;
    }
    onCancel?.call();
    return true;
  }
}
