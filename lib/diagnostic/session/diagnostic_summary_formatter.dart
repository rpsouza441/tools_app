import '../models/diagnostic_fact.dart';
import '../models/diagnostic_run_state.dart';
import '../models/latency_aggregate.dart';

/// Formats a [DiagnosticRunState] into a plain-text, copyable/shareable summary
/// (DIAG-15). In-memory only — no persistence, no PII beyond the run's own
/// network facts, no analytics (D-09, D-11, QUAL-07). Never labels probes as
/// "ping" (D-10).
class DiagnosticSummaryFormatter {
  const DiagnosticSummaryFormatter();

  String format(DiagnosticRunState state) {
    final b = StringBuffer();
    b.writeln('Diagnóstico de Internet');

    final started = state.startedAt;
    final finished = state.finishedAt;
    if (started != null) b.writeln('Início: ${_fmt(started)}');
    if (finished != null) b.writeln('Fim: ${_fmt(finished)}');
    b.writeln('Situação: ${_phaseLabel(state.phase)}');
    b.writeln('');

    _line(b, 'Transporte', state.transport);
    _line(b, 'INTERNET', state.internetCapability);
    _line(b, 'Validado', state.validated);
    _line(b, 'Portal cativo', state.captivePortal);
    _line(b, 'IPv4 local', state.localIpv4);
    _line(b, 'Gateway', state.gateway);
    _line(b, 'IPv4 público', state.publicIpv4);
    b.writeln('');

    _probe(b, 'Gateway (TCP connect)', state.gatewayProbe, state.gatewayLatency);
    _probe(b, 'Internet (HTTPS)', state.internetProbe, state.internetLatency);

    _line(b, 'ICMP', state.icmp);

    return b.toString().trimRight();
  }

  void _line(StringBuffer b, String label, DiagnosticFact fact) {
    final value = fact.isSuccess
        ? (fact.value ?? '—')
        : (fact.message ?? 'Indisponível');
    b.writeln('$label: $value');
    final p = fact.provenance;
    if (p != null && p.thirdParty != null) {
      b.writeln('  Provedor: ${p.thirdParty} (${p.method})');
    }
  }

  void _probe(
    StringBuffer b,
    String label,
    DiagnosticFact fact,
    LatencyAggregate? aggregate,
  ) {
    final value = fact.isSuccess
        ? (fact.value ?? '—')
        : (fact.message ?? 'Indisponível');
    b.writeln('$label: $value');
    if (aggregate != null && aggregate.plannedAttempts > 0) {
      String ms(Duration? d) => d == null ? '—' : '${d.inMilliseconds} ms';
      b.writeln(
        '  mín ${ms(aggregate.min)} · média ${ms(aggregate.avg)} · '
        'máx ${ms(aggregate.max)} · sucessos ${aggregate.denominatorLabel}',
      );
    }
    final p = fact.provenance;
    if (p != null) {
      b.writeln('  ${p.method} · ${p.portOrUrl} · timeout ${p.timeout.inSeconds}s');
      b.writeln('  ${p.limitations}');
    }
  }

  String _phaseLabel(DiagnosticRunPhase phase) {
    return switch (phase) {
      DiagnosticRunPhase.idle => 'Não iniciado',
      DiagnosticRunPhase.running => 'Em andamento',
      DiagnosticRunPhase.success => 'Concluído',
      DiagnosticRunPhase.partialFailure => 'Concluído com falhas parciais',
      DiagnosticRunPhase.cancelled => 'Cancelado',
      DiagnosticRunPhase.offline => 'Sem conexão',
    };
  }

  String _fmt(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${t.year}-${two(t.month)}-${two(t.day)} '
        '${two(t.hour)}:${two(t.minute)}:${two(t.second)}';
  }
}
