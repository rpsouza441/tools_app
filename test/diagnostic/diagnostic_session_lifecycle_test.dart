// QUAL-03 network change mid-run + QUAL-04/DIAG-12 dispose-after-start.
// Handwritten fakes, no integration_test.
import 'package:flutter_test/flutter_test.dart';
import 'package:tools_app/diagnostic/aggregation/latency_aggregator.dart';
import 'package:tools_app/diagnostic/models/diagnostic_fact.dart';
import 'package:tools_app/diagnostic/models/diagnostic_run_state.dart';
import 'package:tools_app/diagnostic/models/network_snapshot.dart';
import 'package:tools_app/diagnostic/session/diagnostic_session_impl.dart';

import 'fakes.dart';

void main() {
  test('networkChanged mid-run: fatos em voo viram networkChanged, sem mistura (QUAL-03)',
      () async {
    final snapshot = FakeNetworkSnapshotSource(
      onlineSnapshot(networkHandle: 1),
    );
    final publicIp = FakePublicIpSource(hang: true);
    final session = DiagnosticSessionImpl(
      snapshotSource: snapshot,
      localIpv4Source: FakeLocalIpv4Source(),
      gatewaySource: FakeDefaultGatewaySource(),
      publicIpSource: publicIp,
      internetProbe: FakeInternetProbe(),
      aggregator: const LatencyAggregator(),
    );
    addTearDown(session.dispose);

    final run = session.start();
    await Future<void>.delayed(Duration.zero);

    // Wi-Fi -> cellular with a different handle during the run.
    snapshot.emit(
      const NetworkSnapshot(
        hasActiveNetwork: true,
        transports: ['cellular'],
        hasInternet: true,
        validated: true,
        captivePortal: false,
        notMetered: false,
        localIpv4: '10.1.1.5',
        gatewayIpv4: '10.1.1.1',
        networkHandle: 2,
      ),
    );

    await run;

    expect(session.state.phase, DiagnosticRunPhase.partialFailure);
    // The public IP sample that was in flight is relabelled networkChanged,
    // never counted as a success.
    expect(
      session.state.publicIpv4.status,
      DiagnosticFactStatus.networkChanged,
    );
  });

  test('dispose after start ignora resultado tardio (QUAL-04, DIAG-12)',
      () async {
    final publicIp = FakePublicIpSource(hang: true);
    final session = DiagnosticSessionImpl(
      snapshotSource: FakeNetworkSnapshotSource(onlineSnapshot()),
      localIpv4Source: FakeLocalIpv4Source(),
      gatewaySource: FakeDefaultGatewaySource(),
      publicIpSource: publicIp,
      internetProbe: FakeInternetProbe(),
      aggregator: const LatencyAggregator(),
    );

    final run = session.start();
    await Future<void>.delayed(Duration.zero);

    // Dispose while running — must abort registered I/O and not throw when a
    // late result completes afterwards.
    session.dispose();
    publicIp.release(
      const DiagnosticFact(
        status: DiagnosticFactStatus.success,
        value: '203.0.113.1',
      ),
    );

    // No exception should escape from the late completion.
    await run;
  });
}
