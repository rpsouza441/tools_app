import 'diagnostic_fact.dart';
import 'latency_aggregate.dart';
import 'network_snapshot.dart';

/// Coarse phase of a run, observed by the UI (D-06).
enum DiagnosticRunPhase { idle, running, success, partialFailure, cancelled, offline }

/// Immutable state of a single diagnostic run. Timestamps live in memory only —
/// nothing is persisted (DIAG-14, D-11). Named facts survive independently.
class DiagnosticRunState {
  const DiagnosticRunState({
    required this.runId,
    required this.phase,
    this.startedAt,
    this.finishedAt,
    this.snapshot,
    this.transport = DiagnosticFact.unavailable,
    this.internetCapability = DiagnosticFact.unavailable,
    this.validated = DiagnosticFact.unavailable,
    this.captivePortal = DiagnosticFact.unavailable,
    this.localIpv4 = DiagnosticFact.unavailable,
    this.gateway = DiagnosticFact.unavailable,
    this.publicIpv4 = DiagnosticFact.unavailable,
    this.internetProbe = DiagnosticFact.unavailable,
    this.icmp = _icmpUnavailable,
    this.internetLatency,
  });

  final int runId;
  final DiagnosticRunPhase phase;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final NetworkSnapshot? snapshot;

  final DiagnosticFact transport;
  final DiagnosticFact internetCapability;
  final DiagnosticFact validated;
  final DiagnosticFact captivePortal;
  final DiagnosticFact localIpv4;
  final DiagnosticFact gateway;
  final DiagnosticFact publicIpv4;
  final DiagnosticFact internetProbe;

  /// ICMP is always unavailable in the MVP (D-10).
  final DiagnosticFact icmp;

  final LatencyAggregate? internetLatency;

  static const DiagnosticFact _icmpUnavailable = DiagnosticFact(
    status: DiagnosticFactStatus.unavailable,
    message: 'Indisponível neste MVP',
  );

  static const DiagnosticRunState initial = DiagnosticRunState(
    runId: 0,
    phase: DiagnosticRunPhase.idle,
  );

  DiagnosticRunState copyWith({
    int? runId,
    DiagnosticRunPhase? phase,
    DateTime? startedAt,
    DateTime? finishedAt,
    NetworkSnapshot? snapshot,
    DiagnosticFact? transport,
    DiagnosticFact? internetCapability,
    DiagnosticFact? validated,
    DiagnosticFact? captivePortal,
    DiagnosticFact? localIpv4,
    DiagnosticFact? gateway,
    DiagnosticFact? publicIpv4,
    DiagnosticFact? internetProbe,
    DiagnosticFact? icmp,
    LatencyAggregate? internetLatency,
  }) {
    return DiagnosticRunState(
      runId: runId ?? this.runId,
      phase: phase ?? this.phase,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      snapshot: snapshot ?? this.snapshot,
      transport: transport ?? this.transport,
      internetCapability: internetCapability ?? this.internetCapability,
      validated: validated ?? this.validated,
      captivePortal: captivePortal ?? this.captivePortal,
      localIpv4: localIpv4 ?? this.localIpv4,
      gateway: gateway ?? this.gateway,
      publicIpv4: publicIpv4 ?? this.publicIpv4,
      internetProbe: internetProbe ?? this.internetProbe,
      icmp: icmp ?? this.icmp,
      internetLatency: internetLatency ?? this.internetLatency,
    );
  }
}
