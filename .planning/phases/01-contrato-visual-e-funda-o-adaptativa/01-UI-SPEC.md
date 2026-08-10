---
phase: 1
slug: contrato-visual-e-funda-o-adaptativa
status: approved
shadcn_initialized: false
preset: none
created: 2026-08-10
---

# Phase 1 — UI Design Contract

> Contrato visual e de interação para a fundação adaptativa do Tools App. Este documento é a fonte de verdade da implementação e deve ser lido junto de `01-CONTEXT.md` e `01-RESEARCH.md`.

---

## Design Intent

**Pessoa e tarefa:** profissional ou estudante de TI que abre o aplicativo para obter um resultado técnico rapidamente, conferir o método e copiar um valor sem ambiguidade.

**Sensação obrigatória:** instrumento técnico calmo, preciso e honesto. A interface deve lembrar um painel de diagnóstico bem organizado, não um terminal neon nem um dashboard promocional.

| Exploração | Contrato |
|------------|----------|
| Domínio | rede, endereço, máscara, unidade, checksum, amostra, evidência e capacidade |
| Mundo de cores | fósforo verde, grafite, carvão, branco de painel e cinza de equipamento |
| Assinatura | padrão “sinal + evidência”: superfícies neutras, verde apenas no sinal ativo e valores técnicos monoespaçados, selecionáveis e copiáveis |
| Default rejeitado 1 | texto inteiro verde neon → texto neutro de alto contraste com acento seletivo |
| Default rejeitado 2 | grade genérica de cards → fluxo sequencial entrada → ação → estado/resultado → explicação |
| Default rejeitado 3 | layout por tipo de dispositivo → layout pelas constraints disponíveis em 600 e 840 logical pixels |

A assinatura deve ser reconhecível em cinco pontos: seleção da navegação, ação primária, foco de campo, progresso ativo e linha de valor/cópia. Cor não substitui ícone, rótulo ou texto de estado.

**Foco visual:** antes da execução, o campo da tarefa que estiver ativo e a ação primária formam o primeiro plano visual, com o campo identificado pelo anel de foco e a CTA pelo accent reservado. Após a execução, o resultado técnico passa a ser o ponto focal da tela; ações, estado e explicação permanecem visualmente subordinados à evidência produzida.

**Fonte:** decisões D-05 a D-08 e D-11 de `01-CONTEXT.md`; direção fechada neste UI-SPEC por discrição delegada.

---

## Design System

| Property | Value |
|----------|-------|
| Tool | Flutter Material 3 existente; nenhum design system externo |
| Preset | não aplicável |
| Component library | widgets Material do Flutter SDK e primitives locais pequenas |
| Icon library | Material Icons, exclusivamente |
| Font | sans-serif Material local da plataforma para interface; família genérica `monospace` para valores técnicos |
| Depth strategy | mudanças discretas de superfície + bordas; sem sombras decorativas |
| Locale | português do Brasil (`pt-BR`) em todo texto visível e semântico |

Não adicionar pacote, fonte remota, backend, analytics, permissão ou persistência. `google_fonts` já existente não deve ser necessário para o novo tema; a fundação usa a tipografia local do Material para funcionamento offline e goldens determinísticos.

### Token ownership

- Cores comuns pertencem a `ColorScheme` e aos component themes de `ThemeData`.
- Spacing, radius, breakpoints e larguras máximas podem pertencer a uma única `ThemeExtension`/classe de tokens.
- Nenhum widget consumidor define hex, elevation, radius ou breakpoint localmente.
- Não introduzir usos novos dos papéis deprecated `background`, `onBackground` ou `surfaceVariant` de `ColorScheme`.

---

## Spacing Scale

Todos os valores são logical pixels e múltiplos de 4.

| Token | Value | Usage |
|-------|-------|-------|
| `spaceXs` | 4 | lacuna de ícone pequeno, chip e metadado inline |
| `spaceSm` | 8 | itens relacionados, conteúdo interno de chip, ícone + rótulo, botões irmãos e linhas de métrica |
| `spaceMd` | 16 | padding compacto, campos consecutivos e conteúdo de card compacto |
| `spaceLg` | 24 | padding de card confortável e separação entre seções |
| `spaceXl` | 32 | padding de página expandida e grupos principais |
| `space2xl` | 48 | separação excepcional entre regiões principais |
| `space3xl` | 64 | respiro de página; não usar dentro de controles |

### Application rules

- Padding horizontal de página: 16 em compacta, 24 em média e 32 em expandida.
- Padding de card: 16 em compacta; 24 quando a largura interna for pelo menos 600.
- Gap entre campos: `spaceMd` (16). Gap entre seções: `spaceLg` (24). Gap entre cards de resultado repetidos: `spaceMd` (16).
- Padding deve ser simétrico, salvo alinhamento intencional de conteúdo leading em listas.
- Não usar valores 6, 10, 14, 18, 20 ou outros fora da escala em layout novo.

**Exceptions:** 48 × 48 é tamanho mínimo de alvo de toque, não spacing. Divisores podem ter 1 logical pixel. O anel de foco pode ter 2 logical pixels.

**Fonte:** D-15/D-16 de `01-CONTEXT.md`; escala fechada neste UI-SPEC nos tokens 4/8/16/24/32/48/64.

---

## Typography

O sistema declara exatamente quatro tamanhos e dois pesos: 400 e 600. Não usar 500, 700 ou 800 nos novos componentes.

| Role | Size | Weight | Line Height | Usage |
|------|------|--------|-------------|-------|
| Body | 16 | 400 | 1.50 | explicações, valores comuns e conteúdo principal |
| Label | 14 | 600 | 1.40 | rótulos de campo, botão, chip, metadado e navegação |
| Heading | 20 | 600 | 1.25 | título de seção/card e AppBar |
| Display | 28 | 600 | 1.20 | título de ferramenta quando houver cabeçalho dentro do conteúdo |

### Typography rules

- Sans-serif Material local em títulos, labels, botões, instruções e erros.
- `monospace`, 16/400/1.50, em hash, IP, CIDR, máscara, bytes, unidades e valores técnicos copiáveis.
- Valores técnicos de destaque podem usar 20/600/1.25, ainda em monospace.
- Ativar números tabulares quando a API/fonte local suportar; não depender disso para alinhamento semântico.
- Informação essencial não usa `maxLines: 1`, ellipsis ou altura fixa. Hashes e endereços podem quebrar em qualquer caractere e permanecem selecionáveis.
- Texto secundário usa `onSurfaceVariant`; placeholder/disabled usa o papel disabled do tema, nunca alpha arbitrário por widget.
- Respeitar `MediaQuery.textScalerOf(context)` sem clamp. Em escala 2.0, cards crescem, ações empilham e o conteúdo continua acessível por scroll vertical.

**Fonte:** D-06, D-07 e D-17 de `01-CONTEXT.md`; Material sans local recomendado por `01-RESEARCH.md`.

---

## Color

O verde Matrix é a identidade de 10%, não a cor padrão de texto. Os valores abaixo são os anchors a configurar diretamente ou obter de um `ColorScheme.fromSeed` ajustado; o resultado renderizado deve preservar estes papéis e contrastes.

### Light theme

| Role | Value | Usage |
|------|-------|-------|
| Dominant canvas (60%) | `#F7F9F7` | `scaffoldBackgroundColor`, áreas vazias e fundo de página |
| Secondary surface (30%) | `#FFFFFF` | cards, inputs, AppBar e superfícies elevadas estáticas |
| Secondary container | `#EDF3EE` | seleção suave, nav/rail e agrupamentos discretos |
| Primary text | `#171D18` | títulos e corpo |
| Secondary text | `#47534A` | ajuda, metadados e descrições |
| Outline | `#707A72` | borda de controle e separação estrutural |
| Accent (10%) | `#006D2C` | ação/seleção/foco/progresso definidos abaixo |
| On accent | `#FFFFFF` | conteúdo sobre accent |
| Accent container | `#B8F3C5` | indicador selecionado e realce de baixa intensidade |
| On accent container | `#002109` | conteúdo sobre accent container |
| Error/destructive | `#BA1A1A` | erro, falha e ação destrutiva real |
| On error | `#FFFFFF` | conteúdo sobre error |

### Dark theme

| Role | Value | Usage |
|------|-------|-------|
| Dominant canvas (60%) | `#0F1511` | `scaffoldBackgroundColor`, áreas vazias e fundo de página |
| Secondary surface (30%) | `#151C17` | cards, inputs e AppBar |
| Secondary container | `#1D2820` | seleção suave, nav/rail e agrupamentos discretos |
| Primary text | `#E1E9E2` | títulos e corpo; substitui o texto verde atual |
| Secondary text | `#BBC5BC` | ajuda, metadados e descrições |
| Outline | `#859087` | borda de controle e separação estrutural |
| Accent (10%) | `#50FA7B` | ação/seleção/foco/progresso definidos abaixo |
| On accent | `#003913` | conteúdo sobre accent |
| Accent container | `#005321` | indicador selecionado e realce de baixa intensidade |
| On accent container | `#A7F5B7` | conteúdo sobre accent container |
| Error/destructive | `#FFB4AB` | erro, falha e ação destrutiva real |
| On error | `#690005` | conteúdo sobre error |

### Accent reservation

Accent é reservado somente para:

1. fundo/conteúdo da ação primária habilitada;
2. indicador e ícone do destino selecionado;
3. borda/caret/anel do campo em foco;
4. indicador de progresso ou etapa ativa;
5. affordance de copiar em foco/pressed e confirmação breve de sucesso;
6. ícone de estado concluído, sempre acompanhado de texto “Concluído”.

Não usar accent em body text, todos os ícones, todas as bordas, cards inteiros ou decoração. Falha/erro usa `error`; vazio, offline e cancelado usam neutros mais ícone e copy próprios. Cor nunca é o único diferenciador.

### Contrast and component states

- Texto normal: contraste mínimo 4.5:1. Texto grande e limites/ícones essenciais: mínimo 3:1.
- Pares principais validados: light `onSurface/canvas` 16.20:1, `onSurfaceVariant/canvas` 7.62:1 e `onPrimary/primary` 6.51:1; dark 14.93:1, 10.41:1 e 9.60:1, respectivamente.
- Foco visível: anel de 2 logical pixels em accent e contraste mínimo 3:1 contra superfícies adjacentes.
- Disabled mantém leitura suficiente do rótulo, mas não usa accent; a indisponibilidade também é exposta por semantics.
- Inputs são visualmente inset: `surface`/`surfaceContainerLowest`, borda `outline`; não usar branco puro no dark theme.
- Cards, AppBar, nav e rail têm elevation 0. Separação usa surface shift e borda de 1 px.
- Somente menus, dropdowns e SnackBar podem usar elevation 2 por serem overlays transitórios. Não usar shadow custom.

**Fonte:** D-05, D-07 e D-08 de `01-CONTEXT.md`; direção `ColorScheme` de `01-RESEARCH.md`.

---

## Radius and Shape

| Token | Value | Usage |
|-------|-------|-------|
| `radiusSm` | 4 | chips pequenos e tags técnicas |
| `radiusMd` | 8 | inputs, botões, indicadores e linhas de métrica |
| `radiusLg` | 12 | cards, status panels, menus e SnackBar |

- Cards e painéis usam borda de 1 px de baixa ênfase e radius 12.
- Inputs e botões usam radius 8 e altura mínima 48.
- Chips não podem parecer botões: radius 4, sem elevation, rótulo + valor claramente estáticos.
- Não usar pill/círculo para containers de texto longo.

**Fonte:** discrição delegada em `01-CONTEXT.md`; escala harmonizada com os raios 8/12 já presentes.

---

## Adaptive Layout Contract

Classificar a largura oferecida ao `AppShell` com `LayoutBuilder`; nunca por device, plataforma ou orientação.

| Width class | Constraint | Navigation | Page padding | Content behavior |
|-------------|------------|------------|--------------|------------------|
| Compact | `< 600` | Material 3 `NavigationBar` inferior | 16 | uma coluna; ação primária ocupa a linha; secundárias abaixo ou em `Wrap` |
| Medium | `>= 600 && < 840` | `NavigationRail` recolhido, 80 px, labels via tooltip/semantics | 24 | conteúdo ao lado do rail; seções continuam em uma coluna legível |
| Expanded | `>= 840` | `NavigationRail` extended, 256 px | 32 | conteúdo centralizado; seções podem usar duas regiões somente quando a ordem de leitura permanecer entrada → ação → resultado |

### Max widths

- `ToolScaffold`/conteúdo total: máximo 960 logical pixels, centralizado.
- Região de formulário/entrada: máximo 720 logical pixels.
- Texto explicativo corrido: máximo 720 logical pixels.
- Resultado técnico com várias colunas/linhas: pode usar até 960, sem esticar uma única linha curta.
- Em compacta, usar toda a largura disponível após padding, sem largura mínima que provoque scroll horizontal.

### Layout invariants

- Em 599 px ainda existe `NavigationBar`; em 600 px já existe rail recolhido.
- Em 839 px o rail continua recolhido; em 840 px passa a extended.
- A troca de classe altera somente o chrome de navegação e arranjo, não recria páginas nem limpa campos/resultados.
- AppBar/título, conteúdo e navegação respeitam safe areas.
- O único scroll de página é vertical. Menus podem rolar internamente. Não aceitar overflow horizontal de informação essencial.
- Em escala de fonte 2.0, qualquer `Row` de ação deve virar `Wrap`/coluna quando a largura intrínseca não couber.

**Fonte:** D-14, D-15 e D-17 de `01-CONTEXT.md`; limites oficiais adotados em `01-RESEARCH.md`.

---

## Navigation and Destination Catalog

### Typed catalog

Uma única coleção imutável e ordenada governa as duas representações de navegação e qualquer catálogo futuro. Cada `AppDestination` deve conter:

| Field | Contract |
|-------|----------|
| `id` | string estável, única, não localizada; nunca derivada do índice ou label |
| `label` | label curta em pt-BR usada em Bar/Rail |
| `semanticLabel` | nome completo quando a label curta puder perder contexto |
| `icon` | Material Icon outlined/inativo |
| `selectedIcon` | contraparte filled/selecionada do mesmo conceito |
| `category` | categoria tipada para o catálogo futuro; nesta fase todos podem usar “Ferramentas” |
| `compactPriority` | ordem explícita para os destinos fixados em compacta quando houver overflow |
| `pageBuilder` | factory da tela; materializada uma vez pelo estado do shell |

Catálogo inicial, na ordem: `rede` → “Rede”; `armazenamento` → “Armazenamento”; `hash` → “Hash”. Não inserir “Diagnóstico de Internet” antes da Phase 3.

### Selection and preservation

- Derivar `NavigationDestination`, `NavigationRailDestination` e páginas do mesmo catálogo; não manter listas paralelas.
- Materializar a lista de páginas uma vez em `initState` e exibi-la em `IndexedStack`.
- Trocar destino atualiza seleção visual e semantics; tocar o destino já selecionado não recria a página.
- Preservar campos e resultados das três ferramentas offline ao navegar ou cruzar breakpoints.
- `IndexedStack` não autoriza I/O oculto. A Phase 3 adicionará contrato de visibilidade/cancelamento antes de reter o diagnóstico.

### Growth rule

- Até quatro destinos principais: mostrar todos no `NavigationBar` compacto.
- Cinco ou mais destinos: mostrar os três destinos de maior `compactPriority` + uma quarta entrada “Ferramentas”.
- “Ferramentas” abre catálogo categorizado derivado da mesma lista, nunca uma segunda lista manual.
- Se o destino selecionado não for um dos três fixados, “Ferramentas” permanece visual e semanticamente selecionado.
- Rail médio/expandido lista todos os destinos e pode rolar verticalmente quando necessário.

### Navigation visual behavior

- Destino selecionado usa indicador de accent container, selected icon e rótulo/estado semanticamente selecionado.
- Destino não selecionado usa `onSurfaceVariant`; nenhum badge ou cor decorativa.
- Cada ícone do rail recolhido tem tooltip com label completa e alvo mínimo 48 × 48.
- Ordem da navegação segue o catálogo e não muda entre breakpoints.

**Fonte:** D-01 a D-04 de `01-CONTEXT.md`; implementação `NavigationBar`/`NavigationRail`/`IndexedStack` recomendada por `01-RESEARCH.md`.

---

## Shared Primitive Inventory

As primitives recebem dados/children de apresentação. Não executam cálculo, validação de domínio, rede ou persistência.

| Primitive | Required anatomy and behavior |
|-----------|-------------------------------|
| `ToolScaffold` | título pt-BR, resumo opcional, conteúdo vertical rolável, safe area, padding por width class e max width centralizado; a tela continua responsável por sua lógica |
| `ToolInputSection` | heading opcional, instrução discreta, campos em ordem de leitura e erros de campo inline; não é form builder |
| `ToolActionGroup` | uma ação primária, ações secundárias opcionais e cancelamento opcional; 48 px mínimo; reflow sem overflow; loading desabilita somente o que conflita |
| `ToolStatusPanel` | variant fechada, ícone, heading, body, progresso opcional e próxima ação opcional; não aceita número sentinela |
| `ToolResultCard` | heading, conteúdo seguro preservável, valores selecionáveis, ações opcionais e borda neutra; não pressupõe um modelo de feature |
| `ToolMetric` | label sans 14/600 + valor mono 16/400; variante linha ou chip; `null` mostra “Indisponível”, nunca `0` inventado |
| `TechnicalValueRow` | label, valor técnico quebrável/selecionável, metadado opcional e `CopyValueAction`; é a manifestação principal de “sinal + evidência” |
| `CopyValueAction` | copia exatamente o valor exibido; ícone Material `copy`, tooltip/semantic label e feedback único via SnackBar live region |

### Tool anatomy

1. Título e resumo curto.
2. Entrada e ajuda contextual.
3. Ações.
4. Estado geral, quando necessário.
5. Resultados e métricas.
6. Explicação secundária.

Resultados aparecem depois da ação. Erros de campo permanecem junto ao campo; falha geral fica junto da região afetada. Conteúdo seguro já concluído não desaparece quando outro item falha ou quando há loading posterior.

**Fonte:** D-09 a D-13 de `01-CONTEXT.md`.

---

## State Contract

Toda variante usa ícone + título + texto; cor sozinha nunca comunica estado.

| State | Icon | Heading | Body / next step | Visual and interaction rules |
|-------|------|---------|------------------|------------------------------|
| Empty | `inbox_outlined` | “Nenhum resultado ainda” | “Preencha os campos e execute a ferramenta para ver os resultados.” | neutro; não mostrar card vazio se a instrução já estiver evidente no formulário |
| Loading | `progress_activity`/progress indicator | “Processando” | “Aguarde enquanto concluímos esta etapa.” | progress com semantics; manter inputs/contexto e resultados seguros visíveis; sem spinner infinito sem rótulo |
| Success | `check_circle_outline` | “Concluído” | feature fornece resumo objetivo | accent apenas no ícone; resultado é o foco, não um banner verde inteiro |
| Failure | `error_outline` | “Não foi possível concluir” | “Confira os dados e tente novamente.” | error role; preservar resultados seguros; ação “Tentar novamente” somente quando existir callback |
| Offline | `wifi_off` | “Sem conexão com a internet” | “Verifique a conexão e tente novamente.” | neutro de alta ênfase; não equivale a falha de cada capability |
| Permission denied | `lock_outline` | “Permissão necessária” | “Ative a permissão nas configurações para continuar.” | error role no ícone; só mostrar ação de configurações se a plataforma a suportar |
| Cancelled | `cancel_outlined` | “Operação cancelada” | “Os resultados concluídos continuam disponíveis.” | neutro; distinto de failure e sem reinício automático |

### Control states

- **Default:** label e affordance completos.
- **Focused:** anel accent de 2 px + estado de foco semanticamente navegável.
- **Pressed/selected:** usar state layer Material, sem alterar layout.
- **Disabled:** remover callback, usar cores disabled e explicar a indisponibilidade quando não for óbvia.
- **Loading action:** manter largura e label compreensível; usar “Processando” ou verbo no gerúndio, não somente spinner.
- **Error input:** helper é substituído por erro específico e acionável; foco deve poder chegar ao campo.

---

## Copywriting Contract

Copy é direta, técnica, cordial e em português do Brasil. Preferir voz ativa, frases curtas e verbos concretos. Não usar “Oops”, “algo deu errado”, promessa de precisão absoluta, “ping” para método não ICMP ou jargão sem explicação.

| Element | Copy |
|---------|------|
| Primary CTA da fundação/catálogo | “Abrir ferramenta” |
| CTA de nova tentativa | “Tentar novamente” |
| Empty state heading | “Nenhum resultado ainda” |
| Empty state body | “Preencha os campos e execute a ferramenta para ver os resultados.” |
| Error state | “Não foi possível concluir. Confira os dados e tente novamente.” |
| Offline state | “Sem conexão com a internet. Verifique a conexão e tente novamente.” |
| Permission state | “Permissão necessária. Ative a permissão nas configurações para continuar.” |
| Cancelled state | “Operação cancelada. Os resultados concluídos continuam disponíveis.” |
| Copy tooltip | “Copiar {rótulo}” |
| Copy confirmation | “{Rótulo} copiado” — exemplos: “Hash SHA-256 copiado”, “Endereço de rede copiado” |
| Destructive confirmation | Não há ação destrutiva na Phase 1 |

Regras adicionais:

- CTAs de ferramenta usam sempre verbo + objeto: “Calcular rede”, “Analisar capacidade”, “Gerar hashes”. “Calcular” isolado não é permitido, inclusive durante a migração incremental da Phase 2.
- “Limpar” é ação secundária reversível da sessão, sem modal de confirmação; deve ficar disabled quando não houver conteúdo.
- Não colocar ponto final em labels, títulos ou botões. Mensagens completas usam pontuação.
- Corrigir cirurgicamente o título atual “Network Calculator” para “Calculadora de Rede” nesta fase; nenhuma outra lógica da tela muda por essa correção.
- Unidade e método acompanham o valor: `24 ms`, `192.168.1.1`, `256 bits`; não depender somente de ícone/abreviação.

**Fonte:** UI-08/UI-09, D-13 e copy atual das três screens; defaults concretizados neste UI-SPEC.

---

## Copy Interaction

- `CopyValueAction` tem alvo mínimo 48 × 48 e nunca copia automaticamente.
- Tooltip e semantic label nomeiam o dado: “Copiar endereço de rede”, não apenas “Copiar”.
- O valor copiado é exatamente o valor selecionável mostrado, sem prefixos invisíveis.
- Após sucesso, ocultar SnackBar de cópia anterior e mostrar um único SnackBar por 2 segundos com “{Rótulo} copiado”.
- SnackBar funciona como live region; não disparar `SemanticsService.announce` em paralelo.
- Falha de clipboard, se exposta pela plataforma, usa “Não foi possível copiar. Selecione o valor e copie manualmente.” e mantém o valor selecionável.

---

## Accessibility Contract

- Alvo interativo mínimo 48 × 48 logical pixels no Android, inclusive ícones de copiar, destinos e menus.
- Todo controle icon-only recebe tooltip e semantic label pt-BR; ícone decorativo é excluído da árvore semântica.
- Ordem de foco/leitura: navegação → título/resumo → campos → ações → estado → resultados → explicação.
- Estado selecionado, loading, disabled e erro são expostos por semantics além da aparência.
- Heading de ferramenta e heading de seção são marcados semanticamente como cabeçalhos quando suportado.
- `SelectableText` técnico expõe o valor uma vez; botão de copiar tem node separado e rótulo específico.
- Não anunciar SnackBar e anúncio manual duplicados.
- Contraste mínimo 4.5:1 para texto normal e 3:1 para texto grande, ícones essenciais, bordas de controle e foco.
- Escala 2.0 não pode ocultar ações, truncar informação essencial nem gerar overflow. O usuário alcança todo conteúdo por scroll vertical.
- TalkBack deve anunciar destino + selecionado, labels/erros dos campos, ações, título/body dos sete estados e confirmação de cópia em ordem compreensível.
- Movimento limita-se às transições Material curtas de estado. Respeitar preferência de redução de movimento; não usar bounce, pulse decorativo ou animação contínua fora de progresso ativo.

---

## Visual Acceptance Criteria

### Shell

- 360 × 800: três destinos visíveis na `NavigationBar`, labels legíveis, seleção clara e nenhum conteúdo atrás da barra.
- 599 px: Bar; 600 px: Rail recolhido; 839 px: Rail recolhido; 840 px: Rail extended.
- 720 × 1024: rail recolhido e conteúdo centralizado sem campos excessivamente largos.
- 1024 × 768: rail extended 256 px, label visível e conteúdo até 960 px na área restante.
- Trocar largura ou tema não limpa input, seleção nem resultado de nenhum destino existente.

### Theme and hierarchy

- Tema escuro não apresenta body text ou todos os labels em verde; verde ocupa apenas os elementos reservados.
- Temas claro e escuro mantêm a mesma hierarquia e os mesmos papéis semânticos.
- Antes da execução, campo ativo + CTA primária constituem o foco visual; após a execução, o resultado técnico assume o foco e os controles permanecem subordinados.
- Cards estáticos não projetam sombra; borda/surface shift é suficiente para reconhecer a camada.
- Focus, disabled, error e selected são distinguíveis por forma/ícone/texto e passam contraste.

### Primitives and states

- Galeria/harness da fundação renderiza os sete estados, ação de copiar, resultado, métrica, campo e grupo de ações.
- Loading mantém contexto e resultado seguro; failure/cancelled não apagam evidência válida.
- Métrica sem valor mostra “Indisponível”; nunca zero, hífen sem explicação ou string vazia.
- Ações empilham antes de truncar em 360 px ou text scale 2.0.
- Hashes, IPs e unidades aparecem em monospace, podem quebrar e permanecem selecionáveis.

---

## Widget and Golden Verification

### Required widget tests

| Area | Objective assertions |
|------|----------------------|
| Destination catalog | três ids iniciais únicos; labels pt-BR não vazias; icon/selectedIcon; uma factory por destino; ordem Rede/Armazenamento/Hash |
| Breakpoints | 599 → Bar; 600 e 839 → rail recolhido; 840 → rail extended |
| Navigation | selecionar cada destino abre a página correta; tocar selecionado não recria; redimensionar preserva controller/estado |
| Growth rule | com cinco destinos fake, Bar contém três priorizados + “Ferramentas”; item não fixado mantém “Ferramentas” selecionado |
| Status panel | sete variants apresentam ícone, heading e body; `null` não vira zero; loading/failure/cancelled preservam child de resultado seguro |
| Copy | writer recebe valor exato; tooltip/semantics específico; um SnackBar “{Rótulo} copiado”; não há anúncio duplicado |
| Accessibility | `androidTapTargetGuideline`, `labeledTapTargetGuideline` e `textContrastGuideline` passam em claro/escuro |
| Text scale | 360, 720 e 1024 em 1.0 e 2.0 sem exceção/overflow; ações e valores permanecem alcançáveis |
| Regression | os oito testes existentes continuam verdes; nenhuma lógica de cálculo é alterada |

### Required goldens

Manter quatro baselines de alto valor; não congelar cada tela existente antes da migração da Phase 2.

| Golden | Viewport | Theme | Required content |
|--------|----------|-------|------------------|
| primitives compact light | 360 × 800 | light | campos, action group, resultado/métrica/cópia e sete estados em gallery rolável controlada |
| primitives compact dark | 360 × 800 | dark | mesma gallery; comprova texto neutro e accent restrito |
| shell medium light | 720 × 1024 | light | rail recolhido, três destinos, seleção e conteúdo centralizado |
| shell expanded dark | 1024 × 768 | dark | rail extended, labels, surface hierarchy e max width |

Golden producer inicial: Windows, Flutter 3.44.x, DPR 1, tamanho físico fixo, animações concluídas e nenhuma fonte/rede remota. Atualização de baselines exige revisão visual explícita; diffs não são aceitos automaticamente.

### Manual gate

- Inspecionar 360, 600, 720, 840 e 1024 em claro/escuro.
- Executar TalkBack em Android para navegação, campos, estados e feedback de cópia.
- Confirmar visualmente ausência de overflow, texto neon dominante, bordas agressivas, ellipsis essencial e campos esticados.

---

## Phase Boundary and Incremental Migration

### Phase 1 includes

- aprovar este UI-SPEC;
- criar catálogo tipado com os três destinos atuais;
- substituir `BottomNavigationBar` por shell `NavigationBar`/`NavigationRail` adaptativo;
- preservar páginas atuais em `IndexedStack` durante navegação e resize;
- centralizar breakpoints, tokens e temas semânticos claro/escuro;
- disponibilizar as primitives compartilhadas e gallery/harness de teste;
- corrigir somente o título “Network Calculator” para “Calculadora de Rede”;
- adicionar widget/accessibility/golden tests da fundação.

### Phase 1 explicitly excludes

- migração completa das três screens para todas as primitives;
- alteração de validação, cálculo, resultado ou serviço existente;
- destino ou lógica de “Diagnóstico de Internet”;
- qualquer request, socket, provider, backend, persistência, analytics ou permissão;
- pacote novo, router novo, framework de estado, form builder ou fonte remota;
- speed test ou promessa de paridade multiplataforma.

### Phase 2 owns

- adotar `ToolScaffold`, seções, action group, result/metric/copy nas três telas, uma por vez;
- substituir cores, radius, rows rígidas e copy local divergentes;
- preservar integralmente rede IPv4, conversão e hashes com testes de regressão;
- consolidar CTAs específicos (“Calcular rede”, “Analisar capacidade”, “Gerar hashes”) sem mudar resultados.

Definition of “foundation ready”: shell e primitives estão integrados/testáveis, mas as três telas podem continuar com anatomia local até a Phase 2. Não marcar migração visual completa como entregue na Phase 1.

---

## Registry Safety

| Registry | Blocks Used | Safety Gate |
|----------|-------------|-------------|
| shadcn official | nenhum | não aplicável — projeto Flutter, `components.json` ausente, verificado em 2026-08-10 |
| third-party | nenhum | não aplicável — nenhum registry ou block declarado em 2026-08-10 |

Somente componentes do Flutter Material SDK e código local entram no contrato. Não há registry de terceiros a vetar.

---

## Decision Provenance

| Source | Decisions applied |
|--------|-------------------|
| `01-CONTEXT.md` | D-01 a D-18: navegação, identidade, primitives, estados, responsividade, acessibilidade e teste |
| `01-RESEARCH.md` | stack Flutter/M3, `LayoutBuilder`, `IndexedStack`, tema semântico, sem package novo, matriz de testes e boundary incremental |
| `REQUIREMENTS.md` | UI-01 a UI-09 e Definition of Done |
| Codebase | três destinos atuais, temas claro/escuro, padrões de spacing aproveitáveis em 8/16, copy de hash e gaps de responsividade existentes |
| UI-SPEC defaults | paleta exata, escala 4–64, radius 4/8/12, elevation 0/2, max widths 720/960 e copy canônica |

---

## Checker Sign-Off

- [x] Dimension 1 Copywriting: VERIFIED
- [x] Dimension 2 Visuals: VERIFIED
- [x] Dimension 3 Color: VERIFIED
- [x] Dimension 4 Typography: VERIFIED
- [x] Dimension 5 Spacing: VERIFIED
- [x] Dimension 6 Registry Safety: VERIFIED

**Approval:** approved on 2026-08-10 — UI checker completed with 6/6 dimensions VERIFIED and no recommendations.
