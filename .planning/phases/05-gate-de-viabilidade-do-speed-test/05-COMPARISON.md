---
plan: 05-02
requirement: GATE-01
created: "2026-09-19"
---

# 05-COMPARISON — Comparação dos candidatos (Phase 5, bloco 2)

Consolida `05-EVIDENCE.md` em uma matriz critério × candidato. Legenda de status:
`P` = PASS, `F` = FAIL, `I` = INSUFFICIENT, `N` = N/A (justificado). Fontes e justificativas
por célula estão em `05-EVIDENCE.md` (acesso 2026-09-19).

## Matriz critério × candidato

| # | Critério obrigatório | C1 Cloudflare | C2 Ookla | C3 M-Lab/NDT7 | C4 LibreSpeed (próprio) |
|---|----------------------|:---:|:---:|:---:|:---:|
| 1 | Provedor/protocolo | P | P | P | P |
| 2 | Licença do cliente/SDK | P | F | P | P |
| 3 | **Autorização de infraestrutura (terceiros)** | I | I | **P** | P* |
| 4 | Termos de uso | I | I | P | P |
| 5 | Custos | I | I | P | I |
| 6 | Limites/rate limits/capacidade | I | I | P | I |
| 7 | Geografia | P | P | P | I |
| 8 | Seleção de servidor | N | P | P | P |
| 9 | Privacidade | P | I | P | P |
| 10 | Retenção | I | I | **F** | P |
| 11 | Publicação de resultados | I | I | **F** | P |
| 12 | Metodologia | P | P | P | P |
| 13 | Download | P | P | P | P |
| 14 | Upload | P | P | P | P |
| 15 | Consumo máximo de dados | I | I | I | P |
| 16 | Duração | I | I | P | P |
| 17 | Precisão e limitações | P | P | P | I |
| 18 | Cancelamento | I | I | P | I |
| 19 | Testabilidade | I | I | P | P |
| 20 | Sustentabilidade operacional | I | I | I | I |

`*` C4 autorização = PASS porque a infraestrutura é **própria** (self-hosted); os
bloqueios de C4 migram para custo/capacidade/geografia/sustentabilidade.

## Contagem por candidato

| Candidato | PASS | FAIL | INSUFFICIENT | N/A | Todos obrigatórios PASS? |
|-----------|:---:|:---:|:---:|:---:|:---:|
| C1 Cloudflare | 8 | 0 | 11 | 1 | **Não** |
| C2 Ookla | 8 | 1 | 11 | 0 | **Não** |
| C3 M-Lab/NDT7 | 15 | 2 | 3 | 0 | **Não** |
| C4 LibreSpeed (próprio) | 13 | 0 | 7 | 0 | **Não** |

## Sumário de elegibilidade por candidato

- **C1 Cloudflare — não elegível.** Bloqueadores: autorização de infraestrutura de
  terceiros, termos, custos, limites, retenção, publicação, consumo, duração, cancelamento,
  testabilidade e sustentabilidade permanecem `INSUFFICIENT`. Nenhum FAIL estrutural — é
  ausência de evidência/termos públicos para uso de terceiros.
- **C2 Ookla — não elegível.** Bloqueador estrutural leve: licença livre `FAIL` (SDK é
  comercial). Custos/termos/autorização dependem de contrato enterprise → `INSUFFICIENT`
  (contato comercial, D-16). Incompatível com o modelo local-first sem orçamento.
- **C3 M-Lab/NDT7 — não elegível.** É o candidato mais completo tecnicamente (15 PASS),
  com autorização de terceiros clara e gratuita — mas **retenção indefinida** e
  **publicação pública obrigatória (CC0, sem opt-out)** são `FAIL` para um app
  privacy-first (QUAL-07). Contornável só com servidor NDT próprio (recai em C4).
- **C4 LibreSpeed self-hosted — não elegível.** Sem FAIL; resolve privacidade/autorização/
  publicação, mas custo, capacidade, geografia, precisão, cancelamento e sustentabilidade
  ficam `INSUFFICIENT` por dependerem de infraestrutura própria não orçada no milestone atual.

## Riscos e limitações

- **Nenhum candidato atinge "todos os obrigatórios PASS"** — pré-condição de GO (D-07) não é
  satisfeita por nenhuma opção.
- **Trade-off central:** o único candidato com autorização de terceiros gratuita e clara
  (M-Lab) obriga publicação pública/retenção indefinida de resultados — conflito direto com
  a privacidade do app. As opções que respeitam privacidade (LibreSpeed próprio) exigem
  infraestrutura/custo não disponíveis.
- **Cliente JS ≠ cliente nativo cancelável:** Cloudflare e LibreSpeed são engines JS/browser;
  um cliente Dart/Android com cancelamento físico e limites de dados exigiria reimplementar o
  protocolo (não é SDK Flutter pronto).
- **Licença ≠ autorização de infraestrutura (D-13):** confirmado em C1/C2/C4.
- **Sustentabilidade `INSUFFICIENT` em todos** — nenhum caminho de longo prazo está
  demonstrado dentro das restrições atuais (privacidade + local-first + sem orçamento
  comercial/infra).
- A maioria dos bloqueios é **ausência de evidência/termos/infraestrutura**, não
  inviabilidade estrutural comprovada → aponta para `NO-GO — ADIADO`, não `DESCARTADO`
  (a decisão global é do bloco 05-03).

---

*Plano 05-02 — comparação consolidada em 2026-09-19. Base factual: 05-EVIDENCE.md. Nenhum
veredito global declarado aqui (isso é do bloco 05-03).*
