# Tools App — Diagnóstico de Internet e Evolução da UI

## What This Is

O Tools App é um aplicativo Flutter, Android-first e offline sempre que possível, voltado a utilidades para profissionais e estudantes de TI. Este ciclo moderniza a interface das ferramentas existentes e adiciona uma área de Diagnóstico de Internet com medições transparentes, canceláveis e resilientes, seguida por uma extensão separada de teste de velocidade quando houver uma solução técnica e legal confiável.

## Core Value

Oferecer diagnósticos técnicos úteis e honestos em uma interface clara, sem ocultar limitações de plataforma, método de medição ou falhas parciais. O Diagnóstico de Internet é um **resumo honesto da rede** para apoiar a avaliação técnica (ex.: um técnico avaliando um Wi-Fi), não um teste pass/fail.

## Current State

**Shipped:** v1.0 — Diagnóstico de Internet e Evolução da UI (2026-09-19).

- 5 fases concluídas (Phases 1–5, 30 planos); auditoria de milestone `passed`.
- Fundação visual adaptativa (Material 3, temas, acessibilidade); três ferramentas
  migradas (Rede/Armazenamento/Hash); Diagnóstico de Internet honesto, cancelável e
  resiliente; validação em Android físico (Wi-Fi/4G/offline) + emulador; README e
  PRIVACY.md fiéis ao implementado.
- **Gate do speed test:** `NO-GO — ADIADO` — nenhum candidato (Cloudflare/Ookla/M-Lab/
  LibreSpeed próprio) atende todos os critérios obrigatórios; SPD-* diferidos.
- Arquivos: [`milestones/v1.0-ROADMAP.md`](./milestones/v1.0-ROADMAP.md),
  [`milestones/v1.0-REQUIREMENTS.md`](./milestones/v1.0-REQUIREMENTS.md),
  [`v1.0-MILESTONE-AUDIT.md`](./v1.0-MILESTONE-AUDIT.md).

## Next Milestone Goals

_A definir._ Candidatos naturais (não comprometidos):

- Reavaliar o speed test se algum gatilho de `05-SPEED-TEST-GATE.md §8` passar a ter
  evidência (SDK/API oficial com termos claros; custo/termos aceitáveis; infraestrutura
  própria orçada; metodologia/testabilidade demonstrável).
- Evoluções EVO-01..EVO-03 (repetir etapa do diagnóstico; recomendações auditáveis;
  fallback adicional de IP/probe sob termos aprovados).

Inicie o próximo ciclo com `/gsd-new-milestone` (numeração de fases continua a partir de 6).

## Requirements

### Validated

- ✓ Modernizar a arquitetura visual e a navegação do aplicativo com Material 3, temas claro/escuro, responsividade e acessibilidade, sem reescrita total. — Phase 1
- ✓ Criar componentes reutilizáveis para entrada, execução, métricas, resultados, cópia, carregamento e estados de falha. — Phase 1
- ✓ Preservar e migrar sem regressões a calculadora IPv4, o conversor de armazenamento e o gerador de hashes. — Phase 2
- ✓ Entregar diagnóstico básico de conectividade com transporte, IPv4 local, IP público, endereço do gateway quando disponível e teste HTTPS de alcance/latência com método explicitado (sem probe TCP ao gateway; sem ICMP). — Phase 3 (DIAG-06 descopado na Phase 4)
- ✓ Suportar múltiplas amostras, mínimo/média/máximo, perdas ou falhas, resultados parciais, última execução e resumo copiável/compartilhável. — Phase 3
- ✓ Garantir timeout, cancelamento, lifecycle Android e lógica de medição testável fora dos widgets. — Phase 3
- ✓ Atualizar README, política de privacidade e documentação das permissões Android realmente necessárias. — Phase 4 (verificada em Android físico 2026-09-19)

### Active

- [ ] Pesquisar e, somente se viável, entregar teste de velocidade separado com limites claros de dados, duração, precisão, privacidade e infraestrutura sustentável. — Phase 5 (gate GO/NO-GO; não implementar antes da decisão)

### Out of Scope

- Backend, contas de usuário e sincronização — contrariam a simplicidade local-first deste ciclo.
- Histórico persistente de diagnósticos — adiado para evitar persistência e escopo sem valor validado.
- Telemetria ou analytics de identificadores e resultados — incompatíveis com a política de privacidade definida.
- Coleta de SSID/BSSID ou permissão de localização — excluída enquanto nenhuma funcionalidade exigir esses dados.
- Paridade garantida entre Android, web, desktop e iOS — capacidades de rede variam por plataforma e devem ser verificadas antes de qualquer promessa.
- Execução automática de speed test — consumo de dados exige consentimento explícito do usuário.
- Acoplamento a endpoints públicos frágeis ou juridicamente inadequados — a fase de velocidade deve ser adiada se não houver solução estável, licenciada e testável.

## Context

- O aplicativo existente usa Flutter, Material 3, navegação inferior, temas claro/escuro e separação entre telas, serviços, modelos e validadores.
- As três ferramentas atuais são calculadora de rede IPv4, conversor decimal/binário de armazenamento e gerador de hashes MD5, SHA-1, SHA-256 e SHA-512.
- A quantidade crescente de ferramentas exige reavaliar a navegação: home em grade/categorias, NavigationBar, NavigationRail e adaptação por largura devem ser comparadas no design contract.
- O diagnóstico deve continuar útil em Wi-Fi, dados móveis, modo offline, ausência de gateway, captive portal e indisponibilidade do serviço de IP público.
- ICMP não pode ser presumido. A pesquisa comparou ICMP, TCP e HTTPS; ICMP e latência de roteamento real ficaram **fora do escopo do MVP** (exigiriam subprocesso `ping` ou plugin nativo não confiável). A UI nomeia com precisão o método realmente usado (HTTPS), nunca "ping".
- Decisão validada em teste físico (Redmi Note 12 Pro, HyperOS 1.0.33, 4G e Wi-Fi): o probe TCP ao gateway quase sempre reportava *indisponível* (roteadores/gateways de operadora filtram as portas 80/443 e um TCP connect cru não prova que a página administrativa abre), confundindo o usuário sem agregar valor. O **probe TCP do gateway foi removido**; o **endereço** do gateway permanece como fato. A latência que importa ("a internet responde?") é coberta pelo probe HTTPS.
- Resultados parciais permanecem visíveis quando uma medição falha; nenhum erro de rede pode travar o aplicativo.
- O speed test é uma extensão posterior e condicionada à decisão sobre infraestrutura, termos, custos, seleção geográfica, consumo de dados e precisão alcançável.
- A definição global de pronto inclui análise estática limpa, testes aprovados, verificação Android em Wi-Fi/dados móveis/offline, responsividade e ausência de regressões.

## Constraints

- **Tech stack**: Manter Flutter e Material 3 — preservar a base existente e evitar reescrita.
- **Platform**: Android-first — outras plataformas recebem somente capacidades verificadas e honestamente limitadas.
- **Language**: Interface em português do Brasil — manter consistência com o público atual.
- **Architecture**: Encapsular IP público, gateway, probes e speed test atrás de interfaces independentes — permitir simulação, testes e troca de provedores.
- **Concurrency**: Não bloquear a isolate principal nem executar comandos de shell pela UI — proteger responsividade e portabilidade.
- **Lifecycle**: Tratar pausa, retomada, cancelamento e descarte da tela no Android — evitar recursos vazando e resultados tardios.
- **Networking**: Toda operação externa deve ter timeout e cancelamento — garantir recuperação previsível.
- **Privacy**: Não enviar identificadores ou resultados a analytics — minimizar coleta e exposição de dados.
- **Permissions**: Evitar localização sem necessidade comprovada de SSID/BSSID — aplicar privilégio mínimo.
- **Quality**: Preservar funcionalidades e testes existentes; incluir testes unitários, de widget e goldens centrais quando úteis — impedir regressões verificáveis.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Evoluir a UI antes ou em fatias compatíveis com o diagnóstico, sem reescrita total | Reduz risco e mantém as ferramentas atuais utilizáveis durante a migração | Phase 1 fundação; Phase 2 migrou Rede, Armazenamento e Hash para ToolScaffold |
| Tratar conectividade, gateway, IP público e probes como adaptadores independentes | Isola limitações de plataforma e torna falhas, fallbacks e testes controláveis | ✓ Phase 3 — sete contratos D-05 injetáveis, sem NetworkService |
| Exibir o método real de latência em vez de chamar todo probe de ping | Evita alegações tecnicamente incorretas e melhora a confiança do usuário | ✓ Phase 3 — rotulado "HTTPS"; ICMP sempre "indisponível", nunca "ping" |
| Remover o probe TCP do gateway, mantendo o endereço | Em teste físico (4G/Wi-Fi) reportava quase sempre *indisponível* e confundia o usuário; TCP connect cru não prova que a página do gateway abre; latência de roteamento real (ICMP) está fora do escopo do MVP | ✓ Phase 4 (2026-09-09) — probe removido, endereço mantido; app definido como resumo honesto da rede |
| Padronizar o alinhamento dos estados do diagnóstico ao centro | "Concluído" ficava à esquerda e "Processando" ao centro; inconsistência apontada em teste físico | ✓ Phase 4 (2026-09-09) — ToolStatusPanel renderiza o card de resultados centralizado em todos os estados |
| Condicionar speed test a infraestrutura legal, estável e testável | Evita dependência frágil, custos imprevistos e resultados enganosos | ✓ Phase 5 (2026-09-19) — gate formal `NO-GO — ADIADO`; nenhum candidato (Cloudflare/Ookla/M-Lab/LibreSpeed próprio) atende todos os critérios; SPD-* diferidos |
| Usar consentimento explícito e limites de dados no speed test | Protege usuários em rede móvel e mantém o consumo previsível | — Diferido (condicionado a um futuro `GO`; ver `05-SPEED-TEST-GATE.md §8`) |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `$gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `$gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-09-19 — Milestone v1.0 SHIPPED e arquivado (audit passed; tag v1.0 local, sem push). Speed test em `NO-GO — ADIADO`; SPD-* diferidos. Próximo ciclo via `/gsd-new-milestone` (fases a partir de 6).*
