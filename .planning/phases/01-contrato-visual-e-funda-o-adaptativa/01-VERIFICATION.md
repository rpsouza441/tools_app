---
phase: 01-contrato-visual-e-funda-o-adaptativa
verified: 2026-08-31T14:37:45.268Z
status: gaps_found
score: "9/25 must-haves verified"
overrides_applied: 0
gaps:
  - truth: "A fase MVP possui uma user story válida cujo outcome pode ser verificado"
    status: failed
    reason: "ROADMAP.md marca a fase como mode: mvp, mas o Goal não segue o formato obrigatório 'As a ..., I want to ..., so that ...'; não há outcome canônico para a cobertura MVP."
    artifacts:
      - path: ".planning/ROADMAP.md"
        issue: "Goal declarativo em português, sem os slots role/capability/outcome exigidos pelo guard MVP."
    missing:
      - "Reformular o goal por /gsd mvp-phase 1 antes da re-verificação, sem reescrevê-lo dentro desta auditoria."
  - truth: "Usuário localiza todos os destinos em navegação adaptativa e recebe rótulos semânticos completos"
    status: failed
    reason: "Com cinco destinos, o overflow compacto também substitui o rail médio/expandido; semanticLabel nunca é consumido e as labels visíveis longas contradizem o catálogo aprovado."
    artifacts:
      - path: "lib/app/app_shell.dart"
        issue: "_useOverflow governa NavigationBar e NavigationRail; linhas 232-248 criam três destinos + Ferramentas também no rail, e linhas 193-257 nunca leem semanticLabel."
      - path: "lib/app/app_destinations.dart"
        issue: "Labels são 'Calculadora de Rede', 'Conversor de Dados' e 'Gerador de Hash', não Rede/Armazenamento/Hash; a lista global também é mutável."
      - path: "test/app/app_shell_test.dart"
        issue: "Cenário de cinco destinos cobre somente 400 px; não há rail em 600/839/840 nem inspeção da árvore semântica."
    missing:
      - "Restringir Ferramentas ao NavigationBar compacto e listar todos os destinos, na ordem do catálogo, em rail rolável."
      - "Usar semanticLabel/tooltip sem duplicação semântica e labels visíveis curtas."
      - "Adicionar testes reais de rail com cinco destinos e de semantics."
  - truth: "Tema, hierarquia e sete estados correspondem exatamente ao UI-SPEC em pt-BR"
    status: failed
    reason: "O tema usa anchors, elevações e raios diferentes do contrato, e seis dos sete estados divergem da cópia/semântica canônica."
    artifacts:
      - path: "lib/theme/theme.dart"
        issue: "ColorScheme.fromSeed sem roles exatos; canvases #FBFDF8/#1A1C19 em vez de #F7F9F7/#0F1511; Card elevation 1, scrolledUnderElevation 1, botão radius 12 e chip radius 8."
      - path: "lib/design_system/tool_status_panel.dart"
        issue: "Empty, loading, failure, offline, permissionDenied e cancelled divergem de heading/body/icon/color do UI-SPEC."
      - path: "test/design_system/tool_components_test.dart"
        issue: "As expectativas repetem as strings incorretas da implementação, produzindo falso verde."
      - path: "test/design_system/design_system_gallery.dart"
        issue: "Contém 'Calcular' e 'Status Panels', contrariando a cópia canônica e UI-08."
    missing:
      - "Implementar roles, shape e elevation exatos do UI-SPEC nos dois temas."
      - "Corrigir os sete estados a partir do contrato e inverter os testes para expectativas independentes."
      - "Eliminar copy inglesa e CTA genérica da galeria/harness."
  - truth: "Copiar valores é consistente, acessível, seguro ao descarte e produz somente o feedback próprio"
    status: failed
    reason: "A conclusão assíncrona usa ScaffoldMessenger após await sem mounted, remove SnackBars alheios e TechnicalValueRow ignora o callback público; a galeria/TalkBack nem renderiza a ação."
    artifacts:
      - path: "lib/design_system/copy_value_action.dart"
        issue: "Linhas 59-81 capturam messenger antes do await, não verificam mounted e chamam hideCurrentSnackBar globalmente."
      - path: "lib/design_system/tool_sections.dart"
        issue: "Linhas 158-160/200 tratam onCopy apenas como booleano e nunca o invocam."
      - path: "test/design_system/design_system_gallery.dart"
        issue: "TechnicalValueRow é construído sem cópia; goldens e harness manual omitem UI-09."
      - path: "test/design_system/tool_components_test.dart"
        issue: "Não testa descarte antes da conclusão nem preservação de SnackBar não relacionado."
    missing:
      - "Guardar/fechar apenas o ScaffoldFeatureController próprio e abandonar conclusão tardia após dispose."
      - "Modelar e testar uma API de cópia realmente conectada em TechnicalValueRow."
      - "Renderizar a ação no gallery/harness e cobrir TalkBack/feedback único."
  - truth: "A fundação real reflui em 360 px/escala 2.0 e os quatro goldens protegem os caminhos críticos"
    status: failed
    reason: "ToolMetric usa Row intrinsecamente rígido; a matriz 360/720/1024 testa uma réplica, os rails golden têm só três labels curtas e os quatro caminhos de artefato declarados no PLAN não existem."
    artifacts:
      - path: "lib/design_system/tool_sections.dart"
        issue: "ToolMetric (linhas 99-117) contém dois Text não flexíveis; o Wrap externo não permite reflow interno."
      - path: "test/design_system/accessibility_test.dart"
        issue: "A matriz de linhas 318-347 usa _buildFixture, não AppShell/ToolScaffold/ToolMetric/galeria reais."
      - path: "test/design_system/design_system_golden_test.dart"
        issue: "Goldens largos usam somente três destinos fake e não exercitam overflow de rail nem semanticLabel."
      - path: "test/goldens"
        issue: "Diretório e quatro PNGs exigidos pelo frontmatter do 01-04-PLAN estão ausentes; alternativas existem em test/design_system/goldens sem override formal."
    missing:
      - "Permitir reflow de label/valor de ToolMetric e provar o caso longo em 360 px/2×."
      - "Executar a matriz com widgets públicos reais, cinco destinos e semantics."
      - "Corrigir ou aceitar formalmente por override a mudança de caminho dos goldens; regenerá-los só após correções e revisão visual."
  - truth: "O gate humano valida cinco larguras, temas, escala 200%, fluxo offline, TalkBack e comparação visual"
    status: failed
    reason: "O checkpoint 01-05 foi autoaprovado por --auto sem dispositivo/emulador Android; os sete checks e TalkBack não foram executados, portanto não existe aprovação humana."
    artifacts:
      - path: ".planning/phases/01-contrato-visual-e-funda-o-adaptativa/01-05-SUMMARY.md"
        issue: "Registra explicitamente que autoaprovação encerrou o plano, mas não é evidência humana e que todos os sete checks ficaram pendentes."
      - path: "test/manual/design_system_app.dart"
        issue: "Harness existe, porém não foi executado em Android e, no estado atual, herda galeria sem ação de cópia."
    missing:
      - "Após corrigir os gaps automatizáveis, executar os sete checks do 01-05-PLAN em dispositivo/emulador Android com TalkBack e obter aprovação humana explícita."
deferred:
  - truth: "As três telas de produção adotam ToolScaffold, seções, ações, resultados, métricas e cópia compartilhados"
    addressed_in: "Phase 2"
    evidence: "Goal da Phase 2: usuários continuam as tarefas 'depois da migração para a nova fundação visual'; o próprio UI-SPEC, seção 'Phase 2 owns', atribui a adoção completa das primitives às três telas à Phase 2."
---

# Phase 1: Contrato visual e fundação adaptativa — Verification Report

**Phase Goal:** Usuários encontram uma interface coerente, adaptativa e acessível, regida por um UI-SPEC aprovado e por componentes compartilhados.  
**Verified:** 2026-08-31T14:37:45.268Z  
**Status:** gaps_found  
**Re-verification:** No — initial verification

## User Flow Coverage

O modo da fase é `mvp`, mas o goal não é uma user story válida. Por isso não é possível extrair os slots obrigatórios de papel, capacidade e outcome sem inventar um contrato diferente.

| Step | Expected | Evidence | Status |
|---|---|---|---|
| MVP format guard | Goal no formato `As a ..., I want to ..., so that ...` | `.planning/ROADMAP.md` usa uma frase declarativa; o binário local também não expõe o verb `user-story.validate` documentado | ✗ FAILED |
| User-flow outcome | Outcome observável derivado do `so that` | Não existe cláusula `so that` no goal atual | ✗ BLOCKED |

O goal não foi reescrito nesta auditoria. Execute `/gsd mvp-phase 1` para corrigir o contrato e então refaça a cobertura de fluxo.

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|---|---|---|
| 1 | Usuário localiza e abre qualquer destino em navegação adaptativa sem superlotação | ✗ FAILED | `app_shell.dart:24-39,229-265` aplica overflow compacto também ao rail com 5+ destinos. |
| 2 | A fundação oferece hierarquia e os sete estados compartilhados coerentes | ✗ FAILED | `tool_status_panel.dart:31-66` diverge do UI-SPEC em seis estados. |
| 3 | Tema claro/escuro, pt-BR e cópia mantêm contraste, significado e confirmação acessível | ✗ FAILED | Contraste automatizado passa, mas tema/copy/harness violam o contrato exato e o lifecycle. |
| 4 | Alvos, leitor de tela e fonte ampliada preservam conteúdo e compreensão | ✗ FAILED | `semanticLabel` não é usado, `ToolMetric` é rígido e TalkBack nunca foi executado. |
| 5 | Rede, Armazenamento e Hash abrem pelo mesmo catálogo tipado em pt-BR | ✓ VERIFIED | `main.dart:20`, `app_destinations.dart:49-88` e teste de integração real. |
| 6 | Bar <600, rail recolhido 600-839 e rail extended >=840 | ✓ VERIFIED | `app_breakpoints.dart:12-15`; testes de boundary passam para catálogo de 3 destinos. |
| 7 | Estado da Calculadora de Rede sobrevive a navegação e breakpoint | ✓ VERIFIED | `IndexedStack` materializado em `initState`; happy path/state preservation passam. |
| 8 | Cinco destinos em compacta mostram três prioridades + Ferramentas | ✓ VERIFIED | `app_shell.dart:193-209`; teste a 400 px passa. |
| 9 | Temas usam anchors/roles/shape/elevation exatos aprovados | ✗ FAILED | `theme.dart:31-35,79-82,122-129,140-170` diverge dos valores do UI-SPEC. |
| 10 | Copy usa sans local e valores técnicos usam monospace sem request remoto | ✓ VERIFIED | Sem `google_fonts` em theme; technical values usam `monospace`. |
| 11 | Controles possuem 48×48 e rótulos semânticos úteis | ✗ FAILED | 48×48 está tematizado, mas o shell descarta `semanticLabel` e não fornece tooltip do rail recolhido. |
| 12 | Shell e primitives reais funcionam em compact/medium/expanded a 1×/2× | ✗ FAILED | Matriz usa fixture substituta; `ToolMetric` real tem Row não flexível. |
| 13 | Existem primitives pequenas e feature-agnostic para anatomia compartilhada | ✓ VERIFIED | `ToolScaffold`, sections, status e copy são substantivos e usados na galeria de teste. |
| 14 | Sete estados têm ícone/heading/body canônicos, preservando evidência | ✗ FAILED | Mapeamento canônico não foi implementado em `tool_status_panel.dart`. |
| 15 | Entrada precede ações/resultados e valores técnicos são selecionáveis/mono | ✓ VERIFIED | `tool_scaffold.dart`, `tool_sections.dart` e galeria mantêm a anatomia e SelectableText. |
| 16 | Cópia é exata e produz uma confirmação acessível própria | ✗ FAILED | Valor direto é copiado, porém lifecycle, SnackBar alheio, callback morto e harness quebram o truth completo. |
| 17 | Conteúdo e ações refluem em 360 px/2× com targets 48×48 | ✗ FAILED | `ToolMetric` não reflui e o caso real não é exercitado pela matriz. |
| 18 | Quatro goldens aprovados protegem shell e primitives centrais | ✗ FAILED | Comparações passam, mas caminhos do PLAN faltam e fixtures omitem copy/5-dest/semantics; não houve revisão humana. |
| 19 | Galeria mostra todos os estados, resultado, métrica, valor técnico e cópia | ✗ FAILED | `design_system_gallery.dart:73-74` cria TechnicalValueRow sem ação de copiar. |
| 20 | Matriz automatizada comprova navegação, targets, labels, contraste e escala da fundação real | ✗ FAILED | `accessibility_test.dart:45-95,318-347` testa réplica própria. |
| 21 | Baselines são determinísticas em Windows/Flutter 3.44, DPR 1, sem rede/fonte remota | ✓ VERIFIED | Flutter 3.44.0 confirmado; golden tests em DPR 1 passam e não há fonte/rede remota. |
| 22 | Humano confirma shell/fluxo offline em 360/600/720/840/1024, temas e escala | ✗ FAILED | `01-05-SUMMARY.md` declara que os sete checks não foram executados. |
| 23 | TalkBack anuncia navegação, headings, campos, estados e cópia sem duplicação | ✗ FAILED | Não executado; além disso semanticLabel é descartado e o harness omite copy. |
| 24 | Inspeção manual não encontra overflow, neon, ellipsis, target pequeno ou perda de estado | ? UNCERTAIN | Nenhuma inspeção humana ocorreu; requer UAT após correções. |
| 25 | Analyzer, suíte completa e quatro comparações golden passam | ✓ VERIFIED | Verificador executou analyzer (0 issues) e `flutter test --no-pub` (100/100). |

**Score:** 9/25 truths verified

### Deferred Items

| # | Item | Addressed In | Evidence |
|---|---|---|---|
| 1 | Adoção das primitives compartilhadas pelas três telas de produção | Phase 2 | ROADMAP: migração das ferramentas para a nova fundação; UI-SPEC atribui explicitamente ToolScaffold/sections/result/copy à Phase 2. |

### Required Artifacts

| Artifact | Expected | Status | Details |
|---|---|---|---|
| `lib/app/app_destinations.dart` | Catálogo concreto único | ⚠ PARTIAL | Existe/substantivo/wired, mas labels divergem, semanticLabel fica sem consumidor e lista é mutável. |
| `lib/app/app_shell.dart` | Shell adaptativo preservando páginas | ✗ FAILED | Existe/substantivo/wired/data flowing; overflow quebra rails 5+. |
| `lib/design_system/app_breakpoints.dart` | Contrato 600/840 | ✓ VERIFIED | Existe, substantivo e consumido pelo shell/scaffold. |
| `lib/design_system/app_tokens.dart` | Tokens aprovados | ✓ VERIFIED | ThemeExtension completo, instalado em ambos os temas e consumido. |
| `lib/theme/theme.dart` | ThemeData claro/escuro exato | ✗ FAILED | Wired, mas roles/shapes/elevations não correspondem ao UI-SPEC. |
| `lib/design_system/tool_scaffold.dart` | Container rolável e max width | ✓ VERIFIED | Substantivo e usa AppTokens/AppBreakpoints. |
| `lib/design_system/tool_sections.dart` | Sections/actions/results/metrics/technical values | ⚠ PARTIAL | ToolMetric não reflui; onCopy público é morto. |
| `lib/design_system/tool_status_panel.dart` | Sete estados canônicos | ✗ FAILED | Enum existe, porém conteúdo/semântica canônicos não. |
| `lib/design_system/copy_value_action.dart` | Cópia segura com feedback único | ✗ FAILED | Funcional no caminho feliz, inseguro após dispose e interfere em SnackBars alheios. |
| `test/design_system/accessibility_test.dart` | Matriz da fundação real | ✗ FAILED | Executa, mas usa réplica e evita os caminhos críticos. |
| `test/design_system/design_system_gallery.dart` | Galeria de todas as primitives | ✗ FAILED | Omite ação de copiar e contém copy não canônica. |
| `test/manual/design_system_app.dart` | Harness Android/TalkBack | ⚠ PARTIAL | Existe e monta a galeria, mas nunca foi executado e a galeria é incompleta. |
| `test/design_system/design_system_golden_test.dart` | Quatro comparações de alto valor | ⚠ PARTIAL | Executa quatro comparações, porém cobertura não testa os cenários que falham. |
| `test/goldens/*.png` | Quatro PNGs nos caminhos do PLAN | ✗ MISSING | Arquivos estão em `test/design_system/goldens/`, mudança sem override. |

### Key Link Verification

| From | To | Via | Status | Details |
|---|---|---|---|---|
| `lib/main.dart` | `lib/app/app_shell.dart` | `MaterialApp.home` | ✓ WIRED | `home: AppShell(destinations: appDestinations)`. |
| `lib/app/app_shell.dart` | `lib/app/app_destinations.dart` | `List<AppDestination>` | ⚠ PARTIAL | Páginas/chrome derivam do catálogo, mas semanticLabel não flui e rail usa chrome compacto. |
| `lib/app/app_shell.dart` | `lib/design_system/app_breakpoints.dart` | `AppBreakpoints.classify` | ✓ WIRED | Classificação usada no LayoutBuilder. |
| `lib/theme/theme.dart` | `lib/design_system/app_tokens.dart` | Theme extensions | ✓ WIRED | AppTokens instalado nos dois temas. |
| `lib/app/app_shell.dart` | `lib/theme/theme.dart` | MaterialApp component themes | ✓ WIRED | Theme aplicado por `main.dart`; link indireto funcional. |
| `lib/design_system/tool_scaffold.dart` | `lib/design_system/app_tokens.dart` | ThemeExtension lookup | ✓ WIRED | Padding/max width vêm de AppTokens. |
| `lib/design_system/tool_sections.dart` | `copy_value_action.dart` | TechnicalValueRow compõe copy | ⚠ PARTIAL | Composição existe, porém callback do consumidor não é conectado. |
| `copy_value_action.dart` | `ScaffoldMessenger` | SnackBar | ✗ FAILED | Chamada existe, mas lifecycle e ownership do SnackBar estão incorretos. |
| `design_system_golden_test.dart` | gallery + goldens | fixture/matchesGoldenFile | ✓ WIRED | Quatro testes passam nos caminhos alternativos relativos ao test. |
| `test/manual/design_system_app.dart` | `lib/design_system` | gallery com widgets públicos | ⚠ PARTIAL | Ligação indireta via import relativo da galeria; copy fica ausente. |

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
|---|---|---|---|---|
| `AppShell` | destino/página selecionados | `appDestinations` → pages em `initState` → `IndexedStack` | Sim, para os 3 destinos reais | ✓ FLOWING |
| `AppShell` com 5+ | índice real/overflow | priorities + `_overflowSelectedActualIndex` | Parcial; o mesmo mapeamento inadequado alimenta rail | ✗ BROKEN FLOW |
| `ToolStatusPanel` | `variant` | mapa local `_statusMap` | Produz dados, porém não os canônicos | ✗ WRONG DATA |
| `TechnicalValueRow` | `label/value/onCopy` | props do consumidor | label/value fluem; onCopy não | ⚠ HOLLOW CALLBACK |
| `CopyValueAction` | valor e feedback | prop `value` → writer → SnackBar | Caminho feliz real; conclusão tardia não é protegida | ⚠ UNSAFE FLOW |
| `DesignSystemGallery` | ação de cópia | chamada de `TechnicalValueRow` | `onCopy` hardcoded ausente | ✗ HOLLOW PROP |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|---|---|---|---|
| Análise estática | `C:\src\flutter\bin\flutter.bat analyze --no-pub` | `No issues found` | ✓ PASS |
| Suíte Flutter completa | `C:\src\flutter\bin\flutter.bat test --no-pub` | `+100: All tests passed!` | ✓ PASS |
| Golden comparisons | incluídas na suíte completa | 4 testes golden passaram | ✓ PASS |
| Rail de 5 destinos | inspeção de `app_shell.dart:24-39,229-265` | Não há teste médio/expanded; código mostra 3 + Ferramentas | ✗ FAIL |
| Semântica do catálogo | `rg semanticLabel lib/app` | somente declaração/inicialização; zero leitura no shell | ✗ FAIL |

### Probe Execution

Step 7c: **SKIPPED** — fase Flutter/UI sem probes declarados e nenhum `probe-*.sh` encontrado.

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|---|---|---|---|---|
| UI-01 | 01-01, 01-04, 01-05 | Abrir qualquer ferramenta em navegação clara compacta/larga | ✗ BLOCKED | Rail 5+ esconde destinos e troca ordem. |
| UI-02 | 01-01, 01-04, 01-05 | Bar/Rail/home conforme espaço e contrato | ✗ BLOCKED | Breakpoints existem, representação larga viola growth rule. |
| UI-03 | 01-03, 01-04, 01-05 | Hierarquia consistente em todas as ferramentas | → DEFERRED | Primitives existem só em test/gallery; adoção das 3 telas é explicitamente Phase 2. |
| UI-04 | 01-02, 01-04, 01-05 | Claro/escuro sem perda de contraste/significado | ✗ BLOCKED | Contraste genérico passa, mas anchors/shape/elevation aprovados não foram implementados nem revisados ao vivo. |
| UI-05 | 01-03, 01-04, 01-05 | Sete estados consistentes | ✗ BLOCKED | Seis estados divergem do UI-SPEC. |
| UI-06 | 01-02, 01-03, 01-04, 01-05 | Alvos acessíveis e leitor de tela | ✗ BLOCKED | 48 px parcial; semanticLabel descartado, gallery omite copy e TalkBack não executado. |
| UI-07 | 01-02, 01-03, 01-04, 01-05 | Fonte ampliada sem perda | ✗ BLOCKED | ToolMetric rígido; matriz não usa widgets reais; gate 200% não executado. |
| UI-08 | 01-01, 01-03, 01-04, 01-05 | Toda interface do ciclo em pt-BR | ✗ BLOCKED | Estados não canônicos e gallery/harness contêm `Status Panels`/título inglês. |
| UI-09 | 01-03, 01-04, 01-05 | Cópia consistente com confirmação acessível | ✗ BLOCKED | Lifecycle/ownership quebrados, callback morto, goldens/harness omitem copy. |

Todos os IDs UI-01..UI-09 aparecem em pelo menos um PLAN. Não há requisito adicional mapeado à Phase 1 em REQUIREMENTS.md que tenha ficado órfão de plano.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|---|---|---|---|---|
| `lib/app/app_shell.dart` | 24-39, 229-265 | Regra compacta reutilizada em rail | 🛑 Blocker | Destinos desaparecem em largura média/larga com 5+. |
| `lib/app/app_shell.dart` | 193-257 | Campo semântico declarado mas nunca usado | 🛑 Blocker | Leitor de tela recebe label visual longa/truncável, não o nome completo dedicado. |
| `lib/design_system/copy_value_action.dart` | 59-81 | async UI after await sem mounted + SnackBar global | 🛑 Blocker | Exceção após dispose e remoção de feedback alheio. |
| `lib/design_system/tool_status_panel.dart` | 31-66 | Teste e implementação compartilham copy incorreta | 🛑 Blocker | Estados públicos contradizem UI-SPEC. |
| `lib/theme/theme.dart` | 31-35, 79-82, 122-170 | Defaults aproximados em vez do contrato | ⚠ Warning | Goldens estabilizam uma aparência diferente da aprovada. |
| `lib/design_system/tool_sections.dart` | 99-117 | Row não flexível para conteúdo escalável | ⚠ Warning | Risco concreto de overflow horizontal em 360 px/2×. |
| `test/app/app_shell_test.dart` | 101,108,152,159 | Placeholder test-only | ℹ Info | Fixture deliberada; não flui para produção e não é stub. |

Não foram encontrados `TBD`, `FIXME` ou `XXX` sem issue formal nos arquivos da fase.

### Human Verification Required

Os itens abaixo continuam obrigatórios, mas devem ser executados **depois** da correção dos blockers automatizáveis.

#### 1. Breakpoints e chrome real

**Test:** Rodar o app e inspecionar 360/599, 600/720/839 e 840/1024.  
**Expected:** Bar apenas em compacta; rail recolhido/extended nas classes exatas; todos os destinos largos visíveis/roláveis; nada coberto.  
**Why human:** Densidade, clipping e superlotação percebida exigem inspeção visual.

#### 2. Preservação offline real

**Test:** Calcular uma rede, navegar para Armazenamento/Hash, voltar e cruzar 600/840.  
**Expected:** Inputs e resultado permanecem idênticos.  
**Why human:** Confirma o fluxo real no runtime, além do widget test.

#### 3. Claro/escuro

**Test:** Alternar tema do sistema.  
**Expected:** Texto neutro, accent verde reservado, estados/foco/erro/disabled/selected legíveis e superfícies estáticas sem sombra indevida.  
**Why human:** Hierarquia e dominância cromática são perceptivas.

#### 4. Fonte 200%

**Test:** Repetir navegação e galeria com escala de texto 200%.  
**Expected:** Sem overflow horizontal ou ellipsis essencial; tudo alcançável por scroll vertical.  
**Why human:** Alcance e compreensão não são totalmente inferíveis de grep/goldens.

#### 5. Harness Android com TalkBack

**Test:** Rodar `flutter run -t test/manual/design_system_app.dart -d {android-device-id}` e percorrer navegação → headings → campos → ações → sete estados → resultado/métrica → valor/cópia.  
**Expected:** Ordem compreensível e nenhum node essencial ausente.  
**Why human:** Leitor de tela real depende do Android/serviço assistivo.

#### 6. Anúncios e targets

**Test:** Confirmar destino selecionado, labels/erros, loading/disabled, estados, `Copiar {rótulo}` e exatamente um `{Rótulo} copiado`; tocar todos os icon buttons.  
**Expected:** Anúncios específicos sem duplicação e targets confortáveis.  
**Why human:** Sequência/duplicação dos anúncios e conforto de toque requerem dispositivo.

#### 7. Comparação visual ao vivo

**Test:** Comparar app/harness corrigidos com quatro PNGs revisados.  
**Expected:** Sem diferenças inexplicadas, clipping, overflow, bordas agressivas ou campos esticados.  
**Why human:** Aprovação visual não pode ser substituída por uma comparação que usa o próprio baseline não revisado.

### Gaps Summary

A fase não atingiu a meta. Os quatro blockers do `01-REVIEW.md` continuam presentes no código e viram blockers de goal/requirements nesta verificação; os seis warnings também permanecem, e quatro deles falham must-haves explícitos (tema exato, reflow, cobertura real e galeria completa). A suíte verde é necessária, mas não suficiente: seus fixtures evitam os caminhos com falha.

Além dos gaps de implementação, o guard de MVP está quebrado e o gate humano nunca ocorreu. A autoaprovação do checkpoint 01-05 por `--auto` é corretamente registrada no SUMMARY como encerramento de workflow, não como evidência de dispositivo, TalkBack ou aprovação visual. A Phase 2 não deve começar como se UI-01..UI-09 estivessem verificados.

---

_Verified: 2026-08-31T14:37:45.268Z_  
_Verifier: the agent (gsd-verifier)_
