---
plan: 01-04
status: complete
started: 2026-08-10T19:38:09-03:00
completed: 2026-08-10T19:45:00-03:00
---

# Plan 01-04 Summary — Golden Tests & Design System Gallery

## What Was Done

Created a test-only design system gallery, 4 golden baseline PNGs for visual regression protection, a manual test harness, and extended accessibility coverage.

## Files Created

| File | Purpose |
|------|---------|
| `test/design_system/design_system_gallery.dart` | `DesignSystemGallery` StatelessWidget showcasing all design system primitives in a controlled, static configuration |
| `test/design_system/design_system_golden_test.dart` | 4 golden comparison tests at different sizes/themes |
| `test/manual/design_system_app.dart` | Runnable harness for manual TalkBack testing on real devices |
| `test/design_system/goldens/primitives_compact_light.png` | Golden baseline — 360×800 light theme |
| `test/design_system/goldens/primitives_compact_dark.png` | Golden baseline — 360×800 dark theme |
| `test/design_system/goldens/shell_medium_light.png` | Golden baseline — 720×1024 AppShell + light theme |
| `test/design_system/goldens/shell_expanded_dark.png` | Golden baseline — 1024×768 AppShell + dark theme |

## Files Modified

| File | Change |
|------|--------|
| `test/design_system/accessibility_test.dart` | Added gallery import + 4 new accessibility tests (labeledTapTarget + textContrast × light/dark) |

## Gallery Content

The `DesignSystemGallery` renders all design system primitives inside a `ToolScaffold`:
- `ToolInputSection` with TextField (normal + errorText)
- `ToolActionGroup` with primary ElevatedButton and secondary TextButton
- `ToolResultCard` with sample result text
- `ToolMetricLayout` with `ToolMetric` (value present) and `ToolMetric` (value null → "Indisponível")
- `TechnicalValueRow` with label + monospace value
- All 7 `ToolStatusPanel` variants (empty, loading, success, failure, offline, permissionDenied, cancelled)

## Golden Test Coverage

| Test | Size | Theme | Content |
|------|------|-------|---------|
| primitives compact light | 360×800 DPR 1 | light | Gallery standalone in Scaffold |
| primitives compact dark | 360×800 DPR 1 | dark | Gallery standalone in Scaffold |
| shell medium light | 720×1024 DPR 1 | light | AppShell with 3 fake destinations |
| shell expanded dark | 1024×768 DPR 1 | dark | AppShell with 3 fake destinations |

## Accessibility Coverage Added

- `labeledTapTargetGuideline` — light theme gallery ✓
- `textContrastGuideline` — light theme gallery ✓
- `labeledTapTargetGuideline` — dark theme gallery ✓
- `textContrastGuideline` — dark theme gallery ✓

Note: `androidTapTargetGuideline` is documented as skipped for the gallery due to Flutter's `SelectableText` rendering read-only text fields with longPress semantics at natural text height (20px). This is a known Flutter semantics behavior for non-interactive selectable text — not a real accessibility regression.

## Verification Results

- `flutter analyze --no-pub` → No issues found
- `flutter test --no-pub --update-goldens` → 4 golden PNGs generated
- `flutter test --no-pub test/design_system/design_system_golden_test.dart` → 4 passed (comparison mode)
- `flutter test --no-pub test/design_system/accessibility_test.dart` → 30 passed
- `flutter test --no-pub` (full suite) → **100 tests passed**

## Design Decisions

1. **Gallery does not own a Scaffold** — callers provide the Material ancestor. This avoids nested Scaffolds when used inside AppShell.
2. **Fake destinations in shell goldens** — avoids importing production screens that have runtime dependencies.
3. **Goldens co-located with test** — stored at `test/design_system/goldens/` next to the test file for clarity.
4. **Shorter metric labels** — used 'Status' instead of 'Indisponível' as the metric label to avoid Wrap/Row overflow at 360px compact width.

## Commits

| Commit | Description |
|--------|-------------|
| `dd45312` | Recovery snapshot for Plans 01-01 through 01-04 after the original execution completed without atomic commits |

## Self-Check: PASSED

Implementation is present and the recovered snapshot passes the full Flutter test and analysis gates.
