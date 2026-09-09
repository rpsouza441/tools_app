// Handwritten fakes for the seven diagnostic contracts (D-05, QUAL-08).
// No mockito, no integration_test, no connectivity_plus, no dart_ping.
import 'dart:async';

import 'package:tools_app/diagnostic/contracts/default_gateway_source.dart';
import 'package:tools_app/diagnostic/contracts/internet_probe.dart';
import 'package:tools_app/diagnostic/contracts/local_ipv4_source.dart';
import 'package:tools_app/diagnostic/contracts/network_snapshot_source.dart';
import 'package:tools_app/diagnostic/contracts/public_ip_source.dart';
import 'package:tools_app/diagnostic/contracts/share_text_port.dart';
import 'package:tools_app/diagnostic/models/diagnostic_fact.dart';
import 'package:tools_app/diagnostic/models/latency_aggregate.dart';
import 'package:tools_app/diagnostic/models/network_snapshot.dart';
import 'package:tools_app/diagnostic/session/cancellation_scope.dart';

/// Fake snapshot source returning a fixed snapshot. Counts calls and watch state.
class FakeNetworkSnapshotSource implements NetworkSnapshotSource {
  FakeNetworkSnapshotSource(this._snapshot);

  NetworkSnapshot _snapshot;
  int currentCalls = 0;
  bool watching = false;
  void Function(NetworkSnapshot snapshot)? _onChanged;

  set snapshot(NetworkSnapshot value) => _snapshot = value;

  /// Push a new snapshot to a registered watcher (simulates network change).
  void emit(NetworkSnapshot value) {
    _snapshot = value;
    _onChanged?.call(value);
  }

  @override
  Future<NetworkSnapshot> current() async {
    currentCalls++;
    return _snapshot;
  }

  @override
  Future<void> startWatching(
    void Function(NetworkSnapshot snapshot) onChanged,
  ) async {
    watching = true;
    _onChanged = onChanged;
  }

  @override
  Future<void> stopWatching() async {
    watching = false;
    _onChanged = null;
  }
}

/// Fake public IP source. Can succeed, fail, or hang on a Completer for cancel tests.
class FakePublicIpSource implements PublicIpSource {
  FakePublicIpSource({this.result, this.hang = false});

  DiagnosticFact? result;
  bool hang;
  int calls = 0;
  Completer<DiagnosticFact>? _gate;
  bool aborted = false;

  /// Complete the held gate to simulate a late response after cancel.
  void release(DiagnosticFact fact) {
    final gate = _gate;
    if (gate != null && !gate.isCompleted) {
      gate.complete(fact);
    }
  }

  @override
  Future<DiagnosticFact> fetch({
    required int runId,
    required CancellationScope scope,
  }) async {
    calls++;
    if (hang) {
      final gate = Completer<DiagnosticFact>();
      _gate = gate;
      scope.register(() {
        aborted = true;
        if (!gate.isCompleted) {
          gate.complete(
            const DiagnosticFact(status: DiagnosticFactStatus.cancelled),
          );
        }
      });
      return gate.future;
    }
    return result ??
        const DiagnosticFact(
          status: DiagnosticFactStatus.success,
          value: '203.0.113.7',
        );
  }
}

/// Fake internet probe.
class FakeInternetProbe implements InternetProbe {
  FakeInternetProbe({this.outcome, this.shouldFail = false});

  ProbeOutcome? outcome;
  bool shouldFail;
  int calls = 0;

  @override
  Future<ProbeOutcome> probe({
    required int runId,
    required CancellationScope scope,
  }) async {
    calls++;
    if (shouldFail) {
      throw StateError('probe failed');
    }
    return outcome ??
        _successOutcome('HTTPS', 'https://www.gstatic.com/generate_204');
  }
}

/// Fake share port recording the last shared text.
class FakeShareTextPort implements ShareTextPort {
  String? lastShared;
  int calls = 0;

  @override
  Future<void> share(String text) async {
    calls++;
    lastShared = text;
  }
}

ProbeOutcome _successOutcome(String method, String target) {
  final provenance = ProbeProvenance(
    method: method,
    target: target,
    portOrUrl: target,
    timeout: const Duration(seconds: 2),
    limitations: 'TCP connect não é ICMP',
  );
  final samples = [
    DiagnosticFact(
      status: DiagnosticFactStatus.success,
      value: '10',
      provenance: provenance,
    ),
    DiagnosticFact(
      status: DiagnosticFactStatus.success,
      value: '20',
      provenance: provenance,
    ),
  ];
  const aggregate = LatencyAggregate(
    min: Duration(milliseconds: 10),
    avg: Duration(milliseconds: 15),
    max: Duration(milliseconds: 20),
    plannedAttempts: 2,
    completedAttempts: 2,
    successes: 2,
    failures: 0,
    timeouts: 0,
    cancelledCount: 0,
    networkChangedCount: 0,
    denominatorLabel: '2 de 2',
  );
  return ProbeOutcome(
    samples: samples,
    aggregate: aggregate,
    summary: DiagnosticFact(
      status: DiagnosticFactStatus.success,
      value: '15 ms',
      provenance: provenance,
    ),
  );
}

/// Local source that reads only the snapshot (never NetworkInterface.list).
class FakeLocalIpv4Source implements LocalIpv4Source {
  @override
  DiagnosticFact fromSnapshot(NetworkSnapshot snapshot) {
    final ip = snapshot.localIpv4;
    if (ip == null) {
      return const DiagnosticFact(
        status: DiagnosticFactStatus.unavailable,
        message: 'IPv4 local indisponível',
      );
    }
    return DiagnosticFact(status: DiagnosticFactStatus.success, value: ip);
  }
}

/// Gateway source reading only the snapshot.
class FakeDefaultGatewaySource implements DefaultGatewaySource {
  @override
  DiagnosticFact fromSnapshot(NetworkSnapshot snapshot) {
    final gw = snapshot.gatewayIpv4;
    if (gw == null) {
      return const DiagnosticFact(
        status: DiagnosticFactStatus.unavailable,
        message: 'Gateway indisponível',
      );
    }
    return DiagnosticFact(status: DiagnosticFactStatus.success, value: gw);
  }
}

/// Convenience snapshot builders for tests.
NetworkSnapshot onlineSnapshot({
  String? localIpv4 = '192.168.0.42',
  String? gatewayIpv4 = '192.168.0.1',
  int networkHandle = 1,
}) {
  return NetworkSnapshot(
    hasActiveNetwork: true,
    transports: const ['wifi'],
    hasInternet: true,
    validated: true,
    captivePortal: false,
    notMetered: true,
    localIpv4: localIpv4,
    gatewayIpv4: gatewayIpv4,
    networkHandle: networkHandle,
  );
}

NetworkSnapshot offlineSnapshot() {
  return const NetworkSnapshot(
    hasActiveNetwork: false,
    transports: [],
    hasInternet: null,
    validated: null,
    captivePortal: null,
    notMetered: null,
    localIpv4: null,
    gatewayIpv4: null,
    networkHandle: null,
  );
}
