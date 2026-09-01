import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../contracts/public_ip_source.dart';
import '../models/diagnostic_fact.dart';
import '../session/cancellation_scope.dart';
import 'public_ip_config.dart';

/// Production [PublicIpSource]: a single cancellable HTTPS GET to ipify with
/// strict validation and timeouts (DIAG-05, D-07, D-12). Any outage/timeout/
/// invalid body becomes an independent non-success fact — never "no internet".
class DioPublicIpSource implements PublicIpSource {
  DioPublicIpSource(this._dio, [this._config = const PublicIpConfig()]) {
    _dio.options
      ..connectTimeout = _config.connectTimeout
      ..sendTimeout = _config.sendTimeout
      ..receiveTimeout = _config.receiveTimeout
      ..followRedirects = false
      ..persistentConnection = false
      ..headers['User-Agent'] = _config.userAgent
      // Let the caller decide on status; never throw on non-2xx.
      ..validateStatus = (status) => status != null && status < 600;
  }

  final Dio _dio;
  final PublicIpConfig _config;

  ProbeProvenance get _provenance => ProbeProvenance(
        method: 'HTTPS',
        target: _config.thirdParty,
        portOrUrl: _config.url,
        timeout: _config.receiveTimeout,
        limitations:
            'O servidor vê o IP público desta conexão; uma indisponibilidade '
            'não significa ausência de internet.',
        thirdParty: _config.thirdParty,
      );

  DiagnosticFact _fact(
    DiagnosticFactStatus status, {
    String? value,
    String? message,
  }) {
    return DiagnosticFact(
      status: status,
      value: value,
      message: message,
      provenance: _provenance,
      occurredAt: DateTime.now(),
    );
  }

  @override
  Future<DiagnosticFact> fetch({
    required int runId,
    required CancellationScope scope,
  }) async {
    final token = CancelToken();
    scope.register(() => token.cancel('cancelled by diagnostic run'));

    try {
      final response = await _dio.get<String>(
        _config.url,
        cancelToken: token,
        options: Options(responseType: ResponseType.plain),
      );

      if (response.statusCode != 200) {
        return _fact(
          DiagnosticFactStatus.failure,
          message: 'Serviço de IP público respondeu ${response.statusCode}',
        );
      }

      // Enforce a body-size ceiling from the header when present...
      final contentLength = response.headers.value(Headers.contentLengthHeader);
      final declared = int.tryParse(contentLength ?? '');
      if (declared != null && declared > _config.maxBodyBytes) {
        return _fact(
          DiagnosticFactStatus.failure,
          message: 'Resposta inválida (tamanho excede limite)',
        );
      }

      final body = response.data ?? '';
      // ...and from the actual bytes read.
      if (utf8.encode(body).length > _config.maxBodyBytes) {
        return _fact(
          DiagnosticFactStatus.failure,
          message: 'Resposta inválida (tamanho excede limite)',
        );
      }

      return _parseBody(body);
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        return _fact(DiagnosticFactStatus.cancelled);
      }
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return _fact(
            DiagnosticFactStatus.timeout,
            message: 'Tempo esgotado ao consultar IP público',
          );
        default:
          return _fact(
            DiagnosticFactStatus.failure,
            message: 'Serviço de IP público indisponível',
          );
      }
    } catch (_) {
      return _fact(
        DiagnosticFactStatus.failure,
        message: 'Resposta inválida do serviço de IP público',
      );
    }
  }

  DiagnosticFact _parseBody(String body) {
    Object? decoded;
    try {
      decoded = jsonDecode(body);
    } catch (_) {
      return _fact(
        DiagnosticFactStatus.failure,
        message: 'Resposta inválida (JSON malformado)',
      );
    }

    if (decoded is! Map) {
      return _fact(
        DiagnosticFactStatus.failure,
        message: 'Resposta inválida (formato inesperado)',
      );
    }

    final ip = decoded['ip'];
    if (ip is! String) {
      return _fact(
        DiagnosticFactStatus.failure,
        message: 'Resposta inválida (campo ip ausente)',
      );
    }

    final parsed = InternetAddress.tryParse(ip);
    if (parsed == null || parsed.type != InternetAddressType.IPv4) {
      return _fact(
        DiagnosticFactStatus.failure,
        message: 'Resposta inválida (IPv4 esperado)',
      );
    }

    return _fact(DiagnosticFactStatus.success, value: ip);
  }
}
