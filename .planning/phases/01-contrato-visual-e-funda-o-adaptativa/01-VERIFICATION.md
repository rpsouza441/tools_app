---
phase: 01-contrato-visual-e-funda-o-adaptativa
verified: 2026-08-31T17:52:00Z
status: passed
score: "25/25 must-haves verified"
overrides_applied: 0
re_verification:
  previous_status: human_needed
  previous_score: 24/25
  gaps_closed:
    - "TalkBack human pass on Android emulator"
  gaps_remaining: []
  regressions: []
deferred:
  - truth: "As três telas de produção adotam ToolScaffold, seções, ações, resultados, métricas e cópia compartilhados"
    addressed_in: "Phase 2"
    evidence: "Goal da Phase 2: usuários continuam as tarefas 'depois da migração para a nova fundação visual'; UI-SPEC 'Phase 2 owns' atribui a adoção completa das primitives às três telas; UI-03 na Phase 1 cobre primitives/galeria."
---

# Phase 1: Contrato visual e fundação adaptativa — Verification Report

**Phase Goal:** As a profissional de TI, I want to usar a fundação adaptativa e acessível, so that eu opere as ferramentas com clareza.
**Verified:** 2026-08-31T17:52:00Z
**Status:** passed
**Re-verification:** Yes — after TalkBack human pass (previous `human_needed` 24/25)

## User Flow Coverage

User story: «As a profissional de TI, I want to usar a fundação adaptativa e acessível, so that eu opere as ferramentas com clareza.»

O Goal em `.planning/ROADMAP.md` casa com `/^As a .+, I want to .+, so that .+\.$/` (role: profissional de TI; capability: usar a fundação adaptativa e acessível; outcome: operar as ferramentas com clareza). Mode permanece `mvp`. `gsd-tools query user-story.validate` não está disponível nesta CLI (`Unknown command: user-story`); a validação usou o regex canônico do workflow.

| Step | Expected | Evidence | Status |
|------|----------|----------|--------|
| Abrir o app | Shell com catálogo Rede / Armazenamento / Hash | `lib/main.dart` → `AppShell(destinations: appDestinations)`; labels curtas e `semanticLabel` completos em `app_destinations.dart` | ✓ VERIFIED |
| Navegar sem superlotação | Bar &lt;600; rail recolhido 600–839; rail extended ≥840; 5 destinos: Ferramentas só na Bar | `app_shell.dart` (`_barUsesOverflow` só no Bar; rail lista `widget.destinations`, `scrollable: true`); testes 599/600/839/840 | ✓ VERIFIED |
| Usar a fundação compartilhada | Hierarquia título → entrada → ação → resultado/métrica + sete estados | `ToolScaffold` / seções / `ToolStatusPanel` / galeria; telas de produção ficam na Phase 2 | ✓ VERIFIED |
| Operar claro/escuro e copiar | Tema canônico, pt-BR, cópia com SnackBar próprio e `mounted` | `theme.dart` + `theme_contract_test.dart`; `copy_value_action.dart` + `copy_lifecycle_test.dart`; galeria `ClipboardCopyWriter`; humano colou `abc123def456` | ✓ VERIFIED |
| Outcome | Operar as ferramentas com clareza | Shell real + primitives + inspeção visual humana APPROVED (sessão anterior) + TalkBack APPROVED nesta re-verificação | ✓ VERIFIED |
| Acessível (TalkBack) | Leitor de tela anuncia destinos, estados e cópia | `01-HUMAN-UAT.md` status complete, test 1 pass; usuário `approved` no emulador Android (foco, labels, campos, “Máscara inválida”, galeria percorrível, sem nós essenciais ausentes nem duplicações problemáticas). Widget/semantics tests existem mas **não** substituem TalkBack — o percurso humano substitui. | ✓ VERIFIED |

## Goal Achievement

### Observable Truths

As 25 verdades da verificação anterior, reavaliadas contra o código vivo e a evidência humana registrada. Nenhum FAILED ou UNCERTAIN copiado.

| # | Truth | Status | Evidence |
| --- | ------- | ---------- | -------------- |
| 1 | Usuário localiza e abre qualquer destino em navegação adaptativa sem superlotação | ✓ VERIFIED | Overflow só na Bar (`_barUsesOverflow`); rail usa o catálogo inteiro com `scrollable: true`. Testes de 5 destinos em 599/600/839/840 passam nesta suíte. |
| 2 | A fundação oferece hierarquia e os sete estados compartilhados coerentes | ✓ VERIFIED | `ToolStatusPanel._statusMap` e testes independentes batem com o State Contract; headings em `onSurface`; ícone carrega primary/error. |
| 3 | Tema claro/escuro, pt-BR e cópia mantêm contraste, significado e confirmação acessível | ✓ VERIFIED | Hex/elevation/radius canônicos; galeria em pt-BR; copy lifecycle com SnackBar próprio. Contraste: `textContrastGuideline` light/dark. Copy humano: clipboard `abc123def456`. |
| 4 | Alvos, leitor de tela e fonte ampliada preservam conteúdo e compreensão | ✓ VERIFIED | 48×48 tematizado; `semanticLabel` em tooltip/semantics; matriz 360/720/1024 × 1.0/2.0. TalkBack: verdade 23, agora executado. |
| 5 | Rede, Armazenamento e Hash abrem pelo mesmo catálogo tipado em pt-BR | ✓ VERIFIED | `appDestinations` `List.unmodifiable`; labels curtas + semanticLabels completos; happy path real. |
| 6 | Bar &lt;600, rail recolhido 600-839 e rail extended ≥840 | ✓ VERIFIED | `AppBreakpoints.classify`; testes de boundary 599/600/839/840. |
| 7 | Estado da Calculadora de Rede sobrevive a navegação e breakpoint | ✓ VERIFIED | `IndexedStack` + `_pagesById`; happy path e resize tests passam. |
| 8 | Cinco destinos em compacta mostram três prioridades + Ferramentas | ✓ VERIFIED | Bar overflow; Ferramentas **ausente** no rail 600/839/840. |
| 9 | Temas usam anchors/roles/shape/elevation exatos aprovados | ✓ VERIFIED | Canvas `#F7F9F7`/`#0F1511`; Card elevation 0 radius 12; AppBar/nav/rail elevation 0; botões radius 8; chips radius 4. `theme_contract_test.dart` oracle = UI-SPEC. |
| 10 | Copy usa sans local e valores técnicos usam monospace sem request remoto | ✓ VERIFIED | Zero `package:google_fonts` em `*.dart`. `fontFamily: 'monospace'` em `ToolMetric`/`TechnicalValueRow`. Dependência `google_fonts` no `pubspec.yaml` não é importada (INFO). |
| 11 | Controles possuem 48×48 e rótulos semânticos úteis | ✓ VERIFIED | `minimumSize` 48; Bar `tooltip: semanticLabel`; rail recolhido Tooltip + `Icon.semanticLabel`; rail extended `semanticsLabel` no texto. |
| 12 | Shell e primitives reais funcionam em compact/medium/expanded a 1×/2× | ✓ VERIFIED | `accessibility_test.dart` monta `AppShell` + galeria pública via `_buildPublicFixture`; fixture clone `_buildFixture` ausente. |
| 13 | Existem primitives pequenas e feature-agnostic para anatomia compartilhada | ✓ VERIFIED | `ToolScaffold`, sections, status, copy; galeria as consome. Telas de produção: Phase 2 (deferred). |
| 14 | Sete estados têm ícone/heading/body canônicos, preservando evidência | ✓ VERIFIED | Empty/loading/success/failure/offline/permissionDenied/cancelled conforme UI-SPEC; loading = `CircularProgressIndicator`. |
| 15 | Entrada precede ações/resultados e valores técnicos são selecionáveis/mono | ✓ VERIFIED | Anatomia da galeria e `ToolScaffold`; `SelectableText` + `copyWriter`. |
| 16 | Cópia é exata e produz uma confirmação acessível própria | ✓ VERIFIED | `context.mounted` após await; `_copySnackBar?.close()` só no controller próprio; sem `hideCurrentSnackBar` em `lib/`; `copyWriter` wired; testes de dispose, SnackBar alheio, writer e fallback. Galeria: `ClipboardCopyWriter` (não `_NoopCopyWriter`). Humano colou `abc123def456`. |
| 17 | Conteúdo e ações refluem em 360 px/2× com targets 48×48 | ✓ VERIFIED | `ToolMetric` é `Wrap`; `tool_metric_reflow_test.dart` (label ≥40 chars + `Indisponível`) sem overflow. |
| 18 | Quatro goldens aprovados protegem shell e primitives centrais | ✓ VERIFIED | `matchesGoldenFile('goldens/...')` → `test/design_system/goldens/` (override formal do 01-04 em 01-10). Quatro PNGs. `test/goldens/` ausente. Aprovação visual humana na sessão anterior. |
| 19 | Galeria mostra todos os estados, resultado, métrica, valor técnico e cópia | ✓ VERIFIED | `Calcular rede`, `Painéis de status`, `ClipboardCopyWriter` em `TechnicalValueRow`; sete `ToolStatusPanel`. CTAs da galeria são samples (`onPressed: () {}`) — HUMAN-UAT test 3 pass deliberado. |
| 20 | Matriz automatizada comprova navegação, targets, labels, contraste e escala da fundação real | ✓ VERIFIED | Fixture pública `_buildPublicFixture`; guidelines Android/labeled/contrast; semantics de 5 destinos em 360/720/1024. |
| 21 | Baselines são determinísticas em Windows/Flutter 3.44, DPR 1, sem rede/fonte remotos | ✓ VERIFIED | Goldens DPR 1; sem fonte/rede remota no tema. |
| 22 | Humano confirma shell/fluxo em evidência representativa; boundaries por testes | ✓ VERIFIED | APPROVED na sessão anterior: Android compacta, harness claro/escuro, Chrome largo. Boundaries 599/600/720/839/840/1024 cobertos por widget tests. Não re-enfileirado. |
| 23 | TalkBack anuncia navegação, headings, campos, estados e cópia sem duplicação | ✓ VERIFIED | Executado no emulador Android. `01-HUMAN-UAT.md` test 1 `result: pass`; usuário `approved`. Observações: foco; campos e rótulos anunciados; campos interativos; “Máscara inválida” acessível; galeria percorrível; sem nós essenciais ausentes nem duplicações problemáticas; UI utilizável. Copy retestado à parte (`abc123def456`). Widget tests de semantics **não** são TalkBack; o percurso humano é a evidência. |
| 24 | Inspeção manual não encontra overflow, neon, ellipsis, target pequeno ou perda de estado | ✓ VERIFIED | Inspeção visual humana APPROVED no conjunto representativo da sessão anterior. Não re-enfileirado. |
| 25 | Analyzer, suíte focada e quatro comparações golden passam | ✓ VERIFIED | Este verificador: `flutter analyze --no-pub` → No issues found. `flutter test --no-pub` → All tests passed (163). Goldens 4/4 em `test/design_system/goldens/`. |

**Score:** 25/25 truths verified

### Deferred Items

| # | Item | Addressed In | Evidence |
|---|------|-------------|----------|
| 1 | Adoção das primitives compartilhadas pelas três telas de produção | Phase 2 | ROADMAP Phase 2 + UI-SPEC «Phase 2 owns». `lib/screen/*` sem `ToolScaffold` **não** é gap da Phase 1. PRES-01..PRES-04 permanecem Phase 2. |

### Required Artifacts

| Artifact | Expected | Status | Details |
| -------- | ----------- | ------ | ------- |
| `lib/app/app_destinations.dart` | Catálogo imutável, labels curtas, semanticLabel | ✓ VERIFIED | `List.unmodifiable`; Rede/Armazenamento/Hash + nomes completos. |
| `lib/app/app_shell.dart` | Overflow só na Bar; rail completo rolável | ✓ VERIFIED | `_barUsesOverflow`; `_onRailDestinationSelected` indexa o catálogo; `semanticLabel` consumido; `IndexedStack`. |
| `lib/design_system/app_breakpoints.dart` | Contrato 600/840 | ✓ VERIFIED | Consumido pelo shell e `ToolScaffold`. |
| `lib/design_system/app_tokens.dart` | Tokens aprovados | ✓ VERIFIED | ThemeExtension nos dois temas; `contentMaxWidth` 960. |
| `lib/theme/theme.dart` | ThemeData claro/escuro exato | ✓ VERIFIED | Roles `copyWith` com hex do UI-SPEC. |
| `lib/design_system/tool_scaffold.dart` | Container rolável e max width | ✓ VERIFIED | Galeria e testes; heading semântico. |
| `lib/design_system/tool_sections.dart` | Sections + ToolMetric Wrap + copyWriter | ✓ VERIFIED | `copyWriter` passado a `CopyValueAction` quando não nulo. |
| `lib/design_system/tool_status_panel.dart` | Sete estados canônicos; heading onSurface | ✓ VERIFIED | Ícone primary/error; heading `colorScheme.onSurface`. |
| `lib/design_system/copy_value_action.dart` | Cópia segura, SnackBar próprio | ✓ VERIFIED | Stateful; `mounted`; sem `hideCurrentSnackBar`. |
| `test/design_system/accessibility_test.dart` | Matriz da fundação real | ✓ VERIFIED | `AppShell` real; `_buildPublicFixture`. |
| `test/design_system/design_system_gallery.dart` | Galeria completa pt-BR + copy | ✓ VERIFIED | `ClipboardCopyWriter`; CTA e painéis em pt-BR. |
| `test/manual/design_system_app.dart` | Harness Android/TalkBack | ✓ VERIFIED | Monta a galeria; usado no percurso TalkBack aprovado. |
| `test/design_system/design_system_golden_test.dart` | Quatro comparações | ✓ VERIFIED | Caminho canônico `test/design_system/goldens/`. |
| `test/design_system/goldens/*.png` | Quatro PNGs | ✓ VERIFIED | Quatro arquivos presentes. `test/goldens/` propositalmente ausente (override 01-10). |
| `test/design_system/copy_lifecycle_test.dart` | Dispose, SnackBar alheio, writer | ✓ VERIFIED | Cinco casos (dispose, SnackBar alheio, writer via row, semantics, falha). |
| `test/design_system/gallery_copy_test.dart` | Clipboard real da galeria | ✓ VERIFIED | Assert `abc123def456` + SnackBar `Hash SHA-256 copiado`. |
| `test/theme/theme_contract_test.dart` | Oracle de hex/shape | ✓ VERIFIED | Literais do UI-SPEC, não `fromSeed` puro. |
| `test/design_system/tool_metric_reflow_test.dart` | Reflow 360/2.0 | ✓ VERIFIED | Widget público, não Row clone. |
| `01-11-SUMMARY.md` | Gate humano após approved | ✓ VERIFIED | `status: complete`; TalkBack + visual + copy. |
| `01-HUMAN-UAT.md` | UAT humano fechado | ✓ VERIFIED | `status: complete`; 3/3 pass; 0 pending. |

### Key Link Verification

| From | To | Via | Status | Details |
| ---- | --- | --- | ------ | ------- |
| `lib/main.dart` | `lib/app/app_shell.dart` | `MaterialApp.home` | ✓ WIRED | `home: AppShell(destinations: appDestinations)`. |
| `lib/app/app_shell.dart` | `lib/app/app_destinations.dart` | catálogo + `semanticLabel` | ✓ WIRED | Bar tooltip; rail Tooltip/`semanticsLabel`. |
| `lib/app/app_shell.dart` | `lib/design_system/app_breakpoints.dart` | `AppBreakpoints.classify` | ✓ WIRED | LayoutBuilder. |
| `lib/theme/theme.dart` | `lib/design_system/app_tokens.dart` | extensions | ✓ WIRED | Ambos os temas. |
| `lib/design_system/tool_scaffold.dart` | `AppTokens` | ThemeExtension | ✓ WIRED | Padding/max width. |
| `TechnicalValueRow` | `CopyValueAction` | `copyWriter` | ✓ WIRED | `writer: copyWriter` quando não nulo. |
| `CopyValueAction` | `ScaffoldMessenger` | controller próprio | ✓ WIRED | `close()` só em `_copySnackBar`. |
| `design_system_golden_test.dart` | `test/design_system/goldens` | `matchesGoldenFile('goldens/...')` | ✓ WIRED | Relativo ao arquivo de teste. Override formal de `test/goldens/`. |
| `test/manual/design_system_app.dart` | `DesignSystemGallery` | import da galeria | ✓ WIRED | Inclui `ClipboardCopyWriter`. |
| `DesignSystemGallery` | `ClipboardCopyWriter` | `_copyWriter` | ✓ WIRED | `static const CopyValueWriter _copyWriter = ClipboardCopyWriter()`. |

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
| -------- | ------------- | ------ | ------------------ | ------ |
| `AppShell` | destino/página | `appDestinations` → `_pagesById` → `IndexedStack` | Sim (3 destinos reais) | ✓ FLOWING |
| `AppShell` 5+ | índice / overflow | `_barUsesOverflow` só na Bar; rail = catálogo | Sim; testes 5 destinos | ✓ FLOWING |
| `ToolStatusPanel` | `variant` | `_statusMap` canônico | Copy/ícone/cor do UI-SPEC; heading onSurface | ✓ FLOWING |
| `TechnicalValueRow` | `copyWriter` | prop → `CopyValueAction.writer` | Writer invocado com o valor | ✓ FLOWING |
| `CopyValueAction` | valor + SnackBar | `write` + `mounted` | Caminho feliz, falha e dispose cobertos | ✓ FLOWING |
| `DesignSystemGallery` | ação de copiar | `ClipboardCopyWriter` | Write real do valor visível `abc123def456` (teste + humano) | ✓ FLOWING |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
| -------- | ------- | ------ | ------ |
| Análise estática | `C:\src\flutter\bin\flutter.bat analyze --no-pub` | No issues found (8.3s) | ✓ PASS |
| Suíte completa | `C:\src\flutter\bin\flutter.bat test --no-pub` | All tests passed (163) | ✓ PASS |
| Goldens | incluídos na suíte | 4/4 em `test/design_system/goldens/` | ✓ PASS |
| Rail 5 destinos | suíte `app_shell_test` 600/839/840 | 5 destinos; sem Ferramentas | ✓ PASS |
| Semântica do catálogo | `semanticLabel` lido em Bar/rail | tooltip / Icon.semanticLabel / semanticsLabel | ✓ PASS |
| `hideCurrentSnackBar` | grep em `lib/` | zero matches | ✓ PASS |
| `_NoopCopyWriter` em código | grep em `lib/` e `test/*.dart` | zero matches (só docs históricos) | ✓ PASS |
| TalkBack dispositivo | `01-HUMAN-UAT.md` + `approved` | emulador Android; pass | ✓ PASS |
| Copy clipboard | humano + `gallery_copy_test` | `abc123def456` | ✓ PASS |

### Probe Execution

Step 7c: **SKIPPED** — fase Flutter/UI sem probes `scripts/*/tests/probe-*.sh` e nenhum probe declarado nos PLANs.

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
| ----------- | ---------- | ----------- | ------ | -------- |
| UI-01 | 01-01, 01-04, 01-07, 01-05/11 | Abrir qualquer ferramenta em navegação clara | ✓ SATISFIED | Catálogo + shell adaptativo + testes 5 destinos. |
| UI-02 | 01-01, 01-04, 01-07 | Bar/Rail conforme espaço | ✓ SATISFIED | Breakpoints 600/840; overflow só compacto. |
| UI-03 | 01-03, 01-04, 01-06, 01-10 | Hierarquia consistente na fundação | ✓ SATISFIED (fundação) | Primitives + galeria. Adoção nas 3 telas → Phase 2 / PRES-*, **não gap**. |
| UI-04 | 01-02, 01-08, 01-11 | Claro/escuro sem perda de contraste/significado | ✓ SATISFIED | Contrato de tema + guidelines + visual APPROVED. |
| UI-05 | 01-03, 01-08 | Sete estados consistentes | ✓ SATISFIED | Copy/ícone/cor canônicos; heading onSurface. |
| UI-06 | 01-02, 01-07, 01-09, 01-11 | Alvos 48 px e leitor de tela | ✓ SATISFIED | Alvos e `semanticLabel` no código. TalkBack real APPROVED no emulador (`01-HUMAN-UAT.md`). |
| UI-07 | 01-02, 01-10 | Fonte ampliada sem perda | ✓ SATISFIED | Matriz 2.0 + reflow de `ToolMetric`. |
| UI-08 | 01-01, 01-08, 01-10 | Interface do ciclo em pt-BR | ✓ SATISFIED | Catálogo, estados, galeria (`Calcular rede`, `Painéis de status`). |
| UI-09 | 01-03, 01-09, 01-10 | Cópia com confirmação acessível | ✓ SATISFIED | Lifecycle + `ClipboardCopyWriter` + galeria + clipboard humano `abc123def456`. |

PRES-01..PRES-04 não são desta fase. Nenhum requisito órfão da Phase 1.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
| ---- | ---- | ------- | -------- | ------ |
| `lib/screen/*` | — | Anatomia local (sem ToolScaffold) | ℹ Info | Esperado; Phase 2 owns. Não é gap. |
| `test/design_system/design_system_gallery.dart` | CTAs | `onPressed: () {}` em `Calcular rede`/`Limpar` | ℹ Info | Samples de layout; HUMAN-UAT test 3 pass deliberado. |
| `pubspec.yaml` | dep | `google_fonts` declarado mas nunca importado | ℹ Info | Sem request remoto; nenhum `package:google_fonts` em Dart. |
| `test/app/app_shell_test.dart` | fixtures 5 destinos | Destinos de teste | ℹ Info | Fixture deliberada; não flui para produção. |

Nenhum `TBD` / `FIXME` / `XXX` em `lib/` nem em `test/*.dart`. Nenhum blocker de debt marker.

**Disconfirmation (Confirmation Bias Counter):** (1) UI-03 nas telas de produção permanece intencionalmente fora desta fase — deferred, não FAIL. (2) Testes de semantics **ainda** não provam TalkBack; o fechamento veio do percurso humano, não da suíte. (3) CTAs da galeria não calculam rede — contrato explícito, não calculadora.

### Human Verification Required

Nenhum item pendente. Os `<human-check>` de 01-05-PLAN e 01-11-PLAN já foram executados: visual APPROVED na sessão anterior; TalkBack + copy + CTAs da galeria em `01-HUMAN-UAT.md` (`status: complete`, 3/3 pass). Não re-enfileirados.

### Gaps Summary

O residual exclusivo da verificação anterior (TalkBack UNCERTAIN / `human_needed` 24/25) está fechado com evidência humana registrada: emulador Android, `approved`, HUMAN-UAT complete.

Não há FAILED. Não há UNCERTAIN. Não há `overrides:` aplicados. Adoção de `ToolScaffold` em `lib/screen/*` continua diferida à Phase 2 e **não** é gap.

ROADMAP Phase 1 permanece `[ ]` até o orquestrador consumir este `passed`. Phase 2 não foi iniciada por este verificador.

---

_Verified: 2026-08-31T17:52:00Z_
_Verifier: Claude (gsd-verifier)_
