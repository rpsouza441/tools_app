---
phase: 02-migra-o-segura-das-ferramentas-atuais
plan: "03"
subsystem: ui
tags: [flutter, ToolScaffold, TechnicalValueRow, PRES-02, Analisar capacidade, NumberFormat]

requires:
  - phase: 02-migra-o-segura-das-ferramentas-atuais
    provides: NetworkCalculatorScreen on ToolScaffold, wrapScreen harness, FakeCopyWriter
provides:
  - DataConverterScreen on ToolScaffold with Analisar capacidade
  - 1 TB advertised/real/difference formatted with NumberFormat('#,##0.000', 'pt_BR')
  - copyWriter injection preserving const DataConverterScreen()
affects:
  - 02-04 Hash + copy + PRES-04 gate

tech-stack:
  added: []
  patterns:
    - Production tool screens return ToolScaffold, not inner Scaffold/AppBar
    - ToolActionGroup has no secondary when the screen had no Limpar
    - Difference uses colorScheme.error, never Colors.red
    - NumberFormat stays in the UI; DataConverter.analyze stays the only calculation

key-files:
  created:
    - test/screen/data_converter_screen_test.dart
  modified:
    - lib/screen/data_converter_screen.dart
    - test/screen/tools_preservation_test.dart

key-decisions:
  - "Optional copyWriter keeps const DataConverterScreen() valid for app_destinations (D-03)"
  - "No Limpar and no onCancel — the screen had no secondary action"
  - "PRES-02 closed for Armazenamento; PRES-04 stays open until 02-04"

patterns-established:
  - "Pattern: isolated wrapScreen tests lock CTA, TB oracle via NumberFormat, field errors, explanation copy, and FakeCopyWriter payload"
  - "Pattern: ToolActionGroup primary-only when the pre-migration screen had no Limpar"

requirements-completed: [PRES-02]

duration: 5min
completed: 2026-08-31
---

# Phase 2 Plan 03: Conversor de Armazenamento ToolScaffold Summary

**DataConverterScreen on ToolScaffold with Analisar capacidade, NumberFormat pt_BR 1 TB values, colorScheme.error difference, and educational 931 GiB copy**

## Performance

- **Duration:** 5 min
- **Started:** 2026-08-31T19:06:00Z
- **Completed:** 2026-08-31T19:10:30Z
- **Tasks:** 3
- **Files modified:** 3

## Accomplishments

- Armazenamento analyzes `1 TB` and shows advertised/real/difference formatted with `NumberFormat('#,##0.000', 'pt_BR')` (PRES-02, D-09).
- Visible CTA is `Analisar capacidade`; `Analisar Capacidade` is gone; no spinner-only button and no `_isLoading` (D-06, D-07).
- Difference uses `colorScheme.error`, never `Colors.red` (D-06). Title remains `Conversor de Armazenamento` (not catalog `Conversor de Dados`).
- Educational copy `Por que a capacidade parece menor?` and `931 GiB` remains (PRES-04).
- Rede stays on ToolScaffold with `Calcular rede`; Hash still has old chrome (`Clipboard.setData`, `Calcular`) (PRES-04, D-04).

## Task Commits

Each task was committed atomically:

1. **Task 1: Write failing Armazenamento widget tests** - `3044e00` (test)
2. **Task 2: Wrap DataConverterScreen without fake loading or Colors.red** - `ff5abce` (feat)
3. **Task 3: Confirm Armazenamento grep gates and Hash still present** — verification only, no code delta

**Plan metadata:** docs commit via `gsd-tools query commit`

## TDD Gate Compliance

- RED: `3044e00` — `test(02-03): add failing test for Armazenamento widget contract` (compile-fail on missing `copyWriter` plus missing Analisar capacidade / ToolScaffold)
- GREEN: `ff5abce` — `feat(02-03): wrap DataConverterScreen in ToolScaffold`
- REFACTOR: not needed

## Files Created/Modified

- `test/screen/data_converter_screen_test.dart` — chrome, empty/non-numeric errors, 1 TB oracle, explanation copy, FakeCopyWriter payload
- `lib/screen/data_converter_screen.dart` — ToolScaffold wrap, optional `copyWriter`, TechnicalValueRow results, `colorScheme.error`
- `test/screen/tools_preservation_test.dart` — Armazenamento heading + Analisar capacidade; Hash AppBar/Calcular unchanged

## Decisions Made

- Optional `CopyValueWriter? copyWriter` preserves `const DataConverterScreen()` in `app_destinations.dart` (D-03). File not edited.
- No `Limpar` and no `onCancel` — the pre-migration screen had no secondary action.
- `NumberFormat('#,##0.000', 'pt_BR')` and `_formatNumber` stay in the UI; `DataConverter.analyze` remains the only calculation (D-09).
- PRES-02 is complete for this plan. PRES-04 remains open until 02-04 because Hash is still unmigrated. The plan frontmatter listed PRES-04 as a preservation constraint, not as a closable requirement.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Explanation finder for 931 GiB in RichText**
- **Found during:** Task 2 (GREEN)
- **Issue:** `find.text('931 GiB')` does not match a `TextSpan` inside a larger `RichText` paragraph. The educational copy was always present; the finder was too strict.
- **Fix:** Assert with `find.textContaining('931 GiB', findRichText: true)` so PRES-04 still locks the wording without changing the explanation structure.
- **Files modified:** `test/screen/data_converter_screen_test.dart`
- **Verification:** `data_converter_screen_test.dart` 7 passed
- **Committed in:** `ff5abce` (Task 2 commit)

---

**Total deviations:** 1 auto-fixed (1 bug)
**Impact on plan:** Finder-only; educational copy and chrome match the plan. No scope creep.

## Issues Encountered

None besides the RichText finder above. Task 1 RED was a compile failure on `copyWriter` (constructor not yet present), which is the intended missing API rather than a malformed finder.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 02-04 can migrate `HashGeneratorScreen` with the same ToolScaffold / ToolActionGroup / CopyValueAction pattern.
- Do not start Phase 3 / Diagnóstico. Do not mark Phase 2 complete. Do not touch `pubspec.lock-old`.

## Verification

1. `data_converter_screen_test.dart` — 7 passed (chrome, two errors, 1 TB oracle, explanation, copy).
2. `tools_preservation_test.dart` — Armazenamento heading + Analisar capacidade; Rede Calcular rede; Hash AppBar Gerador de Hash + Calcular.
3. AppShell happy path and service oracles unchanged (`network_calculator_test`, `data_converter_test`, `hash_calculator_test`). `flutter analyze --no-pub` clean.
4. Armazenamento source has none of `Colors.red`, `_isLoading`, `return Scaffold(`, `AppBar(`, `Analisar Capacidade`, `onCancel:`. Hash still has `Clipboard.setData` and `Text('Calcular')`. Rede still has `Calcular rede`.

## Self-Check: PASSED

- FOUND: `lib/screen/data_converter_screen.dart` (`Analisar capacidade`, `ToolScaffold`, `NumberFormat('#,##0.000', 'pt_BR')`)
- FOUND: `test/screen/data_converter_screen_test.dart`
- FOUND: commits `3044e00`, `ff5abce`
- `lib/screen/hash_generator_screen.dart` and `lib/screen/network_calculator_screen.dart` unmodified
- No stubs that block PRES-02

---
*Phase: 02-migra-o-segura-das-ferramentas-atuais*
*Completed: 2026-08-31*
