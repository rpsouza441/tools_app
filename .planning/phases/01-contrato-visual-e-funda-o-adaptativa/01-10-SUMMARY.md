---
phase: 01-contrato-visual-e-funda-o-adaptativa
plan: "10"
subsystem: ui
tags: [ToolMetric, accessibility, goldens, gallery, tdd, gap-closure, pt-BR]

requires:
  - phase: 01-contrato-visual-e-funda-o-adaptativa
    provides: AppShell adaptativo com 5 destinos, semanticLabel, copyWriter, tema canônico
provides:
  - ToolMetric refluível via Wrap (360 px / TextScaler 2.0 sem overflow)
  - Matriz de a11y sobre AppShell/ToolScaffold/ToolMetric/ToolStatusPanel/TechnicalValueRow reais
  - Galeria/harness com Calcular rede, Painéis de status, copy visível e título pt-BR
  - Override formal do caminho golden: test/design_system/goldens/
affects: [01-11]

tech-stack:
  added: []
  patterns:
    - ToolMetric usa Wrap (spacing/runSpacing 8) sem maxLines/ellipsis em informação essencial
    - matchesGoldenFile('goldens/....png') resolve para test/design_system/goldens/; test/goldens/ é proibido
    - SelectableText anuncia o valor via Semantics(label) e ExcludeSemantics; o alvo 48 px é CopyValueAction

key-files:
  created:
    - test/design_system/tool_metric_reflow_test.dart
    - .planning/phases/01-contrato-visual-e-funda-o-adaptativa/01-10-SUMMARY.md
  modified:
    - lib/design_system/tool_sections.dart
    - test/design_system/accessibility_test.dart
    - test/design_system/design_system_gallery.dart
    - test/design_system/design_system_golden_test.dart
    - test/manual/design_system_app.dart
    - test/design_system/goldens/primitives_compact_light.png
    - test/design_system/goldens/primitives_compact_dark.png
    - test/design_system/goldens/shell_medium_light.png
    - test/design_system/goldens/shell_expanded_dark.png

key-decisions:
  - "Caminho canônico dos goldens é test/design_system/goldens/ via matchesGoldenFile('goldens/...'); test/goldens/ não existe e não deve ser criado (override de 01-04-PLAN)."
  - "ToolMetric reflui com Wrap (gap 8) em vez de Row(mainAxisSize: min); sem maxLines:1 nem ellipsis em label/valor."
  - "SelectableText de TechnicalValueRow não expõe longPress de 20 px na árvore semântica; CopyValueAction permanece o controle de 48 px."
  - "PNG regenerado neste plano não constitui aprovação visual — isso é 01-11."

patterns-established:
  - "Fixtures de a11y/golden montam AppShell e primitives públicas; não clonam regras de layout."
  - "Galeria de teste injeta CopyValueWriter no-op; sem clipboard real nem rede."

requirements-completed: [UI-01, UI-03, UI-06, UI-07, UI-08, UI-09]

duration: 10min
completed: 2026-08-31
---

# Phase 1 Plan 10: Reflow, a11y real, galeria pt-BR e goldens Summary

**ToolMetric público reflui em 360 px com TextScaler 2.0, a matriz de acessibilidade monta AppShell/primitives reais com copy, a galeria/harness usam copy pt-BR canônico, e os quatro goldens vivem só em `test/design_system/goldens/`.**

## Performance

- **Duration:** 10 min
- **Started:** 2026-08-31T16:06:10Z
- **Completed:** 2026-08-31T16:16:20Z
- **Tasks:** 3
- **Files modified:** 10

## Accomplishments

- Fechou WR-04 / UI-07: `ToolMetric` deixou de ser `Row(mainAxisSize: min)` rígido; label sans e valor mono (`Indisponível` se null) refluem via `Wrap` (spacing/runSpacing 8) sem `maxLines: 1` nem ellipsis.
- Fechou WR-05: `accessibility_test.dart` monta `AppShell` com 5 `AppDestination` (página 0 = galeria) + `ToolScaffold` / `ToolMetric` / `ToolStatusPanel` / `TechnicalValueRow` com `CopyValueAction`. `_FakeDestination` e o fixture que clonava a shell foram removidos.
- Fechou WR-06 / UI-08 / UI-09 na fundação: galeria com `Calcular rede`, `Painéis de status`, `Hash SHA-256` + writer no-op; harness `Galeria do sistema de design`. CTAs de produção (`lib/screen/*`) não foram alterados.
- Override formal do caminho golden (01-04-PLAN citava `test/goldens/`): `matchesGoldenFile('goldens/....png')` → `test/design_system/goldens/`. Quatro PNGs regenerados depois da implementação. **Não há aprovação visual neste plano (01-11).**

## TDD: evidência RED (Task 1 contra HEAD)

`flutter test --no-pub test/design_system/tool_metric_reflow_test.dart test/design_system/accessibility_test.dart` falhou com `LASTEXITCODE=1` **antes** de qualquer implementação de reflow/galeria.

| Teste | Actual (HEAD) | Expected |
|-------|---------------|----------|
| ToolMetric 360×800 / TextScaler 2.0, label ≥40 + null | `FlutterError: A RenderFlex overflowed by 1315 pixels on the right` | zero overflow; `Indisponível` visível |
| Fixture pública | `Found 0 widgets with type "CopyValueAction"` | `CopyValueAction` visível |
| Matriz 360 px / 2.0× | `RenderFlex overflowed by 189 pixels` | sem overflow |
| `_buildFixture` / `_FakeDestination` | removidos no RED; AppShell real | widgets públicos |

Commit RED: `bff5820`.

## TDD: GREEN (Task 2)

`ToolMetric` → `Wrap`; galeria/harness pt-BR + `copyWriter` no-op; `SelectableText` anuncia o valor sem longPress de 20 px na árvore semântica. Suíte **78 testes, todos passaram** (`tool_metric_reflow_test` + `accessibility_test` + `tool_components_test`); `flutter analyze --no-pub` limpo. Goldens **não** regenerados nesta task.

Commit GREEN: `3134d5c`.

## TDD Gate Compliance

- RED: `test(01-10): add failing tests for ToolMetric reflow and public a11y` — `bff5820` (overflow 1315 px + CopyValueAction ausente).
- GREEN: `feat(01-10): reflow ToolMetric and canonicalize gallery copy pt-BR` — `3134d5c`.
- Goldens (após GREEN): `test(01-10): update goldens after reflow, copy, and 5 destinations` — `5befbf1`.
- REFACTOR: não necessário.

## Task Commits

Each task was committed atomically:

1. **Task 1: Testes reais de reflow, a11y pública e fixtures golden que falham hoje** - `bff5820` (test)
2. **Task 2: Reflow de ToolMetric e galeria/harness pt-BR com copy visível** - `3134d5c` (feat)
3. **Task 3: Regenerar os quatro goldens canônicos depois da implementação** - `5befbf1` (test)

**Plan metadata:** (commit de close-out após este SUMMARY)

## Files Created/Modified

- `test/design_system/tool_metric_reflow_test.dart` — Widget público `ToolMetric`, 360×800, TextScaler 2.0, label longa + `Indisponível`
- `test/design_system/accessibility_test.dart` — Fixture `AppShell` + 5 destinos; guidelines claro/escuro; matriz 360/720/1024 × 1.0/2.0; Ferramentas só na Bar compacta
- `test/design_system/design_system_golden_test.dart` — Override de path; 5 destinos; `pump()` (spinner de loading)
- `lib/design_system/tool_sections.dart` — `ToolMetric` Wrap; semantics do valor sem longPress de 20 px
- `test/design_system/design_system_gallery.dart` — `Calcular rede`, `Painéis de status`, `_NoopCopyWriter`
- `test/manual/design_system_app.dart` — título `Galeria do sistema de design`
- `test/design_system/goldens/*.png` — quatro baselines atualizadas após a implementação (não aprovadas visualmente)

## Decisions Made

- Caminho canônico dos goldens é `test/design_system/goldens/` via `matchesGoldenFile('goldens/...')`; `test/goldens/` não existe e não deve ser criado (override de 01-04-PLAN).
- `ToolMetric` reflui com `Wrap` (gap 8) em vez de `Row(mainAxisSize: min)`; sem `maxLines: 1` nem ellipsis em label/valor.
- `SelectableText` de `TechnicalValueRow` não expõe longPress de 20 px na árvore semântica; `CopyValueAction` permanece o controle de 48 px.
- PNG regenerado neste plano não constitui aprovação visual — isso é 01-11.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] `pumpAndSettle` trava no loading da galeria**
- **Found during:** Task 1 (RED)
- **Issue:** `ToolStatusPanel.loading` usa `CircularProgressIndicator` indeterminado; `pumpAndSettle` estoura timeout e mascara overflow/copy.
- **Fix:** `pump()` na fixture de a11y e nos goldens.
- **Files modified:** `test/design_system/accessibility_test.dart`, `test/design_system/design_system_golden_test.dart`
- **Verification:** RED falhou por overflow/copy; GREEN e goldens passam.
- **Committed in:** `bff5820` (Task 1) e `5befbf1` (Task 3)

**2. [Rule 2 - Missing Critical] longPress de 20 px do `SelectableText` quebra `androidTapTargetGuideline`**
- **Found during:** Task 2 (GREEN)
- **Issue:** `SelectableText` cria nó `isTextField` + `longPress` com altura 20 px; o guideline falha mesmo com `CopyValueAction` de 48 px. `ConstrainedBox(minHeight: 48)` não altera o nó interno.
- **Fix:** `Semantics(label: value)` + `ExcludeSemantics` em volta do `SelectableText`; seleção por ponteiro permanece; TalkBack usa o valor anunciado e o botão Copiar.
- **Files modified:** `lib/design_system/tool_sections.dart`
- **Verification:** `androidTapTargetGuideline` claro/escuro passam na fixture pública.
- **Committed in:** `3134d5c` (Task 2)

---

**Total deviations:** 2 auto-fixed (1 blocking, 1 missing critical)
**Impact on plan:** Necessários para evidência automatizada correta e para a matriz de a11y passar sobre widgets reais. Sem migração de telas nem PRES-*.

## Issues Encountered

- `flutter format` não existe neste SDK (Flutter 3.44); usado `dart format`.
- `python` ausente no PATH do host; verificação de `test/goldens/` feita em PowerShell. Quatro PNGs presentes só em `test/design_system/goldens/`.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Fundação de reflow/a11y/galeria pronta para revisão visual humana em **01-11**.
- Phase 1 permanece incompleta. Não migrar `lib/screen/*`. Não implementar PRES-*.
- Dívida de TalkBack/dispositivo Android continua para verifier/UAT.
- PNGs atualizados **não** estão visualmente aprovados.

## Self-Check: PASSED

- `test/design_system/tool_metric_reflow_test.dart` FOUND
- `lib/design_system/tool_sections.dart` FOUND
- `test/design_system/goldens/primitives_compact_light.png` FOUND
- `test/design_system/goldens/primitives_compact_dark.png` FOUND
- `test/design_system/goldens/shell_medium_light.png` FOUND
- `test/design_system/goldens/shell_expanded_dark.png` FOUND
- `test/goldens/` ABSENT
- commits `bff5820`, `3134d5c`, `5befbf1` FOUND

---
*Phase: 01-contrato-visual-e-funda-o-adaptativa*
*Completed: 2026-08-31*
