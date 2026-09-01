// TCP connect gateway probe: success via loopback, timeout, cancel, empty host.
// Uses an injectable ConnectStarter to avoid depending on a live gateway.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tools_app/diagnostic/models/diagnostic_fact.dart';
import 'package:tools_app/diagnostic/probes/probe_config.dart';
import 'package:tools_app/diagnostic/probes/tcp_connect_probe.dart';
import 'package:tools_app/diagnostic/session/cancellation_scope.dart';

void main() {
  group('TcpConnectGatewayProbe', () {
    late ServerSocket server;

    setUp(() async {
      server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((socket) => socket.destroy());
    });

    tearDown(() async {
      await server.close();
    });

    test('4 conexões bem-sucedidas → success, method TCP connect (DIAG-08)',
        () async {
      final probe = TcpConnectGatewayProbe(
        config: const GatewayProbeConfig(sampleCount: 4),
        connectStarter: (address, port) =>
            Socket.startConnect(InternetAddress.loopbackIPv4, server.port),
      );

      final outcome = await probe.probe(
        gatewayIpv4: '127.0.0.1',
        runId: 1,
        scope: CancellationScope(),
      );

      expect(outcome.aggregate.successes, 4);
      expect(outcome.summary.status, DiagnosticFactStatus.success);
      expect(outcome.summary.provenance?.method, 'TCP connect');
      expect(outcome.aggregate.plannedAttempts, 4);
    });

    test('starter que não conecta a tempo → timeout, sem hang (D-07)',
        () async {
      // TEST-NET-1 (RFC 5737) is guaranteed non-routable; the connect hangs
      // until the probe's own timeout Timer cancels the ConnectionTask.
      final probe = TcpConnectGatewayProbe(
        config: const GatewayProbeConfig(
          sampleCount: 1,
          timeout: Duration(milliseconds: 100),
        ),
        connectStarter: (address, port) =>
            Socket.startConnect(InternetAddress('192.0.2.1'), port),
      );

      final outcome = await probe.probe(
        gatewayIpv4: '192.0.2.1',
        runId: 1,
        scope: CancellationScope(),
      );

      expect(
        outcome.samples.single.status,
        anyOf(
          DiagnosticFactStatus.timeout,
          // On some hosts the OS rejects instantly; either is a non-success
          // honest outcome, never a hang or invented success.
          DiagnosticFactStatus.failure,
        ),
      );
    });

    test('scope cancelado → amostras cancelled', () async {
      final scope = CancellationScope();
      await scope.cancelAll();

      final probe = TcpConnectGatewayProbe(
        config: const GatewayProbeConfig(sampleCount: 3),
        connectStarter: (address, port) =>
            Socket.startConnect(InternetAddress('192.0.2.1'), port),
      );

      final outcome = await probe.probe(
        gatewayIpv4: '192.0.2.1',
        runId: 1,
        scope: scope,
      );

      expect(
        outcome.samples.every(
          (s) => s.status == DiagnosticFactStatus.cancelled,
        ),
        isTrue,
      );
    });

    test('host vazio → ArgumentError (não inventar IP)', () async {
      final probe = TcpConnectGatewayProbe();
      expect(
        () => probe.probe(
          gatewayIpv4: '',
          runId: 1,
          scope: CancellationScope(),
        ),
        throwsArgumentError,
      );
    });

    test('provenance nunca contém "ping"', () async {
      final probe = TcpConnectGatewayProbe(
        config: const GatewayProbeConfig(sampleCount: 1),
        connectStarter: (address, port) =>
            Socket.startConnect(InternetAddress.loopbackIPv4, server.port),
      );
      final outcome = await probe.probe(
        gatewayIpv4: '127.0.0.1',
        runId: 1,
        scope: CancellationScope(),
      );
      expect(outcome.summary.provenance!.method.toLowerCase(), isNot(contains('ping')));
    });
  });
}
