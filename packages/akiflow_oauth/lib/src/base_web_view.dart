import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:webviewx/webviewx.dart';

T? _ambiguate<T>(T? value) => value;

typedef CertificateValidator = bool Function(X509Certificate certificate);

class BaseWebView extends StatefulWidget {
  static const String firstLoadHeroTag = 'firstLoadOAuthWebAuthHeroTag';
  static const String backButtonTooltipKey = 'backButtonTooltipKey';
  static const String forwardButtonTooltipKey = 'forwardButtonTooltipKey';
  static const String reloadButtonTooltipKey = 'reloadButtonTooltipKey';
  static const String clearCacheButtonTooltipKey = 'clearCacheButtonTooltipKey';
  static const String closeButtonTooltipKey = 'closeButtonTooltipKey';
  static const String clearCacheWarningMessageKey = 'clearCacheWarningMessageKey';

  final String initialUrl;
  final List<String> redirectUrls;

  final ValueChanged<String>? onSuccessRedirect;

  final ValueChanged<dynamic>? onError;

  final VoidCallback? onCancel;

  final CertificateValidator? onCertificateValidate;

  final ThemeData? themeData;
  final Map<String, String>? textLocales;
  final Locale? contentLocale;
  final Map<String, String> headers;

  final Stream<String>? urlStream;

  final bool goBackBtnVisible;
  final bool goForwardBtnVisible;
  final bool refreshBtnVisible;
  final bool clearCacheBtnVisible;
  final bool closeBtnVisible;

  const BaseWebView({
    Key? key,
    required this.initialUrl,
    required this.redirectUrls,
    this.onSuccessRedirect,
    this.onError,
    this.onCancel,
    this.onCertificateValidate,
    this.themeData,
    this.textLocales,
    this.contentLocale,
    Map<String, String>? headers,
    this.urlStream,
    bool? goBackBtnVisible = true,
    bool? goForwardBtnVisible = true,
    bool? refreshBtnVisible = true,
    bool? clearCacheBtnVisible = true,
    bool? closeBtnVisible = true,
  })  : headers = headers ?? const {},
        goBackBtnVisible = goBackBtnVisible ?? true,
        goForwardBtnVisible = goForwardBtnVisible ?? true,
        refreshBtnVisible = refreshBtnVisible ?? true,
        clearCacheBtnVisible = clearCacheBtnVisible ?? true,
        closeBtnVisible = closeBtnVisible ?? true,
        super(key: key);

  @override
  BaseWebViewState<BaseWebView> createState() => BaseWebViewState<BaseWebView>();
}

class BaseWebViewState<S extends BaseWebView> extends State<S> with WidgetsBindingObserver {
  bool ready = false;
  bool showToolbar = false;
  bool isLoading = true;
  bool allowGoBack = false;
  bool allowGoForward = false;
  bool tooltipsAlreadyInitialized = false;
  WebViewXController? webViewXController;
  InAppWebViewController? inAppWebViewController;
  @override
  late BuildContext context;

  late Uri initialUri;
  late String backButtonTooltip;
  late String forwardButtonTooltip;
  late String reloadButtonTooltip;
  late String clearCacheButtonTooltip;
  late String closeButtonTooltip;
  late String clearCacheWarningMessage;

  late Timer toolbarTimerShow;
  late Widget webView;
  StreamSubscription? urlStreamSubscription;

  List<String> get redirectUrls => widget.redirectUrls;
  bool get toolbarVisible =>
      widget.goBackBtnVisible ||
      widget.goForwardBtnVisible ||
      widget.refreshBtnVisible ||
      widget.clearCacheBtnVisible ||
      widget.closeBtnVisible;

  @override
  void initState() {
    super.initState();
    initBase();

    webView = initWebView();
  }

  void initBase() {
    initialUri = Uri.parse(widget.initialUrl);
    toolbarTimerShow = Timer(const Duration(seconds: 5), () {
      setState(() {
        showToolbar = true;
      });
    });
    _ambiguate(WidgetsBinding.instance)?.addObserver(this);
    urlStreamSubscription = widget.urlStream?.listen(controllerGo);
  }

  void initTooltips() {
    if (tooltipsAlreadyInitialized) return;
    backButtonTooltip = widget.textLocales?[BaseWebView.backButtonTooltipKey] ?? 'Go back';
    forwardButtonTooltip = widget.textLocales?[BaseWebView.forwardButtonTooltipKey] ?? 'Go forward';
    reloadButtonTooltip = widget.textLocales?[BaseWebView.reloadButtonTooltipKey] ?? 'Reload';
    clearCacheButtonTooltip = widget.textLocales?[BaseWebView.clearCacheButtonTooltipKey] ?? 'Clear cache';
    closeButtonTooltip =
        widget.textLocales?[BaseWebView.closeButtonTooltipKey] ?? MaterialLocalizations.of(context).closeButtonTooltip;
    clearCacheWarningMessage =
        widget.textLocales?[BaseWebView.clearCacheWarningMessageKey] ?? 'Are you sure you want to clear cache?';
    tooltipsAlreadyInitialized = true;
  }

  Widget initWebView() {

    final Widget content;

    if (kIsWeb) {
      content = WebViewX(
        width: MediaQueryData.fromWindow(window).size.width,
        height: MediaQueryData.fromWindow(window).size.height,
        javascriptMode: JavascriptMode.unrestricted,

        /// This custom userAgent is mandatory due to security constraints of Google's OAuth2 policies (https://developers.googleblog.com/2021/06/upcoming-security-changes-to-googles-oauth-2.0-authorization-endpoint.html)
        userAgent: 'Mozilla/5.0',
        onWebViewCreated: (controller) {
          webViewXController = controller;
          controller.loadContent(initialUri.toString(), SourceType.url, headers: {
            ...widget.headers,
            if (widget.contentLocale != null) 'Accept-Language': widget.contentLocale!.toLanguageTag()
          });
        },
        navigationDelegate: (request) async =>
            onNavigateTo(request.content.source) ? NavigationDecision.navigate : NavigationDecision.prevent,
        onPageFinished: (url) => hideLoading(),
      );
    } else {
      content = InAppWebView(
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            useShouldOverrideUrlLoading: true,
            supportZoom: false,

            /// This custom userAgent is mandatory due to security constraints of Google's OAuth2 policies (https://developers.googleblog.com/2021/06/upcoming-security-changes-to-googles-oauth-2.0-authorization-endpoint.html)
            userAgent: 'Mozilla/5.0',
          ),
          android: AndroidInAppWebViewOptions(
            useHybridComposition: true,
          ),
        ),
        initialUrlRequest: URLRequest(url: initialUri, headers: {
          ...widget.headers,
          if (widget.contentLocale != null) 'Accept-Language': widget.contentLocale!.toLanguageTag()
        }),
        onReceivedServerTrustAuthRequest: (controller, challenge) async {
          return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
        },
        onWebViewCreated: (controller) {
          inAppWebViewController = controller;
        },
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          final url = navigationAction.request.url?.toString() ?? '';
          return onNavigateTo(url) ? NavigationActionPolicy.ALLOW : NavigationActionPolicy.CANCEL;
        },
        onLoadStart: (controller, url) async {
          if (url == initialUri) {
            final certificate = (await controller.getCertificate())?.x509Certificate;
            if (certificate != null && !onCertificateValidate(certificate)) {
              onError(const CertificateException('Invalid certificate'));
            }
          }
          showLoading();
        },
        onLoadStop: (controller, url) async {
          hideLoading();
        },
        onLoadError: (controller, url, code, message) => hideLoading(),
      );
    }

    return GestureDetector(
      onLongPressDown: (details) {},
      child: content,
    );
  }

  void showLoading() {
    if (!isLoading && mounted) {
      setState(() {
        isLoading = true;
      });
    }
  }

  Future<void> hideLoading() async {
    if (isLoading && mounted) {
      ready = true;
      showToolbar = true;
      toolbarTimerShow.cancel();
      isLoading = false;
      allowGoBack = await controllerCanGoBack();
      allowGoForward = await controllerCanGoForward();
      setState(() {});
    }
  }

  bool startsWithAnyRedirectUrl(String url) => redirectUrls.any((redirectUrl) => url.startsWith(redirectUrl));

  bool onNavigateTo(String url) {
    if (url != 'about:blank') showLoading();
    if (startsWithAnyRedirectUrl(url)) {
      onSuccess(url);
      return false;
    }
    return true;
  }

  void onSuccess(String responseRedirect) async {
    widget.onSuccessRedirect?.call(responseRedirect);
  }

  void onError(dynamic error) {
    widget.onError?.call(error);
  }

  void onCancel() {
    widget.onCancel?.call();
  }

  bool onCertificateValidate(X509Certificate certificate) {
    return widget.onCertificateValidate?.call(certificate) ?? true;
  }

  Widget iconButton({
    required IconData iconData,
    String? tooltip,
    VoidCallback? onPressed,
    bool respectLoading = true,
  }) =>
      IconButton(
        iconSize: 30,
        tooltip: tooltip,
        icon: Icon(iconData),
        color: Theme.of(context).colorScheme.secondary,
        onPressed: respectLoading && isLoading ? null : onPressed,
      );

  @override
  Widget build(BuildContext context) {
    final content = Builder(
      builder: (context) {
        this.context = context;
        initTooltips();
        return Scaffold(
          body: Stack(
            children: [
              WillPopScope(
                child: webView,
                onWillPop: onBackPressed,
              ),
              Positioned.fill(
                child: Hero(
                  tag: BaseWebView.firstLoadHeroTag,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: !ready && isLoading ? const CircularProgressIndicator() : const SizedBox(),
                  ),
                ),
              ),
              AnimatedPositioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: ready && isLoading ? 5 : 0,
                duration: const Duration(milliseconds: 200),
                child: const LinearProgressIndicator(),
              ),
            ],
          ),
          bottomNavigationBar: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: toolbarVisible && showToolbar ? null : 0,
            child: BottomAppBar(
              elevation: 8,
              color: Theme.of(context).bottomAppBarColor,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (widget.goBackBtnVisible)
                    iconButton(
                      iconData: Icons.arrow_back_ios_rounded,
                      tooltip: backButtonTooltip,
                      onPressed: !allowGoBack ? null : () => controllerGoBack(),
                    ),
                  if (widget.goForwardBtnVisible)
                    iconButton(
                      iconData: Icons.arrow_forward_ios_rounded,
                      tooltip: forwardButtonTooltip,
                      onPressed: !allowGoForward ? null : () => controllerGoForward(),
                    ),
                  if (widget.refreshBtnVisible)
                    iconButton(
                      iconData: Icons.refresh_rounded,
                      tooltip: reloadButtonTooltip,
                      onPressed: () => controllerReload(),
                    ),
                  if (widget.clearCacheBtnVisible)
                    iconButton(
                      iconData: Icons.cleaning_services_rounded,
                      tooltip: clearCacheButtonTooltip,
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(clearCacheButtonTooltip),
                                content: Text(clearCacheWarningMessage),
                                actions: [
                                  TextButton(
                                    child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  TextButton(
                                    child: Text(MaterialLocalizations.of(context).okButtonLabel),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      controllerClearCache();
                                    },
                                  ),
                                ],
                              );
                            });
                      },
                    ),
                  if (widget.closeBtnVisible)
                    iconButton(
                      iconData: Icons.close,
                      tooltip: closeButtonTooltip,
                      respectLoading: false,
                      onPressed: () => onCancel(),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
    return widget.themeData != null
        ? Theme(
            data: widget.themeData!,
            child: content,
          )
        : content;
  }

  Future<void> controllerGo(String url) async {
    showLoading();
    webViewXController?.loadContent(url, SourceType.url);
    inAppWebViewController?.loadUrl(
        urlRequest: URLRequest(
      url: Uri.parse(url),
      headers: widget.contentLocale == null ? null : {'Accept-Language': widget.contentLocale!.toLanguageTag()},
    ));
  }

  Future<void> controllerGoBack() async {
    showLoading();
    webViewXController?.goBack();
    inAppWebViewController?.goBack();
  }

  Future<void> controllerGoForward() async {
    showLoading();
    webViewXController?.goForward();
    inAppWebViewController?.goForward();
  }

  Future<void> controllerReload() async {
    showLoading();
    webViewXController?.reload();
    inAppWebViewController?.reload();
  }

  Future<void> controllerClearCache() async {
    showLoading();
    await webViewXController?.clearCache();
    await inAppWebViewController?.clearCache();
    hideLoading();
  }

  Future<bool> controllerCanGoForward() async {
    bool? webViewXCanGoForward;
    bool? inAppWebViewCanGoForward;
    try {
      webViewXCanGoForward = await webViewXController?.canGoForward();
    } catch (e) {
      if (kDebugMode) print(e);
    }
    try {
      inAppWebViewCanGoForward = await inAppWebViewController?.canGoForward();
    } catch (e) {
      if (kDebugMode) print(e);
    }
    return webViewXCanGoForward ?? inAppWebViewCanGoForward ?? false;
  }

  Future<bool> controllerCanGoBack() async {
    bool? webViewXCanGoBack;
    bool? inAppWebViewCanGoBack;
    try {
      webViewXCanGoBack = await webViewXController?.canGoBack();
    } catch (e) {
      if (kDebugMode) print(e);
    }
    try {
      inAppWebViewCanGoBack = await inAppWebViewController?.canGoBack();
    } catch (e) {
      if (kDebugMode) print(e);
    }
    return webViewXCanGoBack ?? inAppWebViewCanGoBack ?? false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        hideLoading();
        break;
      default:
        break;
    }
  }

  Future<bool> onBackPressed() async {
    if (await controllerCanGoBack()) {
      controllerGoBack();
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    super.dispose();
    urlStreamSubscription?.cancel();
    toolbarTimerShow.cancel();
  }
}
