// HTTPS internet probe: 204 success, 3xx/200 failure, timeout, cancel.
// Handwritten Dio adapter, no live network. DIAG-07/08, D-10, D-12.
import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tools_app/diagnostic/models/diagnostic_fact.dart';
import 'package:tools_app/diagnostic/probes/dio_https_probe.dart';
import 'package:tools_app/diagnostic/probes/probe_config.dart';
import 'package:tools_app/diagnostic/session/cancellation_scope.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter({this.statusCode = 204, this.body = '', this.hang = false});

  int statusCode;
  String body;
  bool hang;
  DioException Function(RequestOptions options)? throwError;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (throwError != null) throw throwError!(options);
    if (hang) {
      final completer = Completer<ResponseBody>();
      cancelFuture?.then((_) {
        if (!completer.isCompleted) {
          completer.completeError(
            DioException.requestCancelled(
              requestOptions: options,
              reason: 'cancelled',
            ),
          );
        }
      });
      return completer.future;
    }
    return ResponseBody.fromString(body, statusCode);
  }
}

Dio _dioWith(_FakeAdapter adapter) {
  final dio = Dio();
  dio.httpClientAdapter = adapter;
  return dio;
}

void main() {
  group('DioHttpsInternetProbe', () {
    test('4x 204 → 4 sucessos, method HTTPS, url generate_204', () async {
      final probe = DioHttpsInternetProbe(
        _dioWith(_FakeAdapter(statusCode: 204)),
        config: const HttpsProbeConfig(sampleCount: 4),
      );
      final outcome = await probe.probe(runId: 1, scope: CancellationScope());

      expect(outcome.aggregate.successes, 4);
      expect(outcome.summary.provenance?.method, 'HTTPS');
      expect(outcome.summary.provenance?.portOrUrl, contains('generate_204'));
      expect(outcome.summary.provenance?.portOrUrl, isNot(contains('ipify')));
    });

    test('status 200 (HTML) → failure, não success', () async {
      final probe = DioHttpsInternetProbe(
        _dioWith(_FakeAdapter(statusCode: 200, body: '<html></html>')),
        config: const HttpsProbeConfig(sampleCount: 2),
      );
      final outcome = await probe.probe(runId: 1, scope: CancellationScope());
      expect(outcome.aggregate.successes, 0);
      expect(outcome.summary.status, DiagnosticFactStatus.failure);
    });

    test('302 redirect → failure', () async {
      final probe = DioHttpsInternetProbe(
        _dioWith(_FakeAdapter(statusCode: 302)),
        config: const HttpsProbeConfig(sampleCount: 1),
      );
      final outcome = await probe.probe(runId: 1, scope: CancellationScope());
      expect(outcome.samples.single.status, DiagnosticFactStatus.failure);
    });

    test('receiveTimeout → timeout', () async {
      final adapter = _FakeAdapter();
      adapter.throwError = (options) => DioException.receiveTimeout(
            timeout: const Duration(milliseconds: 50),
            requestOptions: options,
          );
      final probe = DioHttpsInternetProbe(
        _dioWith(adapter),
        config: const HttpsProbeConfig(sampleCount: 1),
      );
      final outcome = await probe.probe(runId: 1, scope: CancellationScope());
      expect(outcome.samples.single.status, DiagnosticFactStatus.timeout);
    });

    test('cancel → cancelled', () async {
      final probe = DioHttpsInternetProbe(
        _dioWith(_FakeAdapter(hang: true)),
        config: const HttpsProbeConfig(sampleCount: 1),
      );
      final scope = CancellationScope();
      final future = probe.probe(runId: 1, scope: scope);
      await Future<void>.delayed(Duration.zero);
      await scope.cancelAll();
      final outcome = await future;
      expect(outcome.samples.single.status, DiagnosticFactStatus.cancelled);
    });

    test('url default é gstatic generate_204, não ipify', () {
      const config = HttpsProbeConfig();
      expect(config.url, contains('gstatic.com/generate_204'));
      expect(config.url, isNot(contains('ipify')));
    });
  });
}
