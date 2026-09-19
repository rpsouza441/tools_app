---
plan: 05-01
status: complete
requirements: [GATE-01]
created: "2026-09-19"
files_created:
  - .planning/phases/05-gate-de-viabilidade-do-speed-test/05-EVIDENCE.md
---

# Plan 05-01 SUMMARY — Pesquisa/evidência atualizada

## O que foi feito

Pesquisa documental atualizada (2026-09-19) por candidato, contra os 20 critérios
obrigatórios do gate. Produzido `05-EVIDENCE.md` com status por critério
(PASS/FAIL/INSUFFICIENT/N/A) e fonte citável em cada célula.

## Candidatos avaliados

- C1 Cloudflare Speedtest, C2 Ookla (SDK/Powered), C3 M-Lab/NDT7, C4 LibreSpeed self-hosted.

## Achados-chave

- **M-Lab (C3):** autorização de terceiros clara e gratuita (sem API key), NDT7 aberto,
  Locate v2, cliente Android de referência — mas **retenção indefinida + publicação
  pública obrigatória (CC0) sem opt-out** → FAIL nesses critérios para um app privacy-first.
- **Ookla (C2):** SDK só sob **licença comercial enterprise**; EULA livre é não-comercial
  → FAIL de licença livre; custos/termos exigem contato comercial → INSUFFICIENT (D-16).
- **Cloudflare (C1):** engine JS público, mas **sem termo público autorizando uso de
  terceiros** dos endpoints `speed.cloudflare.com` (a Speed API é Observatory por zona) →
  INSUFFICIENT em autorização/termos/custos/limites.
- **LibreSpeed (C4):** LGPL, self-host resolve privacidade/autorização, mas **custo/
  capacidade/geografia/sustentabilidade** dependem de infraestrutura própria não orçada →
  INSUFFICIENT.

## Regra dura confirmada (D-13)

Licença de SDK/biblioteca ≠ autorização de infraestrutura; endpoint público ≠ autorizado.
Confirmado em C1, C2 e C4.

## Spike

Nenhum spike necessário — todos os critérios resolvidos por fontes documentais públicas.

## Verificação

- Todo PASS tem fonte citável; ausência de evidência registrada como INSUFFICIENT.
- Nenhum código de speed test criado; nenhum arquivo em lib/ ou android/ tocado.
