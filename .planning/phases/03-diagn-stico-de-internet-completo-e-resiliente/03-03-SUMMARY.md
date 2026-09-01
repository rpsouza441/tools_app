---
phase: 03-diagn-stico-de-internet-completo-e-resiliente
plan: "03"
status: complete
completed: "2026-09-01"
requirements:
  - DIAG-01
  - DIAG-08
  - DIAG-11
  - DIAG-13
  - DIAG-14
  - QUAL-01
  - QUAL-08
---

# 03-03 SUMMARY — InternetDiagnosticScreen + 4º destino

## What was built

Primeira fatia clicável: o usuário encontra Diagnóstico no catálogo (barra
compacta com 4 destinos, sem overflow), inicia um run, vê progresso e fatos
independentes, cancela e repete — sessão injetável com stubs de produção.

### Catálogo (`lib/app/app_destinations.dart`)
- Novo `AppDestinationCategory.diagnostico`.
- 4º destino `internet_diagnostic` **após** Hash (ordem preservada): label `Diagnóstico`, semanticLabel `Diagnóstico de Internet`, ícones distintos (`travel_explore`/`_outlined`), `compactPriority: 4`, `pageBuilder → const InternetDiagnosticScreen()`. `List.unmodifiable` mantido.
- `AppShell._barUsesOverflow` (`length > 4`) intocado — 4 destinos = barra plana; overflow só com 5+.

### Tela (`lib/screen/internet_diagnostic_screen.dart`)
- `InternetDiagnosticScreen({session, copyWriter, sharePort})`. Produção: `DiagnosticDefaults.createSession()` no `initState` (catálogo continua one-liner).
- Observa `session.listenable` via `ValueListenableBuilder` — sem `setState` de adapters (D-06).
- `ToolActionGroup`: primary `Iniciar diagnóstico` (idle/terminal vira **Repetir**, DIAG-13); `onPressed null` enquanto running; `onCancel: session.cancel` só em running (**primeiro uso de produção de onCancel**). Sem secondary Limpar, sem CTA Calcular.
- `ToolStatusPanel.onRetry` null (retry único = primary). phase→variant: idle→empty, running→loading, success→success, partialFailure→failure, cancelled→cancelled, offline→offline; permissionDenied só se um fato local tiver esse status (não pede ACCESS_LOCAL_NETWORK).
- `preservedChild` com card de fatos em loading/failure/cancelled; em success o card é sibling abaixo do painel.
- Fatos: `TechnicalValueRow` (IPv4 local/gateway/público) com copyWriter + metadata de provenance (método/alvo/timeout/terceiro); `ToolMetric` para capabilities e probes; `null → Indisponível`. ICMP `ToolMetric` value null. Nenhum texto "ping". startedAt/finishedAt visíveis (DIAG-14).
- `dispose`: `session.cancel()` + `dispose()` se a tela criou a sessão. AppLifecycleListener fica para 03-07.

### Testes
- `destination_catalog_test.dart`: 4 ids/labels/semanticLabels/categorias/pageBuilders + compactPriority 4.
- `app_shell_test.dart`: barra compacta de produção e rail colapsado incluem Diagnóstico/Diagnóstico de Internet; overflow de 5 fakes inalterado.
- `tools_preservation_test.dart`: Rede/Armazenamento/Hash preservados + tap Diagnóstico abre a tela.
- `internet_diagnostic_screen_test.dart` (NOVO): FakeDiagnosticSession (ValueNotifier); idle/running/cancel/terminal-Repetir; ICMP Indisponível; sem "ping"; sem Calcular.

## Verification
- `flutter test --no-pub` (suíte inteira) → **214/214 passed**.
- `flutter analyze --no-pub` → **No issues found**.
- Três ferramentas migradas sem regressão (PRES + testes de serviço verdes).
- `pubspec.lock-old` intocado (D-14).

## Deviations
- Nenhuma.

## Self-Check: PASSED
