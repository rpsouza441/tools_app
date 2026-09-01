/// Aggregated latency stats. min/avg/max are null (never Duration.zero) when
/// there were no successful samples (QUAL-05, DIAG-09).
class LatencyAggregate {
  const LatencyAggregate({
    required this.min,
    required this.avg,
    required this.max,
    required this.plannedAttempts,
    required this.completedAttempts,
    required this.successes,
    required this.failures,
    required this.timeouts,
    required this.cancelledCount,
    required this.networkChangedCount,
    required this.denominatorLabel,
  });

  final Duration? min;
  final Duration? avg;
  final Duration? max;
  final int plannedAttempts;
  final int completedAttempts;
  final int successes;
  final int failures;
  final int timeouts;
  final int cancelledCount;
  final int networkChangedCount;

  /// Human label expressing the success denominator, e.g. "3 de 4".
  final String denominatorLabel;

  static const LatencyAggregate empty = LatencyAggregate(
    min: null,
    avg: null,
    max: null,
    plannedAttempts: 0,
    completedAttempts: 0,
    successes: 0,
    failures: 0,
    timeouts: 0,
    cancelledCount: 0,
    networkChangedCount: 0,
    denominatorLabel: '0 de 0',
  );
}
