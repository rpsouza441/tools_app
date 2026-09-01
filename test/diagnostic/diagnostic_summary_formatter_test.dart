// DIAG-15: the shareable summary includes timestamp, context, metrics,
// provenance, failures and ICMP unavailable — and never the word "ping".
import 'package:flutter_test/flutter_test.dart';
import 'package:tools_app/diagnostic/models/diagnostic_fact.dart';
import 'package:tools_app/diagnostic/models/diagnostic_run_state.dart';
import 'package:tools_app/diagnostic/models/latency_aggregate.dart';
import 'package:tools_app/diagnostic/session/diagnostic_summary_formatter.dart';

void main() {
  const formatter = DiagnosticSummaryFormatter();

  test('resumo de run parcial contém contexto, métricas, provenance, limitações',
      () {
    final state = DiagnosticRunState(
      runId: 1,
      phase: DiagnosticRunPhase.partialFailure,
      startedAt: DateTime(2026, 9, 1, 10, 30, 0),
      finishedAt: DateTime(2026, 9, 1, 10, 30, 7),
      transport: const DiagnosticFact(
        status: DiagnosticFactStatus.success,
        value: 'wifi',
      ),
      localIpv4: const DiagnosticFact(
        status: DiagnosticFactStatus.success,
        value: '192.168.0.42',
      ),
      gateway: const DiagnosticFact(
        status: DiagnosticFactStatus.success,
        value: '192.168.0.1',
      ),
      publicIpv4: const DiagnosticFact(
        status: DiagnosticFactStatus.failure,
        message: 'ipify indisponível',
        provenance: ProbeProvenance(
          method: 'HTTPS',
          target: 'api.ipify.org',
          portOrUrl: 'https://api.ipify.org?format=json',
          timeout: Duration(seconds: 5),
          limitations: 'x',
          thirdParty: 'api.ipify.org',
        ),
      ),
      internetProbe: const DiagnosticFact(
        status: DiagnosticFactStatus.success,
        value: '18 ms',
        provenance: ProbeProvenance(
          method: 'HTTPS',
          target: 'www.gstatic.com',
          portOrUrl: 'https://www.gstatic.com/generate_204',
          timeout: Duration(seconds: 5),
          limitations: 'conexão fria',
        ),
      ),
      internetLatency: const LatencyAggregate(
        min: Duration(milliseconds: 10),
        avg: Duration(milliseconds: 18),
        max: Duration(milliseconds: 30),
        plannedAttempts: 4,
        completedAttempts: 4,
        successes: 3,
        failures: 1,
        timeouts: 0,
        cancelledCount: 0,
        networkChangedCount: 0,
        denominatorLabel: '3 de 4',
      ),
    );

    final text = formatter.format(state);

    expect(text, contains('2026-09-01 10:30:00'));
    expect(text, contains('wifi'));
    expect(text, contains('192.168.0.42'));
    expect(text, contains('192.168.0.1'));
    expect(text, contains('api.ipify.org'));
    expect(text, contains('ipify indisponível'));
    expect(text, contains('HTTPS'));
    expect(text, contains('3 de 4'));
    expect(text, contains('conexão fria'));
    expect(text, contains('ICMP'));
    expect(text, contains('Indisponível'));
    expect(text.toLowerCase(), isNot(contains('ping')));
  });
}
