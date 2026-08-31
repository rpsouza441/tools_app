---
phase: 01-contrato-visual-e-funda-o-adaptativa
plan: "01"
status: complete
started: 2026-08-10T19:20:37-03:00
completed: 2026-08-10T19:35:00-03:00
---
# Plan 01-01 Summary

## What was done

Implemented a typed destination catalog and adaptive navigation shell using TDD:

1. **AppDestination catalog** — Typed destination entries with id, pt-BR label, semanticLabel, icons, category, compactPriority, and pageBuilder factory. Three destinations: Calculadora de Rede, Conversor de Dados, Gerador de Hash.

2. **AppBreakpoints** — Width classifier: compact (<600), medium (600–839), expanded (≥840) logical pixels.

3. **AppShell** — Adaptive navigation widget:
   - NavigationBar in compact mode
   - Collapsed NavigationRail in medium mode
   - Extended NavigationRail in expanded mode
   - IndexedStack with GlobalKey for state preservation across navigation and resize
   - D-03 overflow: 5+ destinations → top 3 by compactPriority + "Ferramentas" overflow item with categorized bottom sheet

4. **main.dart refactored** — Replaced StatefulWidget with parallel lists/BottomNavigationBar by a stateless App that delegates to AppShell.

5. **UI-08** — Renamed AppBar title from 'Network Calculator' to 'Calculadora de Rede'.

## Files created/modified

### Created
- `lib/design_system/app_breakpoints.dart` — AppWidthClass enum + AppBreakpoints.classify()
- `lib/app/app_destinations.dart` — AppDestinationCategory, AppDestination class, appDestinations list
- `lib/app/app_shell.dart` — Adaptive shell with NavigationBar/Rail + IndexedStack + overflow
- `test/app/destination_catalog_test.dart` — 7 catalog contract tests
- `test/app/app_shell_test.dart` — 11 widget tests (breakpoints, boundaries, preservation, overflow, happy path)

### Modified
- `lib/main.dart` — Simplified to StatelessWidget using AppShell
- `lib/screen/network_calculator_screen.dart` — AppBar title → 'Calculadora de Rede'

## Tests

All 26 tests pass (18 new + 8 existing):
- 7 catalog contract tests (ids, labels, icons, order, factories, priorities, semantics)
- 3 breakpoint classification unit tests
- 3 boundary adaptation widget tests (599/600/840 px)
- 2 state preservation tests (navigation + resize)
- 2 D-03 overflow growth tests (compact pins + Ferramentas selection)
- 1 full happy-path integration test (real App, real calculator, state preserved)

## Verification

- `flutter test --no-pub`: 26 tests passed ✓
- `flutter analyze --no-pub`: No issues found ✓

## Commits

| Commit | Description |
|--------|-------------|
| `dd45312` | Recovery snapshot for Plans 01-01 through 01-04 after the original execution completed without atomic commits |

## Self-Check: PASSED

Implementation is present and the recovered snapshot passes the full Flutter test and analysis gates.
