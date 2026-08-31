# Phase 2: Migração segura das ferramentas atuais - Pattern Map

**Mapped:** 2026-08-31
**Files analyzed:** 7 new/modified (3 production screens, 1 existing widget test, 3 new screen widget tests)
**Analogs found:** 7 / 7

Phase 2 wraps existing `StatefulWidget` screens onto Phase 1 primitives. It does **not** create parallel screens, a new router, services, or Diagnóstico. Analog for chrome is the gallery + `tool_sections.dart`; analog for domain logic is the same screen file (keep `_calculate` / validators / result values). Analog for isolated widget tests is `tool_components_test.dart` `_wrap` + `FakeCopyWriter`. Analog for AppShell tests that mount `appDestinations` is `accessibility_test.dart` `theme: lightTheme`.

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `lib/screen/network_calculator_screen.dart` | component | request-response UI (sync form → service) | `test/design_system/design_system_gallery.dart` (chrome); same file lines 21–99 (logic) | exact |
| `lib/screen/data_converter_screen.dart` | component | request-response UI (sync form → service) | gallery composition; same file `_calculate` / `_formatNumber` / explanation copy | exact |
| `lib/screen/hash_generator_screen.dart` | component | request-response UI + clipboard I/O | gallery + `TechnicalValueRow` + `CopyValueAction`; same file `_calculate`/`_clear` | exact |
| `test/app/app_shell_test.dart` | test | event-driven UI | `test/design_system/accessibility_test.dart` `_buildPublicFixture` (theme); same file Happy path (selectors) | exact |
| `test/screen/network_calculator_screen_test.dart` | test | request-response UI | `test/design_system/tool_components_test.dart` `_wrap`; Happy path in `app_shell_test.dart` | role-match |
| `test/screen/data_converter_screen_test.dart` | test | request-response UI | `_wrap` + `data_converter_screen.dart` field/error strings | role-match |
| `test/screen/hash_generator_screen_test.dart` | test | request-response UI + clipboard I/O | `_wrap` + `FakeCopyWriter` + `copy_lifecycle_test.dart` + `hash_calculator_test.dart` oracles | role-match |

**Do not modify this phase** (read-only oracles / already shipped):

| File | Why |
|------|-----|
| `lib/service/network_calculator.dart`, `lib/utils/network_utils.dart` | D-09 value lock |
| `lib/service/data_converter.dart`, `lib/model/analysis_result.dart` | D-09; `NumberFormat` stays in UI |
| `lib/service/hash_calculator.dart` | D-09 digest lock |
| `lib/app/app_shell.dart`, `lib/app/app_destinations.dart` | IndexedStack identity; keep `const NetworkCalculatorScreen()` etc. |
| `lib/design_system/*` | Foundation frozen unless a shared primitive must change (it should not) |
| `test/network_calculator_test.dart`, `test/data_converter_test.dart`, `test/hash_calculator_test.dart` | Do not change value asserts |
| `test/design_system/goldens/` | D-13; PNG is not production-screen sign-off |
| `pubspec.yaml`, `pubspec.lock-old` | D-11 / D-12 |

## Pattern Assignments

### `lib/screen/network_calculator_screen.dart` (component, request-response UI)

**Analog (chrome):** `test/design_system/design_system_gallery.dart`
**Analog (logic):** same file `_calculate` / `_clearFields` / `dispose` — do not extract a controller.

**Imports to add** (gallery + production screens that already use package imports):

```dart
import 'package:flutter/material.dart';
import 'package:tools_app/design_system/copy_value_action.dart';
import 'package:tools_app/design_system/tool_scaffold.dart';
import 'package:tools_app/design_system/tool_sections.dart';
import 'package:tools_app/service/network_calculator.dart';
import 'package:tools_app/utils/network_utils.dart';
```

Keep existing `package:tools_app/service/...` style. Optional `CopyValueWriter? copyWriter` constructor matches Hash (see Hash assignment).

**Core composition pattern** (`design_system_gallery.dart` lines 31–65) — production must wire real callbacks, never `onPressed: () {}`:

```dart
return ToolScaffold(
  title: 'Calculadora de Rede',
  children: [
    ToolInputSection(
      children: [
        TextField(
          controller: _ipController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            labelText: 'Endereço de IP',
            border: const OutlineInputBorder(),
            errorText: _ipError,
          ),
        ),
        TextField(
          controller: _maskOrCidrController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            labelText: 'Máscara de Sub-Rede ou CIDR',
            border: const OutlineInputBorder(),
            errorText: _maskOrCidrError,
          ),
        ),
      ],
    ),
    const SizedBox(height: 24),
    ToolActionGroup(
      primary: ElevatedButton(
        onPressed: _calculate,
        child: const Text('Calcular rede'),
      ),
      secondary: TextButton(
        onPressed: _clearFields,
        child: const Text('Limpar'),
      ),
    ),
    // results only when success (omit empty card)
  ],
);
```

**Delete this chrome** (`network_calculator_screen.dart` lines 102–243): inner `Scaffold` + `AppBar`, `LayoutBuilder` `maxWidth > 600` Row flex 7/3, local `Padding(16)`, compact `Row` with `width * 0.6`, concatenated `_result` `Text` blob, `Text('Calcular')`.

**Keep this logic** (`network_calculator_screen.dart` lines 21–99): `isValidIp` / empty mask / `isValidSubnetMask` / `isValidCidr` `errorText` strings character-exact; `NetworkCalculator` calls; catch `FormatException` → `'Erro: Formato de entrada inválido. Verifique os valores inseridos.'`; generic catch → `'Erro inesperado: ${e.toString()}'`; `_clearFields` clears controllers + errors + result.

**Result display pattern** — split the blob (`network_calculator_screen.dart` lines 68–74) into rows; values stay the service strings:

```dart
// Current blob (DELETE as UI; KEEP the six computed strings):
// 'Endereço de Rede: $networkAddress\n'
// 'Faixa de IPs: $ipRange\n' ...
ToolResultCard(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TechnicalValueRow(
        label: 'Endereço de Rede',
        value: networkAddress,
        copyWriter: widget.copyWriter ?? const ClipboardCopyWriter(),
      ),
      TechnicalValueRow(label: 'Faixa de IPs', value: ipRange, copyWriter: ...),
      TechnicalValueRow(label: 'Endereço de Broadcast', value: broadcastAddress, copyWriter: ...),
      TechnicalValueRow(label: 'Máscara de Sub-rede', value: calculator.subnetMask, copyWriter: ...),
      TechnicalValueRow(label: 'CIDR', value: '/${calculator.cidr}', copyWriter: ...),
      ToolMetric(label: 'Hosts utilizáveis', value: '$usableHosts'),
    ],
  ),
)
```

State must hold structured fields (or the calculator instance) instead of a single `_result` String so labels and values are separate widgets. Field `errorText` stays on the fields — do **not** replace with `ToolStatusPanel.empty` / `.loading` / `.offline`. Catch-all body text may sit under the result region or `ToolStatusPanel.failure`; do not invent diagnostic variants.

**Anti-pattern:** `ToolActionGroup(onCancel: _clearFields)` — `onCancel` always paints `'Cancelar'` (`tool_sections.dart` lines 46–60).

---

### `lib/screen/data_converter_screen.dart` (component, request-response UI)

**Analog (chrome):** `design_system_gallery.dart` + `ToolInputSection` column (not rigid `Row`)
**Analog (logic):** same file `_calculate` / `_formatNumber` / `_buildExplanationCard` copy

**Imports:** this file currently uses relative `../service/` and `../model/` (lines 3–5). New design-system imports should use `package:tools_app/design_system/...` like other production files. Do not move `NumberFormat` into the service.

**Keep** (`data_converter_screen.dart` lines 21–54, 157–326):

- `NumberFormat('#,##0.000', 'pt_BR')` and `_formatNumber`
- `_fromUnit = 'GB'`, `DataConverter.availableUnits`, `DropdownButtonFormField.initialValue`
- error strings `'Insira um valor'`, `'Insira um valor numérico positivo'`, `e.toString().replaceAll('ArgumentError: ', '')`
- explanation words: `'Por que a capacidade parece menor?'`, manufacturer/system `ListTile` copy, `'1 TB'` / `'931 GiB'`

**Delete:** inner `Scaffold`/`AppBar` (lines 65–66); input `Card`+`Row` (73–141); `_isLoading` and spinner-only button child (19, 27–35, 132–135); `Colors.red` (232–235); `BorderRadius.circular(12)` on explanation (252–257); CTA `'Analisar Capacidade'`.

**Replace chrome:**

```dart
return ToolScaffold(
  title: 'Conversor de Armazenamento', // current AppBar; do NOT use catalog 'Conversor de Dados'
  children: [
    ToolInputSection(
      children: [
        TextField( /* labelText: 'Valor Anunciado', errorText: _error, onSubmitted: _calculate */ ),
        DropdownButtonFormField<String>( /* same items / initialValue / Unidade */ ),
      ],
    ),
    const SizedBox(height: 24),
    ToolActionGroup(
      primary: ElevatedButton(
        onPressed: _calculate,
        child: const Text('Analisar capacidade'),
      ),
    ),
    if (_result != null) ToolResultCard(child: /* TechnicalValueRow / ToolMetric */),
    ToolResultCard(child: /* same explanation copy, no local radius 12 */),
  ],
);
```

**Color pattern:** difference text uses `Theme.of(context).colorScheme.error`, never `Colors.red` (`data_converter_screen.dart` 232–235 → `colorScheme.error` like `tool_status_panel.dart` `_iconColor` failure branch lines 100–106).

**Copy:** `TechnicalValueRow` on advertised/real/difference and conversion lines; copied payload = formatted number + unit as displayed (`_formatNumber(data.value) + ' ' + data.unit`). Optional `copyWriter` constructor same as Hash.

**Do not** add `ToolStatusPanel.loading`. `_calculate` is synchronous; drop the fake flag.

---

### `lib/screen/hash_generator_screen.dart` (component, request-response UI + clipboard)

**Analog (chrome):** gallery `ToolScaffold` / `ToolActionGroup` / `ToolMetricLayout`
**Analog (copy):** `lib/design_system/copy_value_action.dart` + `TechnicalValueRow` (`tool_sections.dart` 139–210)
**Analog (logic):** same file `_calculate` / `_clear` (lines 20–48)

**Constructor seam** (recommended; `pageBuilder` stays `const HashGeneratorScreen()`):

```dart
class HashGeneratorScreen extends StatefulWidget {
  const HashGeneratorScreen({super.key, this.copyWriter});
  final CopyValueWriter? copyWriter;
}
```

**DELETE** `_copy` and `flutter/services.dart` if unused (`hash_generator_screen.dart` lines 50–60, 1):

```dart
// DELETE this production path:
await Clipboard.setData(ClipboardData(text: result.value));
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('${result.algorithm} copiado')),
);
```

**USE** (`tool_sections.dart` 142–161 + `copy_value_action.dart` 23–26):

```dart
TechnicalValueRow(
  label: result.algorithm,
  value: result.value,
  metadata: '${result.bits} bits · ${result.strength} · ${result.value.length} hex',
  copyWriter: widget.copyWriter ?? const ClipboardCopyWriter(),
);
```

Copied payload remains `result.value`. SnackBar becomes `{Rótulo} copiado` via `CopyValueAction` (`copy_value_action.dart` 75–83) — for `"MD5"` that is `"MD5 copiado"` (first-letter capitalize of already-uppercase label).

**Metrics** — replace `_HashSummaryCard` / `_MetricChip` (`hash_generator_screen.dart` 156–237) with:

```dart
ToolMetricLayout(
  metrics: [
    ToolMetric(label: 'Caracteres', value: '$_characterCount'),
    ToolMetric(label: 'Bytes UTF-8', value: '$_byteCount'),
    ToolMetric(label: 'Algoritmos', value: '${_results.length}'),
  ],
)
```

Pass real counts, never `null` (`tool_sections.dart` 84–92: null → `'Indisponível'`).

**CTA:** `ToolActionGroup` primary `'Gerar hashes'`, secondary `'Limpar'` calling `_calculate` / `_clear`. Icons optional; do not empty `onPressed`. Delete private `_HashResultTile` / `_MetaLabel` after replacement.

**Keep:** warning `'MD5 e SHA-1 servem para conferência, não para proteger senhas.'`; field `labelText: 'Texto'`; error `'Digite ou cole um texto para calcular o hash.'`; `HashCalculator.calculate(input)` only — do not call `crypto` from the screen.

---

### `test/app/app_shell_test.dart` (test, event-driven UI)

**Analog (theme harness):** `test/design_system/accessibility_test.dart` lines 70–74
**Analog (happy path to update):** same file lines 245–304 and 337–343

**Theme wrap — apply to every pump of `AppShell(destinations: appDestinations)`** (currently missing `lightTheme` at lines 33–35, 50–52, 67–69, 512–514). Fake destinations (`_buildFiveDestinations`, `_CounterPage`) do **not** need tokens until they embed `ToolScaffold`.

```dart
// Source: accessibility_test.dart:70-74
Widget _buildPublicFixture(ThemeData theme) {
  return MaterialApp(
    theme: theme,
    home: AppShell(destinations: _publicDestinations),
  );
}

// Apply as:
await tester.pumpWidget(
  MaterialApp(
    theme: lightTheme,
    home: AppShell(destinations: appDestinations),
  ),
);
```

Import `package:tools_app/theme/theme.dart`. Happy path already uses `const App()` (`main.dart` 15–21 already sets `theme: lightTheme`) — do not wrap `App()` in an extra `Scaffold`.

**Update `_pumpShell` only if it starts mounting production screens.** Today `_pumpShell` (lines 721–735) uses fake destinations — leave as-is unless a test switches to `appDestinations`.

**Happy path selector update** (same plan as Rede). Current (lines 260–302):

```dart
expect(
  find.descendant(
    of: find.byType(AppBar),
    matching: find.text('Calculadora de Rede'),
  ),
  findsOneWidget,
);
await tester.ensureVisible(find.text('Calcular'));
await tester.tap(find.text('Calcular'));
expect(
  find.textContaining('Endereço de Rede: 192.168.1.0'),
  findsOneWidget,
);
```

**After Rede migration:**

```dart
expect(find.text('Calculadora de Rede'), findsWidgets); // ToolScaffold heading + tooltip
expect(
  find.descendant(
    of: find.byType(AppBar),
    matching: find.text('Calculadora de Rede'),
  ),
  findsNothing,
);
await tester.ensureVisible(find.text('Calcular rede'));
await tester.tap(find.text('Calcular rede'));
await tester.pumpAndSettle();
expect(find.text('Endereço de Rede'), findsWidgets);
expect(find.text('192.168.1.0'), findsWidgets);
expect(find.text('Calcular'), findsNothing);
```

If `find.text('192.168.1.0')` misses `SelectableText`, allow `find.textContaining('192.168.1.0', findRichText: true)` (research A1). Compact-bar test (lines 337–343) must drop the AppBar descendant finder the same way. Keep IndexedStack check: tap `'Armazenamento'` then `'Rede'` → value still visible.

Do **not** change catalog tooltips `'Calculadora de Rede'` / `'Conversor de Dados'` / `'Gerador de Hash'` (lines 328–335).

---

### `test/screen/network_calculator_screen_test.dart` (test, request-response UI)

**Analog:** `tool_components_test.dart` `_wrap` (lines 29–42) + Happy path oracles + field error strings from the screen.

`test/screen/` does not exist yet — create it. Isolated tests supply a throwaway `Scaffold` because production screens no longer own one.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tools_app/screen/network_calculator_screen.dart';
import 'package:tools_app/theme/theme.dart';

Widget wrapScreen(Widget child) {
  return MaterialApp(
    theme: lightTheme,
    home: Scaffold(body: child),
  );
}
```

**Happy path + field error** (compose `app_shell_test.dart` 269–288 + `network_calculator_screen.dart` 29–31):

```dart
await tester.pumpWidget(wrapScreen(const NetworkCalculatorScreen()));
await tester.enterText(
  find.widgetWithText(TextField, 'Endereço de IP'),
  '192.168.1.10',
);
await tester.enterText(
  find.widgetWithText(TextField, 'Máscara de Sub-Rede ou CIDR'),
  '24',
);
await tester.tap(find.text('Calcular rede'));
await tester.pumpAndSettle();
expect(find.text('192.168.1.0'), findsWidgets);
expect(find.text('Calcular'), findsNothing);
expect(find.byType(AppBar), findsNothing);
expect(find.byType(ToolScaffold), findsOneWidget);

await tester.tap(find.text('Limpar'));
await tester.pump();
await tester.tap(find.text('Calcular rede'));
await tester.pump();
expect(find.text('Formato de IP inválido (ex: 192.168.1.1).'), findsOneWidget);
```

Also assert remaining field errors character-exact: `'Insira uma máscara de sub-rede ou um CIDR.'`, `'Máscara de sub-rede inválida.'`, `'Valor de CIDR inválido (0-32).'`. Do **not** assert only `find.byType(ToolScaffold)` without IP/error oracles.

Copy (if `copyWriter` injected): copy `FakeCopyWriter` from `tool_components_test.dart` 13–27; tap `CopyValueAction` on network address; `expect(writer.lastValue, '192.168.1.0')` — payload is the IP, not `'Endereço de Rede: 192.168.1.0'`.

---

### `test/screen/data_converter_screen_test.dart` (test, request-response UI)

**Analog:** same `wrapScreen` + screen field labels/errors (`data_converter_screen.dart` 88–92, 34, 41) + service oracle formatted in UI.

```dart
await tester.pumpWidget(wrapScreen(const DataConverterScreen()));
await tester.enterText(
  find.widgetWithText(TextField, 'Valor Anunciado'),
  '1',
);
// default unit is GB — change dropdown to TB if asserting TiB oracle
await tester.tap(find.text('Analisar capacidade'));
await tester.pumpAndSettle();
expect(find.text('Analisar Capacidade'), findsNothing);
expect(find.text('Insira um valor'), findsNothing);
```

For TB fixture matching `test/data_converter_test.dart` lines 6–13: select `'TB'`, analyze `1`, assert formatted advertised/real/difference appear (pt-BR `NumberFormat('#,##0.000')`). Empty submit → `'Insira um valor'`. Non-numeric → `'Insira um valor numérico positivo'`. Explanation copy still present: `'Por que a capacidade parece menor?'` and `'931 GiB'`. No `CircularProgressIndicator` as the only button child. No `Colors.red` in the result tree — difference uses error role.

---

### `test/screen/hash_generator_screen_test.dart` (test, request-response UI + clipboard)

**Analog:** `FakeCopyWriter` (`tool_components_test.dart` 13–27) + digest oracles (`hash_calculator_test.dart` 6–24) + copy invocation (`copy_lifecycle_test.dart` 114–132).

```dart
final writer = FakeCopyWriter();
await tester.pumpWidget(
  wrapScreen(HashGeneratorScreen(copyWriter: writer)),
);
await tester.enterText(find.widgetWithText(TextField, 'Texto'), 'abc');
await tester.tap(find.text('Gerar hashes'));
await tester.pumpAndSettle();

expect(find.text('900150983cd24fb0d6963f7d28e17f72'), findsOneWidget);
expect(find.text('a9993e364706816aba3e25717850c26c9cd0d89d'), findsOneWidget);
expect(
  find.text('ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad'),
  findsOneWidget,
);
expect(find.text('Calcular'), findsNothing);
expect(find.text('MD5 e SHA-1 servem para conferência, não para proteger senhas.'), findsOneWidget);

await tester.tap(find.byType(CopyValueAction).first);
await tester.pumpAndSettle();
expect(writer.lastValue, '900150983cd24fb0d6963f7d28e17f72');
```

Empty submit → `'Digite ou cole um texto para calcular o hash.'`. Do not use host clipboard; do not keep a parallel `_copy` test.

## Shared Patterns

### Page is content; shell is chrome

**Source:** `design_system_gallery.dart` lines 21–23 and 31–34; `lib/app/app_shell.dart` (single `Scaffold`); `lib/main.dart` 15–21.

Production pages return `ToolScaffold(...)` only. `AppShell` is the only `Scaffold` (nav bar / rail). Isolated widget tests wrap `home: Scaffold(body: Screen())`. Integration tests use `const App()` with no extra Scaffold.

`SnackBar` de cópia usa `ScaffoldMessenger.of(context)` on `MaterialApp` (`copy_value_action.dart` 98–101) — inner Scaffold is not required.

### `AppTokens` via `lightTheme`

**Source:** `tool_scaffold.dart` line 32 `Theme.of(context).extension<AppTokens>()!`; `theme.dart` 164–188 (`extensions: const <ThemeExtension>[AppTokens()]`); `tool_components_test.dart` 29–34.

**Apply to:** all new screen widget tests; every `app_shell_test` that pumps `appDestinations`.

Without `theme: lightTheme`, Rede migration crashes AppShell boundary tests with a null-check in `ToolScaffold`.

### IndexedStack page identity (PRES-04)

**Source:** `app_shell.dart` 91–99:

```dart
_pagesById.putIfAbsent(
  destination.id,
  () => destination.pageBuilder(context),
);
```

**Source:** `app_destinations.dart` 83–88:

```dart
Widget _buildNetworkCalculator(BuildContext context) =>
    const NetworkCalculatorScreen();
Widget _buildDataConverter(BuildContext context) => const DataConverterScreen();
Widget _buildHashGenerator(BuildContext context) => const HashGeneratorScreen();
```

Keep the same widget **types** and `const` constructors. Optional `copyWriter` must be optional with default so `const HashGeneratorScreen()` still compiles. Do not rename screens or destination `id`s.

### Field errors stay on fields

**Source:** `network_calculator_screen.dart` 125–128 `errorText: _ipError`; gallery `design_system_gallery.dart` 44–52.

Do not mount `ToolStatusPanel` variants `offline`, `permissionDenied`, `cancelled`, or `loading` on these three tools. Empty: omit the result region. Success: result card only — skip redundant `'Concluído'` (`tool_status_panel.dart` 37–40).

### Copy through `CopyValueAction` only

**Source:** `copy_value_action.dart` 13–20 (sole production `Clipboard.setData`); `tool_sections.dart` 206–207 (`copyWriter != null` → `CopyValueAction`).

**Apply to:** Rede, Armazenamento, Hash after each screen’s plan.

Post-Hash grep: `Clipboard.setData` only in `ClipboardCopyWriter`. Do not keep `_copy` plus `CopyValueAction` (two SnackBars). Inject `FakeCopyWriter` / `RecordingCopyWriter` in tests (`tool_components_test.dart` 13–27; `copy_lifecycle_test.dart` 19–27).

Tooltip / SnackBar contract already tested — do not reimplement: `'Copiar ${label}'` and `'$_capitalizedLabel copiado'` (`copy_value_action.dart` 60–83).

### `ToolActionGroup`: Limpar is `secondary`, never `onCancel`

**Source:** `tool_sections.dart` 32–60; gallery 59–65.

`onCancel` renders `'Cancelar'`. Production: `secondary: TextButton(onPressed: _clearFields, child: const Text('Limpar'))`. Gallery empty callbacks (`onPressed: () {}`) are **not** for production (gallery comment lines 18–19).

### CTA labels (UI-SPEC; results unchanged)

| Screen | Forbidden after that screen’s plan | Required |
|--------|-------------------------------------|----------|
| Rede | `Calcular` | `Calcular rede` |
| Armazenamento | `Analisar Capacidade` | `Analisar capacidade` |
| Hash | `Calcular` | `Gerar hashes` |
| Rede, Hash | — | `Limpar` remains |

Do **not** “fix” `tool_components_test.dart` sample `'Calcular'` (line 213) — it is a primitive sample, not a production CTA.

### Service tests remain value oracles

**Source:** `test/network_calculator_test.dart` 23–36 (`192.168.1.0` / `254` hosts); `test/data_converter_test.dart` 6–13; `test/hash_calculator_test.dart` 6–24 (`'abc'` digests).

Widget tests enter the same fixtures and assert the same numbers/strings. Diffs in those three unit files are a regression, not a UI fix.

### Import style

New design-system imports: `package:tools_app/design_system/...` (gallery, `app_destinations.dart`, `network_calculator_screen.dart`, `hash_generator_screen.dart`). `data_converter_screen.dart` may keep relative service/model imports; do not churn them without need.

## No Analog Found

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| — | — | — | All seven targets have a close analog. `test/screen/` is a new directory; copy `_wrap` / `FakeCopyWriter` from `test/design_system/tool_components_test.dart` rather than inventing a test harness. |

There is no existing production screen already on `ToolScaffold`. The gallery is the composition contract; do not copy its empty `onPressed` or its seven status panels into Rede/Armazenamento/Hash.

## Metadata

**Analog search scope:** `lib/screen/`, `lib/design_system/`, `lib/app/`, `lib/theme/`, `lib/service/`, `lib/main.dart`, `test/app/`, `test/design_system/`, `test/network_calculator_test.dart`, `test/data_converter_test.dart`, `test/hash_calculator_test.dart`
**Files scanned:** 24 lib Dart files + 21 test Dart files (targeted reads of screens, primitives, gallery, AppShell tests, copy tests)
**Pattern extraction date:** 2026-08-31
**Phase 1 map:** `.planning/phases/01-contrato-visual-e-funda-o-adaptativa/01-PATTERNS.md` — Hash clipboard analog now inverted (Phase 2 **adopts** `CopyValueAction` instead of copying `_copy`)
