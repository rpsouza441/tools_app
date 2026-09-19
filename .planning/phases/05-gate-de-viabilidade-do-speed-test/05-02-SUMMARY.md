---
plan: 05-02
status: complete
requirements: [GATE-01]
created: "2026-09-19"
files_created:
  - .planning/phases/05-gate-de-viabilidade-do-speed-test/05-COMPARISON.md
---

# Plan 05-02 SUMMARY — Comparação dos candidatos

## O que foi feito

Produzido `05-COMPARISON.md`: matriz critério × candidato (20 critérios × 4 candidatos)
com status P/F/I/N e contagem por candidato, sumário de elegibilidade e seção de riscos.

## Resultado factual

Nenhum candidato atinge "todos os obrigatórios PASS":
- C1 Cloudflare: 8P/0F/11I/1N — não elegível.
- C2 Ookla: 8P/1F/11I — não elegível (licença livre FAIL; resto depende de contrato).
- C3 M-Lab: 15P/2F/3I — não elegível (retenção indefinida + publicação pública obrigatória = FAIL para privacy-first).
- C4 LibreSpeed próprio: 13P/0F/7I — não elegível (custo/capacidade/geografia/precisão/cancelamento/sustentabilidade INSUFFICIENT).

## Nota

Bloqueios são majoritariamente ausência de evidência/termos/infra → tendência a
`NO-GO — ADIADO` (não DESCARTADO). Veredito global é do bloco 05-03.

## Verificação

- Matriz rastreável a 05-EVIDENCE.md; nenhum veredito global aqui.
- Nenhum código de speed test; nada em lib/ ou android/.
