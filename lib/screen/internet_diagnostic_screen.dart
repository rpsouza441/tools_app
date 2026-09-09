import 'package:flutter/material.dart';
import 'package:tools_app/app/app_shell.dart' show DiagnosticVisibilityScope;
import 'package:tools_app/design_system/copy_value_action.dart';
import 'package:tools_app/design_system/tool_scaffold.dart';
import 'package:tools_app/design_system/tool_sections.dart';
import 'package:tools_app/design_system/tool_status_panel.dart';
import 'package:tools_app/diagnostic/contracts/diagnostic_session.dart';
import 'package:tools_app/diagnostic/contracts/share_text_port.dart';
import 'package:tools_app/diagnostic/diagnostic_defaults.dart';
import 'package:tools_app/diagnostic/models/diagnostic_fact.dart';
import 'package:tools_app/diagnostic/models/diagnostic_run_state.dart';
import 'package:tools_app/diagnostic/models/latency_aggregate.dart';
import 'package:tools_app/diagnostic/session/diagnostic_summary_formatter.dart';

/// Internet diagnostic screen. Observes an injected [DiagnosticSession] and
/// renders immutable run state — the widget never runs HTTP/socket I/O and
/// never calls setState from adapters (D-06). One run at a time (DIAG-01),
/// cancellable while running (DIAG-12), repeatable after any terminal phase
/// (DIAG-13), with independent facts and honest provenance (DIAG-08/11).
class InternetDiagnosticScreen extends StatefulWidget {
  const InternetDiagnosticScreen({
    super.key,
    this.session,
    this.copyWriter,
    this.sharePort,
  });

  /// Injected session. Defaults to the production composition in initState.
  final DiagnosticSession? session;

  /// Injected clipboard writer for copyable technical values.
  final CopyValueWriter? copyWriter;

  /// Injected share port (used by 03-07). Kept for injection symmetry.
  final ShareTextPort? sharePort;

  @override
  State<InternetDiagnosticScreen> createState() =>
      _InternetDiagnosticScreenState();
}

class _InternetDiagnosticScreenState extends State<InternetDiagnosticScreen> {
  late final DiagnosticSession _session;
  late final ShareTextPort _sharePort;
  late final bool _ownsSession;
  AppLifecycleListener? _lifecycleListener;
  String? _lastVisibleId;

  static const DiagnosticSummaryFormatter _formatter =
      DiagnosticSummaryFormatter();

  CopyValueWriter get _copyWriter =>
      widget.copyWriter ?? const ClipboardCopyWriter();

  @override
  void initState() {
    super.initState();
    if (widget.session != null) {
      _session = widget.session!;
      _ownsSession = false;
    } else {
      _session = DiagnosticDefaults.createSession();
      _ownsSession = true;
    }
    _sharePort = widget.sharePort ?? DiagnosticDefaults.createSharePort();

    // Pause/hide/detach cancel the run; resume only refreshes the snapshot and
    // never auto-restarts (QUAL-04, D-08).
    _lifecycleListener = AppLifecycleListener(
      onPause: _cancelIfRunning,
      onHide: _cancelIfRunning,
      onDetach: _cancelIfRunning,
      onResume: () => _session.refreshSnapshotOnly(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cancel the run when this preserved IndexedStack page is no longer the
    // visible destination (QUAL-04).
    final visibleId = DiagnosticVisibilityScope.of(context);
    if (_lastVisibleId == 'internet_diagnostic' &&
        visibleId != null &&
        visibleId != 'internet_diagnostic') {
      _cancelIfRunning();
    }
    _lastVisibleId = visibleId;
  }

  void _cancelIfRunning() {
    if (_session.state.phase == DiagnosticRunPhase.running) {
      _session.cancel();
    }
  }

  @override
  void dispose() {
    _lifecycleListener?.dispose();
    _session.cancel();
    if (_ownsSession) {
      _session.dispose();
    }
    super.dispose();
  }

  bool _isRunning(DiagnosticRunPhase phase) =>
      phase == DiagnosticRunPhase.running;

  bool _isTerminal(DiagnosticRunPhase phase) =>
      phase == DiagnosticRunPhase.success ||
      phase == DiagnosticRunPhase.partialFailure ||
      phase == DiagnosticRunPhase.cancelled ||
      phase == DiagnosticRunPhase.offline;

  ToolStatusVariant _variant(DiagnosticRunState state) {
    // A local fact reporting permissionDenied surfaces that variant honestly
    // without ever requesting ACCESS_LOCAL_NETWORK.
    final hasPermissionDenied = [
      state.localIpv4,
      state.gateway,
      state.gatewayProbe,
    ].any((f) => f.status == DiagnosticFactStatus.permissionDenied);
    if (hasPermissionDenied) return ToolStatusVariant.permissionDenied;

    return switch (state.phase) {
      DiagnosticRunPhase.idle => ToolStatusVariant.empty,
      DiagnosticRunPhase.running => ToolStatusVariant.loading,
      DiagnosticRunPhase.success => ToolStatusVariant.success,
      DiagnosticRunPhase.partialFailure => ToolStatusVariant.failure,
      DiagnosticRunPhase.cancelled => ToolStatusVariant.cancelled,
      DiagnosticRunPhase.offline => ToolStatusVariant.offline,
    };
  }

  String _factValue(DiagnosticFact fact) =>
      fact.isSuccess ? (fact.value ?? '') : (fact.message ?? 'Indisponível');

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DiagnosticRunState>(
      valueListenable: _session.listenable,
      builder: (context, state, _) {
        final running = _isRunning(state.phase);
        final terminal = _isTerminal(state.phase);
        final variant = _variant(state);

        final primaryLabel = terminal ? 'Repetir' : 'Iniciar diagnóstico';
        final factsCard = _buildFactsCard(context, state);

        return ToolScaffold(
          title: 'Diagnóstico de Internet',
          summary:
              'Coleta evidências independentes de conectividade. "Internet '
              'acessível" combina sinais da plataforma com um teste real; não '
              'é um simples indicador Online.',
          children: [
            ToolActionGroup(
              primary: ElevatedButton(
                onPressed: running ? null : _session.start,
                child: Text(primaryLabel),
              ),
              onCancel: running ? _session.cancel : null,
            ),
            const SizedBox(height: 24),
            ToolStatusPanel(
              variant: variant,
              heading: variant == ToolStatusVariant.failure
                  ? 'Concluído com falhas parciais'
                  : null,
              body: variant == ToolStatusVariant.failure
                  ? 'Algumas etapas falharam. Confira os resultados e as '
                        'limitações abaixo.'
                  : null,
              // Single retry is the primary "Repetir" button; no duplicate.
              onRetry: null,
              preservedChild: factsCard,
            ),
            // In success the facts card is a sibling below the panel (the panel
            // hides preservedChild for success/empty).
            if (variant == ToolStatusVariant.success) ...[
              const SizedBox(height: 24),
              factsCard,
            ],
            if (terminal) ...[
              const SizedBox(height: 16),
              _shareActions(context, state),
            ],
          ],
        );
      },
    );
  }

  Widget _shareActions(BuildContext context, DiagnosticRunState state) {
    final summary = _formatter.format(state);
    return Row(
      children: [
        // Reuses the existing CopyValueWriter (48x48) — no new clipboard path.
        CopyValueAction(label: 'resumo', value: summary, writer: _copyWriter),
        IconButton(
          icon: const Icon(
            Icons.share,
            semanticLabel: 'Compartilhar diagnóstico',
          ),
          tooltip: 'Compartilhar diagnóstico',
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          onPressed: () => _share(summary),
        ),
      ],
    );
  }

  Future<void> _share(String summary) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    try {
      await _sharePort.share(summary);
    } catch (_) {
      if (!mounted) return;
      messenger?.showSnackBar(
        const SnackBar(
          content: Text('Não foi possível compartilhar neste dispositivo.'),
        ),
      );
    }
  }

  Widget _buildFactsCard(BuildContext context, DiagnosticRunState state) {
    final started = state.startedAt;
    final finished = state.finishedAt;

    return ToolResultCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ToolMetricLayout(
            metrics: [
              ToolMetric(
                label: 'Transporte',
                value: state.transport.isSuccess ? state.transport.value : null,
              ),
              ToolMetric(
                label: 'INTERNET',
                value: state.internetCapability.isSuccess
                    ? state.internetCapability.value
                    : null,
              ),
              ToolMetric(
                label: 'Validado',
                value: state.validated.isSuccess ? state.validated.value : null,
              ),
              ToolMetric(
                label: 'Portal cativo',
                value: state.captivePortal.isSuccess
                    ? state.captivePortal.value
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _address(context, 'IPv4 local', state.localIpv4),
          _address(context, 'Gateway', state.gateway),
          _address(context, 'IPv4 público', state.publicIpv4),
          const SizedBox(height: 16),
          _probe(
            context,
            'Gateway (TCP connect)',
            state.gatewayProbe,
            state.gatewayLatency,
          ),
          _probe(
            context,
            'Internet (HTTPS)',
            state.internetProbe,
            state.internetLatency,
          ),
          // ICMP is always unavailable in this MVP — never labelled "ping".
          ToolMetric(
            label: 'ICMP',
            value: state.icmp.isSuccess ? state.icmp.value : null,
          ),
          if (started != null || finished != null) ...[
            const SizedBox(height: 16),
            if (started != null)
              ToolMetric(label: 'Início', value: _fmt(started)),
            if (finished != null)
              ToolMetric(label: 'Fim', value: _fmt(finished)),
          ],
        ],
      ),
    );
  }

  Widget _address(BuildContext context, String label, DiagnosticFact fact) {
    final provenance = fact.provenance;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TechnicalValueRow(
        label: label,
        value: _factValue(fact),
        metadata: provenance == null
            ? null
            : '${provenance.method} · ${provenance.target} · '
                  'timeout ${provenance.timeout.inSeconds}s'
                  '${provenance.thirdParty != null ? ' · ${provenance.thirdParty}' : ''}',
        copyWriter: fact.isSuccess ? _copyWriter : null,
      ),
    );
  }

  Widget _probe(
    BuildContext context,
    String label,
    DiagnosticFact fact,
    LatencyAggregate? aggregate,
  ) {
    final provenance = fact.provenance;
    String? ms(Duration? d) => d == null ? null : '${d.inMilliseconds} ms';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ToolMetric(label: label, value: fact.isSuccess ? fact.value : null),
          if (!fact.isSuccess && fact.message != null)
            Text(fact.message!),
          if (aggregate != null && aggregate.plannedAttempts > 0)
            ToolMetricLayout(
              metrics: [
                ToolMetric(label: 'mín', value: ms(aggregate.min)),
                ToolMetric(label: 'média', value: ms(aggregate.avg)),
                ToolMetric(label: 'máx', value: ms(aggregate.max)),
                ToolMetric(
                  label: 'sucessos',
                  value: aggregate.denominatorLabel,
                ),
              ],
            ),
          if (provenance != null)
            Text(
              '${provenance.method} · ${provenance.portOrUrl} · '
              'timeout ${provenance.timeout.inSeconds}s\n${provenance.limitations}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }

  String _fmt(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(t.hour)}:${two(t.minute)}:${two(t.second)}';
  }
}
