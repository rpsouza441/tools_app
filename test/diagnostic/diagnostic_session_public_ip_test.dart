// DIAG-10 at the session level: a public-IP failure yields partialFailure but
// leaves sibling facts (localIpv4, gateway) intact. Uses 03-01 fakes.
import 'package:flutter_test/flutter_test.dart';
import 'package:tools_app/diagnostic/aggregation/latency_aggregator.dart';
import 'package:tools_app/diagnostic/models/diagnostic_fact.dart';
import 'package:tools_app/diagnostic/models/diagnostic_run_state.dart';
import 'package:tools_app/diagnostic/session/diagnostic_session_impl.dart';

import 'fakes.dart';

void main() {
  test('public IP failure → partialFailure, localIpv4 intacto (DIAG-10)',
      () async {
    final session = DiagnosticSessionImpl(
      snapshotSource: FakeNetworkSnapshotSource(onlineSnapshot()),
      localIpv4Source: FakeLocalIpv4Source(),
      gatewaySource: FakeDefaultGatewaySource(),
      publicIpSource: FakePublicIpSource(
        result: const DiagnosticFact(
          status: DiagnosticFactStatus.failure,
          message: 'ipify indisponível',
        ),
      ),
      gatewayProbe: FakeGatewayProbe(),
      internetProbe: FakeInternetProbe(),
      aggregator: const LatencyAggregator(),
    );
    addTearDown(session.dispose);

    await session.start();

    expect(session.state.phase, DiagnosticRunPhase.partialFailure);
    expect(session.state.publicIpv4.status, DiagnosticFactStatus.failure);
    expect(session.state.localIpv4.status, DiagnosticFactStatus.success);
    expect(session.state.gateway.status, DiagnosticFactStatus.success);
  });
}
