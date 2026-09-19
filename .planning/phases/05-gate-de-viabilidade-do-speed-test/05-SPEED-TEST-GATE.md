---
artifact: speed-test-viability-gate
phase: 05-gate-de-viabilidade-do-speed-test
requirements: [GATE-01, GATE-02]
decision_date: "2026-09-19"
global_verdict: "NO-GO — ADIADO"
status: decided
---

# Gate de Viabilidade do Speed Test — Decisão Formal

**Documento canônico da decisão (GATE-01, GATE-02).** Consultável por este arquivo.
Data da decisão: **2026-09-19**.

> Este documento **não** autoriza implementação de speed test. É um gate de decisão.
> `NO-GO`/adiamento é um resultado válido e suficiente para concluir a Phase 5 (GATE-02).

## 1. Objetivo e escopo

Registrar uma decisão formal, auditável e verificável `GO` / `NO-GO` sobre a viabilidade
técnica, jurídica, financeira, de privacidade e operacional de um futuro teste de
velocidade no Tools App, **antes** de qualquer plano de implementação (GATE-01). Nenhum
código de speed test é criado nesta fase. Um eventual `GO` apenas liberaria os requisitos
`SPD-01..SPD-09` para planejamento em milestone/fase posterior — nunca implementação aqui.

**Fora de escopo:** implementação de speed test; adição de SDK/plugin ao produto;
alterações em `lib/` ou `android/`; uso de WebView/endpoint informal/engenharia reversa;
início de milestone posterior.

## 2. Opções/provedores avaliados

| ID | Candidato | Natureza |
|----|-----------|----------|
| C1 | Cloudflare Speedtest (`speed.cloudflare.com`, engine JS) | Infraestrutura de terceiro |
| C2 | Ookla (Speedtest SDK / Powered) | SDK comercial licenciado |
| C3 | M-Lab / NDT7 | Plataforma pública aberta de medição |
| C4 | LibreSpeed self-hosted | Infraestrutura própria (open source LGPL) |

Evidência detalhada por candidato: `05-EVIDENCE.md`. Comparação consolidada: `05-COMPARISON.md`.

## 3. Tabela critério por critério

Status: `P`=PASS, `F`=FAIL, `I`=INSUFFICIENT, `N`=N/A(justificado). Fontes por célula em
`05-EVIDENCE.md` (acesso 2026-09-19).

| # | Critério obrigatório | C1 | C2 | C3 | C4 |
|---|----------------------|:--:|:--:|:--:|:--:|
| 1 | Provedor/protocolo | P | P | P | P |
| 2 | Licença do cliente/SDK | P | F | P | P |
| 3 | Autorização de infraestrutura (terceiros) | I | I | P | P* |
| 4 | Termos de uso | I | I | P | P |
| 5 | Custos | I | I | P | I |
| 6 | Limites/rate limits/capacidade | I | I | P | I |
| 7 | Geografia | P | P | P | I |
| 8 | Seleção de servidor | N | P | P | P |
| 9 | Privacidade | P | I | P | P |
| 10 | Retenção | I | I | F | P |
| 11 | Publicação de resultados | I | I | F | P |
| 12 | Metodologia | P | P | P | P |
| 13 | Download | P | P | P | P |
| 14 | Upload | P | P | P | P |
| 15 | Consumo máximo de dados | I | I | I | P |
| 16 | Duração | I | I | P | P |
| 17 | Precisão e limitações | P | P | P | I |
| 18 | Cancelamento | I | I | P | I |
| 19 | Testabilidade | I | I | P | P |
| 20 | Sustentabilidade operacional | I | I | I | I |

`*` C4 autorização = PASS por ser infraestrutura própria; bloqueios migram para custo/
capacidade/geografia/sustentabilidade.

## 4. Evidência/fonte

- **M-Lab:** "integrating an M-Lab measurement client into any application you want";
  sem API key para NDT; rate limit 40/dia (≤4/dia recomendado para integrações); 125+ sites
  via Locate v2; **"All experiment data is retained indefinitely and published publicly"**;
  **"requires the resulting data to be shared… CC0… no mechanism to exempt certain tests"**
  (measurementlab.net/develop, /privacy, /aup).
- **Ookla:** CLI EULA "personal, non-commercial use" (speedtest.net/about/eula); SDK/Powered
  sob licença enterprise "array of enterprise licensing options" (ookla.com/speedtest-sdk,
  /speedtest-powered).
- **Cloudflare:** IP compartilhado com Cloudflare (radar.cloudflare.com/speedtest); "Speed API"
  é Observatory por zona (developers.cloudflare.com/api/…/speed); Website Terms of Use gerais
  (cloudflare.com/website-terms). Sem termo público autorizando uso de terceiros do endpoint.
- **LibreSpeed:** LGPL v3, self-hosted, "no phoning home" (github.com/librespeed/speedtest).

## 5. Status de cada critério (síntese)

- **Nenhum candidato** possui **todos** os 20 critérios obrigatórios em `PASS`.
- Melhor cobertura técnica: **M-Lab (15 PASS)** — bloqueado por `FAIL` em retenção e
  publicação (conflito com privacidade do app).
- **LibreSpeed** não tem `FAIL`, mas acumula `INSUFFICIENT` em custo/capacidade/geografia/
  precisão/cancelamento/sustentabilidade (dependem de infraestrutura própria não orçada).
- **Cloudflare** e **Ookla** acumulam `INSUFFICIENT` em autorização/termos/custos para uso
  de terceiros (Ookla ainda tem `FAIL` de licença livre).
- **Sustentabilidade operacional** é `INSUFFICIENT` em **todos** os candidatos dentro das
  restrições atuais (privacidade + local-first + sem orçamento comercial/infra).

## 6. Riscos/limitações

- **Trade-off privacidade × autorização:** o único candidato com autorização de terceiros
  gratuita e clara (M-Lab) exige publicação pública e retenção indefinida — incompatível com
  o princípio do app de não expor resultados a terceiros (QUAL-07).
- **Cliente JS ≠ cliente nativo cancelável:** Cloudflare/LibreSpeed são engines JS/browser;
  um cliente Dart/Android com cancelamento físico e limites de dados exigiria reimplementar o
  protocolo — não há SDK Flutter pronto, cancelável e testável.
- **Licença ≠ autorização de infraestrutura (D-13):** confirmado; nenhuma licença de cliente
  comprova direito de usar servidores públicos de terceiros em produto.
- **Custo/infra própria:** a única via que respeita privacidade (LibreSpeed self-host) exige
  servidores, banda, PoPs geográficos e manutenção não orçados neste milestone.

## 7. Veredito global

**`NO-GO — ADIADO`.**

Nenhum candidato satisfaz **todos** os critérios obrigatórios (regra D-07/GATE-02: qualquer
`FAIL`/`INSUFFICIENT` obrigatório impede `GO`). Os bloqueios são majoritariamente **ausência
de evidência pública, de termos de uso de terceiros, de autorização de infraestrutura e de
infraestrutura própria orçada** — **não** inviabilidade estrutural comprovada. Por isso o
resultado é **ADIADO**, não `DESCARTADO` (D-09/D-18).

O que **impede** o `GO` hoje, por candidato:
- **Cloudflare:** falta termo público de autorização de uso de terceiros dos endpoints;
  custos/limites/retenção/publicação/cancelamento/testabilidade não documentados para terceiros.
- **Ookla:** licença livre inexistente (SDK é enterprise pago); custos/termos só sob contrato
  comercial (não obtido nesta fase por D-16).
- **M-Lab:** retenção indefinida e publicação pública obrigatória dos resultados (sem opt-out),
  incompatíveis com o modelo privacy-first.
- **LibreSpeed próprio:** custo, capacidade, cobertura geográfica, precisão demonstrável,
  cancelamento nativo e sustentabilidade dependem de infraestrutura própria não orçada.

Consequência (GATE-02): a Phase 5 conclui com **sucesso**; `SPD-01..SPD-09` permanecem
**diferidos**; nenhum código de speed test é criado; o milestone atual pode ser encerrado.

## 8. Condições para futura reavaliação

O gate deve ser reaberto se **qualquer** das condições abaixo passar a ter evidência:

1. **Provedor com SDK/API oficial e termos claros para terceiros** — ex.: Cloudflare ou outro
   publica termos que autorizem explicitamente uso programático de terceiros do endpoint, com
   limites, custo, retenção e privacidade documentados.
2. **Ookla (ou equivalente) com custo/termos aceitáveis** — obtenção de proposta enterprise
   com custo, limites, privacidade e retenção compatíveis (resolve o INSUFFICIENT de D-16).
3. **Infraestrutura própria viável** — decisão de orçar servidores LibreSpeed/NDT próprios
   com capacidade, cobertura geográfica mínima e sustentabilidade (custo/manutenção) definidas;
   isso também resolve retenção/publicação/privacidade sob controle do projeto.
4. **Metodologia/testabilidade demonstrável** — cliente nativo (Dart/Android) com cancelamento
   físico, limites de dados/duração e adaptador simulável/endpoint de teste controlado provados
   por spike de viabilidade (sob as condições de D-15).

Uma reavaliação que leve **todos** os critérios obrigatórios de **ao menos um** candidato a
`PASS` habilita um `GO` — que, mesmo então, apenas libera `SPD-*` para planejamento futuro.

## 9. Data da decisão

**2026-09-19.** Vocabulário de veredito: `GO` / `NO-GO — ADIADO` / `NO-GO — DESCARTADO`
(este documento: **NO-GO — ADIADO**).

---

*Artefato canônico do gate. Base: 05-EVIDENCE.md + 05-COMPARISON.md. Verificação formal de
GATE-01/GATE-02 em 05-VERIFICATION.md.*
