---
phase: 03-diagn-stico-de-internet-completo-e-resiliente
plan: "01"
status: complete
completed: "2026-09-01"
requirements:
  - DIAG-01
  - DIAG-09
  - DIAG-10
  - DIAG-12
  - DIAG-14
  - QUAL-02
  - QUAL-05
  - QUAL-08
---

# 03-01 SUMMARY — Domínio injetável, agregador e sessão

## What was built

Fundação vertical da sessão de diagnóstico com os sete contratos D-05 separados e
injetáveis, o agregador puro e a `DiagnosticSessionImpl`, usando stubs indisponíveis —
sem I/O real, sem widgets e **sem** `NetworkService`.

### Modelos (`lib/diagnostic/models/`)
- `DiagnosticFact` + `DiagnosticFactStatus` (success/unavailable/failure/cancelled/timeout/networkChanged/permissionDenied), com `ProbeProvenance` (method literal `TCP connect`/`HTTPS`, nunca `ping`).
- `NetworkSnapshot` (transports, INTERNET/VALIDATED/CAPTIVE/NOT_METERED, IPv4 local/gateway, networkHandle) — todos anuláveis, sem `isOnline` booleano.
- `DiagnosticRunState` + `DiagnosticRunPhase` (idle/running/success/partialFailure/cancelled/offline), imutável com `copyWith`; `icmp` nasce sempre `unavailable` "Indisponível neste MVP".
- `LatencyAggregate` (min/avg/max anuláveis, contagens, `denominatorLabel`).

### Contratos D-05 (`lib/diagnostic/contracts/`)
1. `NetworkSnapshotSource` 2. `LocalIpv4Source` 3. `DefaultGatewaySource` 4. `PublicIpSource` 5a `GatewayProbe` 5b `InternetProbe` 6 `DiagnosticSession` 7 `LatencyAggregator` + `ShareTextPort`.

### Sessão (`lib/diagnostic/session/`)
- `CancellationScope`: registra aborts físicos e dispara em `cancelAll` (idempotente); `Future.timeout` sozinho é proibido (D-07, QUAL-02).
- `DiagnosticSessionImpl` (`ValueNotifier`): um run por vez (segundo `start` é no-op, DIAG-01), `runId` incremental, fan-out independente com captura de erro por fato (DIAG-10), gateway probe só com gateway presente (DIAG-06), resultado tardio ignorado após cancel (DIAG-12), `offline` sem spinner infinito (QUAL-01), timestamps só em memória (DIAG-14).

### Stubs + defaults
- `UnsupportedNetworkSnapshotSource`, `SnapshotLocalIpv4Source`, `SnapshotDefaultGatewaySource`, `UnavailablePublicIpSource`, `UnavailableGatewayProbe`, `UnavailableInternetProbe`, `NoopShareTextPort`.
- `DiagnosticDefaults.createSession()` monta a sessão só com stubs (Android/Dio/probes reais chegam em 03-06).

### Testes (`test/diagnostic/`)
- `fakes.dart`: implementações manuscritas dos sete contratos + `ShareTextPort`, com Completer/hang, contadores. Sem mockito.
- `latency_aggregator_test.dart`: DIAG-09 (min/avg/max + denominador) e QUAL-05 (zero sucessos → null, sem throw).
- `diagnostic_session_test.dart`: sucesso, no-op concorrente, parcial, gateway ausente, cancel + tardio, offline.

## Key files
- created: `lib/diagnostic/**` (23 arquivos), `test/diagnostic/{fakes,latency_aggregator_test,diagnostic_session_test}.dart`

## Verification
- `flutter test --no-pub test/diagnostic/latency_aggregator_test.dart test/diagnostic/diagnostic_session_test.dart` → **9/9 passed**.
- `flutter analyze --no-pub lib/diagnostic test/diagnostic` → **No issues found**.
- `grep NetworkService lib/diagnostic` → só comentários "não existe NetworkService"; nenhuma classe.
- `git status`: `pubspec.lock-old` intocado (D-14).

## Deviations
- Teste de cancelamento: adicionado `await Future.delayed(Duration.zero)` após `start()` para que o fan-out registre o abort físico antes do `cancel()` — mantém a intenção DIAG-12/QUAL-02 (abortar I/O em voo + ignorar resultado tardio) sem enfraquecer o caso.

## Self-Check: PASSED
