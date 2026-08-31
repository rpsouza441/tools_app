# Roadmap: Tools App — Diagnóstico de Internet e Evolução da UI

## Overview

Este milestone evolui o aplicativo sem reescrita total: primeiro estabelece e implementa um contrato visual adaptativo, depois migra com segurança as três ferramentas existentes, entrega o diagnóstico de Internet como um fluxo completo e resiliente, comprova o comportamento em Android e publica documentação coerente com a implementação. Por fim, uma fase independente decide, com evidências, se existe base técnica, legal e operacional para planejar um teste de velocidade; `NO-GO` e adiamento são resultados válidos.

## Phases

**Phase Numbering:**

- Integer phases (1, 2, 3): planned milestone work
- Decimal phases (2.1, 2.2): urgent insertions, marked as `INSERTED`

- [x] **Phase 1: Contrato visual e fundação adaptativa** - Definir o UI-SPEC e tornar a base visual, a navegação e os estados compartilhados adaptativos e acessíveis. (completed 2026-08-31)
- [x] **Phase 2: Migração segura das ferramentas atuais** - Levar as três ferramentas existentes à nova fundação sem perda funcional. (completed 2026-08-31)
- [ ] **Phase 3: Diagnóstico de Internet completo e resiliente** - Entregar o fluxo de diagnóstico transparente, progressivo, cancelável e testável de ponta a ponta.
- [ ] **Phase 4: Validação Android e documentação transparente** - Comprovar os cenários Android reais e documentar capacidades, permissões, terceiros e privacidade.
- [ ] **Phase 5: Gate de viabilidade do speed test** - Registrar uma decisão formal `GO` ou `NO-GO` antes de qualquer plano de implementação de teste de velocidade.

## Phase Details

### Phase 1: Contrato visual e fundação adaptativa

**Goal:** As a profissional de TI, I want to usar a fundação adaptativa e acessível, so that eu opere as ferramentas com clareza.
**Mode:** mvp
**Depends on:** Nothing (first phase)
**Requirements:** UI-01, UI-02, UI-03, UI-04, UI-05, UI-06, UI-07, UI-08, UI-09
**Success Criteria** (what must be TRUE):

  1. Usuário pode localizar e abrir qualquer destino por uma navegação definida no UI-SPEC que se adapta de largura compacta para larga sem ficar superlotada.
  2. Usuário reconhece a mesma hierarquia de títulos, entradas, ações, cards, resultados e estados vazio, carregando, sucesso, falha, offline, permissão negada e cancelamento em toda a fundação compartilhada.
  3. Usuário pode operar a interface em tema claro ou escuro, sempre em português do Brasil, sem perder contraste, significado ou confirmação acessível ao copiar valores.
  4. Usuário pode usar alvos de toque acessíveis, leitor de tela e fonte ampliada sem perder conteúdo, ações ou compreensão em larguras compactas e largas.

**Plans:** 11/11 plans complete

Executed (original):

- [x] 01-01-PLAN.md — Catálogo tipado e shell adaptativo
- [x] 01-02-PLAN.md — Tokens e temas semânticos
- [x] 01-03-PLAN.md — Primitives e sete estados
- [x] 01-04-PLAN.md — Galeria, a11y e goldens
- [x] 01-05-PLAN.md — Gate humano (autoaprovado; refeito em 01-11)

Gap-closure:

**Wave 1**

- [x] 01-06-PLAN.md — Contrato MVP (docs) — gap-closure
- [x] 01-07-PLAN.md — Navegação adaptativa e semântica — gap-closure
- [x] 01-08-PLAN.md — Tema canônico e sete estados — gap-closure

**Wave 2** *(blocked on Wave 1 completion)*

- [x] 01-09-PLAN.md — Cópia, lifecycle e API pública — gap-closure

**Wave 3** *(blocked on Wave 2 completion)*

- [x] 01-10-PLAN.md — Reflow, a11y real, galeria pt-BR e goldens — gap-closure

**Wave 4** *(blocked on Wave 3 completion)*

- [x] 01-11-PLAN.md — Gate humano Android/TalkBack — gap-closure

**UI hint:** yes

### Phase 2: Migração segura das ferramentas atuais

**Goal:** Usuários continuam resolvendo as mesmas tarefas nas três ferramentas existentes depois da migração para a nova fundação visual.
**Mode:** mvp
**Depends on:** Phase 1
**Requirements:** PRES-01, PRES-02, PRES-03, PRES-04
**Success Criteria** (what must be TRUE):

  1. Usuário calcula redes IPv4 e obtém os mesmos resultados válidos de antes da migração.
  2. Usuário converte armazenamento decimal e binário e obtém os mesmos resultados válidos de antes da migração.
  3. Usuário gera hashes MD5, SHA-1, SHA-256 e SHA-512 e obtém os mesmos resultados válidos de antes da migração.
  4. Usuário encontra entradas, ações, resultados e cópia das três ferramentas disponíveis durante e depois da migração incremental, sem perda de funcionalidade.

**Plans:** 4/4 plans complete

**Wave 1**

- [x] 02-01-PLAN.md — Harness de tema e fumaça PRES-04 das três ferramentas

**Wave 2** *(blocked on Wave 1)*

- [x] 02-02-PLAN.md — Migrar Calculadora de Rede (PRES-01)

**Wave 3** *(blocked on Wave 2)*

- [x] 02-03-PLAN.md — Migrar Conversor de Armazenamento (PRES-02)

**Wave 4** *(blocked on Wave 3)*

- [x] 02-04-PLAN.md — Migrar Gerador de Hash, cópia e gate PRES-04 (PRES-03)

**UI hint:** yes

### Phase 3: Diagnóstico de Internet completo e resiliente

**Goal:** Usuários executam um diagnóstico de conectividade honesto, progressivo, cancelável e resistente a falhas parciais.
**Mode:** mvp
**Depends on:** Phase 2
**Requirements:** DIAG-01, DIAG-02, DIAG-03, DIAG-04, DIAG-05, DIAG-06, DIAG-07, DIAG-08, DIAG-09, DIAG-10, DIAG-11, DIAG-12, DIAG-13, DIAG-14, DIAG-15, QUAL-01, QUAL-02, QUAL-03, QUAL-04, QUAL-05, QUAL-06, QUAL-07, QUAL-08
**Success Criteria** (what must be TRUE):

  1. Usuário inicia manualmente somente um diagnóstico por vez e vê separadamente transporte, capacidades Android, IPv4 local, gateway e IP público, com proveniência, horário e indisponibilidade explícita quando algum fato não pode ser obtido.
  2. Usuário executa probes do gateway e de um alvo externo autorizado e vê método real, alvo, porta ou URL, timeout, limitações, mínimo, média, máximo, tentativas, sucessos e falhas com denominador explícito.
  3. Usuário acompanha o progresso por etapa, conserva resultados concluídos diante de falha parcial e pode cancelar ou repetir sem spinner infinito, mistura entre redes, recursos órfãos ou respostas tardias alterando o estado.
  4. Usuário consulta o último resultado da sessão e copia ou compartilha um resumo com timestamp, contexto de rede, métricas, proveniência, falhas e limitações, sem criar histórico persistente.
  5. Usuário utiliza o diagnóstico sem localização, telemetria ou envio de resultados a analytics e recebe comportamento previsível em sucesso, timeout, offline, resposta inválida, cancelamento, troca de rede, lifecycle e falhas parciais.

**Plans:** TBD
**UI hint:** yes

### Phase 4: Validação Android e documentação transparente

**Goal:** Usuários recebem um diagnóstico comprovado nos cenários Android-alvo e documentação pública fiel ao comportamento entregue.
**Mode:** mvp
**Depends on:** Phase 3
**Requirements:** QUAL-09, DOC-01, DOC-02, DOC-03, DOC-04
**Success Criteria** (what must be TRUE):

  1. Usuário executa o diagnóstico em Android verificado com Wi-Fi, dados móveis e modo offline sem travamento nem conclusão enganosa.
  2. Usuário consulta no README somente capacidades, limitações e plataformas que foram realmente verificadas.
  3. Usuário consulta quais permissões Android são usadas, por que são necessárias e que localização não é solicitada enquanto SSID/BSSID permanecem fora do escopo.
  4. Usuário identifica o serviço externo de IP público, os dados que ele recebe e a política de privacidade aplicável.
  5. Usuário consulta uma política de privacidade coerente com a ausência de conta, telemetria e histórico persistente.

**Plans:** TBD

### Phase 5: Gate de viabilidade do speed test

**Goal:** Usuários só recebem um futuro plano de speed test quando uma decisão de viabilidade completa e verificável autoriza esse trabalho.
**Mode:** mvp
**Depends on:** Phase 4
**Requirements:** GATE-01, GATE-02
**Success Criteria** (what must be TRUE):

  1. Usuário pode consultar uma decisão formal que cobre provedor ou protocolo, licença e termos, custos e capacidade, geografia, privacidade, retenção ou publicação, metodologia, precisão, testabilidade e seleção de servidor antes de qualquer plano de implementação.
  2. Usuário vê um resultado explícito `NO-GO` com o speed test adiado quando qualquer critério obrigatório carece de evidência; somente um `GO` integral pode liberar requisitos `SPD-*` para um milestone posterior.

**Plans:** TBD

## Progress

**Execution Order:** Phases execute in numeric order: 1 → 2 → 3 → 4 → 5.

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Contrato visual e fundação adaptativa | 11/11 | Complete    | 2026-08-31 |
| 2. Migração segura das ferramentas atuais | 4/4 | Complete    | 2026-08-31 |
| 3. Diagnóstico de Internet completo e resiliente | 0/TBD | Not started | - |
| 4. Validação Android e documentação transparente | 0/TBD | Not started | - |
| 5. Gate de viabilidade do speed test | 0/TBD | Not started | - |

---
*Roadmap created: 2026-08-10*
*Coverage: 43/43 v1 requirements mapped exactly once; v2 `SPD-*` requirements excluded*
