import 'dart:async';
import 'dart:io';

import '../aggregation/latency_aggregator.dart';
import '../contracts/gateway_probe.dart';
import '../models/diagnostic_fact.dart';
import '../models/latency_aggregate.dart';
import '../session/cancellation_scope.dart';
import 'probe_config.dart';

/// Starts a cancellable TCP connection attempt. Injectable for tests so we
/// never require a live CPE. Default is [Socket.startConnect].
typedef ConnectStarter = Future<ConnectionTask<Socket>> Function(
  InternetAddress address,
  int port,
);

Future<ConnectionTask<Socket>> _defaultStarter(
  InternetAddress address,
  int port,
) {
  return Socket.startConnect(address, port);
}

/// TCP-connect probe against the default gateway (DIAG-06, DIAG-08, D-10).
/// Runs N sequential samples, each with a physical timeout that cancels the
/// in-flight ConnectionTask (never Future.timeout alone — D-07). Labelled
/// 'TCP connect', never 'ping'.
class TcpConnectGatewayProbe implements GatewayProbe {
  TcpConnectGatewayProbe({
    this.config = const GatewayProbeConfig(),
    ConnectStarter? connectStarter,
    LatencyAggregator aggregator = const LatencyAggregator(),
  })  : _start = connectStarter ?? _defaultStarter,
        _aggregator = aggregator;

  final GatewayProbeConfig config;
  final ConnectStarter _start;
  final LatencyAggregator _aggregator;

  @override
  Future<ProbeOutcome> probe({
    required String gatewayIpv4,
    required int runId,
    required CancellationScope scope,
  }) async {
    if (gatewayIpv4.isEmpty) {
      // Programmer error — the session must not call this without a gateway.
      throw ArgumentError('gatewayIpv4 must not be empty');
    }

    final address = InternetAddress(gatewayIpv4);
    final provenance = ProbeProvenance(
      method: 'TCP connect',
      target: gatewayIpv4,
      portOrUrl: '$gatewayIpv4:${config.port}',
      timeout: config.timeout,
      limitations: config.limitations,
    );

    final samples = <DiagnosticFact>[];
    for (var i = 0; i < config.sampleCount; i++) {
      if (scope.isCancelled) {
        samples.add(_sample(DiagnosticFactStatus.cancelled, provenance));
        continue;
      }
      samples.add(await _oneSample(address, scope, provenance));
    }

    final aggregate = _aggregator.aggregate(
      samples,
      plannedAttempts: config.sampleCount,
    );
    final summary = _summaryFrom(samples, aggregate, provenance);
    return ProbeOutcome(samples: samples, aggregate: aggregate, summary: summary);
  }

  Future<DiagnosticFact> _oneSample(
    InternetAddress address,
    CancellationScope scope,
    ProbeProvenance provenance,
  ) async {
    final stopwatch = Stopwatch()..start();
    ConnectionTask<Socket>? task;
    Timer? timer;
    var timedOut = false;
    var cancelledByScope = false;

    void abort() {
      cancelledByScope = true;
      task?.cancel();
    }

    scope.register(abort);

    try {
      task = await _start(address, config.port);
      timer = Timer(config.timeout, () {
        timedOut = true;
        task?.cancel();
      });

      final socket = await task.socket;
      stopwatch.stop();
      timer.cancel();
      socket.destroy();
      return DiagnosticFact(
        status: DiagnosticFactStatus.success,
        value: '${stopwatch.elapsedMilliseconds}',
        provenance: provenance,
        occurredAt: DateTime.now(),
      );
    } on SocketException {
      timer?.cancel();
      if (cancelledByScope) {
        return _sample(DiagnosticFactStatus.cancelled, provenance);
      }
      if (timedOut) {
        return _sample(DiagnosticFactStatus.timeout, provenance);
      }
      return _sample(DiagnosticFactStatus.failure, provenance);
    } catch (_) {
      timer?.cancel();
      if (cancelledByScope) {
        return _sample(DiagnosticFactStatus.cancelled, provenance);
      }
      return _sample(DiagnosticFactStatus.failure, provenance);
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
      message: 'Sem resposta TCP do gateway',
      provenance: provenance,
      occurredAt: DateTime.now(),
    );
  }
}
