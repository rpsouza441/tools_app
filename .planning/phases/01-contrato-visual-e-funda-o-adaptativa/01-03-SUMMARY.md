---
phase: 01-contrato-visual-e-funda-o-adaptativa
plan: "03"
status: complete
started: 2026-08-10T19:31:20-03:00
completed: 2026-08-10T19:45:00-03:00
---
# Plan 01-03 Summary

## What was done

Created composable, feature-agnostic primitive widgets for the design system:

1. **ToolScaffold** — Vertical scrollable container with pt-BR title heading (semantic header), optional summary, contentMaxWidth constraint (960px), and progressive padding by width class (16/24/32px for compact/medium/expanded).

2. **ToolInputSection** — Column layout for form fields with consistent 16px spacing. Does not own Form/controller.

3. **ToolActionGroup** — Primary + optional secondary/cancel actions using OverflowBar for automatic reflow at narrow widths. 48px minimum touch targets inherited from theme.

4. **ToolResultCard** — Card wrapper with 16px padding using theme tokens.

5. **ToolMetric** — Label (sans) + value (mono) display. Null value shows 'Indisponível', never zero.

6. **ToolMetricLayout** — Wrap container for multiple ToolMetric items with 24px spacing.

7. **TechnicalValueRow** — Sans label + mono SelectableText value + optional metadata + conditional CopyValueAction.

8. **ToolStatusVariant** — Enum with 7 variants: empty, loading, success, failure, offline, permissionDenied, cancelled.

9. **ToolStatusPanel** — Maps each variant to Material icon + pt-BR heading + body. Color is supplementary (success=primary, failure/offline=error, others=onSurface). Supports preservedChild for loading/failure/cancelled, onRetry and onSettings callbacks.

10. **CopyValueWriter** — Abstract clipboard interface for testability.

11. **ClipboardCopyWriter** — Default implementation using Clipboard.setData.

12. **CopyValueAction** — 48px IconButton with tooltip 'Copiar {label}', copies exact value, shows '{Label} copiado' SnackBar for 2s, hides prior SnackBar, shows fallback message on writer failure.

## Files created/modified

### Created
- `lib/design_system/tool_scaffold.dart` — ToolScaffold widget
- `lib/design_system/tool_sections.dart` — ToolInputSection, ToolActionGroup, ToolResultCard, ToolMetric, ToolMetricLayout, TechnicalValueRow
- `lib/design_system/tool_status_panel.dart` — ToolStatusVariant enum, ToolStatusPanel widget
- `lib/design_system/copy_value_action.dart` — CopyValueWriter, ClipboardCopyWriter, CopyValueAction
- `test/design_system/tool_components_test.dart` — 40 tests across 3 groups

## Tests

40 tests organized in 3 groups:

- **tool anatomy** (17 tests): ToolScaffold title as semantic heading, optional summary, contentMaxWidth, padding by breakpoint (compact/medium/expanded); ToolInputSection spacing; ToolActionGroup primary/cancel/wrap; ToolResultCard; ToolMetric value/null; ToolMetricLayout; TechnicalValueRow label/value/copy/metadata
- **status** (14 tests): All 7 variants render correct icon/heading/body; preservedChild shown for loading/failure/cancelled only; onRetry/onSettings control button visibility
- **copy** (9 tests): Injected writer receives exact value; confirmation SnackBar; hides prior SnackBar; failure fallback message; tooltip text; 48px minimum size; TechnicalValueRow integration

## Verification

- `flutter test --no-pub test/design_system/tool_components_test.dart` → 40 tests, ALL PASS
- `flutter test --no-pub` → 92 tests, ALL PASS (no regressions)
- `flutter analyze --no-pub` → No issues found

## Commits

| Commit | Description |
|--------|-------------|
| `dd45312` | Recovery snapshot for Plans 01-01 through 01-04 after the original execution completed without atomic commits |

## Self-Check: PASSED

Implementation is present and the recovered snapshot passes the full Flutter test and analysis gates.
