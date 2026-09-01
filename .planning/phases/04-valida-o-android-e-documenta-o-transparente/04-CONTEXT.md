# Phase 4: Validação Android e documentação transparente - Context

**Gathered:** 2026-09-01
**Status:** Ready for planning

<domain>
## Phase Boundary

Comprovar o diagnóstico de Internet (entregue na Phase 3) nos cenários Android-alvo
e publicar documentação pública fiel ao comportamento realmente entregue.
Requirements: **QUAL-09, DOC-01, DOC-02, DOC-03, DOC-04**.

**Inclui:** matriz/checklist honesta de verificação Android (Wi-Fi/dados
móveis/offline + comportamentos-chave), README real substituindo o boilerplate,
documentação de permissões, `PRIVACY.md` e divulgação de terceiros (ipify, gstatic).

**NÃO inclui:** GATE-* / SPD-* / speed test (Phase 5); tela in-app de privacidade
(a menos que um requirement existente exija — não exige); alterar código da Phase 3
apenas para trocar o endpoint do probe; fabricar evidência de verificação;
prometer paridade multiplataforma; adicionar permissões futuras como se já usadas.

</domain>

<decisions>
## Implementation Decisions

### QUAL-09 — Evidência de verificação Android (opção "c")
- **D-01:** A Phase 4 **produz** uma MATRIX/checklist pequena e objetiva; a execução real dos cenários que exigem intervenção humana fica como **checkpoint humano** da fase (não auto-certificável pelo agente).
- **D-02:** Modelo de honestidade em **três camadas explícitas**, sem misturar:
  1. **VERIFIED** — comprovado em Android físico ou emulador real;
  2. **AUTOMATED/FAKE** — coberto por testes automatizados/fakes determinísticos (já verdes na Phase 3);
  3. **NOT VERIFIED** — não executado/não comprovado.
- **D-03:** **Nunca** declarar algo como VERIFIED só porque passou em fake/automatizado. Fake ≠ verificado em plataforma.
- **D-04:** Cenários e cobertura desejada da matriz: Wi-Fi, dados móveis (se tecnicamente possível), offline, IPv4 local, gateway (quando disponível), IP público, probe TCP do gateway, probe HTTPS externo, resultados parciais, cancelamento, mudança/perda de rede, pause/resume.
- **D-05:** Estratégia de evidência: testes automatizados existentes cobrem as combinações determinísticas (camada AUTOMATED/FAKE); Android/emulador cobre comportamento de plataforma (camada VERIFIED); checklist manual pequeno cobre o que não pode ser automatizado.
- **D-06:** **Dados móveis:** preferencialmente Android **físico com rede celular real**. Se o emulador não reproduzir uma rede celular real, marcar **NOT VERIFIED** e **não fabricar** evidência artificial nem auto-certificar com fake/emulador.
- **D-07:** Regra de status da fase: se dados móveis (ou qualquer cenário humano obrigatório) não forem executados, a Phase 4 permanece **human_needed** em vez de ser marcada como totalmente verificada. Wi-Fi verificar em Android quando disponível; offline verificar em Android.
- **D-08:** Objetivo é uma **matriz pequena**, não dezenas de screenshots. Sem burocracia excessiva.

### DOC-01 — README real (substituir boilerplate)
- **D-09:** Substituir o boilerplate "A new Flutter project" por um README real do projeto.
- **D-10:** README cobre: o que é o Tools App; ferramentas disponíveis; Diagnóstico de Internet; capacidades; métodos usados; o que cada medição significa; limitações; postura **Android-first**; plataformas **efetivamente verificadas** (coerente com a MATRIX de D-01..D-07); e o que **NÃO** é suportado — em especial **ICMP** e **speed test** neste milestone.
- **D-11:** Evitar documentação excessivamente longa ou linguagem de marketing. Texto factual e enxuto.

### DOC-02 — Permissões (seção no README)
- **D-12:** Documentar permissões como **seção no próprio README** (não arquivo separado), salvo justificativa forte em contrário.
- **D-13:** Documentar exatamente: `INTERNET`; `ACCESS_NETWORK_STATE`; o motivo de cada uma; ausência de localização; ausência de SSID/BSSID; ausência de `ACCESS_LOCAL_NETWORK` no estado atual; e o princípio de nenhuma permissão maior que a necessária.
- **D-14:** **Não** documentar permissões futuras como se já fossem utilizadas (privilégio mínimo, coerente com o manifest real da Phase 3).

### DOC-03 / DOC-04 — Privacidade e terceiros
- **D-15:** Criar **`PRIVACY.md`** (Markdown separado no repositório) + resumo/link no README. **Não** criar tela in-app nesta fase (nenhum requirement existente exige).
- **D-16 (ipify):** Documentar hostname `api.ipify.org`; finalidade (descobrir o IP público); que **uma requisição HTTPS é enviada** e o serviço remoto **necessariamente observa** informações da conexão como o IP público. **Não** afirmar "não registra". **Documentar factualmente a inconsistência** entre o claim de marketing ("No visitor information is ever logged. Period.") e a privacy policy da própria ipify (que declara logar IP, tipo de browser, horários de acesso). **Não** transformar claims do provedor em SLA/garantia. Indicar política/termos oficiais aplicáveis quando existirem.
- **D-17 (gstatic):** Documentar hostname/endpoint `https://www.gstatic.com/generate_204`; finalidade = **probe HTTPS de conectividade** (nunca chamar de "ping"); que **uma requisição HTTPS é feita**; limitações; e que é um **endpoint público de terceiros usado best-effort** — **sem** afirmar SLA, disponibilidade contratada nem autorização específica para dependência de terceiros. Documentar que **pode ser substituído futuramente** e que uma **falha desse probe não equivale automaticamente a "sem internet"**.
- **D-18:** Documentar também: sem conta; sem analytics; sem telemetria de diagnóstico; sem histórico persistente; resultados permanecem apenas na sessão atual; compartilhamento só por ação explícita do usuário; ausência de backend próprio.

### Endpoint do probe HTTPS — decisão B + C
- **D-19:** **Manter** `https://www.gstatic.com/generate_204` como default. **Não** alterar a Phase 3 só para trocar por `connectivitycheck.gstatic.com/generate_204`.
- **D-20:** Justificativa: a alegação de que `connectivitycheck.gstatic.com` seria "o endpoint HTTPS canônico do Android por trás de `NET_CAPABILITY_VALIDATED`" **não está suficientemente sustentada** — a doc Android define `NET_CAPABILITY_VALIDATED` como resultado da validação do sistema, sem estabelecer um único hostname público que aplicações devam reutilizar; AOSP/implementações usam URLs/configurações variadas. Não acoplar a app a esse host sob alegação de oficialidade.
- **D-21:** Preservar a **separação conceitual** entre o sinal Android `NET_CAPABILITY_VALIDATED` (fato de plataforma) e o **probe HTTPS independente** da aplicação.
- **D-22:** `HttpsProbeConfig` (e `PublicIpConfig`) permanecem **totalmente substituíveis**. Se pesquisa futura encontrar uma opção com termos públicos claramente adequados para uso por aplicações de terceiros, pode ser substituída **sem alterar o domínio** desta fase.

### Claude's Discretion
- Estrutura/seções exatas do README e do `PRIVACY.md`, desde que cubram D-09..D-18 sem marketing.
- Nome/formato exato do arquivo de matriz de verificação (recomendação: `.planning/phases/04-.../04-UAT.md` ou um `MATRIX.md`/`VERIFICATION` humano) desde que separe as três camadas de D-02 e trate dados móveis conforme D-06/D-07.
- Fatiamento e número de planos, desde que QUAL-09 e DOC-01..04 apareçam no `requirements` de algum plano.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Escopo e requisitos
- `.planning/ROADMAP.md` — Goal e SCs da Phase 4; requirements QUAL-09, DOC-01..04
- `.planning/REQUIREMENTS.md` — texto canônico de QUAL-09 e DOC-01..04; Definition of Done (verificação Android Wi-Fi/móvel/offline)
- `.planning/PROJECT.md` — Core value (honestidade), constraints de privacidade/permissões/Android-first
- `.planning/phases/03-diagn-stico-de-internet-completo-e-resiliente/03-CONTEXT.md` — decisões travadas D-10 (ICMP não é ping), D-11 (sem localização/analytics), D-12 (terceiro explícito), D-13 (internet = fatos + probe), D-14 (não tocar pubspec.lock-old)
- `.planning/phases/03-diagn-stico-de-internet-completo-e-resiliente/03-VERIFICATION.md` — o que já está VERIFIED por automação/fake (camada AUTOMATED/FAKE da matriz) e a nota de que device real é QUAL-09/Phase 4

### Código a documentar (comportamento real entregue)
- `android/app/src/main/AndroidManifest.xml` — permissões reais: só `INTERNET` + `ACCESS_NETWORK_STATE` (base do DOC-02)
- `lib/diagnostic/public_ip/public_ip_config.dart` — `PublicIpConfig` (URL ipify substituível) — base do DOC-03/ipify
- `lib/diagnostic/probes/probe_config.dart` — `HttpsProbeConfig` (URL gstatic substituível) + `GatewayProbeConfig` — base do DOC-03/gstatic e D-19..D-22
- `lib/diagnostic/diagnostic_defaults.dart` — composição Android vs stubs (base para "plataformas verificadas")
- `README.md` — atualmente boilerplate "A new Flutter project" (substituir, DOC-01)

### Evidência oficial pesquisada nesta discussão (2026-09-01)
- ipify marketing: `https://www.ipify.org/` — "No visitor information is ever logged. Period." + "use without limit" (claim, não SLA)
- ipify privacy policy: `https://geo.ipify.org/privacy-policy` — declara logar IP, tipo de browser, horários de acesso, páginas vistas (contradiz o marketing — documentar factualmente em PRIVACY.md, D-16)
- gstatic `generate_204`: endpoint público de detecção de conectividade/portal cativo (Chrome/Android); sem ToS dedicado para uso programático de terceiros → tratar como best-effort substituível (D-17, D-19..D-22)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `HttpsProbeConfig.defaultUrl` / `PublicIpConfig.defaultUrl` — já injetáveis; a documentação descreve o default e a substituibilidade sem exigir mudança de código.
- `03-VERIFICATION.md` (235 testes verdes, analyze limpo) — fonte da camada AUTOMATED/FAKE da matriz QUAL-09.
- Manifest main já minimizado (INTERNET + ACCESS_NETWORK_STATE) — DOC-02 apenas documenta o que existe.

### Established Patterns
- Honestidade de método/proveniência (Phase 3): a documentação deve espelhar exatamente — TCP connect / HTTPS, nunca ping; ICMP indisponível.
- Privilégio mínimo de permissões (Phase 3, QUAL-06): DOC-02 documenta ausências explicitamente.

### Integration Points
- Docs referenciam comportamento real de `lib/diagnostic/**` e do manifest Android; nenhuma mudança de código de produção é esperada nesta fase (fase de verificação + documentação). Qualquer ajuste de código deve ser justificado e não pode contradizer decisões travadas da Phase 3.

</code_context>

<specifics>
## Specific Ideas

- Matriz de verificação com **três colunas/camadas** claramente rotuladas (VERIFIED / AUTOMATED-FAKE / NOT VERIFIED), pequena e objetiva.
- Dados móveis reais são o caso mais provável de NOT VERIFIED → fase `human_needed` (D-06/D-07), nunca fabricado.
- `PRIVACY.md` factual: divulgar a contradição marketing-vs-policy do ipify em vez de escolher um lado.
- README enxuto, sem marketing; destaque explícito do que NÃO é suportado (ICMP, speed test neste milestone).

</specifics>

<deferred>
## Deferred Ideas

- Substituir o endpoint do probe HTTPS (ou ipify) por uma opção com termos públicos claramente adequados a uso por terceiros — permitido no futuro sem alterar o domínio, via `HttpsProbeConfig`/`PublicIpConfig` (D-22). Não faz parte da Phase 4.
- Trocar default para `connectivitycheck.gstatic.com` — rejeitado por falta de sustentação (D-20); pode ser reavaliado se surgir evidência oficial.
- Tela in-app de política de privacidade — fora de escopo (nenhum requirement exige); só markdown + link neste ciclo.
- GATE-01/GATE-02 e SPD-* / speed test — Phase 5.
- Verificação em device real de dados móveis, se não concluída na Phase 4, permanece como item humano pendente rastreado pela matriz/UAT.

</deferred>

---

*Phase: 04-valida-o-android-e-documenta-o-transparente*
*Context gathered: 2026-09-01*
