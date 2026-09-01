---
phase: 03-diagn-stico-de-internet-completo-e-resiliente
plan: "07"
status: complete
completed: "2026-09-01"
requirements:
  - DIAG-12
  - DIAG-15
  - QUAL-02
  - QUAL-03
  - QUAL-04
  - QUAL-06
  - QUAL-07
  - QUAL-08
---

# 03-07 SUMMARY — Lifecycle/visibilidade + resumo copiável/compartilhável

## What was built (fecha o goal D-01)

Resiliência de lifecycle/visibilidade/troca de rede + resumo compartilhável via
Intent nativo. Último plano da fase.

### Lifecycle & visibilidade (QUAL-04, D-08)
- `AppShell`: novo `DiagnosticVisibilityScope` (InheritedWidget) em volta do `IndexedStack` expõe `selectedId`; overflow `length > 4` inalterado.
- `InternetDiagnosticScreen`: `AppLifecycleListener` (onPause/onHide/onDetach → `cancel`; onResume → `refreshSnapshotOnly`, nunca auto-start); `didChangeDependencies` cancela quando o destino deixa de estar visível; `dispose` cancela + dispose se owned.

### Troca de rede (QUAL-03)
- `DiagnosticSessionImpl` faz `startWatching` durante o run; mudança de `networkHandle` ou wifi↔cellular → `scope.cancelAll()`, fatos em voo relabelados `networkChanged` (não misturados, não contados como sucesso), `phase partialFailure`, `stopWatching` no terminal. Distinto de cancel do usuário (checado antes da guarda de staleness).

### Resumo copiável/compartilhável (DIAG-15, D-09/D-11)
- `DiagnosticSummaryFormatter` puro: timestamp, contexto, IPs, provedor ipify, TCP connect/HTTPS com mín/média/máx + denominador, provenance/limitações, ICMP indisponível; sem "ping", sem PII extra, sem persistência.
- `AndroidShareTextPort` (canal `share_text`) + `ShareTextPlugin.kt` (`Intent.ACTION_SEND` + createChooser "Compartilhar diagnóstico"), registrado no `configureFlutterEngine` do `MainActivity` (mesmo package, pasta não movida). Sem `share_plus` (AGP 8.11.1).
- `DiagnosticDefaults.createSharePort()`: Android → `AndroidShareTextPort`, senão `NoopShareTextPort`.
- UI: `CopyValueAction` (reusa `CopyValueWriter`, 48×48) + `IconButton` compartilhar 48×48 nos estados terminais; guard `mounted` + SnackBar em `PlatformException`.

### Testes (fakes manuscritos; sem integration_test/mockito)
- `diagnostic_session_lifecycle_test.dart` (NOVO): networkChanged mid-run (sem mistura); dispose após start ignora resultado tardio sem exceção.
- `diagnostic_summary_formatter_test.dart` (NOVO): resumo parcial com contexto/métricas/provenance/limitações/ICMP, sem "ping".
- `internet_diagnostic_screen_test.dart`: copiar resumo (grava o texto do formatter) e compartilhar (chama share port).

## Verification
- `flutter analyze --no-pub` → **No issues found**.
- `flutter test --no-pub` → **235/235 passed** (inclui PRES + goldens da fundação sem regressão).
- QUAL-06/07 greps: localização/analytics/share_plus/dart_ping/connectivity_plus só em comentários negativos; nenhum pacote.
- QUAL-08: 13 substrings (success, offline, timeout, invalid, gateway, public, partial, cancel, late, networkChanged, dispose, concurrent, aggregat) presentes em nomes de teste.
- Sem `class NetworkService`, sem SpeedTest; `pubspec.lock-old` intocado (D-14).

## Deviations
- networkChanged: em vez de os probes emitirem `networkChanged` diretamente, a sessão relabela os fatos `cancelled` em voo para `networkChanged` e escreve via bypass da guarda de staleness — o efeito observável (fatos networkChanged, sem mistura, phase partialFailure) é o do plano.

## Self-Check: PASSED
