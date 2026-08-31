---
phase: 02-migra-o-segura-das-ferramentas-atuais
plan: "01"
subsystem: testing
tags: [flutter, widget-test, AppTokens, PRES-04, lightTheme]

requires:
  - phase: 01-contrato-visual-e-funda-o-adaptativa
    provides: lightTheme with AppTokens, AppShell, CopyValueWriter, production destinations
provides:
  - wrapScreen harness with lightTheme for isolated screen tests
  - FakeCopyWriter in-memory clipboard double
  - PRES-04 three-tool smoke via const App()
  - AppTokens-safe AppShell pumps of appDestinations
affects:
  - 02-02 Rede migration (can drop inner Scaffold without crashing boundary tests)
  - 02-03 Armazenamento
  - 02-04 Hash + copy + PRES-04 gate

tech-stack:
  added: []
  patterns:
    - Isolated screen tests wrap with MaterialApp(theme: lightTheme, home: Scaffold(body: child))
    - Integration smoke uses const App() without an extra Scaffold
    - Production appDestinations pumps pass theme: lightTheme; fake destinations do not

key-files:
  created:
    - test/screen/screen_test_harness.dart
    - test/screen/tools_preservation_test.dart
  modified:
    - test/app/app_shell_test.dart

key-decisions:
  - "wrapScreen and FakeCopyWriter live in test/screen/screen_test_harness.dart; tool_components_test analog was not edited"
  - "Four appDestinations pumps pass lightTheme; _pumpShell and fake destinations stay token-free"
  - "PRES-04 smoke uses const App() and current AppBar/CTA chrome; PRES-04 stays open until 02-04"

patterns-established:
  - "Pattern: wrapScreen supplies AppTokens for isolated ToolScaffold tests"
  - "Pattern: appDestinations pumps must set theme: lightTheme before any production screen drops inner Scaffold"

requirements-completed: []

duration: 4min
completed: 2026-08-31
---

# Phase 2 Plan 01: Harness de tema e fumaça PRES-04 Summary

**Shared `wrapScreen`/`FakeCopyWriter` harness plus PRES-04 smoke via `const App()`, with `lightTheme` on every production `appDestinations` AppShell pump**

## Performance

- **Duration:** 4 min
- **Started:** 2026-08-31T18:52:21Z
- **Completed:** 2026-08-31T18:55:20Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments

- Isolated screen tests can resolve `AppTokens` through public `wrapScreen` without touching production chrome.
- `FakeCopyWriter` records clipboard payloads in memory only (T-02-03).
- PRES-04 smoke opens Rede, Armazenamento and Hash in the live `App` and asserts current AppBar titles and CTAs.
- AppShell boundary and production-rail tests no longer omit `lightTheme`, so the next plan can drop Rede's inner Scaffold without a null-check crash.

## Task Commits

Each task was committed atomically:

1. **Task 1: Create wrapScreen harness and PRES-04 three-tool smoke** - `099619b` (test)
2. **Task 2: Supply lightTheme on every AppShell appDestinations pump** - `8742b84` (test)

**Plan metadata:** docs commit via `gsd-tools query commit`

## Files Created/Modified

- `test/screen/screen_test_harness.dart` — public `wrapScreen` and `FakeCopyWriter`
- `test/screen/tools_preservation_test.dart` — harness compile checks + PRES-04 smoke at 360×800
- `test/app/app_shell_test.dart` — `theme: lightTheme` on the four `appDestinations` pumps

## Decisions Made

- Harness is a new `test/screen/` module rather than importing `tool_components_test.dart` (plan forbid).
- Happy path still finds isolated `Calcular` and `Endereço de Rede: 192.168.1.0`; those selectors belong to 02-02 (D-10).
- PRES-04 is evidenced for this increment (all three tools usable with current chrome) but is not marked complete in REQUIREMENTS.md because 02-02..02-04 still carry it.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Removed offstage DataConverterScreen type assert**
- **Found during:** Task 1 (PRES-04 smoke)
- **Issue:** After navigating to Hash, `find.byType(DataConverterScreen)` returned 0 because Flutter test finders skip IndexedStack offstage children. The extra assert was not required by the plan.
- **Fix:** Assert each tool while it is the visible destination; drop the post-Hash type check.
- **Files modified:** `test/screen/tools_preservation_test.dart`
- **Verification:** `flutter test --no-pub test/screen/tools_preservation_test.dart` — 3 passed
- **Committed in:** `099619b` (Task 1)

---

**Total deviations:** 1 auto-fixed (Rule 1)
**Impact on plan:** No scope creep. PRES-04 still proves all three tools via visible chrome.

## Issues Encountered

None beyond the offstage finder above.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 02-02 can migrate `NetworkCalculatorScreen` to `ToolScaffold` without crashing AppShell boundary tests.
- Update PRES-04 Rede assertions in the same plan as the Rede CTA/title change.
- Do not start Phase 3 / Diagnóstico. Do not touch `pubspec.lock-old`.

## Verification

1. `tools_preservation_test.dart` — 3 passed (harness + three-tool smoke).
2. Four `appDestinations` pumps include `theme: lightTheme`; `_pumpShell` does not.
3. `app_shell_test.dart` + service oracles + preservation — 35 passed; `flutter analyze --no-pub` clean.
4. `git diff -- lib/` empty; `test/design_system/goldens/` untouched.

## Self-Check: PASSED

- FOUND: `test/screen/screen_test_harness.dart` (`wrapScreen`)
- FOUND: `test/screen/tools_preservation_test.dart` (`Analisar Capacidade`)
- FOUND: `test/app/app_shell_test.dart` (four `theme: lightTheme`)
- FOUND: commits `099619b`, `8742b84`
- `git diff -- lib/` empty

---
*Phase: 02-migra-o-segura-das-ferramentas-atuais*
*Completed: 2026-08-31*
