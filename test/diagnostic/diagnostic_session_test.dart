// Domain-level QUAL-08 for the session: success, partial, concurrent start,
// gateway-absent, cancel, late-after-cancel. DIAG-01/10/12/14, QUAL-02/05.
import 'package:flutter_test/flutter_test.dart';
import 'package:tools_app/diagnostic/aggregation/latency_aggregator.dart';
import 'package:tools_app/diagnostic/models/diagnostic_fact.dart';
import 'package:tools_app/diagnostic/models/diagnostic_run_state.dart';
import 'package:tools_app/diagnostic/session/diagnostic_session_impl.dart';

import 'fakes.dart';

DiagnosticSessionImpl buildSession({
  required FakeNetworkSnapshotSource snapshot,
  FakePublicIpSource? publicIp,
  FakeInternetProbe? internetProbe,
}) {
  return DiagnosticSessionImpl(
    snapshotSource: snapshot,
    localIpv4Source: FakeLocalIpv4Source(),
    gatewaySource: FakeDefaultGatewaySource(),
    publicIpSource: publicIp ?? FakePublicIpSource(),
    internetProbe: internetProbe ?? FakeInternetProbe(),
    aggregator: const LatencyAggregator(),
  );
}

void main() {
  group('DiagnosticSessionImpl', () {
    test('start com todos os fakes success → phase success, icmp unavailable',
        () async {
      final session = buildSession(
        snapshot: FakeNetworkSnapshotSource(onlineSnapshot()),
      );
      addTearDown(session.dispose);

      await session.start();

      final state = session.state;
      expect(state.phase, DiagnosticRunPhase.success);
      expect(state.publicIpv4.status, DiagnosticFactStatus.success);
      expect(state.localIpv4.status, DiagnosticFactStatus.success);
      expect(state.gateway.status, DiagnosticFactStatus.success);
      expect(state.icmp.status, DiagnosticFactStatus.unavailable);
      expect(state.startedAt, isNotNull);
      expect(state.finishedAt, isNotNull);
    });

    test('segundo start enquanto running é no-op: runId não muda (DIAG-01, concurrent)',
        () async {
      final publicIp = FakePublicIpSource(hang: true);
      final session = buildSession(
        snapshot: FakeNetworkSnapshotSource(onlineSnapshot()),
        publicIp: publicIp,
      );
      addTearDown(session.dispose);

      final first = session.start();
      final runIdWhileRunning = session.state.runId;
      expect(session.state.phase, DiagnosticRunPhase.running);

      await session.start(); // no-op
      expect(session.state.runId, runIdWhileRunning);
      expect(publicIp.calls, 1);

      await session.cancel();
      await first;
    });

    test('publicIp falha, resto sucede → partialFailure e fatos preservados (DIAG-10)',
        () async {
      final publicIp = FakePublicIpSource(
        result: const DiagnosticFact(
          status: DiagnosticFactStatus.failure,
          message: 'ipify indisponível',
        ),
      );
      final session = buildSession(
        snapshot: FakeNetworkSnapshotSource(onlineSnapshot()),
        publicIp: publicIp,
      );
      addTearDown(session.dispose);

      await session.start();

      expect(session.state.phase, DiagnosticRunPhase.partialFailure);
      expect(session.state.publicIpv4.status, DiagnosticFactStatus.failure);
      expect(session.state.localIpv4.status, DiagnosticFactStatus.success);
      expect(session.state.gateway.status, DiagnosticFactStatus.success);
    });

    test('snapshot sem gateway → endereço do gateway indisponível (DIAG-06)',
        () async {
      final session = buildSession(
        snapshot: FakeNetworkSnapshotSource(
          onlineSnapshot(gatewayIpv4: null),
        ),
      );
      addTearDown(session.dispose);

      await session.start();

      expect(session.state.gateway.status, DiagnosticFactStatus.unavailable);
    });

    test('cancel no meio e resposta tardia mantém cancelled (DIAG-12, QUAL-02)',
        () async {
      final publicIp = FakePublicIpSource(hang: true);
      final session = buildSession(
        snapshot: FakeNetworkSnapshotSource(onlineSnapshot()),
        publicIp: publicIp,
      );
      addTearDown(session.dispose);

      final run = session.start();
      expect(session.state.phase, DiagnosticRunPhase.running);

      // Let the snapshot resolve and the fan-out register its physical abort
      // (CancellationScope.register) before cancelling — DIAG-12/QUAL-02 are
      // about aborting in-flight I/O, so the probe must be in flight first.
      await Future<void>.delayed(Duration.zero);

      await session.cancel();
      expect(session.state.phase, DiagnosticRunPhase.cancelled);
      expect(publicIp.aborted, isTrue);

      // Late completion after cancel must not flip the state back.
      publicIp.release(
        const DiagnosticFact(
          status: DiagnosticFactStatus.success,
          value: '203.0.113.9',
        ),
      );
      await run;
      expect(session.state.phase, DiagnosticRunPhase.cancelled);
    });

    test('offline snapshot → phase offline, sem spinner infinito (QUAL-01)',
        () async {
      final session = buildSession(
        snapshot: FakeNetworkSnapshotSource(offlineSnapshot()),
      );
      addTearDown(session.dispose);

      await session.start();

      expect(session.state.phase, DiagnosticRunPhase.offline);
    });
  });
}
