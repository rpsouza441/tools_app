# Phase 01: Contrato visual e fundação adaptativa - Research

**Researched:** 2026-08-10
**Domain:** Flutter Material 3, design system incremental, layout adaptativo e acessibilidade
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

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

### Deferred Ideas (OUT OF SCOPE)

None — discussion stayed within phase scope.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| UI-01 | Usuário pode abrir qualquer ferramenta por uma arquitetura de navegação que permaneça clara em largura compacta e larga. | Catálogo tipado único, `AppShell`, `NavigationBar`/`NavigationRail`, preservação por `IndexedStack` e testes de seleção/boundary. [VERIFIED: codebase grep] [CITED: https://docs.flutter.dev/ui/adaptive-responsive/general] |
| UI-02 | Usuário recebe NavigationBar, NavigationRail ou home categorizada conforme o espaço disponível e o design contract aprovado. | Classes `<600`, `600..<840` e `>=840`, medidas por constraints; barra compacta e rail nas demais faixas. [VERIFIED: codebase grep] [CITED: https://docs.flutter.dev/ui/adaptive-responsive/general] |
| UI-03 | Usuário encontra hierarquia consistente de títulos, entradas, ações, cards e resultados em todas as ferramentas. | UI-SPEC obrigatório e primitives pequenas (`ToolScaffold`, seções, ações, resultado e métrica), criadas sem migrar integralmente as telas. [VERIFIED: codebase grep] |
| UI-04 | Usuário pode usar o aplicativo nos temas claro e escuro sem perda de contraste ou significado. | `ColorScheme.fromSeed`, papéis semânticos, temas de componentes e testes `textContrastGuideline`/goldens claro-escuro. [CITED: https://api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html] [CITED: https://docs.flutter.dev/ui/accessibility/accessibility-testing] |
| UI-05 | Usuário identifica estados vazio, carregando, sucesso, falha, sem conexão, permissão negada e operação cancelada por componentes consistentes. | Modelo fechado de estado visual e galeria/testes para todas as variantes, com ícone+título+texto e sem números sentinela. [VERIFIED: codebase grep] |
| UI-06 | Usuário pode tocar ações por alvos de tamanho acessível e navegar com leitores de tela por rótulos semânticos úteis. | `MaterialTapTargetSize.padded`, mínimo 48x48, tooltips/rótulos e Accessibility Guideline API. [CITED: https://docs.flutter.dev/ui/accessibility] [CITED: https://docs.flutter.dev/ui/accessibility/accessibility-testing] |
| UI-07 | Usuário pode ampliar a fonte sem perder conteúdo, ações ou compreensão em larguras compactas e largas. | `TextScaler`, `Wrap`/empilhamento, scroll vertical e matriz de testes em escala 1.0 e 2.0 nas três faixas. [CITED: https://api.flutter.dev/flutter/painting/TextScaler-class.html] |
| UI-08 | Usuário recebe toda a interface e mensagens do ciclo em português do Brasil. | Catálogo e primitives recebem copy pt-BR; o único título visível em inglês encontrado (`Network Calculator`) exige correção cirúrgica nesta fase. [VERIFIED: codebase grep] |
| UI-09 | Usuário pode copiar valores e resultados por uma ação consistente com confirmação acessível. | `CopyValueAction` compartilhada, `SelectableText` para valores técnicos e `SnackBar`/live region para confirmação. [VERIFIED: codebase grep] [CITED: https://api.flutter.dev/flutter/semantics/SemanticsProperties/liveRegion.html] |
</phase_requirements>

## Summary

A fase deve começar pelo `01-UI-SPEC.md`, porque o estado do projeto registra o contrato visual como pré-requisito para planejamento executável. O contrato precisa fechar: faixas de largura, comportamento da navegação, tokens, anatomia das primitives, matriz de estados, copy pt-BR, regras de foco/semântica/text scale e os poucos checkpoints visuais que serão congelados. A implementação vem depois e deve deixar `main.dart` como bootstrap, sem mover serviços nem reescrever as três screens. [VERIFIED: codebase grep]

A recomendação é usar somente Flutter/Material 3 já presentes: catálogo tipado, `LayoutBuilder`, `NavigationBar`, `NavigationRail`, `IndexedStack`, `ColorScheme`, `ThemeData`, `Semantics`, `ScaffoldMessenger` e `flutter_test`. A orientação oficial recomenda abstrair dados comuns, medir o espaço disponível e então ramificar; ela também cita barra inferior abaixo de 600 logical pixels e rail a partir de 600, alinhando-se ao limiar já decidido. [CITED: https://docs.flutter.dev/ui/adaptive-responsive/general]

O maior risco é confundir “fundação pronta” com “migração concluída”. A Fase 1 deve integrar apenas o shell e expor primitives em uma galeria/harness testável; a adoção completa nas telas é Fase 2. Alterações cirúrgicas indispensáveis à aceitação — como o título inglês atual e a troca de navegação Material 2 por Material 3 — cabem aqui sem tocar na lógica de cálculo. [VERIFIED: codebase grep]

**Primary recommendation:** produzir e aprovar `01-UI-SPEC.md`; depois implementar catálogo + shell + temas + primitives como APIs estáveis, protegidas por testes de widget/semântica/boundary e quatro goldens de alto valor. [VERIFIED: codebase grep]

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| UI-SPEC e tokens | Browser / Client (Flutter) | — | O contrato governa apresentação local; não existe backend ou persistência neste projeto. [VERIFIED: codebase grep] |
| Catálogo de destinos | Browser / Client (Flutter) | — | Rótulos, ícones, ordem e factories de telas pertencem ao shell local. [VERIFIED: codebase grep] |
| Navegação adaptativa | Browser / Client (Flutter) | — | A decisão depende das constraints do espaço entregue ao widget. [CITED: https://docs.flutter.dev/ui/adaptive-responsive/general] |
| Preservação de estado dos destinos atuais | Browser / Client (Flutter) | — | `IndexedStack` mantém o estado dos filhos e mostra um por índice. [CITED: https://api.flutter.dev/flutter/widgets/IndexedStack-class.html] |
| Temas claro/escuro | Browser / Client (Flutter) | Plataforma Android | `MaterialApp` escolhe `theme`/`darkTheme`; preferências de brilho vêm da plataforma quando `themeMode` usa o sistema. [CITED: https://api.flutter.dev/flutter/material/MaterialApp/theme.html] |
| Semântica, foco e alvos de toque | Browser / Client (Flutter) | Serviços de acessibilidade Android | Widgets Material produzem a árvore semântica consumida pelo leitor de tela; testes verificam labels, contraste e targets. [CITED: https://docs.flutter.dev/ui/accessibility/accessibility-testing] |
| Cópia e confirmação | Browser / Client (Flutter) | Clipboard e acessibilidade do SO | A primitive escreve no clipboard e apresenta confirmação anunciável; `SnackBar` é exemplo oficial de live region. [CITED: https://api.flutter.dev/flutter/semantics/SemanticsProperties/liveRegion.html] |

## Project Constraints (from AGENTS.md)

- Manter Flutter e Material 3; preservar a base existente e evitar reescrita. [VERIFIED: codebase grep]
- Ser Android-first; capacidades de outras plataformas devem ser verificadas e honestamente limitadas. [VERIFIED: codebase grep]
- Manter toda a interface em português do Brasil. [VERIFIED: codebase grep]
- Manter futuras capacidades de IP público, gateway, probes e speed test atrás de interfaces independentes; esta fase não implementa nenhuma delas. [VERIFIED: codebase grep]
- Não bloquear a isolate principal nem executar shell pela UI. [VERIFIED: codebase grep]
- Tratar lifecycle Android, cancelamento e resultados tardios nas fases que introduzirem I/O; o shell desta fase não deve esconder esse futuro boundary. [VERIFIED: codebase grep]
- Toda operação externa futura terá timeout e cancelamento; esta fase não adiciona operação externa de produto. [VERIFIED: codebase grep]
- Não enviar identificadores nem resultados a analytics. [VERIFIED: codebase grep]
- Evitar localização sem necessidade comprovada de SSID/BSSID. [VERIFIED: codebase grep]
- Preservar funcionalidades e testes existentes; adicionar testes unitários, de widget e goldens centrais quando úteis. [VERIFIED: codebase grep]
- Alterações no repositório devem continuar pelo fluxo GSD já iniciado pelo `$gsd-plan-phase`. [VERIFIED: codebase grep]

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Flutter + Material 3 | 3.44.0 stable | App shell, tema, layout e semantics | Já instalado e adotado com `useMaterial3: true`; a documentação oficial consultada reflete Flutter 3.44.7 e é compatível com a linha 3.44. [VERIFIED: local SDK metadata] [CITED: https://docs.flutter.dev/ui/adaptive-responsive/general] |
| Dart | 3.12.0 | Modelos tipados de destino/estado e código de apresentação | SDK instalado no checkout local e compatível com o `sdk: ^3.8.1` do projeto. [VERIFIED: local SDK metadata] [VERIFIED: codebase grep] |
| `flutter_test` | SDK Flutter 3.44.0 | Widget, semantics, accessibility guideline e golden tests | Já declarado em `dev_dependencies`; não exige pacote adicional. [VERIFIED: codebase grep] [CITED: https://docs.flutter.dev/cookbook/testing/widget/introduction] |

### Supporting

| Library/API | Version | Purpose | When to Use |
|-------------|---------|---------|-------------|
| `LayoutBuilder` | Flutter SDK | Classificar a largura efetivamente oferecida ao shell/componente | Use no shell e em primitives cujo comportamento depende da constraint local. [CITED: https://docs.flutter.dev/ui/adaptive-responsive/general] |
| `MediaQuery.textScalerOf` / `TextScaler` | Flutter SDK | Respeitar e testar escala de texto | Nunca fixe/clamp a escala na aplicação; use `TextScaler.linear` apenas no harness de teste. [CITED: https://api.flutter.dev/flutter/widgets/MediaQueryData/textScaler.html] [CITED: https://api.flutter.dev/flutter/painting/TextScaler/TextScaler.linear.html] |
| `IndexedStack` | Flutter SDK | Preservar estado das três ferramentas offline durante trocas | Use agora para os destinos existentes; Fase 3 precisa cancelar I/O quando o destino de diagnóstico ficar oculto. [CITED: https://api.flutter.dev/flutter/widgets/IndexedStack-class.html] [VERIFIED: codebase grep] |
| `ThemeExtension` | Flutter SDK | Tokens próprios que não cabem em `ColorScheme`/component themes | Use somente para spacing/radius/max-width; cores comuns ficam em `ColorScheme`. [CITED: https://api.flutter.dev/flutter/material/ThemeExtension-class.html] |
| `ScaffoldMessenger` + `SnackBar` | Flutter SDK | Confirmação breve de cópia | Use como feedback visual e live region; não faça anúncio manual duplicado. [CITED: https://api.flutter.dev/flutter/semantics/SemanticsProperties/liveRegion.html] |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `LayoutBuilder` + constantes locais | pacote de responsividade | Não há capacidade ausente que justifique dependência; pacote ampliaria superfície e não substitui validação visual. [CITED: https://docs.flutter.dev/ui/adaptive-responsive/general] |
| índice local + `IndexedStack` | Router/Navigator aninhado | Rotas profundas não são requisito; router acrescentaria estado e testes sem benefício nesta fase. [VERIFIED: codebase grep] |
| `ColorScheme` + component themes | cores hard-coded em widgets | Cores locais repetem o problema atual e impedem papéis consistentes nos dois temas. [VERIFIED: codebase grep] [CITED: https://api.flutter.dev/flutter/material/ThemeData-class.html] |
| Sans padrão Material | `GoogleFonts.latoTextTheme()` com download em runtime | O pacote existente suporta download/caching; para offline determinístico seria necessário bundle. Nesta fase, use a tipografia Material do SDK; se o UI-SPEC insistir em Lato, bundle arquivos/licença e desabilite runtime fetching antes de depender dela. [CITED: https://pub.dev/packages/google_fonts/versions/7.1.0] |

**Installation:** nenhuma. Não adicionar pacote externo nesta fase. [VERIFIED: codebase grep]

**Version verification:** Flutter 3.44.0 e Dart 3.12.0 foram confirmados em `C:\src\flutter\bin\cache\flutter.version.json`; `flutter_test` vem do mesmo SDK. [VERIFIED: local SDK metadata]

## Package Legitimacy Audit

Não aplicável: a recomendação não instala packages. `flutter`, Material e `flutter_test` vêm do SDK; dependências já existentes não precisam ser atualizadas para a Fase 1. [VERIFIED: codebase grep]

## Architecture Patterns

### System Architecture Diagram

```text
runApp
  ↓
ToolsApp (MaterialApp: lightTheme / darkTheme / pt-BR)
  ↓
AppShell ── reads available width ──┬─ < 600  → NavigationBar
  │                                ├─ 600–839 → NavigationRail + content
  │                                └─ ≥ 840   → extended NavigationRail + constrained content
  │
  ├─ consumes exactly one typed AppDestination catalog
  │      └─ id + pt-BR label + icon + selected icon + page factory
  │
  └─ selected index → IndexedStack
           ├─ NetworkCalculatorScreen (existing, retained)
           ├─ DataConverterScreen (existing, retained)
           └─ HashGeneratorScreen (existing, retained)

Design system foundation
  ├─ ThemeData / ColorScheme / component themes / AppTokens
  ├─ ToolScaffold + sections + action group
  ├─ ToolStatusPanel (empty/loading/success/error/offline/permission/cancelled)
  ├─ ToolResultCard + ToolMetric
  └─ CopyValueAction → Clipboard → SnackBar live region
```

O fluxo é totalmente local e não cria serviço, banco de dados ou persistência. [VERIFIED: codebase grep]

### Recommended Project Structure

```text
.planning/phases/01-contrato-visual-e-funda-o-adaptativa/
├── 01-CONTEXT.md
├── 01-UI-SPEC.md                 # contrato aprovado antes da implementação
└── 01-RESEARCH.md

lib/
├── main.dart                     # bootstrap: runApp apenas
├── app/
│   ├── tools_app.dart            # MaterialApp, temas, locale e shell
│   ├── app_destination.dart      # tipo imutável do destino
│   ├── app_destinations.dart     # única lista concreta; importa screens existentes
│   └── app_shell.dart            # width class, NavigationBar/Rail, IndexedStack
├── design_system/
│   ├── app_breakpoints.dart      # 600/840 e classificação central
│   ├── app_tokens.dart           # ThemeExtension só para spacing/radius/max width
│   ├── tool_scaffold.dart
│   ├── tool_sections.dart        # input/actions/result/metric primitives pequenas
│   ├── tool_status_panel.dart
│   └── copy_value_action.dart
├── theme/
│   └── theme.dart                # evolui o ponto de entrada atual; sem arquivo rival
├── screen/                       # não mover nem reescrever na Fase 1
├── service/                      # intocado
└── model/                        # intocado

test/
├── app/
│   ├── app_shell_test.dart
│   └── destination_catalog_test.dart
├── design_system/
│   ├── tool_components_test.dart
│   ├── accessibility_test.dart
│   └── design_system_golden_test.dart
├── goldens/                      # quatro baselines controladas
└── *_calculator_test.dart        # testes existentes preservados
```

Essa estrutura cria boundaries novas sem mover as telas, serviços ou testes unitários existentes. [VERIFIED: codebase grep]

### Pattern 1: Catálogo tipado único

**What:** cada destino fornece identidade, copy e construção de página; o shell deriva `NavigationDestination` e `NavigationRailDestination` da mesma lista. [VERIFIED: codebase grep]

**When to use:** em toda navegação primária e em qualquer futura home/catálogo. [VERIFIED: codebase grep]

**Example:**

```dart
// Sources:
// https://api.flutter.dev/flutter/material/NavigationBar-class.html
// https://api.flutter.dev/flutter/material/NavigationRail-class.html
@immutable
class AppDestination {
  const AppDestination({
    required this.id,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.pageBuilder,
  });

  final String id;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final WidgetBuilder pageBuilder;
}
```

Não armazene uma segunda lista de páginas em `main.dart`; materialize as páginas uma vez a partir do catálogo no estado do shell. [VERIFIED: codebase grep]

### Pattern 2: Abstract → Measure → Branch

**What:** compartilhar o catálogo, medir constraints e escolher apenas a representação da navegação. [CITED: https://docs.flutter.dev/ui/adaptive-responsive/general]

**When to use:** no shell e em componentes locais que realmente mudam anatomia por largura. [CITED: https://docs.flutter.dev/ui/adaptive-responsive/general]

**Contract:** `compact < 600`, `medium >= 600 && < 840`, `expanded >= 840`; em 600 e 840 o teste deve provar a transição exata. [VERIFIED: codebase grep]

### Pattern 3: Estado preservado com boundary explícito de atividade

**What:** usar `IndexedStack` para as três ferramentas offline atuais. [CITED: https://api.flutter.dev/flutter/widgets/IndexedStack-class.html]

**When to use:** enquanto as telas não possuem operações externas ativas; a futura tela de diagnóstico deve receber evento de visibilidade/cancelar seu run na Fase 3, porque filhos offstage não são descartados. [VERIFIED: codebase grep]

### Pattern 4: Tema semântico primeiro

**What:** gerar `ColorScheme` claro/escuro pelo mesmo seed verde, não sobrescrever `onSurface` com verde, e configurar `NavigationBarThemeData`, `NavigationRailThemeData`, `CardThemeData`, buttons, inputs, chips, SnackBar, focus e disabled pelos papéis do esquema. [CITED: https://api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html] [CITED: https://api.flutter.dev/flutter/material/ThemeData-class.html]

**When to use:** em toda primitive e, na Fase 2, nas telas migradas. [VERIFIED: codebase grep]

### Pattern 5: Primitive visual sem lógica de feature

**What:** widgets recebem children/modelos de apresentação; validação, cálculo e copy específica continuam na feature. [VERIFIED: codebase grep]

**When to use:** `ToolScaffold`, seção de input, ações, status, resultado, métrica e cópia. [VERIFIED: codebase grep]

### Anti-Patterns to Avoid

- **Listas paralelas de telas/labels/ícones:** divergem ao adicionar destino; derivar tudo do catálogo. [VERIFIED: codebase grep]
- **Checar `Platform.isAndroid`, orientação ou “tablet”:** o layout deve reagir à largura disponível. [CITED: https://docs.flutter.dev/ui/adaptive-responsive/general]
- **`Row` rígida para ações:** a implementação atual pode estourar com fonte grande; usar `Wrap`/`OverflowBar` ou trocar para coluna quando faltar espaço. [VERIFIED: codebase grep]
- **Verde como `onSurface`:** transforma todo texto em acento e elimina hierarquia; manter neutros no texto base. [VERIFIED: codebase grep]
- **Form builder universal:** transforma variações reais em parâmetros e adia a migração; manter primitives estruturais pequenas. [VERIFIED: codebase grep]
- **Anúncio duplicado de cópia:** `SnackBar` já é live region; não disparar `SemanticsService.announce` junto. [CITED: https://api.flutter.dev/flutter/semantics/SemanticsProperties/liveRegion.html]
- **Golden de tela inteira para cada combinação:** congela detalhes das screens que serão migradas na Fase 2; testar shell e galeria das primitives. [VERIFIED: codebase grep]

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Breakpoints adaptativos | detector de device/orientation ou pacote de “screen size” | `LayoutBuilder` + `AppBreakpoints` | Constraints representam o espaço real do widget. [CITED: https://docs.flutter.dev/ui/adaptive-responsive/general] |
| Navegação M3 | barra custom desenhada | `NavigationBar` e `NavigationRail` | Widgets oficiais já integram seleção, tema e semantics. [CITED: https://api.flutter.dev/flutter/material/NavigationBar-class.html] [CITED: https://api.flutter.dev/flutter/material/NavigationRail-class.html] |
| Paleta claro/escuro | cálculo manual de tons/contraste | `ColorScheme.fromSeed` + guideline tests | O construtor gera papéis tonais projetados para funcionar juntos; testes verificam o resultado real. [CITED: https://api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html] |
| Accessibility audit | inspeção visual como única prova | Accessibility Guideline API + semantics matchers + TalkBack manual | A API verifica targets, labels e contraste; leitor real cobre ordem e compreensão. [CITED: https://docs.flutter.dev/ui/accessibility/accessibility-testing] |
| Golden framework | comparador de PNG próprio | `matchesGoldenFile` | `flutter_test` já gera/atualiza/compara baselines. [CITED: https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html] |
| Copy feedback | overlay/toast próprio | `ScaffoldMessenger` + `SnackBar` | Feedback padrão é transitório e anunciado como live region. [CITED: https://api.flutter.dev/flutter/semantics/SemanticsProperties/liveRegion.html] |
| Estado genérico de formulário | schema/form builder | validação existente + primitives visuais | Cada ferramenta tem regras próprias e a fase proíbe reescrita. [VERIFIED: codebase grep] |

**Key insight:** Flutter já fornece os mecanismos difíceis desta fase; o trabalho específico do produto é fechar o contrato visual e compor esses mecanismos em boundaries estáveis. [CITED: https://docs.flutter.dev/ui/adaptive-responsive/general]

## Runtime State Inventory

Embora não haja rename de produto, a fase refatora shell e tema; a auditoria explícita confirma que não existe estado runtime a migrar. [VERIFIED: codebase grep]

| Category | Items Found | Action Required |
|----------|-------------|------------------|
| Stored data | Nenhum banco, preferences ou package de persistência detectado. [VERIFIED: codebase grep] | Nenhuma migração de dados. |
| Live service config | Nenhum backend ou serviço externo faz parte da Fase 1. [VERIFIED: codebase grep] | Nenhuma alteração fora do git. |
| OS-registered state | Nenhum registro de SO relacionado ao shell/tema foi encontrado ou é exigido. [VERIFIED: codebase grep] | Nenhuma ação. |
| Secrets/env vars | Nenhum `.env`, secret ou variável necessária ao shell/tema foi detectado. [VERIFIED: codebase grep] | Nenhuma ação. |
| Build artifacts | `.dart_tool/`, `build/` e registrants gerados existem, mas não carregam estado visual a migrar. [VERIFIED: codebase grep] | Não editar manualmente; rebuild normal se a execução alterar outputs. |

## Common Pitfalls

### Pitfall 1: Aprovar o código antes do UI-SPEC

**What goes wrong:** tokens e componentes viram decisões ad hoc e o planner não consegue verificar a intenção visual. [VERIFIED: codebase grep]

**Why it happens:** a implementação atual já contém números e cores locais que parecem um ponto de partida conveniente. [VERIFIED: codebase grep]

**How to avoid:** primeiro criar/aprovar `01-UI-SPEC.md` com matrizes de largura, tema, estado e acessibilidade; só então implementar. [VERIFIED: codebase grep]

**Warning signs:** tasks de código citam “ajustar visualmente” sem valores/estados/checkpoints do UI-SPEC. [VERIFIED: codebase grep]

### Pitfall 2: Quebrar o estado ao alternar Bar/Rail

**What goes wrong:** formulário e resultado são recriados quando a largura cruza 600 ou quando o usuário troca de destino. [VERIFIED: codebase grep]

**Why it happens:** construir listas diferentes de páginas dentro de cada branch altera identidade/posição dos elementos. [CITED: https://api.flutter.dev/flutter/widgets/State-class.html]

**How to avoid:** instanciar páginas uma vez a partir do catálogo e manter o mesmo `IndexedStack`; trocar somente o chrome de navegação. [CITED: https://api.flutter.dev/flutter/widgets/IndexedStack-class.html]

**Warning signs:** `pageBuilder` chamado em todo `build`, `UniqueKey`, listas de children com ordens diferentes ou controllers resetando ao redimensionar. [VERIFIED: codebase grep]

### Pitfall 3: Preservar estado e também preservar I/O oculto

**What goes wrong:** um futuro diagnóstico continua executando quando o destino deixa de ser visível. [VERIFIED: codebase grep]

**Why it happens:** `IndexedStack` mantém filhos; ocultar não equivale a `dispose`. [CITED: https://api.flutter.dev/flutter/widgets/IndexedStack-class.html]

**How to avoid:** documentar no shell um hook de visibilidade e deixar implementação de cancelamento para a Fase 3; nesta fase só os destinos offline são retidos. [VERIFIED: codebase grep]

**Warning signs:** contratos da futura tela dependem apenas de `dispose()` para cancelar. [VERIFIED: codebase grep]

### Pitfall 4: Tema “Matrix” sem hierarquia

**What goes wrong:** body text, labels e ícones competem com ações; erro/disabled/focus perdem significado. [VERIFIED: codebase grep]

**Why it happens:** o tema escuro atual força `onSurface` e vários estilos de texto para verde brilhante. [VERIFIED: codebase grep]

**How to avoid:** verde apenas em primary/indicator/ação; texto e superfícies usam neutros do esquema; não sobrescrever todos os `TextStyle.color`. [CITED: https://api.flutter.dev/flutter/material/ThemeData-class.html]

**Warning signs:** `Colors.green`, `Color(0xFF00FF41)` ou `Colors.red` fora de `theme.dart`/tokens. [VERIFIED: codebase grep]

### Pitfall 5: Fonte ampliada expõe `Row` rígida

**What goes wrong:** labels truncam, botões ficam estreitos ou surge overflow amarelo/preto. [VERIFIED: codebase grep]

**Why it happens:** as screens atuais usam `Row`, larguras percentuais e `Expanded` para ações. [VERIFIED: codebase grep]

**How to avoid:** actions usam `Wrap`/`OverflowBar` e empilham; valores técnicos quebram/selecionam; o content body rola verticalmente. [CITED: https://docs.flutter.dev/ui/accessibility]

**Warning signs:** `maxLines: 1`, `TextOverflow.ellipsis` em informação essencial, altura fixa de card ou width calculada por porcentagem para botão. [VERIFIED: codebase grep]

### Pitfall 6: Goldens instáveis por fonte/host

**What goes wrong:** PNGs mudam entre máquinas embora o layout não tenha regressão. [CITED: https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html]

**Why it happens:** fontes custom podem renderizar diferente por plataforma; `google_fonts` também pode buscar fonte em runtime. [CITED: https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html] [CITED: https://pub.dev/packages/google_fonts/versions/7.1.0]

**How to avoid:** um host canônico, Flutter fixado, DPR/surface size fixos, animações concluídas e nenhuma fonte remota; se Lato for obrigatório, carregar asset determinístico no `flutter_test_config.dart`. [CITED: https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html]

**Warning signs:** golden passa localmente e falha no CI ou exige rede para carregar fonte. [VERIFIED: codebase grep]

## Exact Testing Strategy

A configuração `workflow.nyquist_validation` está explicitamente `false`, portanto o formato formal `## Validation Architecture` deve ser omitido; isso não remove os testes exigidos por UI-01–UI-09 e pelo Definition of Done. [VERIFIED: codebase grep]

### Required automated tests

| File | Cases | Command |
|------|-------|---------|
| `test/app/destination_catalog_test.dart` | ids únicos, labels pt-BR não vazias, icon/selectedIcon, três destinations atuais, uma factory por item | `flutter test test/app/destination_catalog_test.dart` [VERIFIED: codebase grep] |
| `test/app/app_shell_test.dart` | 599 → `NavigationBar`; 600 e 839 → `NavigationRail`; 840 → rail expandido/contrato expanded; seleção abre destino correto; alteração de largura não perde estado | `flutter test test/app/app_shell_test.dart` [CITED: https://docs.flutter.dev/ui/adaptive-responsive/general] |
| `test/design_system/tool_components_test.dart` | todas as sete variantes de estado; loading conserva conteúdo; error não apaga conteúdo seguro; métrica sem valor não mostra zero; ação de copy chama writer e mostra confirmação | `flutter test test/design_system/tool_components_test.dart` [VERIFIED: codebase grep] |
| `test/design_system/accessibility_test.dart` | `androidTapTargetGuideline`, `labeledTapTargetGuideline`, `textContrastGuideline`; labels de icon-only; ordem/labels pt-BR; feedback de cópia como live region | `flutter test test/design_system/accessibility_test.dart` [CITED: https://docs.flutter.dev/ui/accessibility/accessibility-testing] |
| `test/design_system/design_system_golden_test.dart` | galeria claro compacta 360x800; galeria escura compacta 360x800; shell claro 720x1024; shell escuro 1024x768 | `flutter test test/design_system/design_system_golden_test.dart` [CITED: https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html] |
| testes existentes | oito casos de serviço continuam verdes | `flutter test --no-pub` — passou com 8/8 em 2026-08-10. [VERIFIED: local test run] |

### Text-scale matrix

- Executar o shell e a galeria em 360, 720 e 1024 logical pixels com `TextScaler.linear(1.0)` e `TextScaler.linear(2.0)`. [CITED: https://api.flutter.dev/flutter/painting/TextScaler/TextScaler.linear.html]
- Nos testes 2.0, exigir ausência de exceção/overflow, acesso por scroll a toda ação, sem ellipsis de informação essencial e action group empilhado quando necessário. [VERIFIED: codebase grep]
- Configurar tamanho por `tester.view.physicalSize`/`devicePixelRatio` e restaurar com `tester.view.reset()` em `addTearDown`; APIs antigas de `TestWindow` estão deprecated. [CITED: https://api.flutter.dev/flutter/flutter_test/TestFlutterView-class.html] [CITED: https://api.flutter.dev/flutter/flutter_test/TestWindow/physicalSize.html]

### Manual checkpoints

- TalkBack Android: percorrer destinos, inputs, ações, estados e confirmação de cópia; conferir ordem, nomes e ausência de anúncios duplicados. A documentação oficial recomenda teste com leitor de tela real além de automação. [CITED: https://docs.flutter.dev/ui/accessibility]
- Validação visual do UI-SPEC nas larguras 360, 600, 720, 840 e 1024, claro/escuro; somente após isso os valores discricionários de max width/radius/spacing se tornam locked. [VERIFIED: codebase grep]
- Atualizar goldens apenas com revisão visual explícita: `flutter test --update-goldens test/design_system/design_system_golden_test.dart`. [CITED: https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html]

### Sampling rate

- Por task de componente/shell: teste alvo abaixo de 30 s. [ASSUMED]
- Por wave: executar `flutter analyze --no-pub` e depois `flutter test --no-pub`. [VERIFIED: local test run]
- Gate da fase: analyze limpo, suíte inteira verde, quatro goldens revisados e checklist manual TalkBack/text scale concluído. [VERIFIED: codebase grep]

## Code Examples

Verified patterns from official sources:

### Classificação central e shell adaptativo

```dart
// Source: https://docs.flutter.dev/ui/adaptive-responsive/general
enum AppWidthClass { compact, medium, expanded }

abstract final class AppBreakpoints {
  static const double medium = 600;
  static const double expanded = 840;

  static AppWidthClass classify(double width) => switch (width) {
    < medium => AppWidthClass.compact,
    < expanded => AppWidthClass.medium,
    _ => AppWidthClass.expanded,
  };
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.destinations});
  final List<AppDestination> destinations;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int selectedIndex = 0;
  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = widget.destinations
        .map((destination) => Builder(builder: destination.pageBuilder))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final widthClass = AppBreakpoints.classify(constraints.maxWidth);
        final content = IndexedStack(index: selectedIndex, children: pages);

        if (widthClass == AppWidthClass.compact) {
          return Scaffold(
            body: content,
            bottomNavigationBar: NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: select,
              destinations: widget.destinations
                  .map((item) => NavigationDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.selectedIcon),
                        label: item.label,
                      ))
                  .toList(growable: false),
            ),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                extended: widthClass == AppWidthClass.expanded,
                selectedIndex: selectedIndex,
                onDestinationSelected: select,
                destinations: widget.destinations
                    .map((item) => NavigationRailDestination(
                          icon: Icon(item.icon),
                          selectedIcon: Icon(item.selectedIcon),
                          label: Text(item.label),
                        ))
                    .toList(growable: false),
              ),
              const VerticalDivider(width: 1),
              Expanded(child: content),
            ],
          ),
        );
      },
    );
  }

  void select(int index) => setState(() => selectedIndex = index);
}
```

### Accessibility guideline test

```dart
// Source: https://docs.flutter.dev/ui/accessibility/accessibility-testing
testWidgets('follows Android accessibility guidelines', (tester) async {
  final semantics = tester.ensureSemantics();
  addTearDown(semantics.dispose);

  await tester.pumpWidget(const ToolsApp());

  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
});
```

### Tamanho e text scale de teste sem APIs deprecated

```dart
// Sources:
// https://api.flutter.dev/flutter/flutter_test/TestFlutterView-class.html
// https://api.flutter.dev/flutter/painting/TextScaler/TextScaler.linear.html
tester.view.devicePixelRatio = 1;
tester.view.physicalSize = const Size(360, 800);
addTearDown(tester.view.reset);

await tester.pumpWidget(
  MaterialApp(
    home: MediaQuery(
      data: const MediaQueryData(
        size: Size(360, 800),
        textScaler: TextScaler.linear(2),
      ),
      child: const AppShell(destinations: testDestinations),
    ),
  ),
);
expect(tester.takeException(), isNull);
```

### Copy feedback anunciável

```dart
// Source: https://api.flutter.dev/flutter/semantics/SemanticsProperties/liveRegion.html
Future<void> copyValue(BuildContext context, String value) async {
  await Clipboard.setData(ClipboardData(text: value));
  if (!context.mounted) return;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(const SnackBar(content: Text('Valor copiado')));
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `BottomNavigationBar` em app Material 3 | `NavigationBar` | Material 3; API atual recomenda `NavigationBar` para apps novos/configurados com M3 | Troca direta de `items/onTap/currentIndex` por `destinations/onDestinationSelected/selectedIndex`. [CITED: https://api.flutter.dev/flutter/material/BottomNavigationBar-class.html] |
| Detectar tipo/orientação do device | Medir window/parent constraints | Orientação adaptativa atual do Flutter | Funciona em split-screen, foldable e janela redimensionada. [CITED: https://docs.flutter.dev/ui/adaptive-responsive/general] |
| `MediaQuery.textScaleFactor` | `MediaQuery.textScalerOf` / `TextScaler` | API atual; fator escalar simples é mantido só por compatibilidade | Testes e widgets devem usar o modelo de scaling atual. [CITED: https://api.flutter.dev/flutter/painting/TextScaler-class.html] |
| `tester.binding.window.*TestValue` | `WidgetTester.view` / `TestFlutterView` | APIs antigas deprecated após Flutter 3.9 | Evita basear novos testes em singleton legado. [CITED: https://api.flutter.dev/flutter/flutter_test/TestWindow/physicalSize.html] |
| Toda cor definida em cada widget | `ColorScheme` + component themes + extensão mínima | Material 3 | Unifica roles e permite claro/escuro sem repetir overrides. [CITED: https://api.flutter.dev/flutter/material/ThemeData-class.html] |
| Golden de app inteiro | Gallery/component goldens + widget/semantics assertions | Prática recomendada para este incremental | Reduz churn enquanto as screens serão migradas na Fase 2. [VERIFIED: codebase grep] |

**Deprecated/outdated:**

- `BottomNavigationBar` não está removido, mas `NavigationBar` é a substituição preferida em Material 3. [CITED: https://api.flutter.dev/flutter/material/BottomNavigationBar-class.html]
- Setters em `TestWindow` como `physicalSizeTestValue` estão deprecated; use `WidgetTester.view`. [CITED: https://api.flutter.dev/flutter/flutter_test/TestWindow/devicePixelRatioTestValue.html]
- Papéis `ColorScheme.background`, `onBackground` e `surfaceVariant` estão deprecated na API atual; não introduzir novos usos. [CITED: https://api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html]

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Testes alvo por task devem concluir em menos de 30 segundos. | Exact Testing Strategy | Baixo; o planner pode ajustar o sampling sem alterar arquitetura. |
| A2 | Windows + Flutter 3.44.x deve ser o produtor inicial dos goldens se nenhum CI canônico for definido. | Open Questions | Médio; gerar baselines em host diferente pode causar diffs de rasterização. |

Todos os valores visuais discricionários (radius, elevation, spacing e max width) devem ser fechados pelo `01-UI-SPEC.md` após renderização, em vez de serem tratados como fatos nesta pesquisa. [VERIFIED: codebase grep]

## Open Questions

1. **Quais valores finais de spacing, radius, elevation e max content width o UI-SPEC aprovará?**
   - What we know: 16 px de padding/spacing e radius 8/12 já aparecem nas screens; o contexto delega a decisão final após validação visual. [VERIFIED: codebase grep]
   - What's unclear: a combinação final ainda não foi renderizada nem aprovada. [VERIFIED: codebase grep]
   - Recommendation: o UI-SPEC deve comparar no mínimo 360/720/1024 e então travar uma escala curta; nenhuma task de implementação deve inventar valores fora dela. [VERIFIED: codebase grep]

2. **Qual ambiente será canônico para atualizar goldens?**
   - What we know: custom fonts podem diferir por plataforma e o workspace atual é Windows com Flutter 3.44.0. [CITED: https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html] [VERIFIED: local SDK metadata]
   - What's unclear: não há CI/configuração de golden detectada. [VERIFIED: codebase grep]
   - Recommendation: declarar Windows + Flutter 3.44.x como produtor inicial ou, se CI futuro usar outro host, gerar/aprovar nele e proibir updates casuais cross-platform. [ASSUMED]

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | build/analyze/test/goldens | ✓ via caminho explícito | 3.44.0 stable | Usar `C:\src\flutter\bin\flutter.bat`; adicionar ao PATH é conveniência, não requisito. [VERIFIED: local SDK metadata] |
| Dart SDK | compilação | ✓ dentro do Flutter | 3.12.0 | — [VERIFIED: local SDK metadata] |
| `flutter_test` | widget/a11y/goldens | ✓ | SDK 3.44.0 | — [VERIFIED: codebase grep] |
| Android/TalkBack device | checkpoint manual UI-06/UI-07 | Não auditado nesta pesquisa | — | Widget/semantics tests cobrem automação, mas não substituem o checkpoint manual. [CITED: https://docs.flutter.dev/ui/accessibility] |
| Context7 CLI | consulta documental | ✗ | — | Documentação oficial Flutter/API foi usada diretamente. [VERIFIED: environment probe] |

**Missing dependencies with no fallback:** device Android com TalkBack não foi confirmado; é necessário para o gate manual de acessibilidade, mas não bloqueia implementação/testes de widget. [CITED: https://docs.flutter.dev/ui/accessibility]

**Missing dependencies with fallback:** Context7 não está instalado; a documentação oficial atual do Flutter foi consultada diretamente. [VERIFIED: environment probe]

**Baseline:** `flutter analyze --no-pub` passou sem issues e `flutter test --no-pub` passou 8/8 em 2026-08-10, executados com o SDK local. [VERIFIED: local test run]

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no | O app não possui conta/autenticação neste ciclo. [VERIFIED: codebase grep] |
| V3 Session Management | no | Existe apenas estado efêmero de UI local, sem sessão remota. [VERIFIED: codebase grep] |
| V4 Access Control | no | Não há recursos remotos nem papéis de usuário. [VERIFIED: codebase grep] |
| V5 Input Validation | yes | Manter validação específica nas features e erros inline; primitives não alteram nem “sanitizam” resultados. [VERIFIED: codebase grep] |
| V6 Cryptography | no para a fundação | Hashes existentes pertencem à ferramenta offline e não são mecanismo de segurança; esta fase não cria criptografia. [VERIFIED: codebase grep] |

### Known Threat Patterns for Flutter UI foundation

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Clipboard recebe valor errado ou confirmação enganosa | Spoofing / Information Disclosure | Uma ação explícita copia exatamente o valor exibido/selecionável; confirmação nomeia a ação, sem copiar automaticamente. [VERIFIED: codebase grep] |
| Estado de erro revela conteúdo inseguro ou apaga evidência válida | Information Disclosure / Repudiation | `ToolStatusPanel` recebe copy segura e fica separado de cards de resultado; erros de campo permanecem inline. [VERIFIED: codebase grep] |
| Cor como único indicador | Spoofing | Cada estado usa ícone, título e texto semântico além de cor. [VERIFIED: codebase grep] |
| Fonte remota introduz request inesperado | Information Disclosure | Usar sans Material local; se Lato for mantida, bundle e desabilite runtime fetching. [CITED: https://pub.dev/packages/google_fonts/versions/7.1.0] |
| Ação icon-only sem nome | Spoofing / Denial of Service (acessibilidade) | Tooltip/rótulo semântico e `labeledTapTargetGuideline`. [CITED: https://docs.flutter.dev/ui/accessibility/accessibility-testing] |

Nenhuma operação de rede, analytics, permissão, banco de dados ou persistência deve ser adicionada pela Fase 1. [VERIFIED: codebase grep]

## Sources

### Primary (HIGH confidence)

- [Flutter: General approach to adaptive apps](https://docs.flutter.dev/ui/adaptive-responsive/general) — abstract/measure/branch, `LayoutBuilder`, largura disponível e transição bar/rail em 600; página atualizada para a documentação Flutter 3.44.x em 2026. [CITED: https://docs.flutter.dev/ui/adaptive-responsive/general]
- [Flutter accessibility](https://docs.flutter.dev/ui/accessibility) — TalkBack, contraste, 48x48, cor, erros e large scale. [CITED: https://docs.flutter.dev/ui/accessibility]
- [Flutter accessibility testing](https://docs.flutter.dev/ui/accessibility/accessibility-testing) — guideline API para target size, labels e contraste. [CITED: https://docs.flutter.dev/ui/accessibility/accessibility-testing]
- [NavigationBar API](https://api.flutter.dev/flutter/material/NavigationBar-class.html) e [NavigationRail API](https://api.flutter.dev/flutter/material/NavigationRail-class.html) — componentes oficiais Material 3 e uso adaptativo. [CITED: https://api.flutter.dev/flutter/material/NavigationBar-class.html]
- [IndexedStack API](https://api.flutter.dev/flutter/widgets/IndexedStack-class.html) — seleção por índice e preservação do estado dos cards/filhos do exemplo. [CITED: https://api.flutter.dev/flutter/widgets/IndexedStack-class.html]
- [ThemeData API](https://api.flutter.dev/flutter/material/ThemeData-class.html), [ColorScheme.fromSeed](https://api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html) e [ThemeExtension](https://api.flutter.dev/flutter/material/ThemeExtension-class.html) — papéis de tema, esquemas e tokens customizados. [CITED: https://api.flutter.dev/flutter/material/ThemeData-class.html]
- [TextScaler API](https://api.flutter.dev/flutter/painting/TextScaler-class.html) — scaling atual e compatibilidade legada. [CITED: https://api.flutter.dev/flutter/painting/TextScaler-class.html]
- [Semantics liveRegion](https://api.flutter.dev/flutter/semantics/SemanticsProperties/liveRegion.html) — anúncios polidos e `SnackBar` como exemplo. [CITED: https://api.flutter.dev/flutter/semantics/SemanticsProperties/liveRegion.html]
- [`matchesGoldenFile`](https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html) e [`TestFlutterView`](https://api.flutter.dev/flutter/flutter_test/TestFlutterView-class.html) — golden API, font caveats e configuração atual de view em testes. [CITED: https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html]
- Workspace: `01-CONTEXT.md`, `REQUIREMENTS.md`, `ROADMAP.md`, `AGENTS.md`, `pubspec.yaml`, lockfile, `lib/` e `test/` — decisões, requirements, baseline, boundaries e lacunas. [VERIFIED: codebase grep]
- Local SDK metadata e execução: Flutter 3.44.0/Dart 3.12.0, analyze limpo e testes 8/8. [VERIFIED: local SDK metadata] [VERIFIED: local test run]

### Secondary (MEDIUM confidence)

- [`google_fonts` official package documentation](https://pub.dev/packages/google_fonts/versions/7.1.0) — runtime fetching, asset prioritization e orientação de bundle/licença; o projeto usa 6.3.3, cuja linha já inclui esse comportamento. [CITED: https://pub.dev/packages/google_fonts/versions/7.1.0]

### Tertiary (LOW confidence)

- Nenhuma fonte não oficial foi usada para decisões técnicas. [VERIFIED: research log]

## Metadata

**Confidence breakdown:**

- Standard stack: HIGH — versão local e APIs oficiais verificadas; nenhuma dependência nova. [VERIFIED: local SDK metadata]
- Architecture: HIGH — segue decisões locked, estrutura atual e guidance oficial Flutter. [VERIFIED: codebase grep] [CITED: https://docs.flutter.dev/ui/adaptive-responsive/general]
- Pitfalls: HIGH — derivados de código atual, contratos de fase e comportamento documentado de Flutter. [VERIFIED: codebase grep]
- Testing: HIGH — baseline executado e APIs oficiais de widget/a11y/golden consultadas. [VERIFIED: local test run] [CITED: https://docs.flutter.dev/ui/accessibility/accessibility-testing]
- Tokens visuais finais: MEDIUM — dependem da renderização/aprovação do UI-SPEC por decisão explícita do contexto. [VERIFIED: codebase grep]

**Research date:** 2026-08-10
**Valid until:** 2026-09-09 (30 dias; stack estável, mas documentação/API pode evoluir)
