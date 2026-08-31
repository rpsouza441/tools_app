# Phase 3: Diagnóstico de Internet completo e resiliente - Context

**Gathered:** 2026-08-31
**Status:** Ready for planning
**Source:** User locked brief after Phase 2 formal close (verifier passed 13/13)

<domain>
## Phase Boundary

Entregar o fluxo de Diagnóstico de Internet: transparente, progressivo, cancelável, resiliente a falhas parciais e testável fora da UI. Requirements: DIAG-01..DIAG-15 e QUAL-01..QUAL-08.

Phase 3 **não** inclui QUAL-09 nem DOC-* (Phase 4), **não** inclui GATE-* nem SPD-* (Phase 5 / speed test), **não** reescreve Rede/Armazenamento/Hash, **não** pede localização, **não** persiste histórico, **não** envia analytics.

</domain>

<decisions>
## Implementation Decisions

### Escopo travado
- **D-01:** Goal permanece o do ROADMAP: `Usuários executam um diagnóstico de conectividade honesto, progressivo, cancelável e resistente a falhas parciais.`
- **D-02:** Só DIAG-01..15 e QUAL-01..08. Speed test, QUAL-09 e documentação pública ficam fora.
- **D-03:** Preservar as três ferramentas migradas. Adicionar destino de Diagnóstico ao catálogo tipado (UI-SPEC libera na Phase 3). Com 4 destinos, a Bar compacta mostra todos (overflow Ferramentas só a partir de 5).
- **D-04:** Android-first. Outras plataformas: capabilities ausentes = indisponível, nunca zero inventado (QUAL-05).

### Arquitetura (não monolito)
- **D-05:** Contratos separados, injetáveis e simuláveis — **proibido** um `NetworkService` único dono de snapshot + IP público + probes + sessão:
  1. connectivity/capabilities (snapshot da rede ativa)
  2. local IPv4
  3. gateway da rota default
  4. public IP
  5. probes (gateway e externo)
  6. orchestration/session (um run por vez, cancelamento, geração)
  7. aggregation/result model
- **D-06:** Lógica de medição fora dos widgets. UI observa estado imutável do run. Sem `setState` a partir de adapters.
- **D-07:** Toda operação externa tem timeout **e** cancelamento físico do I/O (não só `Future.timeout`). Respostas tardias ignoradas via run ID (DIAG-12, QUAL-02).
- **D-08:** Uma execução por vez (DIAG-01). Troca de rede aborta amostras restantes com motivo distinto; não agregar Wi-Fi+móvel (QUAL-03). Pause/hide/dispose cancelam; resume pede snapshot fresco e **não** reinicia sozinho (QUAL-04).
- **D-09:** Resultados parciais sobrevivem a falhas independentes (DIAG-10/11). Proveniência, método, alvo, porta/URL e timeout visíveis (DIAG-08). Resumo copiável/compartilhável da sessão, sem persistência (DIAG-14/15).

### Honestidade de método e privacidade
- **D-10:** Nunca rotular TCP/HTTPS como ICMP ping. ICMP no MVP só como capability **indisponível** até spike nativo aprovado.
- **D-11:** Sem localização / SSID / BSSID (QUAL-06). Sem telemetria (QUAL-07). Sem histórico persistente. Sem shell a partir da UI. Sem bloquear a isolate principal.
- **D-12:** IP público e probes externos devem registrar terceiro, dados enviados, timeout e substituição. Não encadear silenciosamente vários vendors.
- **D-13:** “Internet acessível” não é `transport != none`. É combinação honesta de fatos de plataforma (validated/captive quando existirem) **mais** probe de aplicação cancelável. Captive portal: reportar o sinal da plataforma; não fingir detecção perfeita.
- **D-14:** Não executar esta fase neste ciclo. Não tocar `pubspec.lock-old`.

### Pesquisa deve decidir (com evidência atual, não conveniência)
O researcher confirma ou revisa, com docs atuais e implicações Android/privacidade:
- snapshot Android (`ConnectivityManager`/`NetworkCapabilities`/`LinkProperties`/`RouteInfo` vs plugins)
- IPv4 local da rede **ativa** (não inventário cego de `NetworkInterface.list`)
- gateway real da rota default (nunca assumir `192.168.x.1`)
- provedor HTTPS de IP público (terceiro, JSON, timeout, cancelamento, substituição)
- probe de gateway e de internet (TCP connect vs HTTPS; ICMP só se o spike passar — expectativa: não passa no MVP)
- agregação min/média/máx, sucessos/falhas com denominador
- `ACCESS_LOCAL_NETWORK` / target SDK 37: modelar `permissionDenied` sem pedir a permissão nesta fase se o target atual for ≤36

### Claude's Discretion
- Nomes finais das interfaces/arquivos desde que os sete contratos existam.
- Número e fatiamento dos planos, desde que DIAG-01..15 e QUAL-01..08 apareçam no `requirements` de algum plano.
- Alvo HTTPS de probe externo (hostname autorizado, pequeno payload) — deve ser explícito e substituível.
- Onde vive o 4º destino no catálogo (recomendação: após Hash, compactPriority que preserve Rede/Armazenamento/Hash se no futuro houver overflow).

</decisions>

<specifics>
## Specific Ideas

- UI-SPEC Phase 1: “Não inserir Diagnóstico de Internet antes da Phase 3.” Agora inserir.
- IndexedStack: Phase 3 precisa de contrato de visibilidade/cancelamento antes de reter o diagnóstico em background (já dito no UI-SPEC).
- Testes obrigatórios (QUAL-08): sucesso, offline, timeout, resposta inválida, gateway ausente, IP público indisponível, falha parcial, cancelamento, resposta tardia após cancelamento, troca de rede, lifecycle/dispose, execução simultânea, agregação.
- Fakes manuscritos; sem framework de mock.

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Escopo
- `.planning/ROADMAP.md` — Goal, SCs, DIAG-* e QUAL-01..08
- `.planning/REQUIREMENTS.md` — texto canônico de cada ID
- `.planning/PROJECT.md` — constraints de arquitetura/privacidade
- `.planning/research/STACK.md` — pesquisa de stack 2026-08-10 (verificar se ainda é atual)
- `.planning/phases/01-contrato-visual-e-funda-o-adaptativa/01-UI-SPEC.md` — catálogo, ToolScaffold, sete estados, overflow 4 vs 5 destinos
- `.planning/phases/03-diagn-stico-de-internet-completo-e-resiliente/03-UI-SPEC.md` — adendo de anatomia do diagnóstico

### Fundação
- `lib/design_system/` — ToolScaffold, status, métricas, copy
- `lib/app/app_destinations.dart` — catálogo a estender
- `lib/app/app_shell.dart` — IndexedStack; lifecycle do diagnóstico na Phase 3

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- ToolScaffold / ToolStatusPanel / ToolMetric / TechnicalValueRow / CopyValueAction já em produção nas três telas.
- AppShell IndexedStack preserva páginas; diagnóstico **não** pode continuar I/O oculto quando a página não está visível ou o app pausa.

### Constraints
- Sem `NetworkService` monolítico.
- Sem speed test.
- Sem localização.
- Sem `pubspec.lock-old`.

</code_context>

<deferred>
## Deferred Ideas

- QUAL-09, DOC-01..04 — Phase 4
- GATE-01, GATE-02, SPD-* — Phase 5
- ICMP de produção — só após spike nativo
- Histórico persistente, analytics, SSID/BSSID

</deferred>

---

*Phase: 03-diagn-stico-de-internet-completo-e-resiliente*
*Context gathered: 2026-08-31 via user locked brief after Phase 2 close*
