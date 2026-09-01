import 'package:dio/dio.dart';

import '../aggregation/latency_aggregator.dart';
import '../contracts/internet_probe.dart';
import '../models/diagnostic_fact.dart';
import '../models/latency_aggregate.dart';
import '../session/cancellation_scope.dart';
import 'probe_config.dart';

/// HTTPS internet probe (DIAG-07, DIAG-08, D-10, D-12). N sequential cold GETs
/// to an approved, injectable target (default gstatic generate_204) expecting
/// a fixed status; a 3xx/200-HTML is a failure, never "internet confirmed" nor
/// "captive portal detected". Labelled 'HTTPS', never 'ping'. Never reuses the
/// ipify host (DIAG-05/07 are independent).
class DioHttpsInternetProbe implements InternetProbe {
  DioHttpsInternetProbe(
    this._dio, {
    this.config = const HttpsProbeConfig(),
    LatencyAggregator aggregator = const LatencyAggregator(),
  }) : _aggregator = aggregator {
    _dio.options
      ..connectTimeout = config.timeout
      ..sendTimeout = config.timeout
      ..receiveTimeout = config.timeout
      ..followRedirects = false
      ..maxRedirects = 0
      ..persistentConnection = false
      ..headers['User-Agent'] = config.userAgent
      ..validateStatus = (status) => status != null && status < 600;
  }

  final Dio _dio;
  final HttpsProbeConfig config;
  final LatencyAggregator _aggregator;

  ProbeProvenance get _provenance => ProbeProvenance(
        method: 'HTTPS',
        target: Uri.parse(config.url).host,
        portOrUrl: config.url,
        timeout: config.timeout,
        limitations: config.limitations,
      );

  @override
  Future<ProbeOutcome> probe({
    required int runId,
    required CancellationScope scope,
  }) async {
    final provenance = _provenance;
    final samples = <DiagnosticFact>[];

    for (var i = 0; i < config.sampleCount; i++) {
      if (scope.isCancelled) {
        samples.add(_sample(DiagnosticFactStatus.cancelled, provenance));
        continue;
      }
      samples.add(await _oneSample(scope, provenance));
    }

    final aggregate = _aggregator.aggregate(
      samples,
      plannedAttempts: config.sampleCount,
    );
    return ProbeOutcome(
      samples: samples,
      aggregate: aggregate,
      summary: _summaryFrom(samples, aggregate, provenance),
    );
  }

  Future<DiagnosticFact> _oneSample(
    CancellationScope scope,
    ProbeProvenance provenance,
  ) async {
    final token = CancelToken();
    scope.register(() => token.cancel('cancelled by diagnostic run'));
    final stopwatch = Stopwatch()..start();

    try {
      final response = await _dio.get<String>(
        config.url,
        cancelToken: token,
        options: Options(responseType: ResponseType.plain),
      );
      stopwatch.stop();

      if (response.statusCode == config.expectedStatus) {
        return DiagnosticFact(
          status: DiagnosticFactStatus.success,
          value: '${stopwatch.elapsedMilliseconds}',
          provenance: provenance,
          occurredAt: DateTime.now(),
        );
      }
      // Any other status (200 HTML, 3xx redirect, ...) is not a confirmed
      // internet reachability signal.
      return DiagnosticFact(
        status: DiagnosticFactStatus.failure,
        message: 'Status inesperado ${response.statusCode}',
        provenance: provenance,
        occurredAt: DateTime.now(),
      );
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        return _sample(DiagnosticFactStatus.cancelled, provenance);
      }
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return _sample(DiagnosticFactStatus.timeout, provenance);
        default:
          return _sample(DiagnosticFactStatus.failure, provenance);
      }
    }
  }

  DiagnosticFact _sample(DiagnosticFactStatus status, ProbeProvenance p) {
    return DiagnosticFact(
      status: status,
      provenance: p,
      occurredAt: DateTime.now(),
    );
  }

  DiagnosticFact _summaryFrom(
    List<DiagnosticFact> samples,
    LatencyAggregate aggregate,
    ProbeProvenance provenance,
  ) {
    final anySuccess = samples.any(
      (s) => s.status == DiagnosticFactStatus.success,
    );
    if (anySuccess) {
      return DiagnosticFact(
        status: DiagnosticFactStatus.success,
        value: aggregate.avg == null
            ? null
            : '${aggregate.avg!.inMilliseconds} ms',
        message: aggregate.denominatorLabel,
        provenance: provenance,
        occurredAt: DateTime.now(),
      );
    }
    final anyCancelled = samples.any(
      (s) => s.status == DiagnosticFactStatus.cancelled,
    );
    return DiagnosticFact(
      status: anyCancelled
          ? DiagnosticFactStatus.cancelled
          : DiagnosticFactStatus.failure,
      message: 'Sem resposta HTTPS esperada',
      provenance: provenance,
      occurredAt: DateTime.now(),
    );
  }
}
