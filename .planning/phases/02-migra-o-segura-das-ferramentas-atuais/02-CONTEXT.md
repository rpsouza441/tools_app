# Phase 2: Migração segura das ferramentas atuais - Context

**Gathered:** 2026-08-31
**Status:** Ready for planning
**Source:** User locked brief after Phase 1 formal close (verifier passed 25/25)

<domain>
## Phase Boundary

Migrar as três telas de produção — Rede (`NetworkCalculatorScreen`), Armazenamento (`DataConverterScreen`) e Hash (`HashGeneratorScreen`) — para a fundação da Phase 1 (`ToolScaffold`, seções, ações, resultados, métricas, `TechnicalValueRow`/cópia, hierarquia compartilhada, comportamento responsivo/acessível), **uma tela por vez**, preservando lógica, validação e resultados atuais.

Esta fase **não** inicia Diagnóstico de Internet (Phase 3 / DIAG-*), **não** adiciona funcionalidades novas às ferramentas, **não** reescreve o aplicativo e **não** altera o UI-SPEC visual da Phase 1.

</domain>

<decisions>
## Implementation Decisions

### Escopo travado
- **D-01:** Goal permanece exatamente: `Usuários continuam resolvendo as mesmas tarefas nas três ferramentas existentes depois da migração para a nova fundação visual.`
- **D-02:** Requirements desta fase são somente PRES-01, PRES-02, PRES-03 e PRES-04. DIAG-* e SPD-* ficam fora.
- **D-03:** Migrar as três telas reais em `lib/screen/`: Rede, Armazenamento e Hash. Não criar telas paralelas nem novo router.
- **D-04:** Incremental: uma tela por vez, com testes verdes entre incrementos. PRES-04 exige que as outras duas continuem utilizáveis enquanto uma migra.

### Fundação a adotar (quando aplicável)
- **D-05:** Adotar `ToolScaffold`, sections, action group, result/metric/copy, `TechnicalValueRow`/`CopyValueAction`, hierarquia visual compartilhada e layout responsivo/acessível do UI-SPEC da Phase 1.
- **D-06:** Substituir anatomia local divergente (Scaffold próprio com padding 16, cards locais, rows rígidas, `Clipboard.setData` direto, cores/radius locais) pelas primitives já existentes em `lib/design_system/`.
- **D-07:** Consolidar CTAs para o contrato do UI-SPEC: “Calcular rede”, “Analisar capacidade”, “Gerar hashes”. “Calcular” isolado não é permitido. Isso **não** muda resultados.
- **D-08:** Feedback de cópia das telas de produção deve usar `CopyValueAction`/`ClipboardCopyWriter` (SnackBar próprio, `mounted`), não `Clipboard.setData` + SnackBar local.

### Preservação (não negociável)
- **D-09:** Preservar toda a lógica e resultados atuais. Não alterar `NetworkCalculator`, `DataConverter`, `HashCalculator`, validadores, fórmulas, unidades, algoritmos MD5/SHA-1/SHA-256/SHA-512 nem strings de resultado que os testes já afirmam.
- **D-10:** Preservar testes existentes (`test/network_calculator_test.dart`, `test/data_converter_test.dart`, `test/hash_calculator_test.dart`, happy path de `test/app/app_shell_test.dart`). Se um seletor de widget mudar (ex.: `find.text('Calcular')` → `Calcular rede`), atualizar o seletor; o valor calculado deve continuar idêntico (`Endereço de Rede: 192.168.1.0` no happy path).
- **D-11:** Manter pt-BR, Material 3, temas claro/escuro. Não adicionar pacote, fonte remota, form builder, framework de estado, persistência, analytics ou permissão.
- **D-12:** Não executar a Phase 2 neste ciclo de planejamento. Não tocar em `pubspec.lock-old`.

### Estratégia de regressão
- **D-13:** A prova de ausência de regressão é: (1) suíte unitária de serviços inalterada em asserts de valor; (2) widget tests por tela migrada cobrindo happy path + erros de validação já existentes; (3) happy path do AppShell continua passando após cada incremento; (4) `flutter analyze --no-pub` limpo; (5) goldens da fundação em `test/design_system/goldens/` não são reescritos salvo se um widget compartilhado mudar — e PNG novo não conta como aprovação visual das telas de produção.
- **D-14:** Ordem sugerida (pesquisador/planner podem confirmar): Rede (já tem happy path no AppShell) → Armazenamento → Hash (cópia local mais divergente) → plano transversal PRES-04/a11y se ainda restar wiring compartilhado. Waves devem impedir duas telas em paralelo no mesmo isolate de UI se isso quebrar PRES-04.

### Claude's Discretion
- Nomes de arquivos de teste de widget por tela e granularidade exata dos planos, desde que PRES-01..PRES-04 apareçam no `requirements` de algum plano e os planos sejam pequenos e executáveis.
- Como fatiar estados (vazio/erro/sucesso) em cada tela sem inventar estados de rede/diagnóstico.
- Se Hash deve migrar copy antes ou junto da anatomia, desde que o resultado dos hashes não mude.

</decisions>

<specifics>
## Specific Ideas

- UI-SPEC Phase 2 owns: adotar primitives nas três telas, uma por vez; substituir cores/radius/rows/copy local divergentes; preservar IPv4, conversão e hashes com testes de regressão; consolidar CTAs sem mudar resultados.
- Copy de Hash hoje: `Clipboard.setData` + SnackBar `'${result.algorithm} copiado'`. Após migração: `CopyValueAction` com confirmação `{Rótulo} copiado` do contrato da Phase 1, sem mudar o valor copiado.
- Erros de Rede atuais a preservar: `Formato de IP inválido (ex: 192.168.1.1).`, `Insira uma máscara de sub-rede ou um CIDR.`, `Máscara de sub-rede inválida.`, `Valor de CIDR inválido (0-32).`
- Happy path existente: IP `192.168.1.10` + CIDR `24` → `Endereço de Rede: 192.168.1.0`.

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Contratos
- `.planning/ROADMAP.md` — Goal, Mode mvp, Success Criteria e PRES-01..PRES-04 da Phase 2.
- `.planning/REQUIREMENTS.md` — texto canônico de PRES-01..PRES-04.
- `.planning/phases/01-contrato-visual-e-funda-o-adaptativa/01-UI-SPEC.md` — contrato visual; seção “Phase 2 owns”; CTAs; anatomia ToolScaffold.
- `.planning/phases/02-migra-o-segura-das-ferramentas-atuais/02-UI-SPEC.md` — adendo de adoção (sem nova linguagem visual).
- `.planning/PROJECT.md` — constraints: Flutter/M3, Android-first, pt-BR, sem reescrita.

### Fundação já entregue
- `lib/design_system/tool_scaffold.dart`
- `lib/design_system/tool_sections.dart`
- `lib/design_system/tool_status_panel.dart`
- `lib/design_system/copy_value_action.dart`
- `lib/app/app_shell.dart` — IndexedStack; não rearquitetar navegação.

### Telas e lógica a preservar
- `lib/screen/network_calculator_screen.dart`
- `lib/screen/data_converter_screen.dart`
- `lib/screen/hash_generator_screen.dart`
- `lib/service/network_calculator.dart`, `lib/utils/network_utils.dart`
- `lib/service/data_converter.dart`, `lib/model/analysis_result.dart`
- `lib/service/hash_calculator.dart`

### Testes de regressão existentes
- `test/network_calculator_test.dart`
- `test/data_converter_test.dart`
- `test/hash_calculator_test.dart`
- `test/app/app_shell_test.dart` (grupo Happy path — real App integration)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `ToolScaffold` + sections + `ToolStatusPanel` + `CopyValueAction` já testados na Phase 1; as telas ainda usam `Scaffold`+`AppBar`+`Card` locais.
- `ClipboardCopyWriter` é o writer de produção; a galeria já o usa.

### Established Patterns
- Screens `StatefulWidget` delegam cálculo a serviços síncronos. Não há isolate, Dio nem lifecycle de diagnóstico nestas três telas.
- AppShell já monta as três screens no IndexedStack; a migração é interna a cada screen.

### Integration Points
- `lib/main.dart` → `AppShell(destinations: appDestinations)` — não mudar o catálogo nesta fase salvo se um título de AppBar/CTA exigir ajuste de teste.
- Happy path do AppShell encontra `find.text('Calcular')` — deve ser atualizado no mesmo plano que migrar a tela Rede.

### Constraints
- Não modificar resultados numéricos/strings de serviço.
- Não iniciar Phase 3.
- Não tocar `pubspec.lock-old`.

</code_context>

<deferred>
## Deferred Ideas

- Diagnóstico de Internet (DIAG-01..DIAG-15) — Phase 3.
- Speed test (SPD-*) e EVO-* — v2 / Phase 5.
- Qualquer feature nova nas três ferramentas.
- Reescrita do app, novo pacote, novo router, form builder.

</deferred>

---

*Phase: 02-migra-o-segura-das-ferramentas-atuais*
*Context gathered: 2026-08-31 via user locked brief after Phase 1 close*
