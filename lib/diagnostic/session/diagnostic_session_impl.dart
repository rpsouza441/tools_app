import 'package:flutter/foundation.dart';

import '../aggregation/latency_aggregator.dart';
import '../contracts/default_gateway_source.dart';
import '../contracts/diagnostic_session.dart';
import '../contracts/gateway_probe.dart';
import '../contracts/internet_probe.dart';
import '../contracts/local_ipv4_source.dart';
import '../contracts/network_snapshot_source.dart';
import '../contracts/public_ip_source.dart';
import '../models/diagnostic_fact.dart';
import '../models/diagnostic_run_state.dart';
import '../models/network_snapshot.dart';
import 'cancellation_scope.dart';

/// Orchestrates one diagnostic run at a time (DIAG-01, D-08) with a runId guard
/// against late results (DIAG-12, QUAL-02) and independent fan-out so a single
/// contract failure never erases sibling facts (DIAG-10). Widgets observe
/// [listenable]; the session never touches Flutter widgets or setState (D-06).
///
/// The seven D-05 roles are injected separately — there is no NetworkService.
class DiagnosticSessionImpl implements DiagnosticSession {
  DiagnosticSessionImpl({
    required NetworkSnapshotSource snapshotSource,
    required LocalIpv4Source localIpv4Source,
    required DefaultGatewaySource gatewaySource,
    required PublicIpSource publicIpSource,
    required GatewayProbe gatewayProbe,
    required InternetProbe internetProbe,
    required LatencyAggregator aggregator,
  })  : _snapshotSource = snapshotSource,
        _localIpv4Source = localIpv4Source,
        _gatewaySource = gatewaySource,
        _publicIpSource = publicIpSource,
        _gatewayProbe = gatewayProbe,
        _internetProbe = internetProbe,
        // aggregator kept for symmetry; probes own their own aggregation.
        _aggregator = aggregator;

  final NetworkSnapshotSource _snapshotSource;
  final LocalIpv4Source _localIpv4Source;
  final DefaultGatewaySource _gatewaySource;
  final PublicIpSource _publicIpSource;
  final GatewayProbe _gatewayProbe;
  final InternetProbe _internetProbe;
  // ignore: unused_field
  final LatencyAggregator _aggregator;

  final ValueNotifier<DiagnosticRunState> _notifier =
      ValueNotifier<DiagnosticRunState>(DiagnosticRunState.initial);

  int _runId = 0;
  CancellationScope? _scope;

  @override
  ValueListenable<DiagnosticRunState> get listenable => _notifier;

  @override
  DiagnosticRunState get state => _notifier.value;

  bool get _isRunning => _notifier.value.phase == DiagnosticRunPhase.running;

  @override
  Future<void> start() async {
    // One run at a time: a second start while running is a no-op (DIAG-01).
    if (_isRunning) return;

    final runId = ++_runId;
    final scope = CancellationScope();
    _scope = scope;

    _notifier.value = DiagnosticRunState(
      runId: runId,
      phase: DiagnosticRunPhase.running,
      startedAt: DateTime.now(),
    );

    // 1. Platform snapshot (contract 1) + derived platform facts.
    final snapshot = await _snapshotSource.current();
    if (_isStale(runId, scope)) return;

    _publishSnapshotFacts(runId, snapshot);

    // Offline: no active network → honest offline phase, no infinite spinner.
    if (!snapshot.hasActiveNetwork) {
      _finish(
        runId,
        DiagnosticRunPhase.offline,
      );
      return;
    }

    final localFact = _localIpv4Source.fromSnapshot(snapshot);
    final gatewayFact = _gatewaySource.fromSnapshot(snapshot);
    _update(runId, (s) => s.copyWith(localIpv4: localFact, gateway: gatewayFact));

    // 2. Independent fan-out. Each branch captures its own error so a failure
    //    produces a failure fact instead of aborting the whole run (DIAG-10).
    final publicIpFuture = _runPublicIp(runId, scope);
    final internetFuture = _runInternetProbe(runId, scope);
    final Future<void> gatewayProbeFuture;
    if (snapshot.gatewayIpv4 != null) {
      gatewayProbeFuture = _runGatewayProbe(runId, scope, snapshot.gatewayIpv4!);
    } else {
      _markGatewayProbeUnavailable(runId);
      gatewayProbeFuture = Future<void>.value();
    }

    await Future.wait<void>([
      publicIpFuture,
      internetFuture,
      gatewayProbeFuture,
    ]);

    if (_isStale(runId, scope)) return;

    _finish(runId, _deriveTerminalPhase(runId));
  }

  Future<void> _runPublicIp(int runId, CancellationScope scope) async {
    try {
      final fact = await _publicIpSource.fetch(runId: runId, scope: scope);
      if (_isStale(runId, scope)) return;
      _update(runId, (s) => s.copyWith(publicIpv4: fact));
    } catch (e) {
      if (_isStale(runId, scope)) return;
      _update(
        runId,
        (s) => s.copyWith(
          publicIpv4: DiagnosticFact(
            status: DiagnosticFactStatus.failure,
            message: 'Falha ao obter IP público: $e',
          ),
        ),
      );
    }
  }

  Future<void> _runInternetProbe(int runId, CancellationScope scope) async {
    try {
      final outcome = await _internetProbe.probe(runId: runId, scope: scope);
      if (_isStale(runId, scope)) return;
      _update(
        runId,
        (s) => s.copyWith(
          internetProbe: outcome.summary,
          internetLatency: outcome.aggregate,
        ),
      );
    } catch (e) {
      if (_isStale(runId, scope)) return;
      _update(
        runId,
        (s) => s.copyWith(
          internetProbe: DiagnosticFact(
            status: DiagnosticFactStatus.failure,
            message: 'Falha no probe de internet: $e',
          ),
        ),
      );
    }
  }

  Future<void> _runGatewayProbe(
    int runId,
    CancellationScope scope,
    String gatewayIpv4,
  ) async {
    try {
      final outcome = await _gatewayProbe.probe(
        gatewayIpv4: gatewayIpv4,
        runId: runId,
        scope: scope,
      );
      if (_isStale(runId, scope)) return;
      _update(
        runId,
        (s) => s.copyWith(
          gatewayProbe: outcome.summary,
          gatewayLatency: outcome.aggregate,
        ),
      );
    } catch (e) {
      if (_isStale(runId, scope)) return;
      _update(
        runId,
        (s) => s.copyWith(
          gatewayProbe: DiagnosticFact(
            status: DiagnosticFactStatus.failure,
            message: 'Falha no probe de gateway: $e',
          ),
        ),
      );
    }
  }

  void _markGatewayProbeUnavailable(int runId) {
    _update(
      runId,
      (s) => s.copyWith(
        gatewayProbe: const DiagnosticFact(
          status: DiagnosticFactStatus.unavailable,
          message: 'Sem gateway: probe não executado',
        ),
      ),
    );
  }

  void _publishSnapshotFacts(int runId, NetworkSnapshot snapshot) {
    DiagnosticFact boolFact(bool? value, String label) {
      if (value == null) {
        return const DiagnosticFact(status: DiagnosticFactStatus.unavailable);
      }
      return DiagnosticFact(
        status: DiagnosticFactStatus.success,
        value: value ? 'Sim' : 'Não',
        message: label,
      );
    }

    final transportFact = snapshot.hasActiveNetwork && snapshot.transports.isNotEmpty
        ? DiagnosticFact(
            status: DiagnosticFactStatus.success,
            value: snapshot.transports.join(', '),
          )
        : const DiagnosticFact(
            status: DiagnosticFactStatus.unavailable,
            message: 'Sem rede ativa',
          );

    _update(
      runId,
      (s) => s.copyWith(
        snapshot: snapshot,
        transport: transportFact,
        internetCapability: boolFact(snapshot.hasInternet, 'INTERNET'),
        validated: boolFact(snapshot.validated, 'VALIDATED'),
        captivePortal: boolFact(snapshot.captivePortal, 'CAPTIVE_PORTAL'),
      ),
    );
  }

  DiagnosticRunPhase _deriveTerminalPhase(int runId) {
    final s = _notifier.value;
    final facts = <DiagnosticFact>[
      s.localIpv4,
      s.gateway,
      s.publicIpv4,
      s.gatewayProbe,
      s.internetProbe,
    ];
    final anyFailure = facts.any(
      (f) =>
          f.status == DiagnosticFactStatus.failure ||
          f.status == DiagnosticFactStatus.timeout,
    );
    return anyFailure
        ? DiagnosticRunPhase.partialFailure
        : DiagnosticRunPhase.success;
  }

  @override
  Future<void> cancel() async {
    if (!_isRunning) return;
    final runId = _notifier.value.runId;
    await _scope?.cancelAll();
    _update(
      runId,
      (s) => s.copyWith(
        phase: DiagnosticRunPhase.cancelled,
        finishedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> refreshSnapshotOnly() async {
    // Fresh platform facts without starting probes (QUAL-04 preparation).
    final runId = _notifier.value.runId;
    final snapshot = await _snapshotSource.current();
    if (runId != _notifier.value.runId) return;
    _publishSnapshotFacts(runId, snapshot);
    if (snapshot.hasActiveNetwork) {
      _update(
        runId,
        (s) => s.copyWith(
          localIpv4: _localIpv4Source.fromSnapshot(snapshot),
          gateway: _gatewaySource.fromSnapshot(snapshot),
        ),
      );
    }
  }

  @override
  void dispose() {
    _scope?.cancelAll();
    _notifier.dispose();
  }

  // --- helpers -------------------------------------------------------------

  bool _isStale(int runId, CancellationScope scope) {
    return runId != _runId || scope.isCancelled || _notifier.value.runId != runId;
  }

  void _update(
    int runId,
    DiagnosticRunState Function(DiagnosticRunState) transform,
  ) {
    // Only mutate if this update belongs to the current run and it has not
    // already reached a terminal cancelled state (late results ignored).
    if (runId != _notifier.value.runId) return;
    if (_notifier.value.phase == DiagnosticRunPhase.cancelled) return;
    _notifier.value = transform(_notifier.value);
  }

  void _finish(int runId, DiagnosticRunPhase phase) {
    if (runId != _notifier.value.runId) return;
    if (_notifier.value.phase == DiagnosticRunPhase.cancelled) return;
    _notifier.value = _notifier.value.copyWith(
      phase: phase,
      finishedAt: DateTime.now(),
    );
  }
}
