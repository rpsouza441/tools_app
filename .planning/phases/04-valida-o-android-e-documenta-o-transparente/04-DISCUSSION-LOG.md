# Phase 4: Validação Android e documentação transparente - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-09-01
**Phase:** 4-Validação Android e documentação transparente
**Areas discussed:** Evidência QUAL-09, Escopo do README (DOC-01), Doc de permissões (DOC-02), Privacidade + terceiros (DOC-03/04), Endpoint do probe HTTPS

---

## Evidência QUAL-09

| Option | Description | Selected |
|--------|-------------|----------|
| a | Usuário tem device Android físico e roda a checklist manual → fase pode auto-certificar | |
| b | Plano mira apenas o emulador Android | |
| c | Fase produz checklist + matriz; execução real em device fica como checkpoint humano | ✓ |

**User's choice:** c
**Notes:** Matriz pequena e objetiva, três camadas explícitas (VERIFIED em Android físico/emulador / AUTOMATED-FAKE / NOT VERIFIED). Dados móveis: preferencialmente Android físico com rede celular real; se emulador não reproduzir rede celular real → NOT VERIFIED e fase permanece human_needed, nunca fabricar evidência. Wi-Fi verificar em Android quando disponível; offline verificar em Android. Fake ≠ verificado. Cobrir Wi-Fi, dados móveis, offline, IPv4 local, gateway, IP público, probe TCP, probe HTTPS, parciais, cancelamento, mudança/perda de rede, pause/resume.

---

## Escopo do README (DOC-01)

| Option | Description | Selected |
|--------|-------------|----------|
| — | Substituir boilerplate por README real, factual, sem marketing | ✓ |

**User's choice:** README real substituindo "A new Flutter project".
**Notes:** Cobrir o que é o app, ferramentas, Diagnóstico de Internet, capacidades, métodos, o que cada medição significa, limitações, Android-first, plataformas verificadas, e o que NÃO é suportado (ICMP, speed test neste milestone). Evitar documentação longa/marketing.

---

## Doc de permissões (DOC-02)

| Option | Description | Selected |
|--------|-------------|----------|
| Seção no README | Documentar permissões no próprio README | ✓ |
| Arquivo separado | Documento dedicado de permissões | |

**User's choice:** Seção no README (salvo justificativa forte para separado).
**Notes:** Documentar INTERNET, ACCESS_NETWORK_STATE, motivo de cada; ausência de localização, SSID/BSSID, ACCESS_LOCAL_NETWORK no estado atual; privilégio mínimo. Não documentar permissões futuras como se já usadas.

---

## Privacidade + terceiros (DOC-03/04)

| Option | Description | Selected |
|--------|-------------|----------|
| PRIVACY.md separado + link no README | Política em Markdown no repo | ✓ |
| Tela in-app | Política dentro do app | |

**User's choice:** PRIVACY.md separado + resumo/link no README. Sem tela in-app (nenhum requirement exige).
**Notes:** ipify — hostname/finalidade, request revela IP ao provedor, NÃO afirmar "não registra", documentar factualmente a contradição marketing-vs-privacy-policy, não transformar claims em SLA. gstatic — hostname/endpoint, finalidade probe HTTPS (não ping), request HTTPS feita, best-effort, sem SLA/autorização de terceiro, substituível, falha ≠ "sem internet". Também: sem conta/analytics/telemetria/histórico; resultados só na sessão; share só por ação explícita; sem backend próprio.

---

## Endpoint do probe HTTPS (ponto pendente da Phase 3)

| Option | Description | Selected |
|--------|-------------|----------|
| A | Trocar default para connectivitycheck.gstatic.com/generate_204 (endpoint do Android) | |
| B | Manter www.gstatic.com/generate_204, documentar honestamente, sem mudar Phase 3 | ✓ |
| C | Documentar como best-effort substituível, sem garantia de terceiro | ✓ |

**User's choice:** B + C
**Notes:** Rejeitou A — a alegação de que connectivitycheck.gstatic.com seria o endpoint canônico oficial por trás de NET_CAPABILITY_VALIDATED não está suficientemente sustentada (doc Android não fixa um hostname público para apps; AOSP usa URLs variadas). Preservar separação entre sinal NET_CAPABILITY_VALIDATED e o probe HTTPS independente. Manter HttpsProbeConfig substituível; substituição futura permitida se surgir opção com termos públicos adequados, sem alterar o domínio.

**Pesquisa (2026-09-01):** ipify marketing (ipify.org) diz "No visitor information is ever logged. Period."; a privacy policy da ipify (geo.ipify.org/privacy-policy) declara logar IP/browser/horários — contradição a documentar factualmente. gstatic generate_204 é endpoint público de detecção de conectividade/portal cativo, sem ToS dedicado para uso programático de terceiros → best-effort substituível.

## Claude's Discretion

- Estrutura/seções exatas de README e PRIVACY.md (sem marketing).
- Nome/formato do artefato de matriz de verificação (separando as três camadas).
- Fatiamento e número de planos, desde que QUAL-09 e DOC-01..04 apareçam no `requirements` de algum plano.

## Deferred Ideas

- Substituir endpoint HTTPS/ipify por opção com termos públicos adequados a terceiros (futuro, via config, sem alterar domínio).
- Trocar default para connectivitycheck.gstatic.com — rejeitado por falta de sustentação; reavaliável com evidência oficial.
- Tela in-app de privacidade — fora de escopo.
- GATE-*/SPD-*/speed test — Phase 5.
- Verificação real de dados móveis, se não concluída, permanece item humano pendente.
