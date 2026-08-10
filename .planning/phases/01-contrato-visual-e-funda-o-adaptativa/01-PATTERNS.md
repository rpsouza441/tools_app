# Phase 1: Contrato visual e fundação adaptativa - Pattern Map

**Mapped:** 2026-08-10
**Files analyzed:** 16 new/modified source and test targets
**Analogs found:** 12 / 16 (four architectural targets rely primarily on the approved research/UI contract)

## Scope Guard

This phase is a local Flutter/Material 3 UI foundation. It introduces no backend, persistence, analytics, permissions, networking, router/state framework, remote font, or package. The three current screens remain intact in an `IndexedStack`; Phase 1 changes only the network screen title to `Calculadora de Rede`. Full adoption of the new primitives by all three screens belongs to Phase 2.

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| `lib/main.dart` | config/bootstrap | request-response (startup) | current `lib/main.dart:7-56` | exact, simplify |
| `lib/app/tools_app.dart` | component/provider | request-response | `lib/main.dart:30-56` | extraction match |
| `lib/app/app_destination.dart` | model | transform | `lib/model/analysis_result.dart` | role-match |
| `lib/app/app_destinations.dart` | config | transform | `lib/main.dart:21-27,39-52` | exact data-source replacement |
| `lib/app/app_shell.dart` | component/store | event-driven UI | `lib/main.dart:17-56`; `network_calculator_screen.dart:102-243` | composite match |
| `lib/design_system/app_breakpoints.dart` | utility | transform | `network_calculator_screen.dart:105-108` | role-match |
| `lib/design_system/app_tokens.dart` | config | transform | `lib/theme/theme.dart` | role-match |
| `lib/design_system/tool_scaffold.dart` | component | request-response UI | `data_converter_screen.dart:64-154` | role-match |
| `lib/design_system/tool_sections.dart` | component | request-response UI | three screen-local cards/actions/results | composite role-match |
| `lib/design_system/tool_status_panel.dart` | component/model | event-driven UI | loading/error fragments in `data_converter_screen.dart:26-54,126-136` | partial |
| `lib/design_system/copy_value_action.dart` | component/utility | event-driven UI + clipboard I/O | `hash_generator_screen.dart:50-60,267-291` | exact |
| `lib/theme/theme.dart` | config | transform | current `lib/theme/theme.dart` | exact, evolve in place |
| `lib/screen/network_calculator_screen.dart` | component | request-response UI | same file, line 104 | surgical modification only |
| `test/app/destination_catalog_test.dart` | test | transform | `test/hash_calculator_test.dart:5-25` | test-style match |
| `test/app/app_shell_test.dart` | test | event-driven UI | no widget-test analog | no close local analog |
| `test/design_system/{tool_components_test,accessibility_test,design_system_golden_test.dart}` | tests | event-driven UI / visual snapshot | current unit tests for syntax only | partial/no close analog |

Golden PNGs belong under `test/goldens/` and are generated artifacts of `design_system_golden_test.dart`, not hand-authored source.

## Pattern Assignments

### `lib/main.dart` and `lib/app/tools_app.dart`

**Analog:** `lib/main.dart`

**Imports/bootstrap pattern** (`lib/main.dart:1-9`):

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}
```

Keep `main()` as the one-line bootstrap, renaming the root to `ToolsApp` if desired. Move the existing `MaterialApp` ownership into `tools_app.dart`; continue providing both themes, the Portuguese title, and `debugShowCheckedModeBanner: false`.

**Material app integration** (`lib/main.dart:30-38`):

```dart
return MaterialApp(
  title: 'Ferramentas de TI',
  theme: lightTheme,
  darkTheme: darkTheme,
  debugShowCheckedModeBanner: false,
  home: /* AppShell */,
);
```

Do not add a router. `AppShell` remains the `home` and owns ephemeral selected-index state.

### `lib/app/app_destination.dart` and `lib/app/app_destinations.dart`

**Analog:** the parallel `_screens` and navigation item lists currently in `lib/main.dart:21-27,39-52`.

```dart
final List<Widget> _screens = [
  const NetworkCalculatorScreen(),
  const DataConverterScreen(),
  const HashGeneratorScreen(),
];

items: const [
  BottomNavigationBarItem(icon: Icon(Icons.network_check), label: 'Rede'),
  BottomNavigationBarItem(icon: Icon(Icons.storage), label: 'Armazenamento'),
  BottomNavigationBarItem(icon: Icon(Icons.tag), label: 'Hash'),
],
```

Replace these parallel lists with one immutable typed catalog. Follow the UI-SPEC fields exactly: stable `id`, Portuguese `label`, `semanticLabel`, outlined `icon`, filled `selectedIcon`, typed `category`, `compactPriority`, and `WidgetBuilder pageBuilder`. Initial order is Rede → Armazenamento → Hash and each builder imports the existing screen without moving it. Do not add the future Internet Diagnostics destination.

Model style should be a small immutable value object with `const` constructor and `final` fields, consistent with the project's plain Dart model/service style; no code generation or package.

### `lib/app/app_shell.dart` and `lib/design_system/app_breakpoints.dart`

**Analogs:** selected-index state from `lib/main.dart:17-27,39-44`, responsive constraint branching from `lib/screen/network_calculator_screen.dart:102-108`, and the concrete shell example in `01-RESEARCH.md` under “Classificação central e shell adaptativo.”

```dart
int _selectedIndex = 0;

onTap: (int index) {
  setState(() {
    _selectedIndex = index;
  });
},
```

```dart
body: LayoutBuilder(
  builder: (context, constraints) {
    bool isWideScreen = constraints.maxWidth > 600;
    // branch from available constraints
  },
),
```

Centralize the exact contract rather than retaining `> 600`: compact `<600`, medium `600..<840`, expanded `>=840`. The shell materializes `pageBuilder` results once in `initState`, renders them through `IndexedStack`, and derives both `NavigationDestination` and `NavigationRailDestination` from the same catalog. Use `NavigationBar` in compact, collapsed rail in medium, and extended rail in expanded.

Guard selection so tapping the already-selected item is a no-op. Resizing must only rebuild chrome, never the page list. The 5+ destination compact overflow rule (“three priorities + Ferramentas”) belongs to this shell/catalog boundary and should be testable with fake destinations, but it must not introduce a route architecture.

### `lib/design_system/app_tokens.dart` and `lib/theme/theme.dart`

**Analog:** centralized `ThemeData` and `ColorScheme` in `lib/theme/theme.dart:4-133`.

```dart
final ThemeData darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: const Color(0xFF00FF41),
  ),
  useMaterial3: true,
  // component themes remain centralized here
);
```

Evolve this file in place; do not create a rival theme entry point. Keep colors in `ColorScheme`/component themes and place only spacing, radius, breakpoints/max-width semantics in the small local token boundary. Use the exact UI-SPEC scales: spacing 4/8/16/24/32/48/64, radii 4/8/12, content widths 720/960, and typography 14/16/20/28 with weights 400/600.

The existing dark theme's `onSurface: #00FF41` and green body text (`theme.dart:13-32`) are the anti-pattern being corrected: body/title text becomes neutral, while green remains reserved for primary action, selected navigation, focus, progress, copy affordance, and success icon. Avoid new deprecated color roles and per-widget hex values. New foundation code uses local Material sans plus generic `monospace`; do not add/remove dependencies or trigger Google Fonts runtime fetching.

### `lib/design_system/tool_scaffold.dart`

**Analog:** `lib/screen/data_converter_screen.dart:64-76`.

```dart
return Scaffold(
  appBar: AppBar(title: const Text('Conversor de Armazenamento')),
  body: SingleChildScrollView(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [/* content */],
    ),
  ),
);
```

Preserve the useful vertical-scroll/column convention, then add safe area, width-class padding, centered max width 960, optional Portuguese summary, and semantic heading. This is a presentation container only: it receives children and never owns controllers, validation, calculation, navigation, or persistence. Phase 1 exposes and tests it in a gallery/harness; screens do not migrate wholesale yet.

### `lib/design_system/tool_sections.dart`

**Analogs:** input/result cards in `data_converter_screen.dart:72-150`, 48px actions in `network_calculator_screen.dart:145-170`, and metric/result patterns in `hash_generator_screen.dart:156-237,240-297`.

**Input/action pattern:**

```dart
Card(
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(children: [/* fields, actions */]),
  ),
)
```

```dart
style: ElevatedButton.styleFrom(
  minimumSize: const Size.fromHeight(48),
),
```

Turn this into small composable `ToolInputSection` and `ToolActionGroup`, not a generic form builder. Preserve inline field errors (`errorText` is used in all screens). Actions use `Wrap`/vertical reflow so 360px and text scale 2.0 never overflow; labels remain verb + object and loading retains a comprehensible label.

**Metric pattern** (`hash_generator_screen.dart:185-193,211-235`):

```dart
Wrap(
  spacing: 8,
  runSpacing: 8,
  children: [
    _MetricChip(label: 'Caracteres', value: '$characterCount'),
    _MetricChip(label: 'Bytes UTF-8', value: '$byteCount'),
  ],
)
```

Use this as the basis for `ToolMetric` row/chip and `TechnicalValueRow`. Replace hard-coded local styles with tokens/theme. A `null` metric renders `Indisponível`; never convert missing data to zero or an unexplained dash.

**Result pattern** (`hash_generator_screen.dart:250-291`):

```dart
Card(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // heading, metadata, copy action
        SelectableText(
          result.value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontFamily: 'monospace',
          ),
        ),
      ],
    ),
  ),
)
```

This is the closest analog for `ToolResultCard` and technical values: safe content stays selectable and may wrap. The shared API accepts presentation children and optional actions; it must not assume `HashResult`, `AnalysisResult`, or any feature service.

### `lib/design_system/tool_status_panel.dart`

**Partial analog:** loading/error state held in `data_converter_screen.dart:17-19,26-54,126-136`.

```dart
bool _isLoading = false;
String? _error;

onPressed: _isLoading ? null : _calculate,
child: _isLoading
    ? const CircularProgressIndicator()
    : const Text('Analisar Capacidade'),
```

Do not copy the spinner-only presentation. Implement the UI-SPEC's closed seven-state presentation model (empty, loading, success, failure, offline, permission denied, cancelled), each with icon + Portuguese heading + body. Accept optional progress, next action, and preserved safe result child. The component performs no async work and interprets no numeric sentinel.

### `lib/design_system/copy_value_action.dart`

**Exact analog:** `lib/screen/hash_generator_screen.dart:50-60,267-291`.

```dart
await Clipboard.setData(ClipboardData(text: result.value));
if (!mounted) return;
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('${result.algorithm} copiado')),
);
```

```dart
IconButton(
  onPressed: onCopy,
  tooltip: 'Copiar ${result.algorithm}',
  icon: const Icon(Icons.copy),
),
```

Extract this interaction behind an injectable writer for tests. Copy exactly the visible value, verify `context.mounted`, hide the prior copy SnackBar before showing one 2-second `“{Rótulo} copiado”` SnackBar, and rely on that live region rather than duplicating `SemanticsService.announce`. Preserve the separate `SelectableText` node and a specific Portuguese tooltip/semantic label. Ensure a minimum 48×48 target.

### `lib/screen/network_calculator_screen.dart`

**Only permitted edit:** `lib/screen/network_calculator_screen.dart:103-105`.

```dart
return Scaffold(
  appBar: AppBar(title: const Text('Network Calculator')),
```

Change only the visible title to `Calculadora de Rede`. Do not alter its `LayoutBuilder`, controllers, validation, calculation, actions, result string, or service calls in this phase.

### Tests under `test/app/` and `test/design_system/`

**Local syntax analog:** `test/hash_calculator_test.dart:5-25`.

```dart
void main() {
  group('HashCalculator', () {
    test('calculates known digests for abc', () {
      final results = /* arrange/act */;
      expect(results['MD5'], /* expected */);
    });
  });
}
```

Continue `flutter_test`, `group`, descriptive English test names, and direct `expect`; introduce no mocking or golden package. Widget tests should pump small fake destinations/components rather than feature services.

- `destination_catalog_test.dart`: unique stable ids, nonempty pt-BR labels, icon/selectedIcon, exact initial order, and one builder per destination.
- `app_shell_test.dart`: assert 599 Bar; 600/839 collapsed Rail; 840 extended Rail; navigation opens all pages; same selection does not recreate; resize preserves each state; five fake destinations exercise “Ferramentas”.
- `tool_components_test.dart`: all seven states, preserved child under loading/failure/cancelled, `null → Indisponível`, action reflow, exact injected clipboard value, and one confirmation.
- `accessibility_test.dart`: acquire/dispose semantics handle; run Android tap target, labeled target, and contrast guidelines in light/dark; test Portuguese icon labels and 1.0/2.0 text scale.
- `design_system_golden_test.dart`: set `tester.view.devicePixelRatio = 1` and fixed physical size, register `addTearDown(tester.view.reset)`, settle animations, then compare four approved baselines only (gallery 360×800 light/dark, shell 720×1024 light, shell 1024×768 dark).

The existing eight service tests are regression gates and remain untouched.

## Shared Patterns

### Imports and boundaries

Existing app-facing files prefer `package:tools_app/...` imports (`main.dart:2-5`, `network_calculator_screen.dart:1-3`). Use those across new app/design-system boundaries. Relative imports currently exist in one screen, but new shared code should use the package convention for consistency. Material SDK and `flutter/services.dart` already cover every Phase 1 need.

### State ownership and disposal

Current screens own `TextEditingController`s and dispose them (`network_calculator_screen.dart:94-99`, `data_converter_screen.dart:57-61`, `hash_generator_screen.dart:62-66`). The shell similarly owns only navigation selection and once-created pages. Shared presentational primitives should be stateless unless the interaction itself requires transient UI state; they never reach into screen controllers.

### Validation and errors

All screens keep domain validation locally and pass errors through `InputDecoration.errorText` (network lines 125-139/182-196; converter lines 83-94; hash lines 85-96). New input primitives must allow this pattern through unchanged. No generalized validation layer is introduced.

### Theme access

Existing reusable UI reads `Theme.of(context).colorScheme` and `textTheme` (`hash_generator_screen.dart:169-180,248-291`). Keep this consumer pattern, but eliminate arbitrary local alpha/radius/weight decisions in new code by using semantic roles and tokens.

### Error handling and async safety

There is no external I/O in Phase 1. Clipboard is the only platform write: await it, then check mounted before UI feedback, as the hash screen does. Do not import future network cancellation/lifecycle rules into these primitives.

## Integration Points

1. `main.dart` delegates to `ToolsApp`; `ToolsApp` wires current themes and `AppShell`.
2. `app_destinations.dart` is the only file importing all three screens and is the only concrete navigation catalog.
3. `AppShell` consumes the catalog and `AppBreakpoints`; it does not import individual screens.
4. `theme.dart` installs `AppTokens` and Material component themes; every primitive reads them through `Theme.of(context)`/the extension.
5. The design-system gallery exists in tests (or a test-only harness), not as a production destination.
6. Phase 2 screens consume the stable primitives later; Phase 1 must not partially refactor their calculation/result anatomy beyond the single title fix.

## User-Change Overlap Risks

The working tree is already substantially dirty and those edits belong to the user.

| Path | Observed overlap | Planner/executor safeguard |
|---|---|---|
| `lib/main.dart` | modified: package rename, Portuguese labels/title, third Hash destination | Treat current working copy as baseline; extract, do not restore HEAD's two-destination version. |
| `lib/theme/theme.dart` | modified: deprecated API cleanup (`WidgetStateProperty`, `withValues`, removed `background`) plus formatting | Preserve these user fixes while replacing palette/typography; do not reintroduce deprecated roles/APIs. |
| `lib/screen/network_calculator_screen.dart` | modified logic/output, keyboard type, disposal, package imports | Change only line 104 title; never overwrite the file from HEAD. |
| `lib/screen/data_converter_screen.dart` | modified and contains newer service/model separation | Read-only in Phase 1; use as analog only. |
| `lib/screen/hash_generator_screen.dart`, `lib/service/hash_calculator.dart`, `test/` | untracked/new user functionality | They are current product scope and must remain; catalog includes Hash and regression tests remain intact. |
| `pubspec.yaml` | modified package name/SDK/dependencies | Phase 1 requires no pubspec edit and no package change. |

Before any implementation patch, re-run `git diff -- <target>` and make surgical edits against the working copy. Never use checkout/reset or generated-file cleanup as part of this phase.

## No Analog Found

| File | Role | Data Flow | Reason / authoritative fallback |
|---|---|---|---|
| `lib/app/app_shell.dart` (complete adaptive behavior) | component/store | event-driven UI | Current app has only `BottomNavigationBar`; use the concrete Research shell example plus UI-SPEC breakpoints/growth rules. |
| `lib/design_system/tool_status_panel.dart` | component/model | event-driven UI | No closed seven-state component exists; use UI-SPEC State Contract verbatim. |
| `test/app/app_shell_test.dart` | widget test | event-driven UI | No widget tests exist; use Research's `WidgetTester.view` and official shell test matrix. |
| `test/design_system/design_system_golden_test.dart` | golden test | visual snapshot | No local golden harness/baselines exist; use Research test setup and four UI-SPEC baselines. |

## Metadata

**Analog search scope:** `lib/main.dart`, `lib/theme/`, `lib/screen/`, `lib/model/`, `test/`, plus Phase 1 Context, Research, and UI-SPEC  
**Files scanned:** 13 source/test files plus 3 phase artifacts and project instructions  
**Strong analogs retained:** 5 (`main.dart`, theme, three screens); search stopped once all local UI patterns were covered  
**Pattern extraction date:** 2026-08-10
