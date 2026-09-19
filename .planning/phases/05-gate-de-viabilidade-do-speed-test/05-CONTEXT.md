# Phase 5: Gate de viabilidade do speed test - Context

**Gathered:** 2026-09-19
**Status:** Ready for planning

<domain>
## Phase Boundary

Esta fase produz **uma decisão formal, auditável e verificável `GO`/`NO-GO`**
sobre a viabilidade técnica, jurídica, financeira, de privacidade e operacional
de um futuro teste de velocidade (GATE-01, GATE-02).

**É um gate de decisão, não uma justificativa para implementar speed test.**

- **Entrega:** um artefato canônico de decisão + verificação de GATE-01/GATE-02.
- **NÃO entrega:** nenhum código de speed test, nenhum SDK de produção, nenhuma
  UI de speed test, nenhuma dependência nova de produto. Escolher/integrar
  provedor pertence a uma fase posterior, condicionada a um `GO` integral.
- `NO-GO`/adiamento são resultados de **sucesso** válidos para a fase.
- SPD-01..SPD-09 permanecem diferidos até um `GO` integral; um `GO` aqui apenas
  **libera** SPD-* para planejamento em milestone/fase futura — não autoriza
  implementação nesta sessão.

</domain>

<decisions>
## Implementation Decisions

### 1. Formato e local do artefato de decisão
- **D-01:** O artefato canônico da decisão é um documento dedicado da fase:
  `.planning/phases/05-gate-de-viabilidade-do-speed-test/05-SPEED-TEST-GATE.md`.
- **D-02:** Estrutura mínima obrigatória do documento, nesta ordem:
  1. Objetivo e escopo
  2. Opções/provedores avaliados
  3. Tabela critério por critério
  4. Evidência/fonte (por critério)
  5. Status de cada critério
  6. Riscos/limitações
  7. Veredito global
  8. Condições para futura reavaliação
  9. Data da decisão
- **D-03:** Status permitidos **por critério**: `PASS` (evidência suficiente),
  `FAIL` (evidência mostra que não atende), `INSUFFICIENT` (evidência
  insuficiente para afirmar que atende), `N/A` (somente quando realmente não
  aplicável, **com justificativa**).
- **D-04:** **Proibido** usar linguagem especulativa ("provavelmente", "parece
  adequado" ou equivalente) como base de um `PASS`. PASS exige evidência
  independente e citável.
- **D-05:** O usuário consulta a decisão **pelo próprio documento**. Referência
  em README/PROJECT é permitida **somente se fizer sentido no escopo atual**.
  **Não criar UI dentro do app** para satisfazer GATE-01.

### 2. Régua de evidência (GATE-01) e regra global (GATE-02)
- **D-06:** GATE-01 exige evidência independente para, no mínimo, os seguintes
  critérios obrigatórios:
  provedor/protocolo; licença e termos de uso; **autorização para uso da
  infraestrutura** (distinta da licença do cliente); custo; limites/capacidade
  (rate limits); geografia/seleção de servidor; privacidade; retenção/publicação
  de resultados; metodologia; consumo máximo de dados; duração;
  precisão/limitações; testabilidade; cancelamento; seleção de servidor;
  sustentabilidade operacional.
- **D-07:** **Regra de agregação global:** `GO` **somente se TODOS** os critérios
  obrigatórios estiverem `PASS`. Qualquer `FAIL` ou `INSUFFICIENT` em critério
  obrigatório **impede** `GO` (satisfaz GATE-02).
- **D-08:** Vereditos globais possíveis:
  - `GO` — todos os critérios obrigatórios têm evidência suficiente (PASS).
  - `NO-GO — ADIADO` — existe `FAIL`/`INSUFFICIENT` reavaliável no futuro.
  - `NO-GO — DESCARTADO` — **somente** com evidência forte de inviabilidade
    estrutural (não apenas ausência de informação).
- **D-09:** **Preferência do milestone:** quando o problema for ausência de
  evidência, termos, infraestrutura ou garantia suficiente, o resultado deve ser
  `NO-GO — ADIADO`, **não** `DESCARTADO`. Não transformar "não encontramos prova"
  em "é proibido". Usar `INSUFFICIENT` quando essa for a conclusão correta.

### 3. Profundidade da investigação
- **D-10:** **Não** apenas copiar a pesquisa existente. Fazer **pesquisa
  atualizada** (web/documental) antes da decisão final.
- **D-11:** Avaliar candidatos reais, incluindo **no mínimo** os já levantados:
  **Cloudflare, Ookla, M-Lab** e qualquer alternativa tecnicamente relevante
  encontrada durante a pesquisa.
- **D-12:** Para cada candidato, investigar documentalmente: existência de
  API/SDK/protocolo apropriado ao nosso caso; licença do cliente; termos da
  infraestrutura; uso permitido por apps de terceiros; limites/rate limits;
  custos; seleção geográfica; privacidade; retenção; publicação dos resultados;
  metodologia; upload e download controlados; tamanho de dados; cancelamento;
  possibilidade de testes automatizados/reprodutíveis.
- **D-13:** **Distinção crítica (regra dura):** licença de biblioteca/SDK **NÃO**
  prova autorização para usar os servidores públicos do provedor. Endpoint
  acessível publicamente **NÃO** significa endpoint permitido para uso em
  produto. São contratos distintos e devem ser avaliados separadamente.
- **D-14:** **Proibido:** WebView, endpoints informais, ou engenharia reversa de
  apps concorrentes como base de viabilidade.
- **D-15:** **Spike técnico** só é permitido se houver dúvida que não possa ser
  resolvida documentalmente **e** se o spike: (a) **não** implementar speed test
  no produto; (b) **não** criar dependência permanente; (c) **não** violar
  termos; (d) tiver objetivo estritamente de verificar viabilidade.
- **D-16:** **Não contatar fornecedor comercial** nesta fase, a menos que seja
  realmente necessário para resolver um critério obrigatório **e** não exista
  informação pública suficiente. Se a decisão depender de contato comercial,
  registrar o critério como `INSUFFICIENT` + condição de reavaliação, em vez de
  bloquear a fase indefinidamente.

### 4. Neutralidade e resultado
- **D-17:** **Não** começar a fase já decidindo `NO-GO`. Investigar primeiro e
  aplicar a régua objetivamente. Também **não** "forçar" um `GO` apenas para
  liberar SPD-*.
- **D-18:** Se a pesquisa atualizada continuar sem identificar uma solução que
  atenda integralmente **todos** os critérios obrigatórios, o resultado correto é
  `NO-GO — ADIADO`. Nesse caso: a Phase 5 é concluída com **sucesso**; GATE-02 é
  satisfeito; SPD-01..09 permanecem diferidos; **nenhum** código de speed test é
  criado; o milestone atual pode ser encerrado normalmente.
- **D-19:** O documento deve registrar **exatamente** o que impediria o `GO` e
  quais mudanças futuras permitiriam reavaliação. Exemplos de gatilhos de
  reavaliação: provedor passa a oferecer SDK/API oficial com termos claros;
  infraestrutura própria passa a ser viável; custo/capacidade passa a ser
  aceitável; metodologia/testabilidade fica demonstrável.
- **D-20:** Se houver `GO`: isso **NÃO** autoriza implementação na Phase 5;
  apenas libera SPD-* para planejamento em milestone/fase posterior; nenhum speed
  test deve ser implementado nesta sessão.

### 5. Forma da fase (orientação ao planner)
- **D-21 [informational — satisfeita estruturalmente]:** O planner deve produzir uma
  fase **curta e focada**, sem feature implementation, com quatro blocos de trabalho.
  *Satisfeita pela estrutura de planos:* 05-01 (pesquisa/evidência), 05-02 (comparação
  de candidatos), 05-03 (gate formal `05-SPEED-TEST-GATE.md`), 05-04 (verificação
  GATE-01/GATE-02). É uma decisão de processo sobre a forma da fase, não uma capacidade
  a implementar — por isso marcada `[informational]` para o gate de cobertura de decisão.
  1. Pesquisa/evidência (atualizada, documental, por candidato) → 05-01
  2. Comparação dos candidatos (tabela critério por critério) → 05-02
  3. Gate formal (`05-SPEED-TEST-GATE.md` com veredito global e condições de
     reavaliação) → 05-03
  4. Verificação de GATE-01/GATE-02 (a decisão cobre todos os critérios
     obrigatórios e o veredito segue a regra de agregação D-07/D-08) → 05-04

### Claude's Discretion
- Layout exato da tabela critério por critério (colunas, ordenação), desde que
  contenha critério, status (PASS/FAIL/INSUFFICIENT/N/A), evidência/fonte e nota.
- Agrupamento dos critérios (ex.: técnico / jurídico / privacidade / operacional)
  desde que todos os obrigatórios de D-06 apareçam.
- Escolha das fontes de pesquisa e de quais candidatos adicionais (além de
  Cloudflare/Ookla/M-Lab) valem investigação, seguindo D-11.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Requisitos e escopo do gate
- `.planning/REQUIREMENTS.md` — GATE-01 (critérios obrigatórios) e GATE-02
  (adiamento explícito quando falta evidência); SPD-01..SPD-09 em "v2
  Requirements" (diferidos até `GO`); tabela "Out of Scope" (proibições:
  WebView/endpoint público informal de speed test).
- `.planning/ROADMAP.md` § "Phase 5: Gate de viabilidade do speed test" — Goal e
  Success Criteria (decisão formal + `NO-GO`/adiamento válidos).
- `.planning/PROJECT.md` — Key Decisions (speed test condicionado a
  infraestrutura legal/estável/testável; consentimento explícito e limites de
  dados) e "Out of Scope".

### Pesquisa de viabilidade já existente (ponto de partida, NÃO substitui D-10)
- `.planning/research/STACK.md` § "Speed Test: Deliberately Deferred Stack" e
  § "What NOT to Use" — lista de critérios de infraestrutura; nota de que o
  engine JS do Cloudflare (`@cloudflare/speedtest`) não é SDK Flutter nem prova
  de autorização de uso de terceiros; pacotes de speed test a evitar.
- `.planning/research/PITFALLS.md` — distinção "licença de cliente ≠ autorização
  de infraestrutura"; risco de consumo de dados/memória; sem background;
  cancelamento real.
- `.planning/research/FEATURES.md` — "speed test: table stakes somente após
  aprovação da fase separada"; métricas (Mbps down/up, latência ociosa/sob
  carga), orçamento de dados, indicador de confiança.
- `.planning/research/SUMMARY.md` — definição do **gate duro**: `GO` só se todos
  os critérios tiverem evidência; `NO-GO` encerra a fase com speed test adiado;
  ausência de solução aprovada não autoriza fallback informal.
- `.planning/research/ARCHITECTURE.md` § SpeedTestAdapter/Orchestrator — o
  isolamento arquitetural do futuro speed test (referência para pós-`GO`; não
  implementar agora).

### Artefato a ser produzido nesta fase
- `.planning/phases/05-gate-de-viabilidade-do-speed-test/05-SPEED-TEST-GATE.md`
  — documento canônico da decisão (estrutura em D-02; status em D-03; veredito
  em D-08).

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- Nenhum código de produto é criado nesta fase. O `SpeedTestEngine`/adapter é
  descrito na pesquisa (`research/STACK.md`, `research/ARCHITECTURE.md`) como
  interface isolada **sem implementação de produção** até o gate passar — serve
  apenas de referência para a régua de "testabilidade" (D-06), não como algo a
  construir aqui.

### Established Patterns
- Convenção de honestidade do projeto (nunca afirmar o não verificado; método
  real sempre nomeado) aplica-se ao gate: `PASS` exige evidência citável; nada
  de linguagem especulativa (D-04).
- Privilégio mínimo e privacidade (sem envio a analytics, consentimento de dados
  móveis) informam os critérios de privacidade/retenção/consumo de dados.

### Integration Points
- Nenhuma integração de runtime. A única "integração" é documental: o veredito
  pode ser referenciado em README/PROJECT **somente se fizer sentido** (D-05),
  sem UI no app.

</code_context>

<specifics>
## Specific Ideas

- Candidatos nomeados a avaliar obrigatoriamente: **Cloudflare, Ookla, M-Lab**
  (+ alternativas relevantes que surgirem) — D-11.
- Vocabulário de veredito fixo: `GO`, `NO-GO — ADIADO`, `NO-GO — DESCARTADO`
  (D-08), com preferência por `ADIADO` sobre `DESCARTADO` quando o bloqueio for
  falta de evidência/termos/infraestrutura (D-09).
- Regra dura repetida a pedido do usuário: SDK/biblioteca licenciada ≠
  autorização de infraestrutura; endpoint público acessível ≠ endpoint permitido
  em produto (D-13).

</specifics>

<deferred>
## Deferred Ideas

- **Implementação do speed test (SPD-01..SPD-09):** diferida; só entra em
  planejamento após um `GO` integral, em milestone/fase posterior. Não
  implementar nesta sessão nem nesta fase.
- **Infraestrutura própria de medição:** possível gatilho de reavaliação futura
  (D-19), fora do escopo atual.
- **Latência sob carga, orçamento configurável, indicador de confiança
  (FEATURES.md):** dependem de `GO` e de metodologia aprovada; fora do escopo do
  gate.
- **EVO-01..EVO-03:** evoluções posteriores não relacionadas ao gate.

</deferred>

---

*Phase: 5-gate-de-viabilidade-do-speed-test*
*Context gathered: 2026-09-19*
