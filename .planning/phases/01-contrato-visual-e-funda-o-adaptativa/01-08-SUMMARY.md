---
phase: 01-contrato-visual-e-funda-o-adaptativa
plan: "08"
subsystem: ui
tags: [theme, ColorScheme, ToolStatusPanel, tdd, gap-closure, material3]

requires:
  - phase: 01-contrato-visual-e-funda-o-adaptativa
    provides: AppTokens, lightTheme/darkTheme fromSeed, ToolStatusPanel com sete variantes
provides:
  - lightTheme/darkTheme com hex canônicos do UI-SPEC (canvas, surface, textos, outline, accent, containers, error)
  - Card elevation 0 + outline 1 px; AppBar/nav/rail elevation 0; botões radius 8; chips radius 4
  - ToolStatusPanel com copy/ícone/cor canônicos dos sete estados
  - Testes independentes (literais UI-SPEC, nunca _statusMap nem fromSeed como oracle)
affects: [01-09, 01-10, 01-11]

tech-stack:
  added: []
  patterns:
    - ColorScheme.fromSeed + copyWith dos roles literais do UI-SPEC; hex não vai para widgets consumidores
    - Expectativas de tema/status são const locais no arquivo de teste, copiadas do UI-SPEC

key-files:
  created:
    - test/theme/theme_contract_test.dart
  modified:
    - lib/theme/theme.dart
    - lib/design_system/tool_status_panel.dart
    - test/design_system/tool_components_test.dart

key-decisions:
  - "ColorScheme.fromSeed permanece o ponto de partida; os roles listados no UI-SPEC são sobrescritos com Color(0xFF...) — fromSeed não é oracle."
  - "Offline usa wifi_off + ícone onSurface (neutro); permissionDenied usa lock_outline + error; loading usa CircularProgressIndicator no slot do ícone porque Icons.progress_activity não existe no Material SDK."
  - "Card elevation 0 com BorderSide outline 1 px; AppBar scrolledUnderElevation 0; botões AppTokens.radius8; chips AppTokens.radius4."

patterns-established:
  - "Testes de contrato visual comparam toARGB32() a literais 0xFF... do UI-SPEC, nunca isNotNull."
  - "Tabela canônica de status vive duplicada no teste (const local) e em _statusMap de produção; o teste não importa _statusMap."

requirements-completed: [UI-04, UI-05, UI-08]

duration: 8min
completed: 2026-08-31
---

# Phase 1 Plan 08: Tema canônico e sete estados Summary

**Temas claro/escuro com hex exatos do UI-SPEC, Card/AppBar/botões/chips no contrato de shape, e ToolStatusPanel com os sete estados canônicos (copy, ícone e papel de cor independentes de fromSeed/_statusMap).**

## Performance

- **Duration:** 8 min
- **Started:** 2026-08-31T15:46:29Z
- **Completed:** 2026-08-31T15:53:43Z
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments

- Fechou o gap B / WR-01: canvas light `#F7F9F7` (não `#FBFDF8`) e dark `#0F1511` (não `#1A1C19`); todos os roles listados no UI-SPEC aplicados via `copyWith`; Card elevation 0 + outline 1 px; AppBar/nav/rail elevation 0; botões radius 8; chips radius 4.
- Fechou o gap C / CR-04 / UI-05 / UI-08 (estados): empty “Nenhum resultado ainda”; loading “Processando” sem reticências + `CircularProgressIndicator`; failure “Não foi possível concluir”; offline `wifi_off` + “Sem conexão com a internet” com ícone neutro; permissionDenied ícone error; cancelled “Operação cancelada” / “Os resultados concluídos continuam disponíveis.”
- Inverteu testes tautológicos: expectativas literais no arquivo de teste, nunca `_statusMap` nem `ColorScheme.fromSeed` como oracle.

## TDD: evidência RED (Task 1 contra HEAD)

`flutter test --no-pub test/theme/theme_contract_test.dart test/design_system/tool_components_test.dart` falhou com `LASTEXITCODE=1` **antes** de qualquer implementação. Falhas por asserts de hex/copy (não compile). Recorte actual vs expected:

| Teste | Actual (HEAD) | Expected (UI-SPEC) |
|-------|---------------|---------------------|
| light canvas | `0xFFFBFDF8` | `0xFFF7F9F7` |
| light surface | `0xFFF7FBF1` | `0xFFFFFFFF` |
| light primary | `0xFF3B6939` | `0xFF006D2C` |
| dark canvas | `0xFF1A1C19` | `0xFF0F1511` |
| dark primary | `0xFFA1D39A` | `0xFF50FA7B` |
| Card elevation | `1.0` | `0` |
| AppBar scrolledUnderElevation | `1.0` | `0` |
| NavigationBar/Rail elevation | `null` | `0` |
| Button radius | `12.0` | `8.0` |
| Chip radius | `8.0` | `4.0` |
| empty heading | 0 widgets “Nenhum resultado ainda” (produção: “Pronto”) | “Nenhum resultado ainda” |
| loading heading | 0 widgets “Processando” (produção: “Processando...”) | “Processando” |
| failure heading | 0 widgets “Não foi possível concluir” (produção: “Falha”) | “Não foi possível concluir” |
| offline heading | 0 widgets “Sem conexão com a internet” (produção: “Sem conexão” + `cloud_off`) | “Sem conexão com a internet” + `wifi_off` |
| cancelled heading | 0 widgets “Operação cancelada” (produção: “Cancelado”) | “Operação cancelada” |

Commit RED: `7ffd553`.

## TDD: GREEN (Task 2)

Implementação mínima: `ColorScheme.fromSeed(...).copyWith` dos roles UI-SPEC; `scaffoldBackgroundColor` dos canvases; component themes (Card/AppBar/nav/botões/chips); `_statusMap` e `_iconColor` canônicos; loading com `CircularProgressIndicator` no slot do ícone. Suíte **81 testes, todos passaram**; `flutter analyze --no-pub` limpo nos arquivos do plano.

Commit GREEN: `1e67d91`.

## TDD Gate Compliance

- RED: `test(01-08): add failing tests for canonical theme and status states` — `7ffd553` (testes falharam antes da implementação).
- GREEN: `feat(01-08): implement canonical ColorScheme roles and seven status states` — `1e67d91`.
- REFACTOR: não necessário.

## Task Commits

Each task was committed atomically:

1. **Task 1: Inverter testes de tema e dos sete estados com expectativas do UI-SPEC** - `7ffd553` (test)
2. **Task 2: Aplicar ColorScheme/shapes exatos e os sete estados canônicos** - `1e67d91` (feat)

**Plan metadata:** (commit de close-out após este SUMMARY)

## Files Created/Modified

- `test/theme/theme_contract_test.dart` — asserts hex/elevation/radius com literais UI-SPEC (`toARGB32()`, nunca `isNotNull`)
- `test/design_system/tool_components_test.dart` — grupo `status` com tabela canônica local; light e dark; papéis de cor do ícone
- `lib/theme/theme.dart` — roles, canvases e shapes canônicos
- `lib/design_system/tool_status_panel.dart` — sete estados canônicos; offline neutro; permissionDenied error; loading com indicador

## Decisions Made

- `fromSeed` continua gerando o restante do scheme; só os roles do contrato são sobrescritos com hex do UI-SPEC.
- `Icons.progress_activity` não existe no Material Icons do SDK; o slot de ícone de loading é um `CircularProgressIndicator` (indeterminado se `progress` for null).
- Offline não compartilha o papel `error` com failure; permissionDenied passa a usar `error` no ícone.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] `find.byType(ProgressIndicator)` não encontra subclasses**
- **Found during:** Task 2 (GREEN)
- **Issue:** `flutter_test` `byType` compara `runtimeType` exato; `CircularProgressIndicator` não casa com `ProgressIndicator`.
- **Fix:** Finder `byWidgetPredicate((w) => w is ProgressIndicator)` no grupo status, preservando a intenção do plano.
- **Files modified:** `test/design_system/tool_components_test.dart`
- **Verification:** loading light/dark passam; 81 testes verdes.
- **Committed in:** `1e67d91` (Task 2)

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** Correção necessária para o assert de loading; sem creep de escopo. Galeria/goldens intocados.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Gaps B/C (exceto copy da galeria) e CR-04/WR-01 fechados.
- Phase 1 permanece incompleta: 01-09 (lifecycle de cópia), 01-10 (galeria/goldens) e 01-11 ainda pendentes. Não regenerar goldens neste plano.
- Galeria ainda pode exibir copy antiga dos estados até 01-10.

## Known Stubs

- Success body da primitive permanece “Resultado disponível abaixo.” — resumo estático da fundação, autorizado pelo plano (a feature fornece o resumo objetivo depois). Não bloqueia o goal deste plano.

## Self-Check: PASSED

- `test/theme/theme_contract_test.dart` FOUND
- `lib/theme/theme.dart` FOUND
- `lib/design_system/tool_status_panel.dart` FOUND
- `test/design_system/tool_components_test.dart` FOUND
- `01-08-SUMMARY.md` FOUND
- commit `7ffd553` FOUND
- commit `1e67d91` FOUND
- Nenhuma expectativa `isNotNull` como prova de role; `_statusMap` não importado nos testes.

---
*Phase: 01-contrato-visual-e-funda-o-adaptativa*
*Completed: 2026-08-31*
