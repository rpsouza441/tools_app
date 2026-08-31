---
phase: 01-contrato-visual-e-funda-o-adaptativa
verified: 2026-08-31T17:14:16Z
status: human_needed
score: "24/25 must-haves verified"
overrides_applied: 0
re_verification:
  previous_status: gaps_found
  previous_score: 9/25
  gaps_closed:
    - "A fase MVP possui uma user story válida cujo outcome pode ser verificado"
    - "Usuário localiza todos os destinos em navegação adaptativa e recebe rótulos semânticos completos"
    - "Tema, hierarquia e sete estados correspondem exatamente ao UI-SPEC em pt-BR"
    - "Copiar valores é consistente, acessível, seguro ao descarte e produz somente o feedback próprio"
    - "A fundação real reflui em 360 px/escala 2.0 e os quatro goldens protegem os caminhos críticos"
    - "Gate humano visual representativo (compacta Android, harness claro/escuro, viewport larga); boundaries 599/600/720/839/840/1024 cobertos por widget tests"
  gaps_remaining: []
  regressions: []
deferred:
  - truth: "As três telas de produção adotam ToolScaffold, seções, ações, resultados, métricas e cópia compartilhados"
    addressed_in: "Phase 2"
    evidence: "Goal da Phase 2: usuários continuam as tarefas 'depois da migração para a nova fundação visual'; UI-SPEC seção 'Phase 2 owns' atribui a adoção completa das primitives às três telas; 01-06-SUMMARY registra a fronteira UI-03."
human_verification:
  - test: "Percorrer o app real e o harness Android com TalkBack ligado: navegação (semanticLabel), headings, campos, ações, sete estados, resultado/métrica, Copiar {rótulo} e exatamente um {Rótulo} copiado."
    expected: "Ordem compreensível, nenhum nó essencial ausente, sem duplicação semântica, confirmação de cópia única."
    why_human: "TalkBack real depende do serviço assistivo Android. Widget tests, goldens e guidelines de semantics não são TalkBack. Não executado nesta sessão."
---

# Phase 1: Contrato visual e fundação adaptativa — Verification Report

**Phase Goal:** As a profissional de TI, I want to usar a fundação adaptativa e acessível, so that eu opere as ferramentas com clareza.
**Verified:** 2026-08-31T17:14:16Z
**Status:** human_needed
**Re-verification:** Yes — after gap closure (previous `gaps_found` 9/25)

## User Flow Coverage

User story: «As a profissional de TI, I want to usar a fundação adaptativa e acessível, so that eu opere as ferramentas com clareza.»

O Goal em `.planning/ROADMAP.md` casa com `/^As a .+, I want to .+, so that .+\.$/`. Mode permanece `mvp`.

| Step | Expected | Evidence | Status |
|---|---|---|---|
| Abrir o app | Shell com catálogo Rede / Armazenamento / Hash | `lib/main.dart` → `AppShell(destinations: appDestinations)`; labels curtas e `semanticLabel` completos em `app_destinations.dart` | ✓ VERIFIED |
| Navegar sem superlotação | Bar &lt;600; rail recolhido 600–839; rail extended ≥840; 5 destinos: Ferramentas só na Bar | `app_shell.dart` (`_barUsesOverflow` só no Bar; rail lista `widget.destinations`, `scrollable: true`); testes 599/600/839/840 | ✓ VERIFIED |
| Usar a fundação compartilhada | Hierarquia título → entrada → ação → resultado/métrica + sete estados | `ToolScaffold` / seções / `ToolStatusPanel` / galeria; telas de produção ficam na Phase 2 | ✓ VERIFIED |
| Operar claro/escuro e copiar | Tema canônico, pt-BR, cópia com SnackBar próprio e `mounted` | `theme.dart` + `theme_contract_test.dart`; `copy_value_action.dart` + `copy_lifecycle_test.dart`; galeria `Calcular rede` / `Painéis de status` | ✓ VERIFIED |
| Outcome | Operar as ferramentas com clareza | Shell real + primitives + inspeção visual humana APPROVED nesta sessão | ✓ VERIFIED |
| Acessível (TalkBack) | Leitor de tela anuncia destinos, estados e cópia | Código e semantics tests prontos; **TalkBack de dispositivo não executado** | ? UNCERTAIN |

## Goal Achievement

### Observable Truths

Mesmas 25 verdades da verificação inicial, reavaliadas contra o código vivo. Nenhum FAILED copiado.

| # | Truth | Status | Evidence |
|---|---|---|---|
| 1 | Usuário localiza e abre qualquer destino em navegação adaptativa sem superlotação | ✓ VERIFIED | Overflow só na Bar (`_barUsesOverflow`); rail usa o catálogo inteiro com `scrollable: true`. Testes de 5 destinos em 599/600/839/840 passam. |
| 2 | A fundação oferece hierarquia e os sete estados compartilhados coerentes | ✓ VERIFIED | `ToolStatusPanel._statusMap` e testes independentes batem com o State Contract do UI-SPEC; headings em `onSurface`; ícone carrega primary/error. |
| 3 | Tema claro/escuro, pt-BR e cópia mantêm contraste, significado e confirmação acessível | ✓ VERIFIED | Hex/elevation/radius canônicos; galeria em pt-BR; copy lifecycle com SnackBar próprio. Contraste: `textContrastGuideline` light/dark. |
| 4 | Alvos, leitor de tela (wiring) e fonte ampliada preservam conteúdo e compreensão | ✓ VERIFIED | 48×48 tematizado; `semanticLabel` em tooltip/semantics; matriz 360/720/1024 × 1.0/2.0 em widgets públicos. **Execução TalkBack é a verdade 23.** |
| 5 | Rede, Armazenamento e Hash abrem pelo mesmo catálogo tipado em pt-BR | ✓ VERIFIED | `appDestinations` `List.unmodifiable`; labels curtas + semanticLabels completos; `destination_catalog_test.dart`; happy path real. |
| 6 | Bar &lt;600, rail recolhido 600-839 e rail extended ≥840 | ✓ VERIFIED | `AppBreakpoints.classify`; testes de boundary 599/600/839/840. |
| 7 | Estado da Calculadora de Rede sobrevive a navegação e breakpoint | ✓ VERIFIED | `IndexedStack` + `_pagesById`; happy path e resize tests passam. |
| 8 | Cinco destinos em compacta mostram três prioridades + Ferramentas | ✓ VERIFIED | Bar overflow; Ferramentas **ausente** no rail 600/839/840. |
| 9 | Temas usam anchors/roles/shape/elevation exatos aprovados | ✓ VERIFIED | Canvas `#F7F9F7`/`#0F1511`; Card elevation 0 radius 12; AppBar/nav/rail elevation 0; botões radius 8; chips radius 4. `theme_contract_test.dart` oracle = UI-SPEC. |
| 10 | Copy usa sans local e valores técnicos usam monospace sem request remoto | ✓ VERIFIED | Sem `google_fonts` em `lib/`; `fontFamily: 'monospace'` em `ToolMetric`/`TechnicalValueRow`. |
| 11 | Controles possuem 48×48 e rótulos semânticos úteis | ✓ VERIFIED | `minimumSize` 48; Bar `tooltip: semanticLabel`; rail recolhido Tooltip + `Icon.semanticLabel`; rail extended `semanticsLabel` no texto. |
| 12 | Shell e primitives reais funcionam em compact/medium/expanded a 1×/2× | ✓ VERIFIED | `accessibility_test.dart` monta `AppShell` + galeria pública; `_buildFixture` ausente. |
| 13 | Existem primitives pequenas e feature-agnostic para anatomia compartilhada | ✓ VERIFIED | `ToolScaffold`, sections, status, copy; galeria as consome. Telas de produção: Phase 2. |
| 14 | Sete estados têm ícone/heading/body canônicos, preservando evidência | ✓ VERIFIED | Empty/loading/success/failure/offline/permissionDenied/cancelled conforme UI-SPEC; loading = `CircularProgressIndicator` (Material não tem `progress_activity`). |
| 15 | Entrada precede ações/resultados e valores técnicos são selecionáveis/mono | ✓ VERIFIED | Anatomia da galeria e `ToolScaffold`; `SelectableText` + `copyWriter`. |
| 16 | Cópia é exata e produz uma confirmação acessível própria | ✓ VERIFIED | `context.mounted` após await; `_copySnackBar?.close()` só no controller próprio; sem `hideCurrentSnackBar`; `copyWriter` wired; testes de dispose, SnackBar alheio, writer e fallback. |
| 17 | Conteúdo e ações refluem em 360 px/2× com targets 48×48 | ✓ VERIFIED | `ToolMetric` é `Wrap`; `tool_metric_reflow_test.dart` (label ≥40 chars + `Indisponível`) sem overflow. |
| 18 | Quatro goldens aprovados protegem shell e primitives centrais | ✓ VERIFIED | `matchesGoldenFile('goldens/...')` → `test/design_system/goldens/` (override formal do 01-04 em 01-10). Quatro PNGs. Fixtures largas: 5 destinos + copy visível. Aprovação visual humana nesta sessão. `test/goldens/` ausente de propósito. |
| 19 | Galeria mostra todos os estados, resultado, métrica, valor técnico e cópia | ✓ VERIFIED | `Calcular rede`, `Painéis de status`, `copyWriter` em `TechnicalValueRow`; sete `ToolStatusPanel`. |
| 20 | Matriz automatizada comprova navegação, targets, labels, contraste e escala da fundação real | ✓ VERIFIED | Fixture pública `_buildPublicFixture`; guidelines Android/labeled/contrast; semantics de 5 destinos em 360/720/1024. |
| 21 | Baselines são determinísticas em Windows/Flutter 3.44, DPR 1, sem rede/fonte remotos | ✓ VERIFIED | Goldens DPR 1; sem fonte/rede remota. |
| 22 | Humano confirma shell/fluxo em evidência representativa; boundaries por testes | ✓ VERIFIED | APPROVED nesta sessão: Android compacta 3 destinos (claro); harness compacto (campos, erro, CTA, resultado, métricas, hash+copy, sete estados, pt-BR); harness escuro; Chrome largo (max-width). Usuário proibiu screenshots 599/600/720/839/840/1024 — cobertos por widget tests. |
| 23 | TalkBack anuncia navegação, headings, campos, estados e cópia sem duplicação | ? UNCERTAIN | **Não executado.** Semantics/widget tests **não** substituem TalkBack. 01-11-SUMMARY é honesto (`residual_talkback`). Checkbox 01-11 no ROADMAP continua desmarcado. |
| 24 | Inspeção manual não encontra overflow, neon, ellipsis, target pequeno ou perda de estado | ✓ VERIFIED | Inspeção visual humana APPROVED no conjunto representativo desta sessão. |
| 25 | Analyzer, suíte focada e quatro comparações golden passam | ✓ VERIFIED | Verificador: `flutter analyze --no-pub` → No issues found. Subconjunto Phase 1 (theme, copy, reflow, a11y, goldens, shell, components) → All tests passed. Relato de sessão: 162/162 na suíte completa. |

**Score:** 24/25 truths verified (1 UNCERTAIN: TalkBack)

### Deferred Items

| # | Item | Addressed In | Evidence |
|---|------|-------------|----------|
| 1 | Adoção das primitives compartilhadas pelas três telas de produção | Phase 2 | ROADMAP Phase 2 + UI-SPEC «Phase 2 owns» + 01-06-SUMMARY. `lib/screen/*` sem `ToolScaffold` **não** é gap da Phase 1. PRES-01..PRES-04 permanecem Phase 2. |

### Required Artifacts

| Artifact | Expected | Status | Details |
|---|---|---|---|
| `lib/app/app_destinations.dart` | Catálogo imutável, labels curtas, semanticLabel | ✓ VERIFIED | `List.unmodifiable`; Rede/Armazenamento/Hash + nomes completos. |
| `lib/app/app_shell.dart` | Overflow só na Bar; rail completo rolável | ✓ VERIFIED | `_barUsesOverflow`; `_onRailDestinationSelected` indexa o catálogo; `semanticLabel` consumido. |
| `lib/design_system/app_breakpoints.dart` | Contrato 600/840 | ✓ VERIFIED | Consumido pelo shell. |
| `lib/design_system/app_tokens.dart` | Tokens aprovados | ✓ VERIFIED | ThemeExtension nos dois temas. |
| `lib/theme/theme.dart` | ThemeData claro/escuro exato | ✓ VERIFIED | Roles `copyWith` com hex do UI-SPEC. |
| `lib/design_system/tool_scaffold.dart` | Container rolável e max width | ✓ VERIFIED | Galeria e testes. |
| `lib/design_system/tool_sections.dart` | Sections + ToolMetric Wrap + copyWriter | ✓ VERIFIED | `copyWriter` passado a `CopyValueAction`. |
| `lib/design_system/tool_status_panel.dart` | Sete estados canônicos; heading onSurface | ✓ VERIFIED | Ícone primary/error; heading `onSurface` (commit `3bb2f36`). |
| `lib/design_system/copy_value_action.dart` | Cópia segura, SnackBar próprio | ✓ VERIFIED | Stateful; `mounted`; sem `hideCurrentSnackBar`. |
| `test/design_system/accessibility_test.dart` | Matriz da fundação real | ✓ VERIFIED | `AppShell` real; sem `_buildFixture`. |
| `test/design_system/design_system_gallery.dart` | Galeria completa pt-BR + copy | ✓ VERIFIED | Copy visível; CTA e painéis em pt-BR. |
| `test/manual/design_system_app.dart` | Harness Android/TalkBack | ✓ VERIFIED (artefato) | Monta a galeria; **TalkBack não rodou**. |
| `test/design_system/design_system_golden_test.dart` | Quatro comparações | ✓ VERIFIED | Caminho canônico `test/design_system/goldens/`. |
| `test/design_system/goldens/*.png` | Quatro PNGs | ✓ VERIFIED | Quatro arquivos presentes. `test/goldens/` propositalmente ausente. |
| `test/design_system/copy_lifecycle_test.dart` | Dispose, SnackBar alheio, writer | ✓ VERIFIED | Cinco casos passam. |
| `test/theme/theme_contract_test.dart` | Oracle de hex/shape | ✓ VERIFIED | Literais do UI-SPEC, não `fromSeed`. |
| `test/design_system/tool_metric_reflow_test.dart` | Reflow 360/2.0 | ✓ VERIFIED | Widget público, não Row clone. |

`pubspec.lock-old` não rastreado: ignorado.

### Key Link Verification

| From | To | Via | Status | Details |
|---|---|---|---|---|
| `lib/main.dart` | `lib/app/app_shell.dart` | `MaterialApp.home` | ✓ WIRED | `home: AppShell(destinations: appDestinations)`. |
| `lib/app/app_shell.dart` | `lib/app/app_destinations.dart` | catálogo + `semanticLabel` | ✓ WIRED | Bar tooltip; rail Tooltip/`semanticsLabel`. |
| `lib/app/app_shell.dart` | `lib/design_system/app_breakpoints.dart` | `AppBreakpoints.classify` | ✓ WIRED | LayoutBuilder. |
| `lib/theme/theme.dart` | `lib/design_system/app_tokens.dart` | extensions | ✓ WIRED | Ambos os temas. |
| `lib/design_system/tool_scaffold.dart` | `AppTokens` | ThemeExtension | ✓ WIRED | Padding/max width. |
| `TechnicalValueRow` | `CopyValueAction` | `copyWriter` | ✓ WIRED | `writer: copyWriter` quando não nulo. |
| `CopyValueAction` | `ScaffoldMessenger` | controller próprio | ✓ WIRED | `close()` só em `_copySnackBar`. |
| `design_system_golden_test.dart` | `test/design_system/goldens` | `matchesGoldenFile('goldens/...')` | ✓ WIRED | Relativo ao arquivo de teste. |
| `test/manual/design_system_app.dart` | `DesignSystemGallery` | import da galeria | ✓ WIRED | Inclui copy. |

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
|---|---|---|---|---|
| `AppShell` | destino/página | `appDestinations` → `_pagesById` → `IndexedStack` | Sim (3 destinos reais) | ✓ FLOWING |
| `AppShell` 5+ | índice / overflow | `_barUsesOverflow` só na Bar; rail = catálogo | Sim; testes 5 destinos | ✓ FLOWING |
| `ToolStatusPanel` | `variant` | `_statusMap` canônico | Copy/ícone/cor do UI-SPEC | ✓ FLOWING |
| `TechnicalValueRow` | `copyWriter` | prop → `CopyValueAction.writer` | Writer invocado com o valor | ✓ FLOWING |
| `CopyValueAction` | valor + SnackBar | `write` + `mounted` | Caminho feliz, falha e dispose cobertos | ✓ FLOWING |
| `DesignSystemGallery` | ação de copiar | `_NoopCopyWriter` | Botão visível; writer injetado | ✓ FLOWING |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|---|---|---|---|
| Análise estática | `C:\src\flutter\bin\flutter.bat analyze --no-pub` | No issues found | ✓ PASS |
| Subconjunto Phase 1 | `flutter test --no-pub` (theme, copy, reflow, a11y, goldens, shell, components) | All tests passed (145 neste run) | ✓ PASS |
| Goldens | incluídos no subconjunto | 4/4 em `test/design_system/goldens/` | ✓ PASS |
| Rail 5 destinos | inspeção + `app_shell_test` 600/839/840 | 5 destinos; sem Ferramentas | ✓ PASS |
| Semântica do catálogo | `semanticLabel` lido em Bar/rail | tooltip / Icon.semanticLabel / semanticsLabel | ✓ PASS |
| `hideCurrentSnackBar` | grep em `lib/` e `test/` | zero matches | ✓ PASS |
| TalkBack dispositivo | não executado | residual humano | ? SKIP |

### Probe Execution

Step 7c: **SKIPPED** — fase Flutter/UI sem probes `scripts/*/tests/probe-*.sh` e nenhum probe declarado nos PLANs.

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|---|---|---|---|---|
| UI-01 | 01-01, 01-04, 01-07, 01-05/11 | Abrir qualquer ferramenta em navegação clara | ✓ SATISFIED | Catálogo + shell adaptativo + testes 5 destinos. |
| UI-02 | 01-01, 01-04, 01-07 | Bar/Rail conforme espaço | ✓ SATISFIED | Breakpoints 600/840; overflow só compacto. |
| UI-03 | 01-03, 01-04, 01-06, 01-10 | Hierarquia consistente na fundação | ✓ SATISFIED (fundação) | Primitives + galeria. Adoção nas 3 telas → Phase 2 / PRES-*, **não gap**. |
| UI-04 | 01-02, 01-08, 01-11 | Claro/escuro sem perda de contraste/significado | ✓ SATISFIED | Contrato de tema + guidelines + visual APPROVED. |
| UI-05 | 01-03, 01-08 | Sete estados consistentes | ✓ SATISFIED | Copy/ícone/cor canônicos; heading onSurface. |
| UI-06 | 01-02, 01-07, 01-09, 01-11 | Alvos 48 px e leitor de tela | ? NEEDS HUMAN | Alvos e `semanticLabel` verificados em código. **TalkBack real pendente.** |
| UI-07 | 01-02, 01-10 | Fonte ampliada sem perda | ✓ SATISFIED | Matriz 2.0 + reflow de `ToolMetric`. |
| UI-08 | 01-01, 01-08, 01-10 | Interface do ciclo em pt-BR | ✓ SATISFIED | Catálogo, estados, galeria (`Calcular rede`, `Painéis de status`). |
| UI-09 | 01-03, 01-09, 01-10 | Cópia com confirmação acessível | ✓ SATISFIED (código) | Lifecycle + writer + galeria. Anúncio TalkBack da confirmação = residual da UI-06. |

PRES-01..PRES-04 não são desta fase. Nenhum requisito órfão da Phase 1.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|---|---|---|---|---|
| `lib/screen/*` | — | Anatomia local (sem ToolScaffold) | ℹ Info | Esperado; Phase 2 owns. |
| `test/app/app_shell_test.dart` | fixtures 5 destinos | Destinos de teste | ℹ Info | Fixture deliberada; não flui para produção. |

Nenhum `TBD` / `FIXME` / `XXX` em `lib/`. Nenhum blocker de debt marker.

**Disconfirmation (Confirmation Bias Counter):** (1) UI-06 está só parcialmente humana — targets/semantics sim, TalkBack não. (2) Tests de semantics **não** provam TalkBack. (3) Falha de clipboard está coberta; o único caminho sem evidência de dispositivo é o leitor de tela real.

### Human Verification Required

A inspeção visual representativa **já foi APPROVED** nesta sessão. Não solicitar screenshots 599/600/720/839/840/1024.

#### 1. TalkBack no Android (único residual)

**Test:** Com TalkBack ligado, percorrer o app (`lib/main.dart`) e o harness (`flutter run -t test/manual/design_system_app.dart`) — navegação, headings, campos, ações, sete estados, resultado/métrica, `Copiar {rótulo}` e exatamente um `{Rótulo} copiado`.
**Expected:** Ordem compreensível; nenhum nó essencial ausente; sem duplicação; confirmação de cópia única.
**Why human:** Serviço assistivo Android. Widget tests e goldens não são TalkBack.

### Gaps Summary

Os seis gaps de código da verificação anterior (9/25) estão fechados no código vivo: user story MVP, navegação/`semanticLabel`, tema e sete estados, copy lifecycle, reflow/a11y/goldens, e gate visual representativo.

Não há FAILED. Não há `overrides:` aplicados. Adoção de `ToolScaffold` em `lib/screen/*` continua diferida à Phase 2.

O único item em aberto é TalkBack real. Por isso o status é **human_needed**, não `passed` e não `gaps_found`. O checkbox 01-11 no ROADMAP permanece desmarcado. Phase 2 não deve começar como se o gate de leitor de tela estivesse concluído.

---

_Verified: 2026-08-31T17:14:16Z_
_Verifier: Claude (gsd-verifier)_
