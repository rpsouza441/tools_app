---
phase: 02-migra-o-segura-das-ferramentas-atuais
plan: "02"
subsystem: ui
tags: [flutter, ToolScaffold, TechnicalValueRow, PRES-01, Calcular rede]

requires:
  - phase: 02-migra-o-segura-das-ferramentas-atuais
    provides: wrapScreen harness, FakeCopyWriter, lightTheme on AppShell appDestinations pumps
provides:
  - NetworkCalculatorScreen on ToolScaffold with Calcular rede
  - Split TechnicalValueRow IPv4 results and copyWriter injection
  - AppShell happy path aligned to 192.168.1.0 without inner AppBar
affects:
  - 02-03 Armazenamento (same wrap pattern)
  - 02-04 Hash + copy + PRES-04 gate

tech-stack:
  added: []
  patterns:
    - Production tool screens return ToolScaffold, not inner Scaffold/AppBar
    - ToolActionGroup.secondary is Limpar; never onCancel
    - Structured result fields feed TechnicalValueRow/ToolMetric instead of a concatenated blob

key-files:
  created:
    - test/screen/network_calculator_screen_test.dart
  modified:
    - lib/screen/network_calculator_screen.dart
    - test/app/app_shell_test.dart
    - test/screen/tools_preservation_test.dart

key-decisions:
  - "Optional copyWriter keeps const NetworkCalculatorScreen() valid for app_destinations (D-03)"
  - "Limpar uses ToolActionGroup.secondary; onCancel is never wired (would paint Cancelar)"
  - "PRES-01 closed for Rede; PRES-04 stays open until 02-04"

patterns-established:
  - "Pattern: first migrated tool screen owns AppShell selector updates in the same plan (D-10)"
  - "Pattern: isolated wrapScreen tests lock CTA, split values, field errors, and copy payload before chrome lands"

requirements-completed: [PRES-01]

duration: 4min
completed: 2026-08-31
---

# Phase 2 Plan 02: Calculadora de Rede ToolScaffold Summary

**NetworkCalculatorScreen on ToolScaffold with Calcular rede, split TechnicalValueRow IPv4 rows, and AppShell happy path asserting 192.168.1.0**

## Performance

- **Duration:** 4 min
- **Started:** 2026-08-31T18:58:20Z
- **Completed:** 2026-08-31T19:02:04Z
- **Tasks:** 3
- **Files modified:** 4

## Accomplishments

- Rede calculates `192.168.1.10 /24` and shows `192.168.1.0` as a separate Endereço de Rede value, not a concatenated blob (PRES-01, D-07, D-09, D-10).
- Visible CTA is `Calcular rede`; Limpar is the secondary action; Cancelar is never painted.
- Inner Scaffold/AppBar and the >600 Row layout are gone; title lives on ToolScaffold.
- Armazenamento and Hash remain on pre-migration chrome and stay reachable (PRES-04 increment).

## Task Commits

Each task was committed atomically:

1. **Task 1: Write failing Rede widget tests** - `dda004d` (test)
2. **Task 2: Wrap NetworkCalculatorScreen and update AppShell selectors** - `d0b7475` (feat)
3. **Task 3: Confirm Rede grep gates and unmigrated screens** — verification only, no code delta

**Plan metadata:** docs commit via `gsd-tools query commit`

## TDD Gate Compliance

- RED: `dda004d` — `test(02-02): add failing test for Rede widget contract` (compile-fail on missing `copyWriter` plus missing Calcular rede / ToolScaffold / split rows)
- GREEN: `d0b7475` — `feat(02-02): wrap NetworkCalculatorScreen in ToolScaffold`
- REFACTOR: not needed

## Files Created/Modified

- `test/screen/network_calculator_screen_test.dart` — happy path, four field errors, copy payload via FakeCopyWriter
- `lib/screen/network_calculator_screen.dart` — ToolScaffold wrap, optional `copyWriter`, structured IPv4 rows
- `test/app/app_shell_test.dart` — Calcular rede, split `192.168.1.0`, AppBar title finder findsNothing
- `test/screen/tools_preservation_test.dart` — Rede heading + Calcular rede; Armazenamento/Hash chrome unchanged

## Decisions Made

- Optional `CopyValueWriter? copyWriter` preserves `const NetworkCalculatorScreen()` in `app_destinations.dart` (D-03). File not edited.
- Validators and `NetworkCalculator` calls stay character-exact in `_calculate` (D-09). Service files untouched.
- PRES-01 is complete for this plan. PRES-04 remains open until 02-04 because Armazenamento and Hash are still unmigrated.

## Deviations from Plan

None - plan executed exactly as written.

Task 3 produced no files: grep gates and the service+AppShell suite passed without a fix.

---

**Total deviations:** 0
**Impact on plan:** None.

## Issues Encountered

None. Task 1 RED was a compile failure on `copyWriter` (constructor not yet present), which is the intended missing API rather than a malformed finder.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 02-03 can migrate `DataConverterScreen` with the same ToolScaffold / ToolActionGroup pattern.
- Do not start Phase 3 / Diagnóstico. Do not migrate Hash in this increment. Do not touch `pubspec.lock-old`.

## Verification

1. `network_calculator_screen_test.dart` — 7 passed (chrome, happy path, four errors, copy).
2. AppShell happy path calculates `192.168.1.0` and keeps it after Armazenamento → Rede; compact-bar AppBar descendant is `findsNothing`.
3. Service oracles unchanged (`network_calculator_test`, `data_converter_test`, `hash_calculator_test`). `flutter analyze --no-pub` clean.
4. Rede source has no `Scaffold(`, `AppBar(`, `Text('Calcular')`, or `onCancel:`. Armazenamento still has `Analisar Capacidade`. Hash still has `Text('Calcular')` and `Gerador de Hash`.

## Self-Check: PASSED

- FOUND: `lib/screen/network_calculator_screen.dart` (`Calcular rede`, `ToolScaffold`)
- FOUND: `test/screen/network_calculator_screen_test.dart`
- FOUND: commits `dda004d`, `d0b7475`
- `lib/screen/data_converter_screen.dart` and `lib/screen/hash_generator_screen.dart` unmodified

---
*Phase: 02-migra-o-segura-das-ferramentas-atuais*
*Completed: 2026-08-31*
