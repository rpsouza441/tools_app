/// Injectable configuration for the public IP lookup. The URL is compiled in
/// (no free-text field in the UI) and there is no second vendor / cascade
/// (D-12, DIAG-05). api.ipify.org's `?format=json` endpoint returns IPv4.
class PublicIpConfig {
  const PublicIpConfig({
    this.url = defaultUrl,
    this.connectTimeout = const Duration(seconds: 5),
    this.sendTimeout = const Duration(seconds: 5),
    this.receiveTimeout = const Duration(seconds: 5),
    this.maxBodyBytes = 2048,
    this.userAgent = 'ToolsApp-Diagnostic/1.1.1',
    this.thirdParty = 'api.ipify.org',
  });

  static const String defaultUrl = 'https://api.ipify.org?format=json';

  final String url;
  final Duration connectTimeout;
  final Duration sendTimeout;
  final Duration receiveTimeout;
  final int maxBodyBytes;
  final String userAgent;
  final String thirdParty;
}
