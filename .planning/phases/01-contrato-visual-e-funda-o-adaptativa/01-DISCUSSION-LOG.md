# Phase 1: Contrato visual e fundação adaptativa - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-08-10
**Phase:** 1-Contrato visual e fundação adaptativa
**Areas discussed:** Estrutura de navegação, Identidade visual técnica, Anatomia das ferramentas, Responsividade e acessibilidade

---

## Estrutura de navegação

| Option | Description | Selected |
|--------|-------------|----------|
| Catálogo adaptativo com NavigationBar/NavigationRail | Uma fonte tipada de destinos alimenta shell compacto e amplo e permite crescimento controlado. | ✓ |
| Home em grade como única navegação | Todos os destinos partem de um catálogo visual, adicionando uma etapa para trocar de ferramenta. | |
| Manter BottomNavigationBar fixa | Menor mudança imediata, mas não resolve adaptação ou crescimento. | |

**User's choice:** Auto-selecionado: catálogo adaptativo com NavigationBar/NavigationRail.
**Notes:** Opção recomendada por Material 3 e compatível com o código atual sem impor uma home extra neste momento.

---

## Identidade visual técnica

| Option | Description | Selected |
|--------|-------------|----------|
| Matrix contida e legível | Verde como acento, neutros para leitura e monospace só para valores técnicos. | ✓ |
| Neon verde dominante | Preserva o visual atual, mas mantém contraste e hierarquia frágeis. | |
| Identidade neutra sem verde | Maximiza neutralidade, mas apaga um traço reconhecível do app. | |

**User's choice:** Auto-selecionado: Matrix contida e legível.
**Notes:** A identidade técnica é preservada sem usar cor como único sinal.

---

## Anatomia das ferramentas

| Option | Description | Selected |
|--------|-------------|----------|
| Primitives incrementais | Componentes pequenos para shell, seções, resultados, métricas, estados e cópia. | ✓ |
| Form builder genérico | Centraliza tudo, mas cria abstração prematura e aumenta o risco de reescrita. | |
| Componentes privados por tela | Mantém velocidade local, mas perpetua inconsistência e duplicação. | |

**User's choice:** Auto-selecionado: primitives incrementais.
**Notes:** A Phase 1 estabiliza contratos; a Phase 2 migra cada ferramenta.

---

## Responsividade e acessibilidade

| Option | Description | Selected |
|--------|-------------|----------|
| Contrato constraint-driven e acessível | Layout por espaço, faixas compacta/média/ampla, toque, semântica e escala de fonte desde a base. | ✓ |
| Um breakpoint fixo simples | Menor custo inicial, mas insuficiente para shell e conteúdo variado. | |
| Otimização apenas para telefone | Contraria os requisitos de largura compacta e larga. | |

**User's choice:** Auto-selecionado: contrato constraint-driven e acessível.
**Notes:** Limiar inicial de 600/840 logical pixels, sujeito a validação visual sem alterar o princípio.

## the agent's Discretion

- Nomes e organização interna dos widgets.
- Tokens finais de espaçamento, radius, elevation e largura máxima após QA visual.
- Estratégia interna de rotas e conjunto mínimo de goldens.

## Deferred Ideas

None.
