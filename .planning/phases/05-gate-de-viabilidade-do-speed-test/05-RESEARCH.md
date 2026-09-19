# Phase 5: Gate de viabilidade do speed test - Research

**Researched:** 2026-09-19 (enquadramento de planejamento — evidência final é trabalho de EXECUÇÃO no bloco 05-01)
**Domain:** Decisão de viabilidade GO/NO-GO de um futuro teste de velocidade (sem implementação)
**Confidence:** N/A — este documento **não** emite vereditos. Ele define candidatos, critérios obrigatórios, método de evidência e fontes a verificar. Os vereditos por critério (PASS/FAIL/INSUFFICIENT/N/A) são produzidos na execução (bloco 05-01) e consolidados em `05-SPEED-TEST-GATE.md` (bloco 05-03).

> **Natureza deste arquivo.** No fluxo GSD, RESEARCH.md normalmente traz achados.
> Aqui, por decisão do usuário (CONTEXT D-10/D-17), a **pesquisa atualizada por
> candidato é trabalho da fase** (bloco 05-01), não do planejamento. Portanto este
> RESEARCH.md é o **enquadramento** da investigação: candidatos, critérios, método,
> regras duras e fontes a consultar. Ele **não** decide o gate e **não** substitui a
> pesquisa de execução. Nenhum veredito, nenhum "provavelmente".

<user_constraints>
## User Constraints (from 05-CONTEXT.md)

### Locked Decisions relevantes ao research
- **D-10:** Não copiar a pesquisa existente — fazer pesquisa **atualizada** antes da decisão.
- **D-11:** Avaliar no mínimo **Cloudflare, Ookla, M-Lab** + alternativas relevantes.
- **D-12:** Investigar por candidato o conjunto completo de critérios (ver matriz abaixo).
- **D-13 (regra dura):** licença de SDK/biblioteca ≠ autorização de uso da infraestrutura;
  endpoint público acessível ≠ endpoint permitido em produto.
- **D-14 (proibições):** sem WebView, endpoints informais ou engenharia reversa.
- **D-15:** spike técnico só se dúvida não resolvível documentalmente **e** sem implementar
  speed test / sem dependência permanente / sem violar termos / só verificar viabilidade.
- **D-16:** não contatar fornecedor comercial salvo necessidade real sem info pública →
  nesse caso registrar `INSUFFICIENT` + condição de reavaliação (não bloquear a fase).
- **D-17/D-18:** neutralidade — investigar antes; sem forçar GO nem assumir NO-GO;
  ausência de evidência/termos/infra → `NO-GO — ADIADO`, não "proibido".
</user_constraints>

## Candidatos a investigar (obrigatórios + expansão)

| # | Candidato | O que é (a confirmar na execução) | Ângulo principal de viabilidade |
|---|-----------|-----------------------------------|--------------------------------|
| C1 | **Cloudflare Speedtest** | Engine JS `@cloudflare/speedtest`; endpoints `speed.cloudflare.com` | Licença do cliente vs. autorização de uso da infraestrutura por app de terceiro nativo; coleta de medições; ToS |
| C2 | **Ookla (Speedtest.net)** | SDK comercial licenciado; rede de servidores | Custos/licenciamento comercial; termos para apps de terceiros; seleção de servidor |
| C3 | **M-Lab (NDT7)** | Plataforma aberta de medição; protocolo NDT7 sobre WebSocket/TLS | Termos de uso aceitável; publicação obrigatória de dados (privacidade/retenção); capacidade/sustentabilidade |
| C4 | **Infraestrutura própria** | Endpoint(s) controlado(s) do projeto | Custo/capacidade/sustentabilidade operacional; metodologia; testabilidade |
| C5+ | **Alternativas relevantes** | Ex.: LibreSpeed (self-host), outros open protocols | Descobertas durante a pesquisa; mesma matriz de critérios |

> A execução (05-01) pode adicionar/remover candidatos conforme a pesquisa, mantendo
> obrigatoriamente C1–C3 (D-11).

## Critérios obrigatórios do gate (matriz — esqueleto, sem veredito)

Cada candidato deve ser avaliado em **todos** os critérios abaixo, com status
`PASS` / `FAIL` / `INSUFFICIENT` / `N/A(justificado)` e **evidência/fonte citável**
(sem linguagem especulativa como base de PASS — D-04).

| Critério | Pergunta de viabilidade | Evidência aceitável |
|----------|-------------------------|---------------------|
| Provedor/protocolo | Existe API/SDK/protocolo apropriado ao nosso caso (Flutter/Android, nativo)? | Doc oficial do protocolo/SDK |
| Licença do cliente/SDK | Qual a licença da biblioteca/SDK cliente? | Arquivo de licença / pub.dev / repo |
| **Autorização de infraestrutura** | O uso dos servidores por app de **terceiro** é permitido? (≠ licença do cliente, D-13) | ToS/AUP do provedor, contrato, política pública |
| Termos de uso | Termos de uso/serviço aplicáveis e suas restrições | ToS oficial |
| Custos | Há custo? Modelo (grátis/pago/enterprise)? | Página de preços / contrato |
| Limites/rate limits/capacidade | Limites de uso, quotas, capacidade sustentável | Doc oficial / política de fair use |
| Geografia | Cobertura geográfica; relevante ao público-alvo | Doc de rede/servidores |
| Seleção de servidor | É possível/necessário selecionar servidor? Como? | Doc do protocolo/SDK |
| Privacidade | Que dados o provedor recebe/observa (IP, resultados)? | Política de privacidade |
| Retenção | Retenção de resultados/dados pelo provedor | Política de dados |
| Publicação de resultados | Resultados são publicados/compartilhados? (ex.: M-Lab) | ToS/AUP |
| Metodologia | Metodologia de medição (down/up/latência); é benchmark ou estimativa? | Doc metodológico |
| Download | Suporta download controlado e observável? | Doc do protocolo |
| Upload | Suporta upload controlado e observável? | Doc do protocolo |
| Consumo máximo de dados | É possível limitar/estimar bytes transferidos? | Doc/capacidade do protocolo |
| Duração | É possível limitar/estimar duração? | Doc/capacidade do protocolo |
| Precisão e limitações | Precisão declarada e limitações conhecidas | Doc/estudos oficiais |
| Cancelamento | É possível cancelar imediatamente e liberar recursos? | Doc do SDK/protocolo |
| Testabilidade | Há endpoint controlado / adaptador simulável para testes reprodutíveis? | Doc / viabilidade de mock |
| Sustentabilidade operacional | Solução é sustentável a longo prazo (custo/capacidade/manutenção)? | Síntese das evidências acima |

## Método de evidência (a aplicar na execução, bloco 05-01)

1. **Somente fontes documentais públicas** por candidato: documentação oficial,
   ToS/AUP, política de privacidade, páginas de preços, repositório/licença.
2. **Citar a fonte** (URL + o que ela comprova) para cada status. Sem fonte → `INSUFFICIENT`.
3. **Distinguir explicitamente** (D-13) licença do cliente de autorização de
   infraestrutura; ambos são critérios separados na matriz.
4. **Não** usar WebView/endpoint informal/engenharia reversa como base (D-14).
5. **Spike** apenas sob as condições de D-15 (verificação de viabilidade, sem
   implementar/depender/violar). Nenhum spike é pré-autorizado aqui.
6. **Contato comercial** evitado (D-16); se um critério obrigatório só puder ser
   resolvido por contato e não houver info pública → `INSUFFICIENT` + condição de
   reavaliação, sem bloquear a fase.

## Regra de decisão (a aplicar no bloco 05-03/05-04)

- `GO` **somente se TODOS** os critérios obrigatórios de **pelo menos um candidato**
  forem `PASS` (D-07). Qualquer `FAIL`/`INSUFFICIENT` obrigatório impede GO para aquele
  candidato.
- Vereditos globais: `GO` / `NO-GO — ADIADO` / `NO-GO — DESCARTADO` (D-08).
- Preferir `NO-GO — ADIADO` quando o bloqueio for ausência de
  evidência/termos/infra/garantia (D-09/D-18). `DESCARTADO` só com inviabilidade
  estrutural comprovada.
- Registrar exatamente o que impede o GO e os gatilhos de reavaliação (D-19).
- `GO` **não** autoriza implementação nesta fase — só libera SPD-* para fase futura (D-20).

## Sources (ponto de partida do projeto — NÃO substituem a pesquisa atualizada)

- `.planning/research/STACK.md` § "Speed Test: Deliberately Deferred Stack" / "What NOT to Use"
- `.planning/research/PITFALLS.md` (licença ≠ infraestrutura; dados/memória; sem background)
- `.planning/research/FEATURES.md` (métricas e limites do speed test pós-aprovação)
- `.planning/research/SUMMARY.md` (definição do gate duro)
- `.planning/research/ARCHITECTURE.md` § SpeedTestAdapter/Orchestrator (isolamento pós-GO)
- Fontes externas a coletar na execução: docs oficiais Cloudflare Speedtest, Ookla,
  M-Lab NDT7, LibreSpeed e alternativas — com URL e data de acesso.

---

*Phase: 5-gate-de-viabilidade-do-speed-test*
*Research framing written: 2026-09-19 — vereditos são produzidos na execução (05-01/05-03), não aqui.*
