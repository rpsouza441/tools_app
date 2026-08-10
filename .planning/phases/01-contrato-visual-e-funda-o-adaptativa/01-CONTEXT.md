# Phase 1: Contrato visual e fundação adaptativa - Context

**Gathered:** 2026-08-10
**Status:** Ready for planning

<domain>
## Phase Boundary

Definir o UI-SPEC do aplicativo e entregar a fundação visual compartilhada: catálogo de destinos, shell adaptativo, temas legíveis e primitives acessíveis para entradas, ações, estados, resultados, métricas e cópia. A migração funcional completa das três ferramentas pertence à Phase 2; o diagnóstico de Internet pertence à Phase 3.

</domain>

<decisions>
## Implementation Decisions

### Estrutura de navegação
- **D-01:** Manter uma única fonte de verdade tipada para destinos, rótulos e ícones; o shell e qualquer seletor de ferramentas consomem esse catálogo em vez de listas paralelas em `main.dart`.
- **D-02:** Em largura compacta, usar Material 3 `NavigationBar` enquanto os destinos principais couberem claramente; em largura ampla, usar `NavigationRail` com conteúdo ao lado.
- **D-03:** O shell deve estar preparado para crescimento: se a quantidade ultrapassar a capacidade clara da barra compacta, o UI-SPEC define home/catálogo ou overflow sem exigir nova arquitetura de rotas.
- **D-04:** Preservar estado de cada destino durante trocas de navegação quando isso não mantiver operações externas ativas; lifecycle de diagnósticos será definido na Phase 3.

### Identidade visual técnica
- **D-05:** Preservar o verde “Matrix” como acento reconhecível, não como cor de todo o texto. Superfícies e texto usam neutros de alto contraste nos temas claro e escuro.
- **D-06:** Reservar tipografia monoespaçada para hashes, endereços, unidades e outras saídas técnicas; títulos, rótulos e explicações usam a família sans-serif do tema.
- **D-07:** A hierarquia depende primeiro de tamanho, peso, espaçamento e superfície; cor nunca é o único indicador de estado.
- **D-08:** Tema claro e escuro compartilham papéis semânticos de cor e componentes, com contraste verificado em estados normais, desabilitados, erro e foco.

### Anatomia das ferramentas
- **D-09:** Evoluir por primitives pequenas, composáveis e adotáveis tela a tela; não criar form builder genérico nem reescrever as screens nesta fase.
- **D-10:** A base deve oferecer um `ToolScaffold`/container equivalente, largura de conteúdo controlada, seção de entrada, grupo de ações, card de resultado, linha/chip de métrica, apresentação de estado e ação de copiar.
- **D-11:** Entradas ficam antes das ações, resultados aparecem depois da ação e explicações secundárias usam hierarquia mais discreta; valores técnicos permanecem selecionáveis quando apropriado.
- **D-12:** Estados são explícitos e não reutilizam números falsos: vazio explica a próxima ação; carregando mantém contexto; sucesso mostra dados; falha preserva conteúdo seguro; cancelado é distinto de erro.
- **D-13:** Feedback de cópia usa confirmação breve e anunciável por leitor de tela; erros de campo ficam inline e falhas gerais aparecem próximas ao contexto afetado.

### Responsividade e acessibilidade
- **D-14:** Layout responde ao espaço disponível, não ao tipo nominal de device. O UI-SPEC usa faixas compacta, média e expandida como contrato, com limiares iniciais de 600 e 840 logical pixels sujeitos apenas a validação visual.
- **D-15:** Conteúdo de formulários recebe largura máxima legível e padding progressivo; telas largas não esticam campos e linhas técnicas indefinidamente.
- **D-16:** Alvos interativos atendem pelo menos 48x48 logical pixels no Android; ações possuem tooltip/rótulo semântico quando o ícone sozinho não é suficiente.
- **D-17:** Escala de fonte grande pode aumentar a altura e empilhar ações; truncamento de informação essencial e overflow horizontal não são aceitos.
- **D-18:** Critérios visuais centrais são protegidos por widget tests e goldens enxutos para temas e larguras representativas, sem tentar congelar cada tela inteira.

### the agent's Discretion
- Nomes finais dos widgets e organização exata de arquivos, desde que as boundaries acima permaneçam claras.
- Valores finais de radius, elevation, spacing scale e largura máxima após renderização/validação do UI-SPEC.
- Estratégia de roteamento interna mais simples compatível com o catálogo tipado e preservação de estado.
- Seleção dos poucos goldens de maior valor e tolerâncias adequadas ao ambiente de teste.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Escopo e contratos
- `planning/GSD_NETWORK_AND_UI_BRIEF.md` — briefing original, entregáveis da fundação visual, estados, acessibilidade e restrição contra reescrita total.
- `.planning/PROJECT.md` — core value, constraints e decisões de arquitetura do milestone.
- `.planning/REQUIREMENTS.md` — requisitos UI-01 a UI-09 atribuídos a esta fase e Definition of Done global.
- `.planning/ROADMAP.md` — boundary, dependências e success criteria oficiais da Phase 1.

### Pesquisa
- `.planning/research/SUMMARY.md` — recomendações consolidadas de stack, arquitetura, features, pitfalls e ordem de construção.
- `.planning/research/STACK.md` — baseline Flutter/Material 3 e compatibilidade do toolchain existente.
- `.planning/research/ARCHITECTURE.md` — AppShell, design system incremental e estratégia de proteção contra regressões.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `lib/theme/theme.dart`: já centraliza `ThemeData`, ColorScheme, texto, botões e inputs; deve evoluir para papéis semânticos e contraste consistente, preservando o verde como acento.
- `lib/screen/hash_generator_screen.dart`: contém padrões úteis de resumo, metric chips, resultados selecionáveis e cópia com feedback; extrair apenas depois de estabilizar a API compartilhada.
- `lib/screen/data_converter_screen.dart`: demonstra cards de entrada/resultado/explicação e separação da lógica em service/model.
- `lib/screen/network_calculator_screen.dart`: já usa `LayoutBuilder`, largura ampla e ações com altura mínima, oferecendo casos reais para validar primitives responsivas.

### Established Patterns
- Flutter Material 3 com temas claro/escuro e screens `StatefulWidget` que delegam cálculo a serviços.
- Layouts com `SingleChildScrollView`, padding de 16 e cards locais; a fase deve sistematizar esses padrões sem introduzir novo framework de estado.
- Ações e resultados ainda variam entre containers, cards, botões e strings; a fundação deve unificar sem mudar a lógica funcional neste momento.

### Integration Points
- `lib/main.dart`: substituição da lista `_screens` + `BottomNavigationBar` por catálogo de destinos e shell adaptativo.
- `lib/theme/theme.dart`: tokens, componentes e papéis de cor dos dois temas.
- `lib/screen/*.dart`: consumidores graduais das primitives; a adoção completa fica na Phase 2.
- `test/`: widget/golden tests da fundação e regressões do shell.

</code_context>

<specifics>
## Specific Ideas

- A identidade deve continuar parecendo uma ferramenta técnica, mas sem texto neon dominante no tema escuro.
- Dados como IPs, hashes e unidades podem usar monospace; conteúdo explicativo permanece em sans-serif legível.
- A arquitetura visual deve comportar o futuro destino “Diagnóstico de Internet” sem redesenhar o shell.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 1-Contrato visual e fundação adaptativa*
*Context gathered: 2026-08-10*
