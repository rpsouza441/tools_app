// Session-level probe wiring: gateway-absent skips the gateway probe; a gateway
// probe timeout does not prevent the internet probe from running (DIAG-06/10).
import 'package:flutter_test/flutter_test.dart';
import 'package:tools_app/diagnostic/aggregation/latency_aggregator.dart';
import 'package:tools_app/diagnostic/contracts/gateway_probe.dart';
import 'package:tools_app/diagnostic/models/diagnostic_fact.dart';
import 'package:tools_app/diagnostic/models/latency_aggregate.dart';
import 'package:tools_app/diagnostic/session/diagnostic_session_impl.dart';

import 'fakes.dart';

DiagnosticSessionImpl _session({
  required FakeNetworkSnapshotSource snapshot,
  FakeGatewayProbe? gatewayProbe,
  FakeInternetProbe? internetProbe,
}) {
  return DiagnosticSessionImpl(
    snapshotSource: snapshot,
    localIpv4Source: FakeLocalIpv4Source(),
    gatewaySource: FakeDefaultGatewaySource(),
    publicIpSource: FakePublicIpSource(),
    gatewayProbe: gatewayProbe ?? FakeGatewayProbe(),
    internetProbe: internetProbe ?? FakeInternetProbe(),
    aggregator: const LatencyAggregator(),
  );
}

ProbeOutcome _timeoutOutcome() {
  const aggregate = LatencyAggregate(
    min: null,
    avg: null,
    max: null,
    plannedAttempts: 4,
    completedAttempts: 4,
    successes: 0,
    failures: 0,
    timeouts: 4,
    cancelledCount: 0,
    networkChangedCount: 0,
    denominatorLabel: '0 de 4',
  );
  return const ProbeOutcome(
    samples: [],
    aggregate: aggregate,
    summary: DiagnosticFact(
      status: DiagnosticFactStatus.timeout,
      message: 'timeout',
    ),
  );
}

void main() {
  test('snapshot sem gateway → gatewayProbe.probe count 0 (DIAG-06)', () async {
    final gatewayProbe = FakeGatewayProbe();
    final session = _session(
      snapshot: FakeNetworkSnapshotSource(onlineSnapshot(gatewayIpv4: null)),
      gatewayProbe: gatewayProbe,
    );
    addTearDown(session.dispose);

    await session.start();

    expect(gatewayProbe.calls, 0);
    expect(session.state.gatewayProbe.status, DiagnosticFactStatus.unavailable);
  });

  test('gateway probe timeout não impede o internet probe (DIAG-10)',
      () async {
    final gatewayProbe = FakeGatewayProbe(outcome: _timeoutOutcome());
    final internetProbe = FakeInternetProbe();
    final session = _session(
      snapshot: FakeNetworkSnapshotSource(onlineSnapshot()),
      gatewayProbe: gatewayProbe,
      internetProbe: internetProbe,
    );
    addTearDown(session.dispose);

    await session.start();

    expect(gatewayProbe.calls, 1);
    expect(internetProbe.calls, 1);
    expect(session.state.internetProbe.status, DiagnosticFactStatus.success);
    expect(session.state.gatewayProbe.status, DiagnosticFactStatus.timeout);
  });
}
