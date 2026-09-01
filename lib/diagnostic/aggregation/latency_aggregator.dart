import '../models/diagnostic_fact.dart';
import '../models/latency_aggregate.dart';

/// Contract 7 (D-05): pure aggregation of latency samples. min/avg/max come
/// only from successful samples; with zero successes they are null, never
/// Duration.zero (QUAL-05, DIAG-09). cancelled/networkChanged samples are
/// counted separately and never treated as failures.
class LatencyAggregator {
  const LatencyAggregator();

  LatencyAggregate aggregate(
    List<DiagnosticFact> samples, {
    required int plannedAttempts,
  }) {
    final successDurations = <Duration>[];
    var successes = 0;
    var failures = 0;
    var timeouts = 0;
    var cancelledCount = 0;
    var networkChangedCount = 0;

    for (final sample in samples) {
      switch (sample.status) {
        case DiagnosticFactStatus.success:
          successes++;
          final ms = int.tryParse(sample.value ?? '');
          if (ms != null) {
            successDurations.add(Duration(milliseconds: ms));
          }
          break;
        case DiagnosticFactStatus.timeout:
          timeouts++;
          break;
        case DiagnosticFactStatus.failure:
          failures++;
          break;
        case DiagnosticFactStatus.cancelled:
          cancelledCount++;
          break;
        case DiagnosticFactStatus.networkChanged:
          networkChangedCount++;
          break;
        case DiagnosticFactStatus.unavailable:
        case DiagnosticFactStatus.permissionDenied:
          // Not counted toward success or failure denominators.
          break;
      }
    }

    Duration? min;
    Duration? max;
    Duration? avg;
    if (successDurations.isNotEmpty) {
      min = successDurations.reduce((a, b) => a < b ? a : b);
      max = successDurations.reduce((a, b) => a > b ? a : b);
      final totalMicros = successDurations.fold<int>(
        0,
        (sum, d) => sum + d.inMicroseconds,
      );
      avg = Duration(microseconds: totalMicros ~/ successDurations.length);
    }

    final completedAttempts =
        successes + failures + timeouts + cancelledCount + networkChangedCount;

    return LatencyAggregate(
      min: min,
      avg: avg,
      max: max,
      plannedAttempts: plannedAttempts,
      completedAttempts: completedAttempts,
      successes: successes,
      failures: failures,
      timeouts: timeouts,
      cancelledCount: cancelledCount,
      networkChangedCount: networkChangedCount,
      denominatorLabel: '$successes de $plannedAttempts',
    );
  }
}
