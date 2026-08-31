# Phase 2: Migração segura das ferramentas atuais - Research

**Researched:** 2026-08-31
**Domain:** Flutter/Material 3 UI migration of three production tool screens onto Phase 1 primitives, with regression-locked IPv4 / storage / hash results
**Confidence:** HIGH

## Summary

Phase 2 is an incremental, one-screen-at-a-time wrap of the three existing production screens onto the Phase 1 foundation. It is not a rewrite, not a new router, and not Diagnóstico de Internet. Each screen already owns synchronous domain logic in a `StatefulWidget` and delegates to a pure service (`NetworkCalculator`, `DataConverter`, `HashCalculator`). The migration replaces local chrome — nested `Scaffold`+`AppBar`, padding 16, `Card`/`Row` rígidas, `Clipboard.setData` direto, `Colors.red`, CTA “Calcular” isolado — with `ToolScaffold` / `ToolInputSection` / `ToolActionGroup` / `ToolResultCard` / `ToolMetric` / `TechnicalValueRow` / `CopyValueAction`, while leaving services, validators, result values, and IndexedStack navigation untouched.

The highest-risk mechanical traps are (1) dual AppBars if a screen keeps its own `Scaffold` after adopting `ToolScaffold` (the shell already provides the only `Scaffold`); (2) `Theme.extension<AppTokens>()!` exploding in `AppShell` tests that pump `appDestinations` without `lightTheme`; (3) `find.textContaining('Endereço de Rede: 192.168.1.0')` breaking when Rede splits the blob into `TechnicalValueRow` label+value; (4) Hash copy remaining on `Clipboard.setData` instead of `CopyValueAction`. No new packages. No goldens of production screens. Foundation goldens stay frozen unless a shared primitive changes.

**Primary recommendation:** Four sequential plans — harness/theme wrappers, then Rede (PRES-01), Armazenamento (PRES-02), Hash+copy (PRES-03) — each leaving the other two screens usable (PRES-04). Drop inner `Scaffold`/`AppBar`. Keep field `errorText` strings exact. Update AppShell selectors in the same plan that changes the widget they find.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

- **D-01:** Goal permanece exatamente: `Usuários continuam resolvendo as mesmas tarefas nas três ferramentas existentes depois da migração para a nova fundação visual.`
- **D-02:** Requirements desta fase são somente PRES-01, PRES-02, PRES-03 e PRES-04. DIAG-* e SPD-* ficam fora.
- **D-03:** Migrar as três telas reais em `lib/screen/`: Rede, Armazenamento e Hash. Não criar telas paralelas nem novo router.
- **D-04:** Incremental: uma tela por vez, com testes verdes entre incrementos. PRES-04 exige que as outras duas continuem utilizáveis enquanto uma migra.
- **D-05:** Adotar `ToolScaffold`, sections, action group, result/metric/copy, `TechnicalValueRow`/`CopyValueAction`, hierarquia visual compartilhada e layout responsivo/acessível do UI-SPEC da Phase 1.
- **D-06:** Substituir anatomia local divergente (Scaffold próprio com padding 16, cards locais, rows rígidas, `Clipboard.setData` direto, cores/radius locais) pelas primitives já existentes em `lib/design_system/`.
- **D-07:** Consolidar CTAs para o contrato do UI-SPEC: “Calcular rede”, “Analisar capacidade”, “Gerar hashes”. “Calcular” isolado não é permitido. Isso **não** muda resultados.
- **D-08:** Feedback de cópia das telas de produção deve usar `CopyValueAction`/`ClipboardCopyWriter` (SnackBar próprio, `mounted`), não `Clipboard.setData` + SnackBar local.
- **D-09:** Preservar toda a lógica e resultados atuais. Não alterar `NetworkCalculator`, `DataConverter`, `HashCalculator`, validadores, fórmulas, unidades, algoritmos MD5/SHA-1/SHA-256/SHA-512 nem strings de resultado que os testes já afirmam.
- **D-10:** Preservar testes existentes (`test/network_calculator_test.dart`, `test/data_converter_test.dart`, `test/hash_calculator_test.dart`, happy path de `test/app/app_shell_test.dart`). Se um seletor de widget mudar (ex.: `find.text('Calcular')` → `Calcular rede`), atualizar o seletor; o valor calculado deve continuar idêntico (`Endereço de Rede: 192.168.1.0` no happy path).
- **D-11:** Manter pt-BR, Material 3, temas claro/escuro. Não adicionar pacote, fonte remota, form builder, framework de estado, persistência, analytics ou permissão.
- **D-12:** Não executar a Phase 2 neste ciclo de planejamento. Não tocar em `pubspec.lock-old`.
- **D-13:** A prova de ausência de regressão é: (1) suíte unitária de serviços inalterada em asserts de valor; (2) widget tests por tela migrada cobrindo happy path + erros de validação já existentes; (3) happy path do AppShell continua passando após cada incremento; (4) `flutter analyze --no-pub` limpo; (5) goldens da fundação em `test/design_system/goldens/` não são reescritos salvo se um widget compartilhado mudar — e PNG novo não conta como aprovação visual das telas de produção.
- **D-14:** Ordem sugerida (pesquisador/planner podem confirmar): Rede (já tem happy path no AppShell) → Armazenamento → Hash (cópia local mais divergente) → plano transversal PRES-04/a11y se ainda restar wiring compartilhado. Waves devem impedir duas telas em paralelo no mesmo isolate de UI se isso quebrar PRES-04.

### Claude's Discretion

- Nomes de arquivos de teste de widget por tela e granularidade exata dos planos, desde que PRES-01..PRES-04 apareçam no `requirements` de algum plano e os planos sejam pequenos e executáveis.
- Como fatiar estados (vazio/erro/sucesso) em cada tela sem inventar estados de rede/diagnóstico.
- Se Hash deve migrar copy antes ou junto da anatomia, desde que o resultado dos hashes não mude.

### Deferred Ideas (OUT OF SCOPE)

- Diagnóstico de Internet (DIAG-01..DIAG-15) — Phase 3.
- Speed test (SPD-*) e EVO-* — v2 / Phase 5.
- Qualquer feature nova nas três ferramentas.
- Reescrita do app, novo pacote, novo router, form builder.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| PRES-01 | Usuário continua calculando redes IPv4 com os mesmos resultados válidos após a migração visual. | Migrar só `NetworkCalculatorScreen` chrome → `ToolScaffold`+sections+actions+`TechnicalValueRow`. Não tocar `NetworkCalculator` / `network_utils`. Oráculos de serviço `/24`, `/31`, `/32` e erros de campo listados abaixo. CTA `Calcular rede`. Atualizar AppShell happy path no mesmo plano. |
| PRES-02 | Usuário continua convertendo armazenamento decimal e binário com os mesmos resultados válidos após a migração visual. | Migrar só `DataConverterScreen`. Não tocar `DataConverter` / `AnalysisResult`. Manter `NumberFormat('#,##0.000', 'pt_BR')` na UI. CTA `Analisar capacidade`. Trocar `Colors.red` por `colorScheme.error`. Sem cópia local hoje — adotar `TechnicalValueRow`/`CopyValueAction` nos valores técnicos. |
| PRES-03 | Usuário continua gerando hashes MD5, SHA-1, SHA-256 e SHA-512 com os mesmos resultados válidos após a migração visual. | Migrar `HashGeneratorScreen` anatomia **junto** da cópia. Digests de `'abc'` inalterados. Substituir `_copy`/`Clipboard.setData` por `TechnicalValueRow.copyWriter`. CTA `Gerar hashes`. Métricas locais → `ToolMetric`. |
| PRES-04 | Usuário não perde funcionalidades existentes enquanto as três telas são migradas em incrementos verificáveis. | Uma tela por plano; `IndexedStack`/`appDestinations` intocados; após cada incremento as outras duas screens continuam montáveis; AppShell happy path verde; grep de `Clipboard.setData` só em `ClipboardCopyWriter`. |
</phase_requirements>

## Project Constraints (from .cursor/rules/)

Nenhum arquivo em `.cursor/rules/` neste workspace. Constraints operacionais vêm de `AGENTS.md` / `PROJECT.md`: Flutter + Material 3, Android-first, pt-BR, sem reescrita, sem analytics, CLI `C:\src\flutter\bin\flutter.bat`. [VERIFIED: glob `.cursor/rules/**` vazio; `PROJECT.md` Constraints]

## Architectural Responsibility Map

Esta fase é 100% Flutter client. Não há API, SSR, CDN nem persistência.

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| IPv4 calculate / validate | Browser / Client (Dart service + screen) | — | `NetworkCalculator` + `network_utils` já são síncronos e locais. A tela só orquestra controllers e `errorText`. |
| Storage decimal/binary convert | Browser / Client | — | `DataConverter.analyze` retorna `AnalysisResult`; a UI só formata com `intl`. |
| MD5/SHA-1/SHA-256/SHA-512 | Browser / Client | — | `HashCalculator` via pacote `crypto` já pinado. UI não reimplementa digest. |
| Copy technical values | Browser / Client + OS clipboard | — | `CopyValueAction` + `ClipboardCopyWriter` já entregues na Phase 1; SnackBar via `ScaffoldMessenger` do `MaterialApp`. |
| Adaptive chrome / navigation | Browser / Client (`AppShell`) | — | Bar/Rail/`IndexedStack` já na Phase 1. Phase 2 **não** altera o shell. |
| Visual hierarchy of a tool | Browser / Client (`ToolScaffold` tree) | — | Título → input → actions → result/metric/copy. Sem AppBar interno. |
| Theme tokens (`AppTokens`) | Browser / Client (`lightTheme`/`darkTheme`) | — | `ToolScaffold` faz `extension<AppTokens>()!`. Testes que montam screens de produção **devem** usar esses temas. |

## Standard Stack

Nenhum pacote novo. Reusar o que já está no repo e na fundação Phase 1.

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Flutter SDK | 3.44.0 (stable, local `C:\src\flutter\bin\flutter.bat`) | Widgets, Material 3, `OverflowBar`, `ScaffoldMessenger`, widget tests | Já é o runtime do app. [VERIFIED: `flutter --version`] |
| Dart SDK | 3.12.0 (`sdk: ^3.8.1` no pubspec) | Services, `utf8`, records not required | Já usado pelos três serviços. [VERIFIED: pubspec.yaml + flutter --version] |
| `flutter_test` | SDK | Widget + unit regression | Já cobre AppShell, primitives, serviços. [VERIFIED: `test/`] |
| `lib/design_system/*` | in-repo Phase 1 | `ToolScaffold`, sections, status, copy | Contrato UI-SPEC; galeria é o analog de composição. [VERIFIED: codebase] |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `crypto` | `^3.0.7` (já em pubspec) | MD5/SHA-* | Somente via `HashCalculator` existente. Não chamar `crypto` da screen. |
| `intl` | `^0.20.2` (já em pubspec) | `NumberFormat('#,##0.000', 'pt_BR')` | Somente na UI de Armazenamento, como hoje. Não mover formatação para o serviço. |
| `cupertino_icons` | `^1.0.8` | unused by this phase | Não adicionar ícones Cupertino nas tools. |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Drop inner `Scaffold`+`AppBar`, title on `ToolScaffold` | Keep inner AppBar + ToolScaffold title | Dual titles. Flutter docs: avoid nested Scaffolds. [CITED: api.flutter.dev Scaffold “Nested Scaffolds”] |
| `TechnicalValueRow` for Rede results | Keep concatenated `_result` blob | Finder `textContaining('Endereço de Rede: 192.168.1.0')` sobrevive, mas viola D-05. **Reject.** Update the finder. |
| `ToolActionGroup.onCancel` for Limpar | `secondary: TextButton(Limpar)` | `onCancel` renderiza o label fixo `'Cancelar'`. [VERIFIED: `tool_sections.dart`] |
| Inject `CopyValueWriter` on Hash screen | Test only `find.byType(CopyValueAction)` | Sem writer, o teste de cópia é tautológico ou depende do clipboard do host. Inject opcional no construtor. |
| `ToolStatusPanel.empty` on first paint | Omit result region (current) | UI-SPEC: “não mostrar card vazio se a instrução já estiver evidente no formulário”. Prefer omit. |
| Form builder / Provider / GoRouter | — | Forbidden by D-11 / deferred. |

**Installation:** none. Do not run `flutter pub add`. Do not touch `pubspec.yaml` or `pubspec.lock-old`.

**Version verification:** Flutter 3.44.0 / Dart 3.12.0 confirmed via `C:\src\flutter\bin\flutter.bat --version` on 2026-08-31. `crypto` and `intl` already declared in `pubspec.yaml`.

## Package Legitimacy Audit

Esta fase **não instala** pacotes externos. slopcheck não se aplica.

| Package | Registry | Age | Downloads | Source Repo | slopcheck | Disposition |
|---------|----------|-----|-----------|-------------|-----------|-------------|
| — | — | — | — | — | — | No installs |

**Packages removed due to slopcheck [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** none

## Architecture Patterns

### System Architecture Diagram

```
User tap (NavigationBar/Rail)
        │
        ▼
AppShell (ONLY Scaffold) ── IndexedStack (pages materialized once)
        │
        ├── NetworkCalculatorScreen  → ToolScaffold
        ├── DataConverterScreen      → ToolScaffold
        └── HashGeneratorScreen      → ToolScaffold
                │
                ├─ ToolInputSection (TextFields / dropdown; errorText inline)
                ├─ ToolActionGroup (primary CTA + secondary Limpar)
                ├─ [optional] ToolStatusPanel.failure only if catch-all, not for field errors
                ├─ ToolResultCard
                │     ├─ ToolMetricLayout (Hash summary; Rede hosts)
                │     └─ TechnicalValueRow (label + SelectableText + CopyValueAction)
                └─ explanation (Armazenamento only) as ToolResultCard child
                            │
                            ├─ NetworkCalculator / DataConverter / HashCalculator
                            └─ CopyValueAction → CopyValueWriter → Clipboard
                                              → owned SnackBar via ScaffoldMessenger
```

`pageBuilder` em `app_destinations.dart` continua retornando as **mesmas classes** de screen. Não criar `NetworkCalculatorScreenV2`.

### Recommended Project Structure

```
lib/screen/
├── network_calculator_screen.dart   # wrap only; keep _calculate/_clearFields
├── data_converter_screen.dart       # wrap only; keep NumberFormat + analyze()
└── hash_generator_screen.dart       # wrap + delete _copy; optional copyWriter
lib/design_system/                   # DO NOT rewrite unless a shared widget must change
lib/service/                         # DO NOT edit
lib/utils/network_utils.dart         # DO NOT edit
lib/model/analysis_result.dart       # DO NOT edit
lib/app/app_shell.dart               # DO NOT rearquitetar
lib/app/app_destinations.dart        # DO NOT add destinations
test/screen/                         # NEW widget tests (discretionary path)
├── network_calculator_screen_test.dart
├── data_converter_screen_test.dart
└── hash_generator_screen_test.dart
test/app/app_shell_test.dart         # selector + theme wrappers only
test/network_calculator_test.dart    # DO NOT change value asserts
test/data_converter_test.dart        # DO NOT change value asserts
test/hash_calculator_test.dart       # DO NOT change digest asserts
test/design_system/goldens/          # DO NOT regenerate unless primitive changes
```

### Screen anatomy vs ToolScaffold (wrap, do not rewrite logic)

#### Rede — `NetworkCalculatorScreen` (PRES-01)

| Current | After | Notes |
|---------|-------|-------|
| `Scaffold` + `AppBar('Calculadora de Rede')` | **Delete.** Return `ToolScaffold(title: 'Calculadora de Rede', summary: optional short pt-BR)` | AppShell already has the Scaffold. Dual AppBar is the #1 pitfall. [CITED: api.flutter.dev Scaffold Nested Scaffolds] |
| `LayoutBuilder` + `isWideScreen > 600` Row flex 7/3 | Delete local breakpoint branch. `ToolInputSection` is always a column. Padding/max-width come from `ToolScaffold`. | Local `> 600` duplicates `AppBreakpoints` and fights UI-SPEC “uma coluna”. [VERIFIED: screen lines 107–218] |
| Two `TextField`s, labels unchanged | Same controllers, same `labelText`, same `errorText` | Selectors `find.widgetWithText(TextField, 'Endereço de IP')` survive. |
| `ElevatedButton('Calcular')` + `TextButton('Limpar')` | `ToolActionGroup(primary: ElevatedButton(onPressed: _calculate, child: Text('Calcular rede')), secondary: TextButton(onPressed: _clearFields, child: Text('Limpar')))` | Never `onCancel:` (that paints “Cancelar”). Compact Rede button today lacks explicit 48px; theme already sets `minimumSize: Size(48,48)`. |
| `_result` as one `Text` blob | `ToolResultCard` + one `TechnicalValueRow` per field; optional `ToolMetric(label: 'Hosts utilizáveis', value: '$usableHosts')` | **Service outputs stay.** Display splits label/value. AppShell finder **must** change in this plan (see oracles). |
| No copy | `copyWriter:` on each `TechnicalValueRow` (default `ClipboardCopyWriter`) | Adoption of UI-09, not a new calculator feature. Copied text = the IP/range/mask string, not the `"Endereço de Rede: …"` prefix. |
| Catch `FormatException` / generic | Keep the two error strings; show as body text under the result region or `ToolStatusPanel.failure` + `preservedChild`. Do **not** replace field `errorText`. | Field errors stay on the fields. |

Keep `_calculate` / `_clearFields` / `dispose` as-is. Do not extract a controller class.

#### Armazenamento — `DataConverterScreen` (PRES-02)

| Current | After | Notes |
|---------|-------|-------|
| `Scaffold` + `AppBar('Conversor de Armazenamento')` | `ToolScaffold(title: 'Conversor de Armazenamento')` | Catalog `semanticLabel` is `'Conversor de Dados'` — **do not** rename the screen title or the catalog in this phase. [VERIFIED: app_destinations.dart vs screen AppBar] |
| Input `Card` + `Row` value/dropdown | `ToolInputSection` with the same two fields (column, not rigid Row). Dropdown still `DataConverter.availableUnits`. | `DropdownButtonFormField.initialValue` already used — keep. |
| `'Analisar Capacidade'` | `'Analisar capacidade'` (sentence case per UI-SPEC) | Results unchanged. |
| `_isLoading` + spinner-only in the button | Drop the fake flag. `_calculate` is synchronous inside one `setState`. | Never visible today. Do **not** introduce `ToolStatusPanel.loading`. |
| Result `Card` + `Text` lists + `Colors.red` difference | `ToolResultCard` + `TechnicalValueRow` / `ToolMetric` for conversions; difference uses `colorScheme.error`, never `Colors.red` | Formatter stays in the screen. |
| Static explanation `Card` radius 12 / `ListTile`s | `ToolResultCard` wrapping the same copy (“Por que a capacidade parece menor?” … “931 GiB”). No new tokens. | Educational copy is existing functionality (PRES-04) — keep the words. |
| No copy | Add `CopyValueAction` on formatted technical values (advertised/real/difference and conversion lines). | Copied value = formatted number + unit as displayed. |

Keep error strings: `'Insira um valor'`, `'Insira um valor numérico positivo'`, and `e.toString().replaceAll('ArgumentError: ', '')`.

#### Hash — `HashGeneratorScreen` (PRES-03)

| Current | After | Notes |
|---------|-------|-------|
| `Scaffold` + `AppBar('Gerador de Hash')` | `ToolScaffold(title: 'Gerador de Hash')` | |
| Input `Card` + multiline `TextField` + warning | `ToolInputSection` + same field + same warning string | `'MD5 e SHA-1 servem para conferência, não para proteger senhas.'` stays. |
| `ElevatedButton.icon('Calcular')` + `TextButton.icon('Limpar')` | `ToolActionGroup` primary `'Gerar hashes'` (no isolated Calcular), secondary `'Limpar'`. Icons optional; do not empty `onPressed`. | |
| `_HashSummaryCard` / `_MetricChip` | `ToolMetricLayout` with `ToolMetric(label: 'Caracteres'\|'Bytes UTF-8'\|'Algoritmos', value: '$n')` | Values are real counts, not sentinels. Do not pass `null` here. |
| `_HashResultTile` + `IconButton` + `Clipboard.setData` + SnackBar `'${algorithm} copiado'` | `ToolResultCard` + `TechnicalValueRow(label: result.algorithm, value: result.value, metadata: '${result.bits} bits · ${result.strength} · ${result.value.length} hex', copyWriter: widget.copyWriter ?? const ClipboardCopyWriter())` | Delete `_copy`. Delete `flutter/services.dart` import if unused. SnackBar becomes `{Rótulo} copiado` via `CopyValueAction` (for `"MD5"` → `"MD5 copiado"`). Copied payload remains `result.value`. |
| Private `_HashSummaryCard` / `_MetricChip` / `_HashResultTile` / `_MetaLabel` | Delete after replacement | Do not keep parallel local widgets. |

**Discretion resolved:** migrate Hash copy **together** with anatomy. `TechnicalValueRow.copyWriter` is the copy slot; a separate copy-only pass would touch the same widgets twice.

**Optional constructor seam (recommended):**

```dart
class HashGeneratorScreen extends StatefulWidget {
  const HashGeneratorScreen({super.key, this.copyWriter});
  final CopyValueWriter? copyWriter;
}
```

`pageBuilder` stays `const HashGeneratorScreen()`. Tests inject a `FakeCopyWriter`. Same optional param on Rede/Armazenamento if they gain copy.

### Pattern 1: Page is content, shell is chrome

**What:** Production pages return `ToolScaffold(...)` only. `AppShell` is the single `Scaffold` (nav bar / rail). Gallery already documents this: *“When used inside AppShell, the shell provides the Scaffold.”* [VERIFIED: `design_system_gallery.dart` lines 21–23]

**When to use:** All three screens.

**Example (composition — analog is the gallery, not a new API):**

```dart
// Source: test/design_system/design_system_gallery.dart (Phase 1 composition contract)
return ToolScaffold(
  title: 'Calculadora de Rede',
  children: [
    ToolInputSection(children: [/* existing TextFields */]),
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
    // results…
  ],
);
```

`SnackBar` de cópia usa `ScaffoldMessenger.of(context)` no `MaterialApp`, não precisa de Scaffold interno. [CITED: flutter.dev cookbook snackbars; Flutter 2.0 ScaffoldMessenger]

### Pattern 2: Field errors stay on fields; do not invent diagnostic states

**What:** Keep `InputDecoration.errorText`. Do **not** mount `ToolStatusPanel` variants `offline`, `permissionDenied`, `cancelled`, or `loading` on these three tools — those states do not exist in current UX. Empty: omit the result region (UI-SPEC empty rule). Success: result card is enough; skip a redundant “Concluído” banner unless it helps a11y without changing values.

**When to use:** All three screens.

### Pattern 3: Widget tests wrap with `lightTheme`

**What:** `ToolScaffold` does `Theme.of(context).extension<AppTokens>()!`. Isolated tests copy the helper already in `tool_components_test.dart`. AppShell tests that pump `appDestinations` must also pass `theme: lightTheme` (or `const App()`), or they crash after Rede migrates.

**Example:**

```dart
// Source: test/design_system/tool_components_test.dart
Widget wrapScreen(Widget child) {
  return MaterialApp(
    theme: lightTheme,
    home: Scaffold(body: child),
  );
}
```

Isolated screen tests: `home: Scaffold(body: NetworkCalculatorScreen())` because there is no AppShell Scaffold in that tree. Integration tests: `const App()` — do **not** wrap an extra Scaffold around `App`.

### Anti-Patterns to Avoid

- **Dual AppBar:** inner `Scaffold(appBar: …)` + `ToolScaffold` title. Flutter: nested Scaffolds are for rare embedding cases, not tab/tool bodies. [CITED: https://api.flutter.dev/flutter/material/Scaffold-class.html — Nested Scaffolds]
- **Empty `onPressed: () {}`:** gallery samples do this; production CTAs must call `_calculate` / `_clear`. Phase 1 HUMAN-UAT explicitly allowed empty gallery callbacks; production must not copy that.
- **`ToolActionGroup.onCancel` for Limpar:** paints “Cancelar”.
- **Tautological tests:** `expect(find.byType(ToolScaffold), findsOneWidget)` without asserting IPs, errors, or digests.
- **Rewriting service tests or goldens** to make the UI pass.
- **Two screens in one plan / parallel UI isolate:** breaks PRES-04.
- **Keeping `_copy` + adding `CopyValueAction`:** two copy paths, two SnackBars.
- **`Colors.red` / local `BorderRadius.circular(12)`** on Armazenamento.
- **Local `> 600` Row** on Rede after ToolScaffold exists.
- **Changing `appDestinations` ids/labels/page types.**
- **Diagnóstico, Dio, isolates, permissions.**

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Copy + SnackBar + mounted | New `_copy` / `Clipboard.setData` | `CopyValueAction` + `ClipboardCopyWriter` | Lifecycle, owned SnackBar, 48×48, `{Rótulo} copiado` already tested. |
| Responsive page padding / max width | Local `Padding(16)` + `LayoutBuilder` | `ToolScaffold` | Tokens 16/24/32 + 960 already implemented. |
| Action reflow at 360 / textScale 2 | `Row` + `width * 0.6` | `ToolActionGroup` → `OverflowBar` | OverflowBar switches row→column when children overflow. [CITED: https://api.flutter.dev/flutter/widgets/OverflowBar-class.html] |
| Metric chips | `_MetricChip` | `ToolMetric` / `ToolMetricLayout` | Null→Indisponível contract; Wrap reflow. |
| Technical value + copy | `SelectableText` + raw `IconButton` | `TechnicalValueRow` | Semantics: value once, copy node separate. |
| Hash algorithms | Reimplement md5/sha | `HashCalculator.calculate` | Digests locked by unit tests. |
| Number grouping | `toStringAsFixed` in service | Existing `NumberFormat` in UI | D-09: formatting stays out of `DataConverter`. |
| Theme tokens | Per-widget hex | `ThemeData` + `AppTokens` | Phase 1 contract. |

**Key insight:** The domain is already extracted. Hand-rolling chrome a second time is how Rede kept a private breakpoint and Hash kept a private clipboard path. Wrap the screens; do not rebuild the foundation or the services.

## Runtime State Inventory

Migration is UI-only. After every Dart file is updated, no runtime system holds old CTA strings or AppBar titles.

| Category | Items Found | Action Required |
|----------|-------------|------------------|
| Stored data | None — verified: no DB, SharedPreferences, or file cache of tool results in `lib/` | none |
| Live service config | None — no remote dashboards; ipify unused until Phase 3 | none |
| OS-registered state | None — no scheduled tasks or named Flutter isolates for these screens | none |
| Secrets/env vars | None — no `.env` keys tied to screen titles/CTAs | none |
| Build artifacts | `pubspec.lock-old` exists untracked — **do not touch** (D-12). No egg-info/npm cache of screen names. | none |

## Common Pitfalls

### Pitfall 1: Nested Scaffold + dual AppBar
**What goes wrong:** Two titles (“Calculadora de Rede” in AppBar and in `ToolScaffold`), extra padding, SnackBar geometry oddities, AppShell tests still looking `of: find.byType(AppBar)`.
**Why it happens:** Current screens each own a `Scaffold`; AppShell also owns one. Copy-paste of the old `return Scaffold(...)`.
**How to avoid:** Delete screen-level `Scaffold`/`AppBar`. Title lives only on `ToolScaffold`. Isolated widget tests supply a throwaway `Scaffold` in the test wrapper, not in production.
**Warning signs:** `find.byType(AppBar)` still matches inside a production destination after that screen’s plan.

### Pitfall 2: `AppTokens` null-check crash in AppShell tests
**What goes wrong:** `ToolScaffold` → `Theme.of(context).extension<AppTokens>()!` throws. Tests like `shows NavigationBar at 599px width` pump `MaterialApp(home: AppShell(destinations: appDestinations))` **without** `lightTheme`.
**Why it happens:** Those tests never needed tokens while screens used raw `Scaffold`.
**How to avoid:** In the **first** implementation plan (before or with Rede), add `theme: lightTheme` (and `darkTheme` if relevant) to every AppShell test that mounts `appDestinations`. Happy path already uses `const App()` and is safe.
**Warning signs:** `Null check operator used on a null value` in `tool_scaffold.dart` during `app_shell_test`.

### Pitfall 3: Concatenated result finder dies after TechnicalValueRow
**What goes wrong:** `find.textContaining('Endereço de Rede: 192.168.1.0')` matches `Text.data`. After split, label widget is `Endereço de Rede` and value is `SelectableText('192.168.1.0')`. Finder returns nothing.
**Why it happens:** D-05 requires `TechnicalValueRow`; D-10 example still quotes the old blob.
**How to avoid:** In the Rede plan, update AppShell + screen tests to assert **both** `find.text('Endereço de Rede')` and `find.text('192.168.1.0')` (or `find.textContaining('192.168.1.0')` with `findRichText: true` if SelectableText needs it). The **calculated** value `192.168.1.0` must not change. Do not keep the blob just to spare a finder.
**Warning signs:** Happy path red only on `textContaining('Endereço de Rede: 192.168.1.0')` after a green unit suite.

`find.textContaining` matches `Text` / `EditableText` and, with `findRichText: true`, `RichText`. [CITED: https://api.flutter.dev/flutter/flutter_test/CommonFinders/textContaining.html]

### Pitfall 4: Isolated “Calcular” leftover
**What goes wrong:** UI-SPEC forbids “Calcular” isolado **durante** a migração incremental. Hash still says Calcular until PRES-03; Rede must change in PRES-01.
**Why it happens:** Reusing gallery `find.text('Calcular')` from `tool_components_test` (that file’s own sample button is out of scope — do not “fix” it in this phase unless a plan touches that primitive).
**How to avoid:** Grep `lib/screen` for `Text('Calcular')` after Rede and Hash plans. Leave `tool_components_test` ToolActionGroup sample labeled `'Calcular'` alone (it is not a production CTA).
**Warning signs:** `find.text('Calcular')` still used in `app_shell_test` happy path.

### Pitfall 5: IndexedStack state / page rebuild
**What goes wrong:** Changing `pageBuilder` to a new widget type or adding a `Key` that changes identity remounts the screen and clears fields — looks like PRES-04 failure.
**Why it happens:** `AppShell._pagesById.putIfAbsent` caches the first build. [VERIFIED: `app_shell.dart`]
**How to avoid:** Keep `const NetworkCalculatorScreen()` (and siblings) as the builder output. Do not replace with a differently named widget. Do not edit destination `id`s.
**Warning signs:** Happy path “navigate to Armazenamento and back” loses `192.168.1.0`.

### Pitfall 6: Hash copy value vs SnackBar label
**What goes wrong:** Passing the whole `"MD5: <digest>"` into `CopyValueAction.value`, or changing digest casing.
**Why it happens:** Old `_copy` copied `result.value` and labeled SnackBar with `algorithm`.
**How to avoid:** `value: result.value`, `label: result.algorithm`. Unit test `'abc'` digests remain the oracle for **values**. Widget test with `FakeCopyWriter` asserts `lastValue == known md5`.
**Warning signs:** SnackBar text changes are OK; clipboard payload changes are not.

### Pitfall 7: Fake loading / spinner-only CTA
**What goes wrong:** Armazenamento sets `_isLoading = true` then `false` in the same `setState`; a `CircularProgressIndicator` as the **only** button child violates UI-SPEC “loading retains a comprehensible label”.
**How to avoid:** Delete `_isLoading`. Do not add `ToolStatusPanel.loading`.
**Warning signs:** `onPressed: _isLoading ? null : _calculate` surviving the migration.

### Pitfall 8: Tautological or service-rewriting tests
**What goes wrong:** Weak widget tests; or “fixing” `expect(network, '192.168.1.0')` because the UI changed.
**How to avoid:** Service files are read-only this phase. Widget tests enter the same fixtures and assert the same numbers/strings listed in Regression Oracles.
**Warning signs:** Diff in `test/network_calculator_test.dart` that is not whitespace.

### Pitfall 9: Regenerating foundation goldens as “proof”
**What goes wrong:** PNG updates without a primitive change; used as fake visual sign-off of production screens.
**How to avoid:** D-13: do not rewrite `test/design_system/goldens/` unless a shared widget API/layout must change (it should not). No production-screen goldens required.
**Warning signs:** `*goldens*` in the Phase 2 git status.

### Pitfall 10: Empty gallery pattern leaking into production
**What goes wrong:** `onPressed: () {}` copied from `DesignSystemGallery`.
**How to avoid:** Production `ElevatedButton.onPressed` is always `_calculate` / equivalent.
**Warning signs:** CTA visible but tap does nothing in widget test.

## Code Examples

### Isolated Rede widget test (happy path + one field error)

```dart
// Source: pattern from test/design_system/tool_components_test.dart _wrap
// + oracles from test/app/app_shell_test.dart and network_calculator_screen.dart
await tester.pumpWidget(
  MaterialApp(
    theme: lightTheme,
    home: const Scaffold(body: NetworkCalculatorScreen()),
  ),
);
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

await tester.tap(find.text('Limpar'));
await tester.pump();
await tester.tap(find.text('Calcular rede'));
await tester.pump();
expect(find.text('Formato de IP inválido (ex: 192.168.1.1).'), findsOneWidget);
```

### Hash copy must go through CopyValueAction, not Clipboard.setData

```dart
// Source: lib/design_system/copy_value_action.dart + hash_generator_screen.dart current _copy
// DELETE this production path:
await Clipboard.setData(ClipboardData(text: result.value));
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('${result.algorithm} copiado')),
);

// USE TechnicalValueRow (copyWriter injected for tests):
TechnicalValueRow(
  label: result.algorithm,
  value: result.value,
  metadata: '${result.bits} bits · ${result.strength} · ${result.value.length} hex',
  copyWriter: widget.copyWriter ?? const ClipboardCopyWriter(),
);
```

### AppShell happy path selector update (same plan as Rede)

```dart
// Source: test/app/app_shell_test.dart Happy path group — update, do not drop
await tester.ensureVisible(find.text('Calcular rede'));
await tester.tap(find.text('Calcular rede'));
await tester.pumpAndSettle();
expect(find.text('192.168.1.0'), findsWidgets);
expect(
  find.descendant(
    of: find.byType(AppBar),
    matching: find.text('Calculadora de Rede'),
  ),
  findsNothing,
);
expect(find.text('Calculadora de Rede'), findsWidgets); // ToolScaffold heading
```

Also in that file’s production compact-bar test: the `AppBar` descendant finder for `'Calculadora de Rede'` must become a heading/`ToolScaffold` finder in the Rede plan.

### Do not use onCancel for Limpar

```dart
// Source: lib/design_system/tool_sections.dart — onCancel always labels 'Cancelar'
ToolActionGroup(
  primary: ElevatedButton(onPressed: _calculate, child: const Text('Calcular rede')),
  secondary: TextButton(onPressed: _clearFields, child: const Text('Limpar')),
);
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Per-screen `Scaffold`+`AppBar` | Shell `Scaffold` + page `ToolScaffold` heading | Phase 1 shipped shell; Phase 2 adopts on pages | Drop nested Scaffold (Flutter guidance). |
| SnackBar via `Scaffold.of` | `ScaffoldMessenger` on `MaterialApp` | Flutter 2.0 | Copy works without inner Scaffold. [CITED: flutter.dev scaffold-messenger breaking change] |
| Isolated “Calcular” | Verb + object CTAs | UI-SPEC Phase 1 / Phase 2 owns | Rede+Hash labels change; results do not. |
| Hash `Clipboard.setData` | `CopyValueAction` | Phase 1 primitive; Phase 2 adoption | mounted + owned SnackBar. |
| Rede local `maxWidth > 600` | `AppBreakpoints` + column | Phase 1 tokens | Delete local wide Row. |

**Deprecated/outdated:**
- Nested per-tab Scaffolds with unique AppBars: official troubleshooting says update one AppBar instead; here the page heading replaces AppBar entirely because the shell has no AppBar. [CITED: Scaffold Nested Scaffolds]
- Spinner-as-only-child on a loading button: UI-SPEC forbids.

## Regression Oracles (must survive)

Service tests — **do not edit asserts:**

| File | Fixture | Must remain |
|------|---------|-------------|
| `test/network_calculator_test.dart` | `192.168.1.10` cidr 24 | network `192.168.1.0`, broadcast `192.168.1.255`, mask `255.255.255.0`, range `192.168.1.1 - 192.168.1.254`, hosts `254` |
| same | `10.0.0.4` /31 | range `10.0.0.4 - 10.0.0.5`, hosts `2` |
| same | `10.0.0.9` /32 | range `10.0.0.9`, hosts `1` |
| `test/data_converter_test.dart` | `analyze(1, 'TB')` | `realUnit == 'TiB'`, `realValue` closeTo `0.9094947017`, difference closeTo `0.0905052982` |
| same | `analyze(1, 'B')` | `throwsArgumentError` |
| `test/hash_calculator_test.dart` | `'abc'` | MD5 `900150983cd24fb0d6963f7d28e17f72`; SHA-1 `a9993e364706816aba3e25717850c26c9cd0d89d`; SHA-256 `ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad`; SHA-512 the 128-hex string already in the test |

Screen-level error strings — **character-exact** (Rede currently; widget tests must keep them):

| Screen | String |
|--------|--------|
| Rede | `Formato de IP inválido (ex: 192.168.1.1).` |
| Rede | `Insira uma máscara de sub-rede ou um CIDR.` |
| Rede | `Máscara de sub-rede inválida.` |
| Rede | `Valor de CIDR inválido (0-32).` |
| Rede catch | `Erro: Formato de entrada inválido. Verifique os valores inseridos.` |
| Armazenamento | `Insira um valor` |
| Armazenamento | `Insira um valor numérico positivo` |
| Hash | `Digite ou cole um texto para calcular o hash.` |

AppShell happy path (360×800, `const App()`):

1. `NavigationBar` present.
2. Title `'Calculadora de Rede'` visible (heading after Rede migration, not AppBar).
3. IP `192.168.1.10` + CIDR `24` → **value** `192.168.1.0` for network address.
4. Tap `'Armazenamento'` then `'Rede'` → result still visible (`IndexedStack`).
5. Compact labels `Rede` / `Armazenamento` / `Hash`; tooltips unchanged.

CTA copy after each screen’s plan:

| Screen | Forbidden | Required |
|--------|-----------|----------|
| Rede | `Calcular` | `Calcular rede` |
| Armazenamento | `Analisar Capacidade` | `Analisar capacidade` |
| Hash | `Calcular` | `Gerar hashes` |
| Rede, Hash | — | `Limpar` remains |

## Recommended plan slices

Granularity is coarse; keep plans small enough that PRES-04 holds. **Do not run two screen migrations in the same plan.**

| Plan | Wave | Requirements | Goal | Depends on |
|------|------|----------------|------|------------|
| 02-01 Harness | Wave 1 | PRES-04 (partial) | `lightTheme` on AppShell tests that mount `appDestinations`; optional shared `wrapScreen` helper. No production CTA change yet **or** land this as Task 1 of 02-02. | — |
| 02-02 Rede | Wave 1 (after harness) | PRES-01, PRES-04 | Widget tests RED→GREEN; migrate `network_calculator_screen.dart`; update AppShell happy path + AppBar title finder; services untouched; `flutter analyze --no-pub`; other two screens still old chrome and still usable. | 02-01 |
| 02-03 Armazenamento | Wave 2 | PRES-02, PRES-04 | Same pattern for `data_converter_screen.dart`; drop fake loading and `Colors.red`; keep explanation copy; AppShell happy path still green. | 02-02 |
| 02-04 Hash + copy + gate | Wave 3 | PRES-03, PRES-04 | Migrate anatomy **and** copy together; widget tests with `FakeCopyWriter`; grep `lib/screen` has no `Clipboard.setData`, no inner `Scaffold`/`AppBar`, no isolated `Calcular`; three screen widget suites + AppShell happy path + unit services + analyze. | 02-03 |

If the planner prefers three plans, fold harness into Rede as Task 1. Do **not** fold Hash into Armazenamento.

Per-increment verification (D-13):

```
C:\src\flutter\bin\flutter.bat test test/network_calculator_test.dart test/data_converter_test.dart test/hash_calculator_test.dart
C:\src\flutter\bin\flutter.bat test test/app/app_shell_test.dart
C:\src\flutter\bin\flutter.bat test test/screen/<migrated>_test.dart
C:\src\flutter\bin\flutter.bat analyze --no-pub
```

Nyquist validation is **disabled** in `.planning/config.json` (`workflow.nyquist_validation: false`). Do not add a Nyquist Validation Architecture section or Wave 0 test-framework install. Widget tests above are the phase’s own regression map, not Nyquist.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | `find.text('192.168.1.0')` matches `TechnicalValueRow`’s `SelectableText` without `findRichText: true` | Pitfall 3 / Code Examples | First Rede widget test may need `findRichText: true` or a semantics finder; planner should allow that one-line finder tweak. `[ASSUMED]` |
| A2 | Disabling `Limpar` when fields+result are empty (UI-SPEC) is optional polish, not required for PRES-* | Discretion | If executor implements it, tests must tap only when enabled. `[ASSUMED]` |

**If this table is empty:** All claims in this research were verified or cited — no user confirmation needed.

## Open Questions

1. **AppBar finder vs heading**
   - What we know: two AppShell tests look for `'Calculadora de Rede'` as an AppBar descendant. Catalog tooltips stay `'Calculadora de Rede'`.
   - What's unclear: none — locked to update the selector in the Rede plan.
   - Recommendation: assert `find.text('Calculadora de Rede')` on the page; stop using `find.byType(AppBar)` for production titles.

2. **Conversor de Armazenamento vs Conversor de Dados**
   - What we know: screen AppBar ≠ catalog `semanticLabel`.
   - What's unclear: product may want them aligned later.
   - Recommendation: **do not** change either in Phase 2 (PRES-04 / no extra copy churn). ToolScaffold title = current AppBar string.

3. **ToolStatusPanel.success after calculate**
   - What we know: UI-SPEC lists success; current tools have no “Concluído” banner.
   - What's unclear: a11y benefit vs extra chrome.
   - Recommendation: skip success/empty/loading panels; field errors + result card only.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter CLI | analyze + test | ✓ | 3.44.0 (`C:\src\flutter\bin\flutter.bat`) | — |
| Dart | services / tests | ✓ | 3.12.0 | — |
| `lightTheme` / `AppTokens` | ToolScaffold | ✓ | in-repo | Tests must opt in |
| Android device / TalkBack | not this phase | n/a | — | Phase 1 already gated; Phase 2 is widget-test + analyze |
| New pub packages | — | n/a | — | Forbidden |

**Missing dependencies with no fallback:** none

**Missing dependencies with fallback:** none

Step 2.6: Flutter toolchain present; no extra services.

## Security Domain

`security_enforcement` is not set in `.planning/config.json` (treat as enabled). This phase is offline UI migration with existing crypto-for-integrity-display.

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no | No accounts |
| V3 Session Management | no | No sessions |
| V4 Access Control | no | No authz |
| V5 Input Validation | yes | Existing `network_utils` / empty-text / `double.tryParse`; keep inline `errorText`; do not weaken validators |
| V6 Cryptography | yes (display-only) | Use existing `crypto` via `HashCalculator`; do not hand-roll digests; keep the MD5/SHA-1 warning copy |

### Known Threat Patterns for this stack

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Clipboard leakage of hashes / IPs | Information disclosure | Session-only copy; no analytics (D-11); copy exact visible value; no new permissions |
| User treats MD5/SHA-1 as password hash | Elevation of privilege (misuse) | Preserve warning string on Hash input |
| XSS/injection | Tampering | Flutter Text, not HTML; still do not interpolate raw exceptions into misleading success |
| Supply-chain (new packages) | Tampering | No new packages this phase |
| SnackBar spoof / hideCurrentSnackBar wiping unrelated alerts | Denial of service / spoofing | Use `CopyValueAction` owned controller only (already Phase 1) |

## Sources

### Primary (HIGH confidence)

- Workspace: `lib/screen/*.dart`, `lib/design_system/*.dart`, `lib/app/app_shell.dart`, `lib/service/*.dart`, listed tests — 2026-08-31
- `.planning/phases/02-migra-o-segura-das-ferramentas-atuais/02-CONTEXT.md`, `02-UI-SPEC.md`
- `.planning/phases/01-contrato-visual-e-funda-o-adaptativa/01-UI-SPEC.md` (anatomy, CTAs, copy, Phase 2 owns)
- Flutter Scaffold nested-scaffold troubleshooting — https://api.flutter.dev/flutter/material/Scaffold-class.html
- OverflowBar — https://api.flutter.dev/flutter/widgets/OverflowBar-class.html
- `find.textContaining` — https://api.flutter.dev/flutter/flutter_test/CommonFinders/textContaining.html
- Flutter SnackBar / ScaffoldMessenger cookbook — Context7 `/flutter/website` snackbars.md
- Flutter 3.44.0 / Dart 3.12.0 — local CLI

### Secondary (MEDIUM confidence)

- Phase 1 `01-PATTERNS.md` (Hash clipboard analog, nested screen Scaffold analog)
- Gallery comment that AppShell provides Scaffold for TextField/Material

### Tertiary (LOW confidence)

- Whether `find.text` hits `SelectableText` without `findRichText` (A1)

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — no new libraries; Flutter version verified locally
- Architecture: HIGH — screens, shell, and primitives read in this session; Flutter nested-Scaffold docs cited
- Pitfalls: HIGH — AppTokens crash, AppBar finder, concatenated result string, Hash clipboard all observed in current code

**Research date:** 2026-08-31
**Valid until:** 2026-09-30 (stable Flutter UI migration; revisit if Flutter major bumps)
