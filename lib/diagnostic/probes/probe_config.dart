/// Injectable config for the TCP-connect gateway probe (DIAG-06, D-10).
class GatewayProbeConfig {
  const GatewayProbeConfig({
    this.ports = const [80, 443],
    this.sampleCount = 4,
    this.timeout = const Duration(seconds: 2),
    this.limitations =
        'Verifica apenas conexão TCP; não abre uma página HTTP/HTTPS nem '
        'valida certificado. Porta fechada, filtrada ou sem resposta não '
        'significa falta de Internet nem gateway inalcançável.',
  });

  /// Ports probed sequentially (never concurrently); each keeps its own
  /// independent samples/aggregate — never mixed into one statistic.
  final List<int> ports;
  final int sampleCount;
  final Duration timeout;
  final String limitations;
}

/// Injectable config for the HTTPS internet probe (DIAG-07, D-12).
class HttpsProbeConfig {
  const HttpsProbeConfig({
    this.url = defaultUrl,
    this.expectedStatus = 204,
    this.sampleCount = 4,
    this.timeout = const Duration(seconds: 5),
    this.userAgent = 'ToolsApp-Diagnostic/1.1.1',
    this.limitations =
        'HTTPS GET (resposta de status), conexão fria. Um 3xx/200 não '
        'confirma internet completa nem prova portal cativo.',
  });

  static const String defaultUrl = 'https://www.gstatic.com/generate_204';

  final String url;
  final int expectedStatus;
  final int sampleCount;
  final Duration timeout;
  final String userAgent;
  final String limitations;
}
