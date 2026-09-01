// DIAG-09 aggregation + QUAL-05 honest empty behaviour.
import 'package:flutter_test/flutter_test.dart';
import 'package:tools_app/diagnostic/aggregation/latency_aggregator.dart';
import 'package:tools_app/diagnostic/models/diagnostic_fact.dart';
import 'package:tools_app/diagnostic/models/latency_aggregate.dart';

DiagnosticFact _sample(DiagnosticFactStatus status, {String? ms}) =>
    DiagnosticFact(status: status, value: ms);

void main() {
  const aggregator = LatencyAggregator();

  group('LatencyAggregator', () {
    test('3 sucessos + 1 timeout: min/avg/max e denominador (DIAG-09)', () {
      final samples = [
        _sample(DiagnosticFactStatus.success, ms: '10'),
        _sample(DiagnosticFactStatus.success, ms: '20'),
        _sample(DiagnosticFactStatus.success, ms: '30'),
        _sample(DiagnosticFactStatus.timeout),
      ];

      final LatencyAggregate result = aggregator.aggregate(
        samples,
        plannedAttempts: 4,
      );

      expect(result.min, const Duration(milliseconds: 10));
      expect(result.max, const Duration(milliseconds: 30));
      expect(result.avg, const Duration(milliseconds: 20));
      expect(result.successes, 3);
      expect(result.failures + result.timeouts, greaterThanOrEqualTo(1));
      expect(result.timeouts, 1);
      expect(result.plannedAttempts, 4);
      expect(result.denominatorLabel, contains('3'));
      expect(result.denominatorLabel, contains('4'));
    });

    test('zero sucessos: min/avg/max null, sem throw, sem zero (QUAL-05)', () {
      final samples = [
        _sample(DiagnosticFactStatus.timeout),
        _sample(DiagnosticFactStatus.failure),
      ];

      final result = aggregator.aggregate(samples, plannedAttempts: 2);

      expect(result.min, isNull);
      expect(result.avg, isNull);
      expect(result.max, isNull);
      expect(result.successes, 0);
    });

    test('cancelled e networkChanged não entram no denominador de falha', () {
      final samples = [
        _sample(DiagnosticFactStatus.success, ms: '12'),
        _sample(DiagnosticFactStatus.cancelled),
        _sample(DiagnosticFactStatus.networkChanged),
      ];

      final result = aggregator.aggregate(samples, plannedAttempts: 4);

      expect(result.successes, 1);
      expect(result.cancelledCount, 1);
      expect(result.networkChangedCount, 1);
      // Falhas reais não incluem cancel/networkChanged.
      expect(result.failures, 0);
      expect(result.timeouts, 0);
    });
  });
}
