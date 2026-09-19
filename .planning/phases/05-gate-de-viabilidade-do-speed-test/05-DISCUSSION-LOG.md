# Phase 5: Gate de viabilidade do speed test - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-09-19
**Phase:** 5-gate-de-viabilidade-do-speed-test
**Areas discussed:** Formato do artefato, Régua de evidência, Profundidade da investigação, Neutralidade/resultado

---

## 1. Formato e local do artefato de decisão

| Option | Description | Selected |
|--------|-------------|----------|
| Documento dedicado da fase | `05-SPEED-TEST-GATE.md` como artefato canônico com estrutura fixa | ✓ |
| ADR genérico em `.planning/` | Registrar como decisão de arquitetura | |
| Seção em VERIFICATION/SUMMARY | Sem documento dedicado | |

**User's choice:** Documento dedicado `05-SPEED-TEST-GATE.md`, canônico.
**Notes:** Estrutura mínima definida (objetivo/escopo, opções avaliadas, tabela
critério a critério, evidência/fonte, status por critério, riscos/limitações,
veredito global, condições de reavaliação, data). Status por critério:
PASS / FAIL / INSUFFICIENT / N/A (com justificativa). Proibida linguagem
especulativa como PASS. Consulta pelo próprio documento; referência em
README/PROJECT só se fizer sentido; **sem UI no app** para GATE-01.

---

## 2. Régua de evidência (GATE-01/GATE-02)

| Option | Description | Selected |
|--------|-------------|----------|
| GO só com todos os obrigatórios PASS | Qualquer FAIL/INSUFFICIENT impede GO | ✓ |
| Score ponderado / maioria | Permitir GO com pendências menores | |

**User's choice:** GO somente se TODOS os critérios obrigatórios = PASS.
**Notes:** Lista obrigatória ampliada (provedor/protocolo, licença e termos,
**autorização de infraestrutura**, custo, limites/capacidade,
geografia/seleção de servidor, privacidade, retenção/publicação, metodologia,
consumo máximo de dados, duração, precisão/limitações, testabilidade,
cancelamento, seleção de servidor, sustentabilidade operacional). Vereditos:
`GO`, `NO-GO — ADIADO`, `NO-GO — DESCARTADO`. Preferir `ADIADO` quando o bloqueio
for falta de evidência/termos/infraestrutura; `DESCARTADO` só com inviabilidade
estrutural comprovada. Não transformar "não encontramos prova" em "é proibido";
usar INSUFFICIENT quando correto.

---

## 3. Profundidade da investigação

| Option | Description | Selected |
|--------|-------------|----------|
| Só registrar pesquisa existente | Copiar research/ atual | |
| Pesquisa atualizada + candidatos reais | Web/documental por candidato antes da decisão | ✓ |

**User's choice:** Pesquisa atualizada; não apenas copiar a existente.
**Notes:** Avaliar no mínimo Cloudflare, Ookla, M-Lab + alternativas relevantes.
Investigar por candidato: API/SDK/protocolo apropriado, licença do cliente,
termos da infraestrutura, uso permitido por terceiros, limites/rate limits,
custos, seleção geográfica, privacidade, retenção, publicação, metodologia,
upload/download controlados, tamanho de dados, cancelamento, testabilidade.
Regra dura: licença de SDK ≠ autorização de infraestrutura; endpoint público ≠
permitido em produto. Proibido WebView/endpoints informais/engenharia reversa.
Spike só se dúvida não resolvível documentalmente e sem implementar/violar
termos/criar dependência. Não contatar fornecedor comercial salvo necessidade
real e sem info pública — nesse caso, INSUFFICIENT + condição de reavaliação.

---

## 4. Neutralidade e resultado

| Option | Description | Selected |
|--------|-------------|----------|
| Investigar e aplicar a régua objetivamente | Sem pré-decidir NO-GO nem forçar GO | ✓ |
| Registrar NO-GO já no início | Assumir inviabilidade | |
| Buscar GO para liberar SPD-* | Viés a favor de implementar | |

**User's choice:** Investigar primeiro, decidir objetivamente.
**Notes:** Sem solução que atenda todos os critérios → `NO-GO — ADIADO` (fase
conclui com sucesso; GATE-02 satisfeito; SPD-* diferidos; nenhum código criado;
milestone pode encerrar). Documento registra o que impediria o GO e gatilhos de
reavaliação. `GO` não autoriza implementação na Phase 5 — apenas libera SPD-*
para milestone/fase posterior; nenhum speed test implementado nesta sessão.

---

## Claude's Discretion

- Layout/colunas e agrupamento da tabela critério a critério (desde que cubram
  todos os obrigatórios com status + evidência/fonte).
- Fontes de pesquisa e candidatos adicionais além de Cloudflare/Ookla/M-Lab.

## Deferred Ideas

- Implementação do speed test (SPD-01..09) — só após `GO` integral, fase futura.
- Infraestrutura própria de medição — possível gatilho de reavaliação.
- Latência sob carga / orçamento configurável / indicador de confiança — pós-GO.
- EVO-01..EVO-03 — evoluções posteriores não relacionadas ao gate.
