// E2E widget test for InternetDiagnosticScreen: title, Iniciar/Cancelar/Repetir,
// no isolated Calcular, no "ping", facts preserved. DIAG-01/08/11/13/14.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tools_app/design_system/tool_status_panel.dart';
import 'package:tools_app/diagnostic/contracts/diagnostic_session.dart';
import 'package:tools_app/diagnostic/contracts/share_text_port.dart';
import 'package:tools_app/diagnostic/models/diagnostic_fact.dart';
import 'package:tools_app/diagnostic/models/diagnostic_run_state.dart';
import 'package:tools_app/diagnostic/models/latency_aggregate.dart';
import 'package:tools_app/screen/internet_diagnostic_screen.dart';

import 'screen_test_harness.dart';

/// Manually-controlled fake session (no real I/O). Drives phase transitions.
class FakeDiagnosticSession implements DiagnosticSession {
  final ValueNotifier<DiagnosticRunState> _notifier =
      ValueNotifier<DiagnosticRunState>(DiagnosticRunState.initial);

  int startCalls = 0;
  int cancelCalls = 0;
  bool disposed = false;

  void emit(DiagnosticRunState state) => _notifier.value = state;

  @override
  ValueListenable<DiagnosticRunState> get listenable => _notifier;

  @override
  DiagnosticRunState get state => _notifier.value;

  @override
  Future<void> start() async {
    startCalls++;
    _notifier.value = DiagnosticRunState(
      runId: _notifier.value.runId + 1,
      phase: DiagnosticRunPhase.running,
      startedAt: DateTime(2026, 1, 1, 10),
    );
  }

  @override
  Future<void> cancel() async {
    cancelCalls++;
    _notifier.value = _notifier.value.copyWith(
      phase: DiagnosticRunPhase.cancelled,
    );
  }

  @override
  Future<void> refreshSnapshotOnly() async {}

  @override
  void dispose() {
    disposed = true;
    _notifier.dispose();
  }
}

void main() {
  group('InternetDiagnosticScreen', () {
    testWidgets(
      'idle: título, Iniciar diagnóstico, status empty, sem Calcular',
      (tester) async {
        final session = FakeDiagnosticSession();
        await tester.pumpWidget(
          wrapScreen(InternetDiagnosticScreen(session: session)),
        );

        expect(find.text('Diagnóstico de Internet'), findsOneWidget);
        expect(find.text('Iniciar diagnóstico'), findsOneWidget);
        expect(find.byType(ToolStatusPanel), findsOneWidget);
        expect(find.text('Calcular'), findsNothing);
        expect(find.textContaining('ping', findRichText: true), findsNothing);
      },
    );

    testWidgets('running: primary desabilitado + Cancelar via onCancel', (
      tester,
    ) async {
      final session = FakeDiagnosticSession();
      await tester.pumpWidget(
        wrapScreen(InternetDiagnosticScreen(session: session)),
      );

      await tester.tap(find.text('Iniciar diagnóstico'));
      await tester.pump();

      expect(session.startCalls, 1);
      expect(find.text('Cancelar'), findsOneWidget);

      // Primary is disabled while running.
      final primary = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(primary.onPressed, isNull);

      await tester.tap(find.text('Cancelar'));
      await tester.pump();
      expect(session.cancelCalls, 1);
    });

    testWidgets(
      'terminal: primary vira Repetir e dispara novo start (DIAG-13)',
      (tester) async {
        final session = FakeDiagnosticSession();
        await tester.pumpWidget(
          wrapScreen(InternetDiagnosticScreen(session: session)),
        );

        session.emit(
          DiagnosticRunState(
            runId: 1,
            phase: DiagnosticRunPhase.success,
            startedAt: DateTime(2026, 1, 1, 10),
            finishedAt: DateTime(2026, 1, 1, 10, 0, 5),
            publicIpv4: const DiagnosticFact(
              status: DiagnosticFactStatus.success,
              value: '203.0.113.7',
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Repetir'), findsOneWidget);
        // onRetry on the status panel stays null — single retry is the primary.
        final panel = tester.widget<ToolStatusPanel>(
          find.byType(ToolStatusPanel),
        );
        expect(panel.onRetry, isNull);

        await tester.tap(find.text('Repetir'));
        await tester.pump();
        expect(session.startCalls, 1);
      },
    );

    testWidgets('ICMP aparece como Indisponível, nunca ping', (tester) async {
      final session = FakeDiagnosticSession();
      await tester.pumpWidget(
        wrapScreen(InternetDiagnosticScreen(session: session)),
      );

      session.emit(
        const DiagnosticRunState(runId: 1, phase: DiagnosticRunPhase.success),
      );
      await tester.pump();

      expect(find.textContaining('ICMP'), findsWidgets);
      expect(find.textContaining('ping', findRichText: true), findsNothing);
    });

    testWidgets('offline: variant offline, Repetir habilitado, sem spinner', (
      tester,
    ) async {
      final session = FakeDiagnosticSession();
      await tester.pumpWidget(
        wrapScreen(InternetDiagnosticScreen(session: session)),
      );

      session.emit(
        const DiagnosticRunState(runId: 1, phase: DiagnosticRunPhase.offline),
      );
      await tester.pump();

      expect(find.text('Sem conexão com a internet'), findsOneWidget);
      expect(find.text('Repetir'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      final primary = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(primary.onPressed, isNotNull);
    });

    testWidgets('parcial: IP público falha + HTTPS ok mostra os dois fatos', (
      tester,
    ) async {
      final session = FakeDiagnosticSession();
      await tester.pumpWidget(
        wrapScreen(InternetDiagnosticScreen(session: session)),
      );

      session.emit(
        DiagnosticRunState(
          runId: 1,
          phase: DiagnosticRunPhase.partialFailure,
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
            value: '12 ms',
            provenance: ProbeProvenance(
              method: 'HTTPS',
              target: 'www.gstatic.com',
              portOrUrl: 'https://www.gstatic.com/generate_204',
              timeout: Duration(seconds: 5),
              limitations: 'x',
            ),
          ),
        ),
      );
      await tester.pump();

      // Provider ipify surfaces near the public IP fact.
      expect(find.textContaining('api.ipify.org'), findsWidgets);
      // No copy that claims full internet — failure fact shows its message.
      expect(find.textContaining('ipify indisponível'), findsWidgets);
    });

    testWidgets(
      'falha parcial: mensagem de conclusão parcial preserva HTTPS, IP e resumo',
      (tester) async {
        final session = FakeDiagnosticSession();
        final copyWriter = FakeCopyWriter();
        await tester.pumpWidget(
          wrapScreen(
            InternetDiagnosticScreen(session: session, copyWriter: copyWriter),
          ),
        );
        session.emit(
          const DiagnosticRunState(
            runId: 1,
            phase: DiagnosticRunPhase.partialFailure,
            publicIpv4: DiagnosticFact(
              status: DiagnosticFactStatus.success,
              value: '203.0.113.7',
            ),
            internetProbe: DiagnosticFact(
              status: DiagnosticFactStatus.failure,
              message: 'Falha no probe de internet',
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Concluído com falhas parciais'), findsOneWidget);
        expect(find.text('Não foi possível concluir'), findsNothing);
        expect(find.text('Confira os dados e tente novamente.'), findsNothing);
        expect(find.text('Falha no probe de internet'), findsOneWidget);
        expect(find.text('203.0.113.7'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('Repetir'), findsOneWidget);

        await tester.ensureVisible(find.byTooltip('Copiar resumo'));
        await tester.tap(find.byTooltip('Copiar resumo'));
        await tester.pump();
        expect(
          copyWriter.lastValue,
          contains('Situação: Concluído com falhas parciais'),
        );
        expect(copyWriter.lastValue, contains('Falha no probe de internet'));
        expect(copyWriter.lastValue, contains('203.0.113.7'));
      },
    );

    testWidgets('agregado 3/4 sucessos exibe denominador (DIAG-09)', (
      tester,
    ) async {
      final session = FakeDiagnosticSession();
      await tester.pumpWidget(
        wrapScreen(InternetDiagnosticScreen(session: session)),
      );

      session.emit(
        const DiagnosticRunState(
          runId: 1,
          phase: DiagnosticRunPhase.success,
          internetProbe: DiagnosticFact(
            status: DiagnosticFactStatus.success,
            value: '20 ms',
          ),
          internetLatency: LatencyAggregate(
            min: Duration(milliseconds: 10),
            avg: Duration(milliseconds: 20),
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
        ),
      );
      await tester.pump();

      expect(find.textContaining('3 de 4'), findsWidgets);
    });

    testWidgets(
      'terminal: copiar resumo grava o texto do formatter (DIAG-15)',
      (tester) async {
        final session = FakeDiagnosticSession();
        final copyWriter = FakeCopyWriter();
        await tester.pumpWidget(
          wrapScreen(
            InternetDiagnosticScreen(session: session, copyWriter: copyWriter),
          ),
        );

        session.emit(
          DiagnosticRunState(
            runId: 1,
            phase: DiagnosticRunPhase.success,
            startedAt: DateTime(2026, 9, 1, 10),
            publicIpv4: const DiagnosticFact(
              status: DiagnosticFactStatus.success,
              value: '203.0.113.7',
            ),
          ),
        );
        await tester.pump();

        await tester.ensureVisible(find.byTooltip('Copiar resumo'));
        await tester.tap(find.byTooltip('Copiar resumo'));
        await tester.pump();

        expect(copyWriter.callCount, 1);
        expect(copyWriter.lastValue, contains('Diagnóstico de Internet'));
        expect(copyWriter.lastValue, contains('203.0.113.7'));
      },
    );

    testWidgets(
      'terminal: compartilhar chama o share port com o resumo (DIAG-15)',
      (tester) async {
        final session = FakeDiagnosticSession();
        final sharePort = _FakeSharePort();
        await tester.pumpWidget(
          wrapScreen(
            InternetDiagnosticScreen(session: session, sharePort: sharePort),
          ),
        );

        session.emit(
          const DiagnosticRunState(runId: 1, phase: DiagnosticRunPhase.success),
        );
        await tester.pump();

        await tester.ensureVisible(find.byTooltip('Compartilhar diagnóstico'));
        await tester.tap(find.byTooltip('Compartilhar diagnóstico'));
        await tester.pump();

        expect(sharePort.calls, 1);
        expect(sharePort.lastShared, contains('Diagnóstico de Internet'));
      },
    );
  });
}

class _FakeSharePort implements ShareTextPort {
  int calls = 0;
  String? lastShared;

  @override
  Future<void> share(String text) async {
    calls++;
    lastShared = text;
  }
}
