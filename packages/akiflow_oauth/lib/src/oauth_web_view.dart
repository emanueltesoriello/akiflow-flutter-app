import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:akiflow_oauth/src/base_web_view.dart';

const String _charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';

class OAuthWebView extends BaseWebView {
  final String authorizationEndpointUrl;
  final String tokenEndpointUrl;
  final String redirectUrl;
  final String? baseUrl;
  final String clientId;
  final String? clientSecret;
  final List<String>? scopes;
  final String? loginHint;
  final List<String>? promptValues;
  final ValueChanged<MapEntry<String, String>> onSuccessAuth;

  OAuthWebView({
    Key? key,
    required this.authorizationEndpointUrl,
    required this.tokenEndpointUrl,
    required this.redirectUrl,
    this.baseUrl,
    required this.clientId,
    this.clientSecret,
    this.scopes,
    this.loginHint,
    this.promptValues,
    required this.onSuccessAuth,
    required ValueChanged<dynamic> onError,
    required VoidCallback onCancel,
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
  }) : super(
          key: key,

          /// Initial url is obtained from getAuthorizationUrl below.
          initialUrl: '',
          redirectUrls: baseUrl != null ? [redirectUrl, baseUrl] : [redirectUrl],
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
        );

  @override
  OAuthWebViewState createState() => OAuthWebViewState();
}

class OAuthWebViewState extends BaseWebViewState<OAuthWebView> with WidgetsBindingObserver {
  late oauth2.AuthorizationCodeGrant authorizationCodeGrant;
  late String codeVerifier;
  @override
  void initBase() {
    super.initBase();
    controllerClearCache();

    codeVerifier = List.generate(128, (i) => _charset[Random.secure().nextInt(_charset.length)]).join();
    authorizationCodeGrant = oauth2.AuthorizationCodeGrant(
      widget.clientId,
      Uri.parse(widget.authorizationEndpointUrl),
      Uri.parse(widget.tokenEndpointUrl),
      codeVerifier: codeVerifier,
      secret: widget.clientSecret,
    );
    initialUri = authorizationCodeGrant.getAuthorizationUrl(
      Uri.parse(widget.redirectUrl),
      scopes: widget.scopes,
    );
    initialUri = initialUri.replace(
        queryParameters: Map.from(initialUri.queryParameters)
          ..addAll({
            'codeVerifier': codeVerifier,
            'state': const Base64Encoder.urlSafe().convert(DateTime.now().toIso8601String().codeUnits),
            'nonce': const Base64Encoder.urlSafe().convert(DateTime.now().millisecondsSinceEpoch.toString().codeUnits),
            if (widget.loginHint != null) 'login_hint': widget.loginHint!,
            if (widget.promptValues?.isNotEmpty ?? false) 'prompt': widget.promptValues!.join(' '),
          }));
  }

  @override
  void onSuccess(String responseRedirect) async {
    if ((widget.baseUrl?.isNotEmpty ?? false) && responseRedirect.startsWith(widget.baseUrl!)) {
      return onCancel();
    }

    responseRedirect = responseRedirect.trim().replaceAll('#', '');
    final parameters = Uri.dataFromString(responseRedirect).queryParameters;

    try {
      widget.onSuccessAuth(MapEntry(parameters.entries.first.value, codeVerifier));
    } catch (e) {
      onError(e);
    }
  }
}
