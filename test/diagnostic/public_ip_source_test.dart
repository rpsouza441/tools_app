// QUAL-08 for the public IP source: success, invalid JSON, IPv6, oversize,
// timeout, connection failure, cancel. Handwritten Dio adapter, no mockito,
// no live network. DIAG-05, D-07, D-12.
import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tools_app/diagnostic/models/diagnostic_fact.dart';
import 'package:tools_app/diagnostic/public_ip/dio_public_ip_source.dart';
import 'package:tools_app/diagnostic/session/cancellation_scope.dart';

/// Handwritten adapter that returns a canned response, throws, or hangs.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter({
    this.body = '{"ip":"8.8.8.8"}',
    this.headers = const <String, List<String>>{},
    this.hang = false,
  });

  int statusCode = 200;
  String body;
  Map<String, List<String>> headers;
  DioException Function(RequestOptions options)? throwError;
  bool hang;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (throwError != null) {
      throw throwError!(options);
    }
    if (hang) {
      final completer = Completer<ResponseBody>();
      // Abort when the CancelToken fires so cancel tests resolve.
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
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: headers,
    );
  }
}

Dio _dioWith(_FakeAdapter adapter) {
  final dio = Dio();
  dio.httpClientAdapter = adapter;
  return dio;
}

void main() {
  group('DioPublicIpSource', () {
    test('IPv4 válido → success com provenance HTTPS/ipify', () async {
      final source = DioPublicIpSource(
        _dioWith(_FakeAdapter(body: '{"ip":"8.8.8.8"}')),
      );
      final fact = await source.fetch(runId: 1, scope: CancellationScope());

      expect(fact.status, DiagnosticFactStatus.success);
      expect(fact.value, '8.8.8.8');
      expect(fact.provenance?.method, 'HTTPS');
      expect(fact.provenance?.thirdParty, 'api.ipify.org');
    });

    test('JSON com ip inválido → failure', () async {
      final source = DioPublicIpSource(
        _dioWith(_FakeAdapter(body: '{"ip":"not-an-ip"}')),
      );
      final fact = await source.fetch(runId: 1, scope: CancellationScope());
      expect(fact.status, DiagnosticFactStatus.failure);
    });

    test('HTML/JSON malformado → failure sem exceção vazando', () async {
      final source = DioPublicIpSource(
        _dioWith(_FakeAdapter(body: '<html>nope</html>')),
      );
      final fact = await source.fetch(runId: 1, scope: CancellationScope());
      expect(fact.status, DiagnosticFactStatus.failure);
    });

    test('IPv6 → failure (DIAG-05 é IPv4)', () async {
      final source = DioPublicIpSource(
        _dioWith(_FakeAdapter(body: '{"ip":"2001:4860:4860::8888"}')),
      );
      final fact = await source.fetch(runId: 1, scope: CancellationScope());
      expect(fact.status, DiagnosticFactStatus.failure);
    });

    test('Content-Length > 2048 → failure', () async {
      final source = DioPublicIpSource(
        _dioWith(_FakeAdapter(
          body: '{"ip":"8.8.8.8"}',
          headers: {
            Headers.contentLengthHeader: ['3000'],
          },
        )),
      );
      final fact = await source.fetch(runId: 1, scope: CancellationScope());
      expect(fact.status, DiagnosticFactStatus.failure);
    });

    test('payload maior que 2048 bytes → failure', () async {
      final big = '{"ip":"${'8' * 4000}"}';
      final source = DioPublicIpSource(_dioWith(_FakeAdapter(body: big)));
      final fact = await source.fetch(runId: 1, scope: CancellationScope());
      expect(fact.status, DiagnosticFactStatus.failure);
    });

    test('receiveTimeout → timeout', () async {
      final adapter = _FakeAdapter();
      adapter.throwError = (options) => DioException.receiveTimeout(
            timeout: const Duration(milliseconds: 50),
            requestOptions: options,
          );
      final source = DioPublicIpSource(_dioWith(adapter));
      final fact = await source.fetch(runId: 1, scope: CancellationScope());
      expect(fact.status, DiagnosticFactStatus.timeout);
    });

    test('erro de conexão → failure serviço indisponível', () async {
      final adapter = _FakeAdapter();
      adapter.throwError = (options) => DioException.connectionError(
            requestOptions: options,
            reason: 'no route',
          );
      final source = DioPublicIpSource(_dioWith(adapter));
      final fact = await source.fetch(runId: 1, scope: CancellationScope());
      expect(fact.status, DiagnosticFactStatus.failure);
    });

    test('cancel antes da resposta → cancelled', () async {
      final source = DioPublicIpSource(_dioWith(_FakeAdapter(hang: true)));
      final scope = CancellationScope();

      final future = source.fetch(runId: 1, scope: scope);
      await Future<void>.delayed(Duration.zero);
      await scope.cancelAll();

      final fact = await future;
      expect(fact.status, DiagnosticFactStatus.cancelled);
    });
  });
}
