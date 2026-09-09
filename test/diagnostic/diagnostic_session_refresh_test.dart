import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tools_app/diagnostic/aggregation/latency_aggregator.dart';
import 'package:tools_app/diagnostic/models/diagnostic_fact.dart';
import 'package:tools_app/diagnostic/models/diagnostic_run_state.dart';
import 'package:tools_app/diagnostic/models/network_snapshot.dart';
import 'package:tools_app/diagnostic/session/diagnostic_session_impl.dart';
import 'package:tools_app/diagnostic/session/diagnostic_summary_formatter.dart';

import 'fakes.dart';

const cellular = NetworkSnapshot(
  hasActiveNetwork: true,
  transports: ['cellular'],
  hasInternet: true,
  validated: true,
  captivePortal: false,
  notMetered: false,
  localIpv4: '192.0.0.2',
  gatewayIpv4: '192.0.0.1',
  networkHandle: 2,
);

DiagnosticSessionImpl createSession(
  FakeNetworkSnapshotSource source, {
  FakePublicIpSource? publicIp,
}) => DiagnosticSessionImpl(
  snapshotSource: source,
  localIpv4Source: FakeLocalIpv4Source(),
  gatewaySource: FakeDefaultGatewaySource(),
  publicIpSource: publicIp ?? FakePublicIpSource(),
  gatewayProbe: FakeGatewayProbe(),
  internetProbe: FakeInternetProbe(),
  aggregator: const LatencyAggregator(),
);

void main() {
  for (final partial in [false, true]) {
    test(
      'resume preserva resultado e resumo (partial=$partial); repetir usa nova rede',
      () async {
        final source = FakeNetworkSnapshotSource(cellular);
        final session = createSession(
          source,
          publicIp: FakePublicIpSource(
            result: partial
                ? const DiagnosticFact(status: DiagnosticFactStatus.failure)
                : null,
          ),
        );
        addTearDown(session.dispose);
        await session.start();
        final completed = session.state;
        const formatter = DiagnosticSummaryFormatter();
        final summary = formatter.format(completed);
        expect(
          completed.phase,
          partial
              ? DiagnosticRunPhase.partialFailure
              : DiagnosticRunPhase.success,
        );

        source.snapshot = onlineSnapshot();
        await session.refreshSnapshotOnly();
        expect(session.state, same(completed));
        expect(formatter.format(session.state), summary);
        expect(session.state.transport.value, 'cellular');
        expect(
          session.state.gatewayProbe.provenance!.portOrUrl,
          '192.0.0.1:80',
        );

        await session.start();
        expect(session.state.runId, completed.runId + 1);
        expect(session.state.transport.value, 'wifi');
        expect(session.state.gateway.value, '192.168.0.1');
        expect(
          session.state.gatewayProbe.provenance!.portOrUrl,
          '192.168.0.1:80',
        );
      },
    );
  }

  test('refresh idle atualiza rede e limpa endereços quando offline', () async {
    final source = FakeNetworkSnapshotSource(cellular);
    final session = createSession(source);
    addTearDown(session.dispose);
    await session.refreshSnapshotOnly();
    expect(session.state.transport.value, 'cellular');
    source.snapshot = offlineSnapshot();
    await session.refreshSnapshotOnly();
    expect(session.state.phase, DiagnosticRunPhase.idle);
    expect(session.state.localIpv4.status, DiagnosticFactStatus.unavailable);
    expect(session.state.gateway.status, DiagnosticFactStatus.unavailable);
  });

  test('refresh durante execução não substitui contexto', () async {
    final source = FakeNetworkSnapshotSource(cellular);
    final session = createSession(
      source,
      publicIp: FakePublicIpSource(hang: true),
    );
    addTearDown(session.dispose);
    final run = session.start();
    await Future<void>.delayed(Duration.zero);
    final running = session.state;
    source.snapshot = onlineSnapshot();
    await session.refreshSnapshotOnly();
    expect(session.state, same(running));
    await session.cancel();
    await run;
  });

  test('refresh pendente não altera nova execução', () async {
    final source = DelayedSnapshotSource();
    final session = createSession(source);
    addTearDown(session.dispose);
    final refresh = session.refreshSnapshotOnly();
    await session.start();
    final completed = session.state;
    source.pending.complete(onlineSnapshot());
    await refresh;
    expect(session.state, same(completed));
  });

  test('refresh pendente é ignorado após dispose', () async {
    final source = DelayedSnapshotSource();
    final session = createSession(source);
    final refresh = session.refreshSnapshotOnly();
    session.dispose();
    source.pending.complete(onlineSnapshot());
    await refresh;
  });
}

class DelayedSnapshotSource extends FakeNetworkSnapshotSource {
  DelayedSnapshotSource() : super(cellular);
  final pending = Completer<NetworkSnapshot>();
  bool first = true;

  @override
  Future<NetworkSnapshot> current() {
    if (first) {
      first = false;
      return pending.future;
    }
    return super.current();
  }
}
