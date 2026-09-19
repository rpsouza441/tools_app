---
plan: 05-01
requirement: GATE-01
created: "2026-09-19"
sources_access_date: "2026-09-19"
---

# 05-EVIDENCE — Dossiê de evidência por candidato (Phase 5, bloco 1)

Pesquisa documental **atualizada** (2026-09-19) sobre a viabilidade de um futuro teste
de velocidade, por candidato e por critério obrigatório. Status por critério:
`PASS` (evidência suficiente) / `FAIL` (evidência mostra que não atende) /
`INSUFFICIENT` (evidência insuficiente para afirmar que atende) /
`N/A` (não aplicável, justificado). **Todo PASS tem fonte citável.** Nenhuma linguagem
especulativa foi usada como base de PASS (D-04).

**Regra dura aplicada (D-13):** a licença de um cliente/SDK é avaliada **separadamente**
da autorização de uso da infraestrutura/servidores do provedor. Endpoint público
acessível **não** equivale a endpoint autorizado para uso em produto.

> Este arquivo reúne evidência. O veredito global é do bloco 05-03; a comparação
> consolidada é do bloco 05-02.

## Candidatos avaliados

- **C1 — Cloudflare Speedtest** (`speed.cloudflare.com`, engine JS `@cloudflare/speedtest`)
- **C2 — Ookla** (Speedtest SDK / Speedtest Powered — licença comercial)
- **C3 — M-Lab / NDT7** (plataforma aberta de medição)
- **C4 — LibreSpeed self-hosted** (infraestrutura própria; open source LGPL)

## Sub-seção: Spike de viabilidade (D-15)

**Nenhum spike necessário.** Todos os critérios obrigatórios puderam ser avaliados por
fontes documentais públicas (ToS/AUP, políticas, licenças, docs oficiais). Não há dúvida
que exija execução de código para ser resolvida nesta fase. Portanto nenhum spike é
executado (respeitando D-15: sem implementar speed test, sem dependência, sem violar termos).

---

## C1 — Cloudflare Speedtest

| Critério | Status | Evidência / fonte (acesso 2026-09-19) |
|----------|--------|----------------------------------------|
| Provedor/protocolo | PASS | Engine JS `@cloudflare/speedtest` + endpoints `speed.cloudflare.com`; metodologia descrita em blog oficial "How does Cloudflare's Speed Test really work?" (blog.cloudflare.com). |
| Licença do cliente/SDK | PASS | `@cloudflare/speedtest` é engine JS público (repositório Cloudflare). É licença de **cliente** apenas. |
| **Autorização de infraestrutura (terceiros)** | INSUFFICIENT | A "Speed API" documentada em developers.cloudflare.com/api/…/speed é a **Observatory** de page-speed por zona (`/zones/{zone_id}/speed_api/...`), para as *suas próprias* zonas — não uma API de medição de rede para apps de terceiros. Os Website Terms of Use (cloudflare.com/website-terms) não concedem explicitamente autorização para um app nativo de terceiro dirigir os endpoints de `speed.cloudflare.com` em produção. Sem termo público que autorize esse uso → INSUFFICIENT (não FAIL). |
| Termos de uso | INSUFFICIENT | Website Terms of Use aplicáveis, mas sem cláusula pública específica autorizando uso programático de terceiros do speed test. |
| Custos | INSUFFICIENT | Sem página de preços pública para uso de terceiros do endpoint de speed test (o produto de página/Observatory é atrelado a zonas Cloudflare). |
| Limites/rate limits/capacidade | INSUFFICIENT | Sem limites publicados para uso de terceiros dos endpoints de `speed.cloudflare.com`. |
| Geografia | PASS | Rede global anycast da Cloudflare (documentada); cobertura ampla. |
| Seleção de servidor | N/A | Anycast seleciona o edge automaticamente; não há seleção explícita de servidor pelo cliente (justificativa: modelo anycast). |
| Privacidade | PASS (fato) | "When you run Speed Test, your IP address will be shared with Cloudflare and processed in accordance with our privacy policy" (radar.cloudflare.com/speedtest). Fato claro; a implicação para um app privacy-first é registrada em Riscos. |
| Retenção | INSUFFICIENT | Política de privacidade geral aplica-se, mas retenção específica de resultados de speed test de terceiros não está publicada. |
| Publicação de resultados | INSUFFICIENT | Não há declaração pública de que resultados de terceiros sejam ou não publicados. |
| Metodologia | PASS | Blog oficial descreve down/up/latência e o efeito da localização do servidor. |
| Download | PASS | Suportado pelo engine. |
| Upload | PASS | Suportado pelo engine. |
| Consumo máximo de dados | INSUFFICIENT | Engine ajusta o volume dinamicamente; sem limite rígido documentado para uso de terceiros. |
| Duração | INSUFFICIENT | Sem limite de duração documentado para uso de terceiros. |
| Precisão e limitações | PASS | Blog oficial discute limitações (localização do servidor afeta resultados). |
| Cancelamento | INSUFFICIENT | Engine é JS/browser; cancelamento imediato num cliente Dart/Android nativo não é documentado (dependeria de reimplementar o protocolo). |
| Testabilidade | INSUFFICIENT | Sem endpoint de teste controlado documentado para terceiros; engine JS não é adaptador Dart simulável. |
| Sustentabilidade operacional | INSUFFICIENT | Depende de autorização/termos não confirmados; sem SLA para uso de terceiros. |

**Elegível a GO?** Não — múltiplos INSUFFICIENT em critérios obrigatórios (autorização de
infraestrutura, termos, custos, limites, retenção, publicação, consumo, duração,
cancelamento, testabilidade).

---

## C2 — Ookla (Speedtest SDK / Powered)

| Critério | Status | Evidência / fonte (acesso 2026-09-19) |
|----------|--------|----------------------------------------|
| Provedor/protocolo | PASS | Speedtest SDK integra medição em app mobile/web (ookla.com/speedtest-sdk). |
| Licença do cliente/SDK | FAIL (para uso livre) | A EULA do cliente CLI concede licença "for your personal, **non-commercial** use on a single personal computer" (speedtest.net/about/eula). O SDK para produtos é licença **comercial enterprise** separada. Não há licença livre para embutir em um produto. |
| **Autorização de infraestrutura (terceiros)** | INSUFFICIENT | O uso da rede Ookla por terceiros requer licença enterprise (Speedtest SDK/Powered) sob order form; autorização existe **somente sob contrato pago**. Sem contrato, não há autorização. Como depende de acordo comercial e não há termo público de uso livre → INSUFFICIENT + condição de reavaliação (D-16). |
| Termos de uso | INSUFFICIENT | Termos enterprise sob order form (não públicos na íntegra); Ookla Terms of Use gerais aplicam-se ao site. |
| Custos | INSUFFICIENT | Licenciamento enterprise sem preço público ("array of enterprise licensing options", ookla.com/speedtest-powered). Requer contato comercial → INSUFFICIENT (D-16). |
| Limites/rate limits/capacidade | INSUFFICIENT | Definidos por contrato enterprise; não públicos. |
| Geografia | PASS | Rede global de servidores Ookla (amplamente documentada). |
| Seleção de servidor | PASS | SDK/plataforma suportam seleção de servidor (documentação Ookla). |
| Privacidade | INSUFFICIENT | Coleta "rich insights into network experience"; termos específicos de dados sob contrato. Para um app que não envia dados a terceiros, isso é um conflito potencial (ver Riscos). |
| Retenção | INSUFFICIENT | Definida por contrato; não pública. |
| Publicação de resultados | INSUFFICIENT | Não documentada publicamente para o modelo SDK. |
| Metodologia | PASS | Metodologia de medição documentada (Ookla é referência de mercado). |
| Download | PASS | Suportado. |
| Upload | PASS | Suportado. |
| Consumo máximo de dados | INSUFFICIENT | Não documentado publicamente; sob contrato. |
| Duração | INSUFFICIENT | Não documentado publicamente. |
| Precisão e limitações | PASS | Metodologia madura e documentada. |
| Cancelamento | INSUFFICIENT | Não documentado publicamente para o SDK. |
| Testabilidade | INSUFFICIENT | SDK proprietário; adaptador simulável/endpoint de teste controlado não documentado publicamente. |
| Sustentabilidade operacional | INSUFFICIENT | Depende de custo enterprise recorrente não conhecido; incompatível com app offline/local-first sem orçamento comercial. |

**Elegível a GO?** Não — FAIL na licença livre + múltiplos INSUFFICIENT (autorização,
custos, termos, privacidade, retenção, cancelamento, testabilidade). Requer contato
comercial (D-16) → INSUFFICIENT, não bloqueio definitivo.

---

## C3 — M-Lab / NDT7

| Critério | Status | Evidência / fonte (acesso 2026-09-19) |
|----------|--------|----------------------------------------|
| Provedor/protocolo | PASS | NDT7 é protocolo aberto sobre TCP (BBR onde disponível), documentado em github.com/m-lab/ndt-server (spec) e measurementlab.net/tests/ndt/ndt7. |
| Licença do cliente/SDK | PASS | Clientes de referência open source; cliente Android community-supported (github.com/m-lab/ndt7-client-android); clientes de terceiros não precisam ser open source. |
| **Autorização de infraestrutura (terceiros)** | PASS | "You are welcome to utilize the M-Lab platform by integrating an M-Lab measurement client into any application you want" e "Anyone may use M-Lab's services as long as they follow the AUP and obtain user consent" (measurementlab.net/develop). Sem API key para NDT. |
| Termos de uso | PASS | AUP pública (measurementlab.net/aup) governa o uso; requisitos claros de consentimento e privacidade. |
| Custos | PASS | Uso da plataforma é gratuito (plataforma pública sem fins lucrativos). |
| Limites/rate limits/capacidade | PASS (com limite) | Rate limit **40 testes/cliente/dia** (204 No Content ao exceder); recomenda **≤4/dia** para integrações, com agendamento Poisson (measurementlab.net/develop). |
| Geografia | PASS | 125+ sites globais via Locate API v2; maioria em NA/Europa, presença em mercados em desenvolvimento (measurementlab.net/develop). |
| Seleção de servidor | PASS | Locate API v2 fornece servidores candidatos próximos e fallback (measurementlab.net/develop/locate-v2). |
| Privacidade | PASS (com ressalva) | AUP exige consentimento informado; PII não é armazenada na plataforma; apenas o IP público é coletado por necessidade. A ressalva (publicação) está abaixo. |
| Retenção | FAIL (para modelo privacy-first) | "All experiment data is retained **indefinitely** and published publicly" (M-Lab Privacy Policy). Retenção indefinida. |
| Publicação de resultados | FAIL (para modelo privacy-first) | "Using M-Lab's test infrastructure and services **requires the resulting data to be shared**… published to the public without restriction under CC0… **no mechanism to exempt certain tests**" (measurementlab.net/develop). Conflita diretamente com o princípio do app de não enviar/expor resultados a terceiros (QUAL-07/privacidade). |
| Metodologia | PASS | NDT7 coleta estatísticas TCP via TCP_INFO; metodologia documentada. |
| Download | PASS | NDT7 mede download (spec do protocolo). |
| Upload | PASS | NDT7 mede upload (spec do protocolo). |
| Consumo máximo de dados | INSUFFICIENT | NDT7 satura o enlace por ~10s por direção; sem limite rígido de bytes documentado (dependeria de configuração do cliente). Relevante para consentimento de dados móveis (SPD-01 futuro). |
| Duração | PASS | NDT7 tem duração limitada por design (~10s/direção); documentado. |
| Precisão e limitações | PASS | Metodologia e limitações documentadas; plataforma acadêmica de referência. |
| Cancelamento | PASS (viável) | Protocolo WebSocket/TLS; cliente pode fechar a conexão para cancelar (clientes de referência demonstram controle da conexão). |
| Testabilidade | PASS | Servidor NDT open source (github.com/m-lab/ndt-server) pode ser hospedado como endpoint controlado para testes reprodutíveis; protocolo simulável. |
| Sustentabilidade operacional | INSUFFICIENT | SLO best-effort business-hours (99–99.9% em 2019); "your service will inherit our SLO"; capacidade finita. Sustentável para uso responsável, mas sem SLA — a app deve "fail gracefully". |

**Elegível a GO?** Não — **FAIL** em Retenção e Publicação de resultados (retenção
indefinida + publicação pública obrigatória sem opt-out), que conflitam com o modelo
privacy-first do app; + INSUFFICIENT em consumo máximo de dados e sustentabilidade. Note:
o FAIL de publicação é **contornável** apenas hospedando um servidor NDT **próprio** (=
candidato C4/infra própria), não usando a plataforma pública M-Lab.

---

## C4 — LibreSpeed self-hosted (infraestrutura própria)

| Critério | Status | Evidência / fonte (acesso 2026-09-19) |
|----------|--------|----------------------------------------|
| Provedor/protocolo | PASS | Speed test open source (github.com/librespeed/speedtest); mede down/up/ping/jitter via XHR/Web Workers; backend PHP/Node/Rust. |
| Licença do cliente/SDK | PASS | LGPL v3 — uso, modificação e redistribuição livres, inclusive em software proprietário (github.com/librespeed/speedtest wiki). |
| **Autorização de infraestrutura (terceiros)** | PASS (se própria) | Como é **self-hosted**, o operador (o projeto) é o dono da infraestrutura; a autorização é do próprio projeto. Não depende de terceiros. |
| Termos de uso | PASS | LGPL; sem termos de terceiro sobre a infraestrutura (é própria). |
| Custos | INSUFFICIENT | Software gratuito, mas exige **custo de hospedagem/servidores** (VPS, banda) não orçado neste milestone. Requer decisão de custo/capacidade → INSUFFICIENT. |
| Limites/rate limits/capacidade | INSUFFICIENT | Definidos pela capacidade dos servidores próprios, que não existem/orçados hoje. |
| Geografia | INSUFFICIENT | Sem plano de PoPs geográficos; um único servidor não cobre geografia relevante. |
| Seleção de servidor | PASS (suportado) | LibreSpeed suporta múltiplos servidores e seleção (README/doc). |
| Privacidade | PASS | Self-hosted; "no phoning home" — dados ficam sob controle do projeto; compatível com privacy-first. |
| Retenção | PASS (controlável) | Retenção definida pelo operador; pode ser zero/sessão. |
| Publicação de resultados | PASS (controlável) | Nenhuma publicação obrigatória; sob controle do projeto. |
| Metodologia | PASS | Metodologia documentada (XHR + Web Workers; mede down/up/ping/jitter). Cliente de referência é JS/browser. |
| Download | PASS | Suportado. |
| Upload | PASS | Suportado. |
| Consumo máximo de dados | PASS (configurável) | Volume configurável no LibreSpeed (parâmetros de teste). |
| Duração | PASS (configurável) | Duração configurável. |
| Precisão e limitações | INSUFFICIENT | Precisão depende da capacidade/banda do servidor próprio e do caminho de rede; sem servidor não há como demonstrar precisão. |
| Cancelamento | INSUFFICIENT | Cliente de referência é JS/browser; um cliente Dart/Android nativo exigiria reimplementar o protocolo com cancelamento — não demonstrado nesta fase. |
| Testabilidade | PASS | Self-hosted permite endpoint controlado para testes reprodutíveis (o próprio servidor). |
| Sustentabilidade operacional | INSUFFICIENT | Depende de manter servidores próprios (custo recorrente, capacidade, manutenção) — não viável/orçado no milestone atual. |

**Elegível a GO?** Não — INSUFFICIENT em custos, limites/capacidade, geografia, precisão,
cancelamento e sustentabilidade (todos dependentes de infraestrutura própria inexistente/
não orçada hoje). Viável no futuro se houver decisão de custo/capacidade.

---

## Observações transversais (para Riscos/limitações — bloco 05-02/05-03)

- **Cliente JS ≠ cliente nativo (D-13/testabilidade):** Cloudflare e LibreSpeed têm engines
  JS/browser. Um cliente Dart/Android nativo com cancelamento físico e limites de dados
  exigiria reimplementar o protocolo — não é um SDK Flutter pronto e cancelável.
- **Licença ≠ autorização de infraestrutura (D-13):** confirmado em C1 (engine JS público,
  mas sem termo de uso de terceiro do endpoint) e C2 (SDK sob licença comercial; rede só
  sob contrato). LGPL do LibreSpeed autoriza o **software**, e a infraestrutura é própria.
- **Privacidade vs. publicação (M-Lab):** o único candidato com autorização de terceiros
  clara e gratuita (M-Lab) exige publicação pública e retenção indefinida dos resultados,
  o que conflita com o modelo privacy-first do app (QUAL-07). Contornável só com servidor
  NDT próprio (recai em C4/custo).
- **Contato comercial (D-16):** Ookla resolve-se apenas por contrato enterprise; sem info
  pública de custo/termos → INSUFFICIENT + condição de reavaliação, sem bloquear a fase.

---

*Plano 05-01 — evidência coletada em 2026-09-19. Fontes: measurementlab.net (AUP,
Privacy, Developer), speedtest.net/about/eula, ookla.com (SDK/Powered/Terms),
cloudflare.com (website-terms, developers/api/speed, blog, radar), github.com/librespeed.*
