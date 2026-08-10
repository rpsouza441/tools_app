# Project Research Summary

**Project:** Tools App — Diagnóstico de Internet e Evolução da UI
**Domain:** Aplicativo Flutter Android-first de utilidades técnicas e diagnóstico transparente de conectividade
**Researched:** 2026-08-10
**Confidence:** HIGH para modernização e diagnóstico básico; LOW para speed test até aprovação do gate de viabilidade

## Executive Summary

O Tools App deve evoluir incrementalmente, preservando as três ferramentas offline existentes e introduzindo uma base visual Material 3 adaptativa antes de ampliar a navegação. O diagnóstico de Internet não é um simples indicador “online”: especialistas o constroem como uma sequência de evidências independentes — transporte e capacidades Android, IPv4 local, rota/gateway, IP público e probes TCP/HTTPS explicitamente rotulados — com resultados parciais, proveniência, múltiplas amostras e limitações visíveis.

A abordagem recomendada mantém Flutter 3.44 e Dart 3.12, usa um adaptador Android estreito sobre `ConnectivityManager`, `NetworkCapabilities` e `LinkProperties`, e adiciona `dio` 5.11.0 para HTTPS cancelável. A arquitetura deve seguir fluxo unidirecional com controller por tela, orquestrador, interfaces de capacidade, adaptadores que realmente abortam recursos e modelos imutáveis. Não há justificativa para backend, persistência, service locator global ou novo framework de estado neste ciclo.

Os maiores riscos são conclusões tecnicamente falsas, cancelamento apenas aparente, regressões na UI existente, permissões excessivas e dependência de endpoints frágeis. Eles são mitigados com nomenclatura precisa do método, `OperationScope` e `runId`, testes de caracterização e em devices Android, privilégio mínimo e provedores injetáveis. O speed test é uma extensão independente e possui um **gate duro**: sem endpoint/protocolo autorizado, sustentável, limitado, simulável e aprovado em privacidade, custos e metodologia, a decisão correta é adiar a funcionalidade — nunca improvisar com endpoints públicos ou packages comunitários.

## Key Findings

### Recommended Stack

Preservar a base atual e acrescentar somente capacidades necessárias. A fonte de verdade de rede deve ser a rede ativa do Android, não plugins genéricos nem `NetworkInterface.list()`. Toda medição permanece em Dart e fora dos widgets; Kotlin apenas serializa fatos da plataforma.

**Core technologies:**
- **Flutter 3.44.0 + Material 3:** shell adaptativo, componentes compartilhados, acessibilidade e lifecycle — evolução sem reescrita.
- **Dart 3.12.0:** modelos, orquestração, agregação e sockets assíncronos — lógica testável e independente da UI.
- **Android `ConnectivityManager` / `NetworkCapabilities` / `LinkProperties`:** transporte, validação, portal cativo, endereços e rota padrão — fonte Android autoritativa.
- **`MethodChannel`:** adaptador nativo estreito para snapshot da rede ativa — evita verdades concorrentes de plugins.
- **`dio` 5.11.0:** IP público e probes HTTPS com timeout, streaming e `CancelToken` — aborta I/O de verdade.
- **`Socket.startConnect`:** probes TCP 443 canceláveis — devem ser chamados de conexão TCP, nunca ICMP.
- **`AppLifecycleListener`, `flutter_test` e `integration_test`:** cleanup, testes unitários/widgets e validação em device.

Requisitos críticos: manter AGP 8.11.1 salvo decisão explícita por plugins Plus; declarar apenas `INTERNET` e `ACCESS_NETWORK_STATE`; modelar desde já `permissionDenied` para o futuro `ACCESS_LOCAL_NETWORK` no target SDK 37, sem solicitar essa permissão no target atual.

### Expected Features

**Must have (table stakes):**
- Navegação adaptativa, temas claro/escuro e primitives consistentes para entrada, ação, progresso, métricas, cópia e falha.
- Migração sem regressão da calculadora IPv4, conversor de armazenamento e gerador de hashes.
- Execução manual, progresso por etapa, cancelamento real, repetição e última execução em memória.
- Snapshot separado de transporte, `INTERNET`, `VALIDATED`, portal cativo e rede medida.
- IPv4 local, gateway quando disponível e IP público por HTTPS com provedor e privacidade documentados.
- Probes de gateway/externo com método, alvo, porta/URL e timeout reais; ausência de gateway é resultado válido.
- Múltiplas amostras com mínimo/média/máximo, tentativas, sucessos e falhas com denominador.
- Resultados parciais, mudança de rede, lifecycle Android e falhas acionáveis sem spinner infinito.
- Resumo copiável/compartilhável com timestamp, proveniência e limitações.
- Acessibilidade verificável e documentação de permissões/privacidade.

**Should have (competitive):**
- Diagnóstico em camadas “rede → gateway → internet → serviço externo”, com hipóteses cautelosas.
- Proveniência ao lado de cada métrica e resumo de evidências/não medido/limitações.
- Privilégio mínimo sem SSID/BSSID, localização, conta ou varredura de LAN.
- Continuidade visual entre ferramentas offline e diagnóstico.
- Em v1.x, reexecutar apenas uma etapa e recomendações auditáveis, se validadas com usuários.

**Defer (v2+):**
- Speed test, latência sob carga, confiança e orçamento configurável — somente após o gate duro.
- DNS avançado, traceroute, scanner de LAN/portas e novas ferramentas, cada qual com ameaça e permissões próprias.
- Contas/backend, histórico persistente, telemetria, SSID/BSSID/localização, execução automática e paridade multiplataforma não verificada.

### Architecture Approach

Usar fluxo unidirecional e injeção manual: a tela envia comandos a um `DiagnosticController` screen-scoped; o controller mantém um único run e estado imutável; o `DiagnosticOrchestrator` executa um grafo de trabalho com resultados incrementais; interfaces isolam capacidades; adaptadores possuem e abortam sockets, requests, timers e subscriptions; agregadores puros calculam métricas. Cada medição tem status próprio (`pending`, sucesso, falha, indisponível, cancelada ou não executada), método e proveniência. Não usar `Future.wait` fail-fast nem um resultado global anulável.

**Major components:**
1. **AppShell + design system** — catálogo único de destinos, NavigationBar/Rail por largura e primitives acessíveis.
2. **Legacy tool features** — preservam serviços síncronos e migram tela a tela sob testes de caracterização.
3. **DiagnosticController** — estado de apresentação, start/cancel/repeat, lifecycle, run atual e último resultado em memória.
4. **DiagnosticOrchestrator + OperationScope** — dependências, concorrência limitada, deadlines, merge parcial e cleanup aguardado.
5. **Domain models + ProbeMetricsAggregator** — outcomes tipados, proveniência e cálculos puros.
6. **Capability adapters** — snapshot Android, rede local/gateway, IP público e probes TCP/HTTPS substituíveis.
7. **SpeedTestAdapter/Orchestrator futuro** — separado do diagnóstico e inexistente em produção até o gate passar.

Padrões obrigatórios: cancelamento cooperativo em todas as camadas; `runId` para rejeitar eventos tardios; um run por vez; cancelamento ao ocultar destino/pausar/descartar; não reiniciar automaticamente ao retomar; nunca agregar amostras de redes diferentes.

### Critical Pitfalls

1. **Confundir transporte com Internet** — apresentar separadamente transporte, validação Android, portal cativo e resultado do probe.
2. **Chamar TCP/HTTPS de ping ou inferir causa** — preservar método/alvo e usar conclusões condicionais, não culpar roteador/ISP sem evidência.
3. **Timeout sem aborto real** — cancelar `CancelToken`, `ConnectionTask`, sockets, timers e subscriptions; aguardar cleanup e rejeitar respostas antigas por `runId`.
4. **Falha única apagar evidências válidas** — normalizar falhas por capability e emitir snapshots incrementais; ausência de gateway ou IP público não encerra o restante.
5. **UI big-bang ou I/O nos widgets** — caracterizar ferramentas atuais, migrar por fatias e manter plugins/sockets/HTTP atrás de adapters.
6. **Permissões e coleta excessivas** — não coletar SSID/BSSID/localização, não adicionar analytics e documentar todo serviço externo.
7. **Speed test improvisado** — não usar WebView, defaults de packages ou APIs internas de Ookla/Fast.com; sem autorização, privacidade, caps e endpoint testável, adiar.

## Implications for Roadmap

Based on research, suggested phase structure:

### Phase 1: Contrato visual e proteção contra regressões
**Rationale:** A expansão da navegação e os componentes compartilhados afetam todas as ferramentas; testes de caracterização precisam proteger o valor já entregue.
**Delivers:** UI-SPEC, critérios de responsividade/acessibilidade, testes das três ferramentas atuais, tokens e contratos dos componentes.
**Addresses:** preservação das ferramentas, temas, acessibilidade e estados consistentes.
**Avoids:** reescrita total, regressões silenciosas e abstrações genéricas prematuras.

### Phase 2: Shell adaptativo e migração incremental das ferramentas
**Rationale:** Estabelece a linguagem visual e o catálogo de destinos antes da experiência assíncrona mais complexa.
**Delivers:** AppShell, NavigationBar/Rail ou home categorizada conforme UI-SPEC, primitives e migração tela a tela.
**Uses:** Flutter/Material 3 e serviços síncronos existentes.
**Avoids:** lógica de feature em `main.dart`, estado global e duplicação de UI.

### Phase 3: Contratos do domínio diagnóstico e cancelamento
**Rationale:** Outcomes, proveniência e cancelamento são dependências críticas de adapters, orquestração e UI; devem ser provados com fakes primeiro.
**Delivers:** modelos imutáveis, failure taxonomy, `DiagnosticRequest`, agregador, `OperationScope`, capability interfaces, fake clock/adapters e testes de timeout/cancel/repeat/stale events.
**Addresses:** múltiplas amostras, resultados parciais, método real, lifecycle e uma execução por vez.
**Avoids:** `Future.wait` fail-fast, timeout aparente, zero falso e callbacks tardios.

### Phase 4: Adapters Android e medições reais
**Rationale:** Só após contratos estáveis devem entrar platform channel e rede externa; cada capability pode ser validada isoladamente.
**Delivers:** snapshot Android, IPv4/gateway, ipify por HTTPS e probes TCP/HTTPS aprovados, com contract tests e paths unsupported.
**Uses:** `ConnectivityManager`, `NetworkCapabilities`, `LinkProperties`, `MethodChannel`, `dio` e `Socket.startConnect`.
**Addresses:** contexto de rede, IP público, gateway e alcance/latência transparentes.
**Avoids:** plugins como fonte de verdade, ICMP não comprovado, gateway `.1` presumido e falha de provider tratada como offline.

### Phase 5: Experiência completa de diagnóstico
**Rationale:** Integra capacidades já testadas em um slice vertical sem empurrar semântica de rede para widgets.
**Delivers:** controller, tela, snapshots progressivos, start/cancel/repeat, estados completos, métricas, resumo copiável/compartilhável e última execução em memória.
**Addresses:** fluxo principal do v1, proveniência, acessibilidade e falhas acionáveis.
**Avoids:** whole-screen failure, segunda execução concorrente e resultados atualizados após cancelamento.

### Phase 6: Validação Android, privacidade e documentação
**Rationale:** Com adapters concretos é possível documentar apenas permissões e terceiros realmente usados e testar condições reais.
**Delivers:** matriz Wi-Fi/móvel/offline/VPN/portal cativo/troca de rede/background, análise/testes limpos, README, política de privacidade e manifesto mínimo.
**Addresses:** definition of done do projeto e confiança operacional.
**Avoids:** confiar em emulador, pedir localização “por garantia” e publicar claims não verificadas.

### Phase 7: Gate de viabilidade do speed test (go/no-go)
**Rationale:** Endpoint e contrato de medição são dependências de produto, jurídicas e operacionais; não são detalhe de implementação.
**Delivers:** decisão documentada sobre provider/protocolo, autorização/licença, geografia, capacidade/custo, privacidade/LGPD, seleção de servidor, caps de bytes/tempo/concurrency, consentimento, metodologia/precisão e endpoint controlado ou protocolo simulável.
**Gate duro:** somente `GO` se todos os critérios tiverem evidência; `NO-GO` encerra a fase com speed test explicitamente adiado. Ausência de solução aprovada não autoriza fallback informal.
**Avoids:** custo imprevisível, consumo surpresa, coleta/publicação inesperada, resultados enganosos e dependência frágil.

### Phase 8: Speed test limitado (somente após GO)
**Rationale:** Reutiliza cancelamento e métricas sem contaminar o diagnóstico básico, mas apenas quando a infraestrutura estiver aprovada.
**Delivers:** download/upload em streaming, consentimento a cada execução, caps rígidos, progresso, cancelamento imediato, invalidação por troca de rede e metodologia/provedor/bytes visíveis.
**Avoids:** buffer gigante, teste automático, concorrência ilimitada e resultado final para sessão incompleta.

### Phase Ordering Rationale

- A ordem crítica é: proteção contra regressões → shell/primitives → outcomes tipados → cancelamento → fakes/orquestração → adapters concretos → UI integrada → validação em device.
- UI e domínio são agrupados por contratos estáveis; capabilities independentes evitam que uma indisponibilidade bloqueie o todo.
- O gate de speed test ocorre depois do diagnóstico básico e antes de qualquer código de produção da feature, para que a incerteza externa não bloqueie o milestone principal.
- Acessibilidade, privacidade e lifecycle são critérios transversais desde a primeira fase, não polimento final.

### Research Flags

Phases likely needing deeper research during planning:
- **Phase 1:** executar `$gsd-ui-phase`; navegação compacta/ampla, hierarquia, tokens e acessibilidade exigem design contract.
- **Phase 4:** executar research-phase para validar gateway em devices/minSdk, alvo autorizado do probe, comportamento captive/VPN e decidir se ICMP merece spike. Gateway ICMP só avança com prova em múltiplos vendors/API levels e cancelamento <250 ms.
- **Phase 6:** validar target SDK, futuro `ACCESS_LOCAL_NETWORK`, matriz física Android e texto jurídico/privacidade dos providers reais.
- **Phase 7:** pesquisa obrigatória e decisão formal; inclui termos/licença, LGPD, custos, método, capacidade e estratégia de testes.
- **Phase 8:** research-phase obrigatório mesmo após GO, focado no protocolo/provider escolhido e limites empiricamente úteis.

Phases with standard patterns (skip research-phase):
- **Phase 2:** Material 3 adaptativo e migração incremental têm padrões oficiais e alta confiança; usar UI-SPEC como fonte.
- **Phase 3:** state machine, DI manual, outcomes, fakes e cancelamento cooperativo estão bem definidos pela arquitetura pesquisada.
- **Phase 5:** integração controller/listenable e rendering de estados segue contratos já estabelecidos; pesquisa adicional só se surgir novo framework.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH / MEDIUM | HIGH para Flutter, Dart, Android framework, Dio e arquitetura de cancelamento; MEDIUM para gateway/probe real; LOW para infraestrutura de speed test. |
| Features | HIGH | Table stakes, anti-features, matriz de estados e dependências convergem entre requisitos, APIs oficiais e referências de produto. |
| Architecture | HIGH / MEDIUM | HIGH para camadas, estado, testes, lifecycle e resultados parciais; MEDIUM para adapters até validação em devices. |
| Pitfalls | HIGH | Riscos principais são sustentados por documentação oficial Android/Flutter/Dart, RFCs e políticas publicadas. |

**Overall confidence:** HIGH para o roadmap do diagnóstico básico; MEDIUM para integrações concretas; LOW para prometer speed test.

### Gaps to Address

- **Alvo externo do probe:** escolher host/porta ou URL autorizada, estável, substituível e com política/SLA aceitáveis antes da Phase 4.
- **Gateway/ICMP:** validar disponibilidade por versão/vendor; se ICMP for obrigatório, executar spike com cancelamento, loss e cleanup comprovados. Caso contrário, exibir endereço e indisponibilidade do método.
- **IP público:** ipify é a recomendação atual, mas confirmar termos, disclosure, família IP desejada e política de fallback; falha continua parcial.
- **Android real:** definir minSdk/targetSdk finais e testar Wi-Fi, móvel, offline, VPN, portal, gateway ausente e troca de rede em devices.
- **Permissão LAN futura:** preparar outcome `permissionDenied`; não solicitar `ACCESS_LOCAL_NETWORK` antes do target SDK 37 exigir a feature ativa.
- **Speed test:** provider/protocolo, autorização, custo, capacidade, geografia, privacidade, retenção/publicação, caps, metodologia e ambiente controlado permanecem bloqueadores. M-Lab é referência de trade-offs, não seleção automática.
- **LGPD/Google Play:** revisão jurídica depende dos providers e fluxos finais antes de distribuição pública.

## Sources

### Primary (HIGH confidence)
- [Flutter architecture guide](https://docs.flutter.dev/app-architecture/guide) — separação, DI e testabilidade.
- [Flutter adaptive design](https://docs.flutter.dev/ui/adaptive-responsive/general) — adaptação por espaço disponível.
- [Flutter lifecycle API](https://api.flutter.dev/flutter/widgets/AppLifecycleListener-class.html) — pausa, retomada e dispose.
- [Android network state](https://developer.android.com/develop/connectivity/network-ops/reading-network-state) — rede padrão, capabilities, links e callbacks.
- [Android `NetworkCapabilities`](https://developer.android.com/reference/android/net/NetworkCapabilities) — `INTERNET`, `VALIDATED`, portal e transportes.
- [Android `LinkProperties`](https://developer.android.com/reference/android/net/LinkProperties) e [RouteInfo](https://developer.android.com/reference/android/net/RouteInfo) — endereços, rotas e gateway.
- [Android local network permission](https://developer.android.com/privacy-and-security/local-network-permission) — evolução de proteção LAN.
- [Dart `Future.timeout`](https://api.dart.dev/dart-async/Future/timeout.html), [`Socket.startConnect`](https://api.dart.dev/dart-io/Socket/startConnect.html) e [`HttpClientRequest.abort`](https://api.dart.dev/dart-io/HttpClientRequest/abort.html) — timeout e cancelamento físico.
- [Dio documentation](https://pub.dev/packages/dio) — `CancelToken`, timeouts e response streaming.
- [ipify API](https://www.ipify.org/) — endpoint HTTPS/JSON recomendado para IP público.
- [M-Lab NDT/ndt7](https://www.measurementlab.net/tests/ndt/) — metodologia, coleta e trade-offs de speed test.
- [Google Play User Data policy](https://support.google.com/googleplay/android-developer/answer/10144311) — responsabilidade por dados e terceiros.
- [LGPD — Lei 13.709/2018](https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709compilado.htm) — base regulatória brasileira.

### Secondary (MEDIUM confidence)
- `connectivity_plus` e `network_info_plus` — alternativas documentadas, mas inferiores ao snapshot Android para este escopo e com requisitos próprios de toolchain/permissão.
- Fing e Network Analyzer — landscape competitivo de ferramentas, não evidência de precisão ou prioridade para este MVP.
- Packages Flutter de ICMP/speed test — úteis apenas como candidatos de spike; nenhum satisfaz hoje o contrato integral do projeto.

### Tertiary (LOW confidence)
- Inferências sobre autorização de endpoints internos/defaults de serviços comerciais — ausência de documentação oficial é razão para não integrar, não prova jurídica de proibição.
- Viabilidade/precisão de um speed test Flutter futuro — depende totalmente do provider, protocolo e infraestrutura ainda não escolhidos.

---
*Research completed: 2026-08-10*
*Ready for roadmap: yes — speed test remains behind a mandatory feasibility gate*
