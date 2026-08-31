# Phase 3: Diagnóstico de Internet completo e resiliente - Research

**Researched:** 2026-08-31
**Domain:** Flutter/Android connectivity diagnostics (snapshot, public IP, TCP/HTTPS probes, session lifecycle)
**Confidence:** HIGH for Android snapshot + Dio/Socket cancellation; MEDIUM for HTTPS probe target authorization and gateway TCP semantics; LOW for ICMP (intentionally unused)

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

- **D-01:** Goal permanece o do ROADMAP: `Usuários executam um diagnóstico de conectividade honesto, progressivo, cancelável e resistente a falhas parciais.`
- **D-02:** Só DIAG-01..15 e QUAL-01..08. Speed test, QUAL-09 e documentação pública ficam fora.
- **D-03:** Preservar as três ferramentas migradas. Adicionar destino de Diagnóstico ao catálogo tipado (UI-SPEC libera na Phase 3). Com 4 destinos, a Bar compacta mostra todos (overflow Ferramentas só a partir de 5).
- **D-04:** Android-first. Outras plataformas: capabilities ausentes = indisponível, nunca zero inventado (QUAL-05).

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

- **D-10:** Nunca rotular TCP/HTTPS como ICMP ping. ICMP no MVP só como capability **indisponível** até spike nativo aprovado.
- **D-11:** Sem localização / SSID / BSSID (QUAL-06). Sem telemetria (QUAL-07). Sem histórico persistente. Sem shell a partir da UI. Sem bloquear a isolate principal.
- **D-12:** IP público e probes externos devem registrar terceiro, dados enviados, timeout e substituição. Não encadear silenciosamente vários vendors.
- **D-13:** “Internet acessível” não é `transport != none`. É combinação honesta de fatos de plataforma (validated/captive quando existirem) **mais** probe de aplicação cancelável. Captive portal: reportar o sinal da plataforma; não fingir detecção perfeita.
- **D-14:** Não executar esta fase neste ciclo. Não tocar `pubspec.lock-old`.

Pesquisa deve decidir (com evidência atual, não conveniência):
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

### Deferred Ideas (OUT OF SCOPE)

- QUAL-09, DOC-01..04 — Phase 4
- GATE-01, GATE-02, SPD-* — Phase 5
- ICMP de produção — só após spike nativo
- Histórico persistente, analytics, SSID/BSSID
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| DIAG-01 | Um diagnóstico por vez, início manual | Sessão com geração/`runId`; botão iniciar desabilitado enquanto `running`; novo start só após estado terminal |
| DIAG-02 | Transporte, INTERNET, validated, captive separados | Snapshot Kotlin: `hasTransport(TRANSPORT_*)`, `NET_CAPABILITY_INTERNET`, `VALIDATED`, `CAPTIVE_PORTAL` — nunca um booleano `isOnline` |
| DIAG-03 | IPv4 local da rede ativa ou indisponível | `LinkProperties.getLinkAddresses()` da `getActiveNetwork()`; não `NetworkInterface.list()` |
| DIAG-04 | Gateway da rota default, sem endereço inventado | `RouteInfo.isDefaultRoute()` + `getGateway()` IPv4; `null` → indisponível |
| DIAG-05 | IPv4 público HTTPS + provedor + horário + falha independente | `PublicIpSource` Dio → `https://api.ipify.org?format=json`; validar JSON/`InternetAddress.tryParse`; outage ≠ “sem internet” |
| DIAG-06 | Alcance/latência do gateway quando alvo e método existirem | TCP connect (`Socket.startConnect`) ao IPv4 do gateway, porta injetada (default 80); ICMP indisponível; TCP falho ≠ L3 down |
| DIAG-07 | Alcance/latência de alvo externo autorizado e substituível | HTTPS GET injetável (default `https://www.gstatic.com/generate_204`, esperar 204, sem redirect); `CancelToken` por amostra |
| DIAG-08 | Método, alvo, porta/URL, timeout e limites visíveis | Cada fato carrega `method`, `target`, `portOrUrl`, `timeout`, `limitations`; labels **TCP connect** / **HTTPS**, nunca “ping” |
| DIAG-09 | min/média/máx, tentativas, sucessos, falhas com denominador | Agregador puro: min/avg/max só de sucessos; texto `3/4 sucessos` |
| DIAG-10 | Resultados concluídos sobrevivem a falha irmã | Fan-out independente após snapshot; um contrato não apaga outro |
| DIAG-11 | Progresso por etapa sem apagar parciais | Estado imutável copy-on-write; UI usa `ToolStatusPanel.preservedChild` |
| DIAG-12 | Cancelar e ignorar respostas tardias | Abortar `CancelToken`/`ConnectionTask`/timers/callback + ignorar se `runId` ≠ atual |
| DIAG-13 | Repetir após sucesso, falha parcial ou cancelamento | `start()` só em estado terminal; limpa run anterior e cria nova geração |
| DIAG-14 | Horário + último resultado da sessão, sem persistência | `startedAt`/`finishedAt` só em memória; sem SharedPreferences/arquivo/DB |
| DIAG-15 | Copiar e compartilhar resumo textual | Copiar: `CopyValueWriter` já existente. Compartilhar: `ShareTextPort` via `Intent.ACTION_SEND` (não `share_plus` neste AGP) |
| QUAL-01 | Sem spinner infinito em offline/móvel/gateway ausente/captive/serviço caído | Todo I/O tem timeout; fatos independentes; UI sempre alcança estado terminal |
| QUAL-02 | Interromper I/O real (requests, sockets, timers, streams, callbacks) | Escopo de cancelamento da sessão registra cada abort; `Future.timeout` sozinho é proibido |
| QUAL-03 | Não agregar Wi-Fi+móvel | `Network.getNetworkHandle()` + transports; mudança → `networkChanged` nas amostras restantes |
| QUAL-04 | Pause/hide/troca de destino/dispose: cancelar, sem auto-restart, sem UI descartada | `AppLifecycleListener` + contrato de visibilidade do `IndexedStack`; resume só refresca snapshot |
| QUAL-05 | Capability ausente = indisponível, não zero/falha global | Não-Android e campos `null` → `unavailable`; nunca `0 ms` inventado |
| QUAL-06 | Sem localização enquanto SSID/BSSID fora de escopo | Não chamar SSID/BSSID/`FLAG_INCLUDE_LOCATION_INFO`/`getTransportInfo`; não pedir location |
| QUAL-07 | Sem analytics de identificadores/resultados | Nenhum SDK de telemetria; adapters não logam PII; resumo só sai por copiar/compartilhar explícito |
| QUAL-08 | Testes com fakes: sucesso, timeout, offline, JSON inválido, cancel, troca de rede, lifecycle, parciais | `flutter_test` + fakes manuscritos; **não** `integration_test` nesta fase (QUAL-09 é Phase 4) |
</phase_requirements>

## Summary

A Phase 3 deve acrescentar um fluxo de diagnóstico **ao lado** das três ferramentas já migradas, sem monolito de rede e sem speed test. O snapshot da rede ativa sai de um adapter Kotlin estreito sobre `ConnectivityManager` + `NetworkCapabilities` + `LinkProperties`/`RouteInfo` (API 23+; o `minSdk` deste repo já é 24). HTTPS cancelável fica em `dio` 5.11.0 (`CancelToken` + timeouts `Duration`). Probes de gateway usam `Socket.startConnect` / `ConnectionTask.cancel`. ICMP **não** entra em produção.

“Internet acessível” é a **conjunção honestamente rotulada** de (1) fatos de plataforma INTERNET / VALIDATED / CAPTIVE_PORTAL e (2) o resultado do probe HTTPS de aplicação. Nenhum desses fatos, nem o IP público no ipify, prova que “toda a internet” funciona.

**Primary recommendation:** Manter Flutter 3.44 / Dart 3.12 / Material 3; adicionar só `dio: ^5.11.0`; implementar sete contratos injetáveis; snapshot nativo Android; ipify IPv4 como `PublicIpSource` inicial; TCP connect ao gateway; HTTPS GET substituível a `gstatic.com/generate_204` como probe externo; share via `ACTION_SEND` nativo (não `share_plus` enquanto AGP for 8.11.1); ICMP = indisponível.

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Catálogo / IndexedStack / visibilidade | Flutter UI (`AppShell`) | Tela de diagnóstico | Overflow e ciclo de vida da página já vivem no shell; o diagnóstico precisa ser avisado quando deixa de estar visível |
| Snapshot transporte/capabilities | Android nativo (`ConnectivityManager`) | Adapter Dart `NetworkSnapshotSource` | Única fonte autoritativa da rede **ativa**; plugins de conveniência não expõem VALIDATED/CAPTIVE/rota default |
| IPv4 local da rede ativa | Android nativo (`LinkProperties`) | Contrato Dart separado (pode ler o snapshot) | `NetworkInterface.list()` não escolhe a rota default |
| Gateway da rota default | Android nativo (`RouteInfo`) | Contrato Dart separado | `isDefaultRoute` + `getGateway`; nunca chute `192.168.1.1` |
| IPv4 público | Cliente HTTPS no device (`dio`) | Terceiro ipify | Sem backend próprio; encapsular URL/validação/cancelamento |
| Probe de gateway | dart:io no device | — | TCP connect cancelável; ICMP indisponível |
| Probe de internet | Cliente HTTPS no device (`dio`) | Terceiro do alvo injetado | Camada de aplicação, independente do ipify e do VALIDATED do SO |
| Orquestração / um run / cancelamento | Dart domain (fora de widgets) | UI só observa | Evita `setState` a partir de I/O e permite fakes |
| Agregação min/avg/max | Dart puro | — | Sem I/O; testável sem rede |
| Copiar resumo | Flutter services (`Clipboard`) | `CopyValueWriter` já existente | Padrão da Phase 1 |
| Compartilhar resumo | Android `Intent.ACTION_SEND` | Adapter Dart `ShareTextPort` | Texto puro; sem plugin que force AGP 8.12.1 |
| Persistência / analytics / backend | — | — | Proibido nesta fase |

## Project Constraints (from .cursor/rules/)

Nenhum `.cursor/rules/` no repositório. Restrições vigentes vêm de `PROJECT.md`, `AGENTS.md`/`STACK.md` (hipótese 2026-08-10, verificada abaixo) e `03-CONTEXT.md`.

## Standard Stack

### Core

| Library / API | Version | Purpose | Why Standard |
|---------------|---------|---------|--------------|
| Flutter + Material 3 | **3.44.0** stable (framework `559ffa3f75`, 2026-05-15) [VERIFIED: `C:\src\flutter\bin\flutter.bat --version`] | Shell, ToolScaffold, temas, acessibilidade | Já em produção; Phase 3 é incremental |
| Dart SDK | **3.12.0** (`pubspec` floor `^3.8.1`) [VERIFIED: mesmo comando] | Modelos, orquestração, `dart:io` | `Socket.startConnect`, records, `InternetAddress.tryParse` |
| Android `ConnectivityManager` + `NetworkCapabilities` + `LinkProperties` + `RouteInfo` | API 23+; repo `minSdk=24`, `targetSdk=36`, `compileSdk=36` [VERIFIED: `FlutterExtension.kt` deste SDK] | Snapshot da rede ativa | Docs oficiais: transporte, INTERNET, VALIDATED, CAPTIVE, endereços e rotas |
| Flutter `MethodChannel` | Flutter SDK | Um canal estreito de fatos serializáveis | Sem plugin de conectividade; handlers no main thread, trabalho curto |
| `dio` | **5.11.0** (pub.dev, publisher `flutter.cn`, Dart ≥2.18, MIT) [CITED: pub.dev/packages/dio] | IP público + probe HTTPS | `CancelToken` aborta o pedido; timeouts `Duration`; testável com adapter fake |
| `dart:io` `Socket.startConnect` / `ConnectionTask` | Dart 3.12 | Probe TCP do gateway | `cancel()` aborta a tentativa; `Socket.destroy()` após sucesso |

### Supporting

| Library / API | Version | Purpose | When to Use |
|---------------|---------|---------|-------------|
| `AppLifecycleListener` | Flutter SDK | pause/hide/resume/detach | Obrigatório na fronteira sessão↔UI |
| `flutter_test` | Flutter SDK | QUAL-08 | Fakes manuscritos; sem mockito |
| `Clipboard` / `CopyValueWriter` | já em `lib/design_system/copy_value_action.dart` | DIAG-15 copiar | Reutilizar; não criar segundo clipboard |
| `Intent.ACTION_SEND` + `createChooser` | Android framework | DIAG-15 compartilhar | Via `ShareTextPort`; sem permissão extra para texto |

### Alternatives Considered (não usar nesta fase)

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Snapshot Kotlin | `connectivity_plus` **7.3.1** | Docs do próprio plugin: transporte ≠ internet; captive possível; broadcast Android só em foreground; **AGP ≥ 8.12.1** (repo está em **8.11.1**) |
| `LinkProperties` ativo | `network_info_plus` | `getWifiGatewayIP()` / `getWifiIP()` são **Wi-Fi-only** e podem ser `null` em móvel/VPN; SSID/BSSID exigem localização — proibido |
| `Socket.startConnect` no gateway | `dart_ping` **10.0.1** | No Android usa subprocesso `ping` (conflita com “sem shell”); publisher “unverified uploader” |
| `Socket.startConnect` | `InetAddress.isReachable` | ICMP depois TCP echo porta 7; best-effort; bloqueante; não cancelável de forma limpa; **não é ICMP puro** |
| `Intent.ACTION_SEND` | `share_plus` **13.3.0** | Requer **AGP ≥ 8.12.1**, Gradle ≥ 8.13, Kotlin ≥ 2.2.0. Gradle 8.14.2 e Kotlin 2.2.21 já servem; **só o AGP 8.11.1 bloqueia**. Não vale um plugin extra só para texto |
| Dio direto ao ipify | `dart_ipify` / wrappers | Perderiam CancelToken, limite de body e injeção |

**Installation (única dependência hosted nova):**

```bash
flutter pub add dio:^5.11.0
```

Não adicionar `connectivity_plus`, `network_info_plus`, `dart_ping`, `share_plus`, `permission_handler`, pacotes de speed test, nem `integration_test` nesta fase.

**Version verification (2026-08-31):**
- Flutter 3.44.0 / Dart 3.12.0 — SDK em `C:\src\flutter` (não está no PATH desta sessão PowerShell; usar o caminho absoluto).
- dio 5.11.0 — latest stable em pub.dev, publicado há 37 dias; 5.9.2 ainda aparece em índices defasados — **não** piná-lo.
- AGP 8.11.1, Gradle 8.14.2, Kotlin 2.2.21, Java compile 17 (JDK da máquina: Temurin 21.0.7).
- `targetSdk` / `compileSdk` = 36 via `flutter.targetSdkVersion`.

## Package Legitimacy Audit

slopcheck **0.6.1** instalado, mas **não tem ecossistema pub.dev/Dart** (só pypi, npm, crates.io, go, rubygems, maven, packagist). **Não** rodar `slopcheck install dio` sem `--ecosystem`: no PyPI existe outro artefato homônimo — risco clássico de confusão cross-ecosystem.

| Package | Registry | Age | Downloads | Source Repo | slopcheck | Disposition |
|---------|----------|-----|-----------|-------------|-----------|-------------|
| `dio` 5.11.0 | pub.dev (publisher flutter.cn) | ~8 anos (1.0.0 em 2018; 5.x atual) | “8.3k likes” no pub.dev; não há weekly npm-style no scrape | github.com/cfug/dio [CITED: Context7 `/cfug/dio`] | N/A (sem pub.dev) | **Approved** — Context7 + pub.dev oficial. Planner: `flutter pub add dio:^5.11.0` sem checkpoint de slop. |
| `share_plus` 13.3.0 | pub.dev | maduro | — | fluttercommunity plus_plugins | N/A | **Não instalar** nesta fase (AGP) |
| `connectivity_plus` 7.3.1 | pub.dev | maduro | — | fluttercommunity | N/A | **Não instalar** |
| `network_info_plus` | pub.dev | maduro | — | fluttercommunity | N/A | **Não instalar** |
| `dart_ping` 10.0.1 | pub.dev | atual (59 dias) | baixo | GitHub; **unverified uploader** | N/A | **REMOVED** da recomendação (subprocesso `ping`) |
| qualquer speed-test (`internet_speed_test`, `flutter_internet_speed_test`, `flutter_network_speed_test`) | — | — | — | — | — | **REMOVED** — Phase 5 / GATE |

**Packages removed due to slopcheck [SLOP] verdict:** none (slopcheck não pontuou Dart).
**Packages flagged as suspicious [SUS]:** none scored; `dart_ping` rejeitado por arquitetura, não por slopcheck.

*dio é `[CITED: pub.dev + Context7]`. Não `[VERIFIED]` no sentido estrito do gate slopcheck, porque o gate não se aplica a pub.dev.*

## Third-Party Services

| Service | Role | URL | Data sent | Timeout | Substitutable | Silent cascade |
|---------|------|-----|-----------|---------|---------------|----------------|
| **ipify** (api.ipify.org) | IPv4 público | `https://api.ipify.org?format=json` | GET HTTPS; o servidor **vê o IP público** do cliente; User-Agent Dio/app; SNI `api.ipify.org`; corpo esperado `{"ip":"<v4>"}` | connect 5s, receive 5s, send 5s; body máx. 2048 bytes | **Sim** — URL injetada em `PublicIpSourceConfig` | **Não**. Um vendor. Falha = fato `publicIp` failed/unavailable |
| **Google gstatic** | Probe HTTPS de aplicação | `https://www.gstatic.com/generate_204` | GET HTTPS; sem body útil; `followRedirects: false`; esperar **204**; User-Agent identificável do app (não fingir Chrome) | connect 5s, receive 5s por amostra | **Sim** — `HttpsProbeConfig.url` + `expectedStatus` | **Não** |

**ipify — privacidade e SLA:** o site afirma “No visitor information is ever logged. Period.” [CITED: ipify.org]. Isso é **claim de marketing**, não SLA contratual. Tratar outage como falha **parcial**. Divulgar o hostname na UI e (Phase 4) na política de privacidade. Código-fonte do serviço: github.com/rdegges/ipify-api.

**Por que `api.ipify.org` e não `api64`:** DIAG-05 e a UI pedem **IPv4 público**. `api64` devolve a família usada naquela conexão (pode ser IPv6). Campo na UI: “IPv4 público”, provedor “ipify (api.ipify.org)”.

**Por que gstatic generate_204:** payload vazio, status 204 inequívoco, HTTPS (captive HTTP-intercept não se confunde com sucesso). Android/Chrome usam a variante **HTTP** do mesmo padrão para portal cativo — o probe do app é **HTTPS**, portanto evidência **independente** do `NET_CAPABILITY_VALIDATED` do SO. **Não há licença escrita Google para apps de terceiros** — ver Assumptions Log A1. Não usar `/cdn-cgi/trace` (devolve IP e colo). Não reutilizar o host do ipify no probe (DIAG-05 e DIAG-07 deixariam de ser independentes).

**Não enviar:** identificadores de usuário, resultados agregados, analytics, lista de apps, localização.

## Honest definition: “Internet acessível”

**Não é** `transport != none`. **Não é** um único booleano.

Exibir **três famílias de fatos**, cada uma com o próprio estado:

1. **Transporte da rede ativa** — `TRANSPORT_WIFI` / `CELLULAR` / `VPN` / `ETHERNET` / … (uma rede pode ter vários, ex. VPN sobre Wi-Fi). Ausência de rede ativa → transporte indisponível / offline de plataforma.
2. **Sinais do sistema Android** (quando a plataforma os fornecer):
   - `NET_CAPABILITY_INTERNET` = a rede **está configurada** para internet, não que servidores públicos respondam [CITED: developer.android.com reading-network-state, last updated 2026-06-02].
   - `NET_CAPABILITY_VALIDATED` = o SO **validou** conectividade (para redes INTERNET, “Internet connectivity was successfully detected”) [CITED: NetworkCapabilities.VALIDATED]. Ainda pode haver filtragem por IP ou perda súbita.
   - `NET_CAPABILITY_CAPTIVE_PORTAL` = o SO **encontrou** portal cativo na última sonda. Enquanto o login não completa: INTERNET + CAPTIVE, **sem** VALIDATED. Depois do login: VALIDATED sobe, CAPTIVE some. **Não é detecção perfeita** — é o sinal da plataforma.
   - `NET_CAPABILITY_NOT_METERED` = contexto (móvel/medido), não “online”.
3. **Probe de aplicação** — HTTPS GET ao alvo configurado, cancelável, com amostras. Sucesso = **este** HTTPS a **este** host retornou o status esperado. Não prova o restante da internet.

**Copy sugerida (pt-BR), não um badge mentiroso “Online”:**
- Validado pelo Android + HTTPS 204 → “O sistema validou a rede e o probe HTTPS a gstatic.com obteve 204.”
- Captive sem VALIDATED → “Indício de portal cativo (sinal Android). O probe HTTPS pode falhar até autenticar.”
- Transporte Wi-Fi, INTERNET, sem VALIDATED, HTTPS falhou → não dizer “sem cabo”; dizer os três fatos.
- ipify falhou e HTTPS 204 ok → “IPv4 público indisponível (ipify); o probe HTTPS a gstatic.com sucedeu.”

IP público bem-sucedido é evidência de **um** GET HTTPS ao ipify, não de “internet completa”.

## ICMP: unavailable in production MVP

| Candidate | Verdict | Evidence |
|-----------|---------|----------|
| `dart_ping` 10.0.1 | **Não usar** | pub.dev: Android/Windows/macOS/Linux via **subprocesso `ping`**. Conflita com D-11 (sem shell) e com cancelamento de I/O próprio |
| `InetAddress.isReachable` | **Não usar** | Docs Android: tenta ICMP ECHO e cai para **TCP Echo porta 7**; best-effort; firewalls mentem; em Oreo o timeout efetivo pode dobrar; chamada bloqueante, sem `ConnectionTask` |
| Plugin ICMP nativo próprio | Fora desta fase | Spike exigido pelo CONTEXT; expectativa: **não passa no MVP** |

**UI:** fato “ICMP” = `unavailable`, label “Indisponível neste MVP”, nunca mostrar 0 ms. Gateway e internet usam TCP/HTTPS com o nome real do método.

## Architecture Patterns

### System Architecture Diagram

```text
[Usuário: Iniciar / Cancelar / Repetir / Copiar / Compartilhar]
        |
        v
[InternetDiagnosticScreen]  --observa-->  ValueListenable<DiagnosticRunState> (imutável)
        |                                      ^
        | nunca chama Dio/Socket               |
        v                                      |
[DiagnosticSession]  (contrato 6: um run, runId, cancel scope)
        |
        +-- snapshot --> [NetworkSnapshotSource] --MethodChannel--> [Kotlin ConnectivityManager]
        |                     |                       facts: transports, internet, validated,
        |                     |                       captive, notMetered, localIpv4, gatewayIpv4,
        |                     v                       networkHandle
        |              contratos 2–3 leem o snapshot (sem segundo I/O)
        |
        +-- fan-out independente (após snapshot):
        |       [PublicIpSource] --Dio+CancelToken--> api.ipify.org
        |       [GatewayProbe]   --Socket.startConnect--> gateway:port
        |       [InternetProbe]  --Dio+CancelToken--> gstatic generate_204
        |
        +-- [LatencyAggregator] (contrato 7) sobre amostras de cada probe
        |
        +-- NetworkCallback só enquanto running --> motivo networkChanged
        +-- AppLifecycleListener + visibilidade IndexedStack --> cancel
        |
        v
[ShareTextPort] --MethodChannel--> Intent.ACTION_SEND text/plain
[CopyValueWriter] --> Clipboard (já existe)
```

### Recommended Project Structure

```
lib/
  app/
    app_destinations.dart          # inserir 4º destino após Hash
    app_shell.dart                 # notificar visibilidade do diagnóstico
  design_system/                   # não duplicar; reutilizar ToolScaffold/status/copy
  diagnostic/
    models/
      diagnostic_fact.dart         # status: success/unavailable/failure/cancelled/timeout/networkChanged
      diagnostic_run_state.dart    # imutável + copyWith
      latency_aggregate.dart
      probe_provenance.dart        # method, target, portOrUrl, timeout, limitations, thirdParty
    contracts/
      network_snapshot_source.dart
      public_ip_source.dart
      gateway_probe.dart
      internet_probe.dart
      diagnostic_session.dart
      share_text_port.dart
    aggregation/
      latency_aggregator.dart
    session/
      diagnostic_session_impl.dart
      cancellation_scope.dart      # registra CancelToken, ConnectionTask, Timer, callback
    public_ip/
      dio_public_ip_source.dart
      public_ip_config.dart
    probes/
      tcp_connect_probe.dart
      dio_https_probe.dart
      probe_config.dart
    platform/
      android_network_snapshot_source.dart
      unsupported_network_snapshot_source.dart
      android_share_text_port.dart
  screen/
    internet_diagnostic_screen.dart
android/app/src/main/kotlin/br/dev/rodrigopinheiro/tools_app/
  MainActivity.kt                  # registrar canais (arquivo hoje está em com/example/tools_app — ver pitfall)
  NetworkSnapshotPlugin.kt         # só fatos; sem SSID
  ShareTextPlugin.kt
```

Nomes de tipo sugeridos (discrição): `NetworkSnapshotSource`, `PublicIpSource`, `GatewayProbe`, `InternetProbe`, `DiagnosticSession`, `LatencyAggregator` / modelo `LatencyAggregate`, `ShareTextPort`. **Não** criar `NetworkService`.

Local IPv4 e gateway **podem** ser extraídos do snapshot (um round-trip nativo) desde que os **contratos Dart** continuem separados e testáveis — a UI e a sessão dependem das interfaces, não do plugin.

### Pattern 1: Snapshot Android (fatos, não opinião)

**What:** `getActiveNetwork()` + `getNetworkCapabilities` + `getLinkProperties` no início do run e no resume. Durante o run, `registerDefaultNetworkCallback` **somente enquanto `running`**, unregister no terminal/cancel/dispose.

**When to use:** Sempre no Android. Não-Android: `UnsupportedNetworkSnapshotSource` → todos os campos `unavailable`.

**Kotlin — fatos serializáveis (não `toString()` de Capabilities):**

```kotlin
// Source: https://developer.android.com/develop/connectivity/network-ops/reading-network-state
val cm = getSystemService(ConnectivityManager::class.java)
val network = cm.activeNetwork // requires ACCESS_NETWORK_STATE
val caps = network?.let { cm.getNetworkCapabilities(it) }
val link = network?.let { cm.getLinkProperties(it) }

val transports = buildList {
  if (caps?.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) == true) add("wifi")
  if (caps?.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) == true) add("cellular")
  if (caps?.hasTransport(NetworkCapabilities.TRANSPORT_VPN) == true) add("vpn")
  if (caps?.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET) == true) add("ethernet")
}
val hasInternet = caps?.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) == true
val validated = caps?.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED) == true
val captive = caps?.hasCapability(NetworkCapabilities.NET_CAPABILITY_CAPTIVE_PORTAL) == true
val notMetered = caps?.hasCapability(NetworkCapabilities.NET_CAPABILITY_NOT_METERED) == true
```

IPv4 local: iterar `link.linkAddresses`, ficar com `Inet4Address`, excluir link-local `169.254.0.0/16` se houver outro. Se vários, preferir o que casa com a interface da rota default IPv4; senão o primeiro não-link-local; senão `null` → indisponível.

Gateway: iterar `link.routes`; `route.isDefaultRoute && route.hasGateway()`; gateway `Inet4Address` → string. Sem match → `null`. **Nunca** defaultar `192.168.1.1`.

Identidade para QUAL-03: `network.networkHandle` (Long) + conjunto de transports. Mudança de handle **ou** troca wifi↔cellular durante o run → `networkChanged`.

**Não** usar `NetworkCallback.FLAG_INCLUDE_LOCATION_INFO`. **Não** ler `WifiInfo`/SSID/BSSID/`transportInfo` (docs: campo location-sensitive; ACCESS_FINE_LOCATION). [CITED: NetworkCapabilities getTransportInfo / FLAG_INCLUDE_LOCATION_INFO]

Callback: **não** chamar `getNetworkCapabilities`/`getLinkProperties` síncronos dentro de `onAvailable` (race). Esperar `onCapabilitiesChanged` / `onLinkPropertiesChanged`. Unregister em `onPause` da sessão, não deixar callback órfão (há limite de callbacks). [CITED: reading-network-state]

`getActiveNetwork()` exige `ACCESS_NETWORK_STATE`. [CITED: ConnectivityManager.getActiveNetwork]

### Pattern 2: Sessão com geração e cancelamento físico

**What:** `DiagnosticSession.start()` incrementa `runId`, cria `CancellationScope`, publica estado `running`. Qualquer conclusão de I/O com `runId` antigo é descartada.

**When to use:** Sempre. Inclusive fakes nos testes QUAL-08.

Escopo registra: `cancelToken.cancel()`, `connectionTask.cancel()`, `timer.cancel()`, `cm.unregisterNetworkCallback`. Depois marca terminal `cancelled`. `CancelableOperation` / `Future.timeout` **não** substituem o abort.

Um run por vez: se `state.phase == running`, `start()` é no-op (ou lança em debug). A UI não oferece Iniciar. Cancelar é a única saída. Repetir só em terminal.

Fan-out: snapshot primeiro (fornece gateway). Em seguida `Future.wait` com `eagerError: false` equivalente — na prática `wait` em lista de futures que **capturam** erros por fato, para ninguém cancelar o irmão. DIAG-10.

### Pattern 3: Probes e agregação

**Gateway (DIAG-06):** se `gatewayIpv4 == null` → fato `unavailable` (“sem rota default IPv4”), **não** executa TCP. Senão N amostras **sequenciais** de `Socket.startConnect(InternetAddress(gateway), port)`. Default **porta 80**, timeout **2s** por amostra, N=**4**. Após connect: `socket.destroy()` imediato. Label: **TCP connect**. Limitação obrigatória na UI: “Falha TCP não prova que o gateway está inalcançável em L3; roteadores costumam filtrar portas.”

**Internet (DIAG-07):** N=4 amostras sequenciais HTTPS GET, `persistentConnection: false` (ou Dio novo por amostra) para não medir conexão quente. `followRedirects: false`. Sucesso = status == 204. 3xx/200 com HTML = falha (possível interceptação), não “sucesso”. Métrica: tempo total até status (Stopwatch no client), documentado como “HTTPS GET (resposta de status), conexão fria”.

**Agregação (DIAG-09):** min/média/máx **somente** amostras `success`. `attempts = N` (ou menos se cancel/networkChanged no meio). `successes` / `failures` com denominador = attempts efetivadas (excluir cancelled/networkChanged do denominador de “falha”, mas mostrar linhas separadas: `2 sucessos, 1 timeout, 1 cancelado (3 tentativas concluídas / 4 planejadas)`). Média em double; UI em ms inteiros com método visível.

### Pattern 4: Catálogo e visibilidade

Inserir após Hash [D-03 + UI-SPEC Phase 3]:

| Campo | Valor |
|-------|--------|
| `id` | `internet_diagnostic` |
| `label` | `Diagnóstico` |
| `semanticLabel` | `Diagnóstico de Internet` |
| `category` | novo `AppDestinationCategory.diagnostico` |
| `compactPriority` | `4` (Rede=1, Armazenamento=2, Hash=3 permanecem pinned se um dia houver 5+ destinos) |

Com 4 destinos, `AppShell._barUsesOverflow` (`length > 4`) continua falso — os quatro aparecem na NavigationBar.

`IndexedStack` **preserva** `State`. UI-SPEC Phase 1: “IndexedStack não autoriza I/O oculto.” O `AppShell` deve expor visibilidade (ex. `ValueNotifier<String> selectedId` ou callback `onDestinationVisible(id, visible)`). Quando `selectedId != internet_diagnostic` e há run `running` → `session.cancel()`. Pause/hide do app → cancel. Resume → `snapshotSource.current()` fresco; **não** `start()`.

Atualizar `test/app/destination_catalog_test.dart` (hoje afirma exatamente 3 ids).

### Anti-Patterns to Avoid

- **`NetworkService` monolítico** — viola D-05; impede falha parcial testável.
- **`connectivity_plus` como `isOnline`** — o README do plugin diz o contrário.
- **`NetworkInterface.list()` como autoridade** — inventário de todas as interfaces, inclusive virtuais.
- **Rotular TCP/HTTPS como ping** — D-10.
- **`Future.timeout` sem abortar** — o `Future.timeout` do Dart só completa o wrapper; o I/O continua [CITED: dart-lang/sdk `future_impl.dart`].
- **Agregar amostras após troca wifi↔móvel**.
- **Auto-restart no resume**.
- **`setState` dentro de adapter**.
- **Pedir localização / `FLAG_INCLUDE_LOCATION_INFO`**.
- **Cascade silencioso de vendors** de IP público.
- **Instalar `share_plus` sem subir AGP**.
- **Adicionar `ACCESS_LOCAL_NETWORK` ou `permission_handler` com target 36**.
- **Speed-test packages / `SpeedTestEngine` de produção**.
- **`integration_test` como substituto de QUAL-08** — QUAL-09 é Phase 4.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| HTTP cancelável + timeout | HttpClient cru + `Future.timeout` | `dio` `CancelToken` + `BaseOptions` Duration | Abort real; um token por run/amostra |
| TCP cancelável | `Socket.connect` + ignore | `Socket.startConnect` + `ConnectionTask.cancel` + `destroy()` | Docs oficiais de cancelamento |
| Snapshot de rota/capabilities | parsear `ip route` / shell | Kotlin `ConnectivityManager` | Sem shell; rede ativa |
| Clipboard | canal novo | `CopyValueWriter` existente | Já testado (UI-09) |
| Share sheet de texto | UI própria de apps | `Intent.ACTION_SEND` | Sistema já faz o chooser |
| JSON de IP | regex de IPv4 | `jsonDecode` + `InternetAddress.tryParse` | Rejeita lixo e IPv6 inesperado |
| Mock de I/O | mockito/code-gen | Fakes manuscritos das 7 interfaces | QUAL-08 / CONTEXT |

**Key insight:** o difícil não é a média de 4 RTT — é **abortar I/O de verdade** e **não mentir** sobre método, rede ativa e portal cativo. Usar as primitivas oficiais (CancelToken, ConnectionTask, ConnectivityManager) e hand-roll só orquestração, modelo e agregação.

## Common Pitfalls

### Pitfall 1: Resposta tardia após cancel
**What goes wrong:** UI volta de `cancelled` para `success` quando o GET termina.  
**Why:** `Future.timeout` ou `await` sem checar `runId`.  
**How to avoid:** abortar o I/O **e** `if (result.runId != current) return;`. Teste obrigatório QUAL-08.  
**Warning signs:** SnackBar/status mudando sozinho depois de Cancelar.

### Pitfall 2: Misturar Wi-Fi e móvel
**What goes wrong:** min/avg mistura 20 ms (wifi) com 80 ms (cellular).  
**Why:** callback `onAvailable` no meio das amostras.  
**How to avoid:** handle+transports; abortar resto com `networkChanged`; não chamar o agregador em conjunto misto.  
**Warning signs:** transports do snapshot inicial ≠ transports do fim do run.

### Pitfall 3: Chamar TCP/HTTPS de “ping”
**What goes wrong:** perda de confiança; requisito DIAG-08.  
**How to avoid:** enums de método + copy review; teste de widget que falha se o texto “ping” aparecer para esses fatos.

### Pitfall 4: `Future.timeout` sem abort
**What goes wrong:** socket/HTTP segue até o SO cansar; QUAL-02 falha.  
**How to avoid:** timer do timeout chama `ConnectionTask.cancel()` / `CancelToken.cancel()`, não só completa um Future.

### Pitfall 5: `NetworkInterface.list()` como verdade
**What goes wrong:** mostra IP de VPN/rmnet/wlan ao mesmo tempo, ou um IP que não é o da rota ativa.  
**How to avoid:** só `LinkProperties` da `activeNetwork`. `NetworkInterface.list` no máximo como fallback **não-Android** rotulado indisponível/aproximado — nesta fase, não-Android = unavailable.

### Pitfall 6: Gateway TCP = “gateway morto”
**What goes wrong:** usuário acha que o roteador caiu porque a porta 80 recusou.  
**How to avoid:** copy de limitação; endereço do gateway continua visível mesmo se o probe falhar (DIAG-10).

### Pitfall 7: Captive “detector perfeito”
**What goes wrong:** app afirma portal cativo sem o sinal Android, ou ignora o sinal.  
**How to avoid:** só reportar `NET_CAPABILITY_CAPTIVE_PORTAL`; HTTPS 3xx no probe é “resposta inesperada”, não “captive comprovado”.

### Pitfall 8: INTERNET só no debug
**What goes wrong:** release sem sockets.  
**How to avoid:** declarar `INTERNET` e `ACCESS_NETWORK_STATE` no **main** `AndroidManifest.xml`. Hoje só debug/profile têm `INTERNET`; main **não tem nenhuma** das duas. Ambas são *normal permissions* (install-time). [CITED: developer.android.com/develop/connectivity/network-ops/connecting]

### Pitfall 9: Location por acidente
**What goes wrong:** Play Console / usuário vê pedido de localização.  
**How to avoid:** zero `ACCESS_FINE_LOCATION` / `COARSE` / `NEARBY_WIFI_DEVICES`; não usar APIs SSID; não `FLAG_INCLUDE_LOCATION_INFO`.

### Pitfall 10: IndexedStack continua o diagnóstico oculto
**What goes wrong:** QUAL-04; dados móveis queimados em background de UI.  
**How to avoid:** contrato de visibilidade no `AppShell` (já previsto no UI-SPEC Phase 1 linha IndexedStack).

### Pitfall 11: `ACCESS_LOCAL_NETWORK` cedo demais
**What goes wrong:** prompt inútil ou target 37 acidental.  
**How to avoid:** target atual **36**; apps `< 37` com `INTERNET` têm grant **implícito temporário**. Modelar `permissionDenied` no **modelo**, não pedir, não declarar a permission. [CITED: developer.android.com/privacy-and-security/local-network-permission — Android 17 enforcement]

### Pitfall 12: Pacote `MainActivity` vs pasta
**What goes wrong:** canal não registra.  
**How to avoid:** `MainActivity.kt` está em `android/app/src/main/kotlin/com/example/tools_app/` com `package br.dev.rodrigopinheiro.tools_app`. Manter o `package` alinhado ao `namespace` Gradle; registrar o `MethodChannel` em `configureFlutterEngine`.

### Pitfall 13: Dio keep-alive nas amostras HTTPS
**What goes wrong:** amostra 1 inclui handshake; 2–4 saem “rápidas demais” e a UI parece milagrosa.  
**How to avoid:** `persistentConnection: false` / cliente por amostra; documentar “conexão fria”.

### Pitfall 14: Testes de catálogo quebram
**What goes wrong:** `destination_catalog_test` espera 3 ids.  
**How to avoid:** atualizar contrato para 4 destinos no mesmo plano que o catálogo.

## Code Examples

Verified patterns from official sources:

### TCP connect cancelável

```dart
// Source: https://api.dart.dev/stable/dart-io/Socket/startConnect.html
// Source: https://api.dart.dev/stable/dart-io/ConnectionTask/cancel.html
// Source: https://api.dart.dev/stable/dart-io/Socket/destroy.html
final sw = Stopwatch()..start();
final task = await Socket.startConnect(InternetAddress(gatewayIpv4), port);
late Timer timer;
timer = Timer(timeout, task.cancel); // abort físico, não só Future.timeout
try {
  final socket = await task.socket;
  timer.cancel();
  socket.destroy();
  return sw.elapsed;
} on SocketException {
  timer.cancel();
  rethrow;
}
```

`ConnectionTask.cancel()` faz `task.socket` completar com `SocketException` cujo texto indica cancelamento. [CITED: api.dart.dev ConnectionTask.socket]

### Dio CancelToken + timeouts Duration

```dart
// Source: https://github.com/cfug/dio/blob/main/dio/README.md (Context7 /cfug/dio)
// Source: https://pub.dev/documentation/dio/latest/dio/CancelToken-class.html
final dio = Dio(
  BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    sendTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
    followRedirects: false,
    maxRedirects: 0,
    persistentConnection: false,
    validateStatus: (s) => s != null && s < 600, // tratar 204/4xx no caller
    headers: {'Accept': 'application/json', 'User-Agent': 'ToolsApp-Diagnostic/1.1.1'},
  ),
);
final token = CancelToken();
scope.register(() => token.cancel('run cancelled'));
try {
  final res = await dio.get<Map<String, dynamic>>(
    'https://api.ipify.org?format=json',
    cancelToken: token,
  );
  // size, json shape, InternetAddress.tryParse — ver abaixo
} on DioException catch (e) {
  if (CancelToken.isCancel(e) || e.type == DioExceptionType.cancel) {
    // cancelled
  }
}
```

Validação ipify: status 200; se `content-length` > 2048, rejeitar; `data` deve ser `Map` com `ip` `String`; `InternetAddress.tryParse(ip)` não-null e `type == InternetAddressType.IPv4`. Qualquer outro formato → fato `failure` (resposta inválida), **não** derruba o run.

### MethodChannel Kotlin (padrão Flutter)

```kotlin
// Source: https://docs.flutter.dev/platform-integration/platform-channels
override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
  super.configureFlutterEngine(flutterEngine)
  MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "br.dev.rodrigopinheiro.tools_app/network_snapshot")
    .setMethodCallHandler { call, result ->
      // invoked on main thread — keep snapshot reads short
      when (call.method) {
        "getSnapshot" -> result.success(readSnapshotMap())
        else -> result.notImplemented()
      }
    }
}
```

### AppLifecycleListener

```dart
// Source: https://api.flutter.dev/flutter/widgets/AppLifecycleListener-class.html
late final AppLifecycleListener _lifecycle;
_lifecycle = AppLifecycleListener(
  onPause: session.cancel,
  onHide: session.cancel,
  onDetach: session.cancel,
  onResume: () { session.refreshSnapshotOnly(); },
);
// dispose(): _lifecycle.dispose(); session.cancel();
```

### Share texto Android (sem share_plus)

```kotlin
val send = Intent(Intent.ACTION_SEND).apply {
  type = "text/plain"
  putExtra(Intent.EXTRA_TEXT, text)
}
startActivity(Intent.createChooser(send, "Compartilhar diagnóstico"))
```

Sem permissão extra. Não precisa de `queries` extras para o chooser do sistema.

### Permissions no main manifest

```xml
<!-- Source: https://developer.android.com/develop/connectivity/network-ops/connecting -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

Não adicionar `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`, `ACCESS_BACKGROUND_LOCATION`, `NEARBY_WIFI_DEVICES`, `ACCESS_LOCAL_NETWORK`, `CHANGE_NETWORK_STATE`.

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `NetworkInfo` / `CONNECTIVITY_ACTION` | `NetworkCapabilities` + `NetworkCallback` | API 21–28 deprecation; `NetworkInfo` deprecated API 29 | Não usar APIs deprecated |
| Plugin `connectivity` como online | Transporte + VALIDATED + probe de app | Docs Android 2024–2026; README connectivity_plus | Três fatos, não um bool |
| `Future.timeout` | Abort `CancelToken` / `ConnectionTask` | Sempre foi verdade no Dart; ainda pega gente | QUAL-02 |
| `ping` subprocesso | TCP/HTTPS nomeados | Política do projeto 2026 | ICMP indisponível |
| `share_plus` recente | AGP 8.12.1+ | share_plus 12.0.0 breaking | Este repo: Intent nativo |
| Local network aberto | `ACCESS_LOCAL_NETWORK` no target 37 | Android 17 | Modelar, não pedir agora |

**Deprecated/outdated:**
- `ConnectivityManager.getActiveNetworkInfo()` — deprecated API 29.
- `connectivity_plus` como prova de internet — o próprio pacote desencoraja.
- Wrappers de IP público que escondem o vendor.
- Pacotes Flutter de speed test com endpoints HTTP de terceiros — Phase 5.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Usar `https://www.gstatic.com/generate_204` como probe HTTPS inicial é aceitável sem contrato Google | Third-party / DIAG-07 | Google pode rate-limit, mudar o endpoint ou discordar do uso. Mitigação: URL 100% injetável; UI mostra o host. Planner pode trocar o default sem redesenhar contratos |
| A2 | Porta TCP **80** é o default menos pior para gateway doméstico | Gateway probe | Muitos gateways filtram 80; 53 às vezes abre. Mitigação: porta injetável + copy de limitação |
| A3 | 4 amostras e timeouts 2s (TCP) / 5s (HTTPS) cabem no QUAL-01 sem spinner eterno | Probes | Em rede péssima o run pode passar de ~30s. Mitigação: progresso por etapa; cancel sempre disponível |
| A4 | `Intent.createChooser` + `ACTION_SEND` text/plain cobre DIAG-15 em Android sem `queries` extras | Share | OEM estranho. Mitigação: copiar continua funcionando |
| A5 | Claim ipify “não loga visitantes” é só marketing | Public IP | Exposição de IP a terceiro é certa de qualquer forma — divulgar na UI |
| A6 | Em target 36, probe TCP ao gateway LAN **não** precisa de `ACCESS_LOCAL_NETWORK` | Permissions | Android 16 opt-in de restrição LAN pode quebrar o probe em devices de teste. Mitigação: fato `permissionDenied` no modelo; não opt-in nesta fase; QUAL-09 na Phase 4 |

## Open Questions (RESOLVED for planning)

1. **Licença/ToS do generate_204 para app de terceiro** — RESOLVED (planning default): A1 + 03-05. Default `https://www.gstatic.com/generate_204`, URL 100% injetável. Evidência de ToS Google para apps de terceiros **permanece ausente** — produto pode trocar o host antes do execute sem redesenhar contratos.

2. **Porta default do gateway** — RESOLVED: A2 + 03-05. TCP porta **80**, injetável; copy de limitação L3; endereço visível se o probe falhar.

3. **Subir AGP 8.12.1 só para share_plus** — RESOLVED: **não** subir AGP; 03-07 usa `ShareTextPort` + `Intent.ACTION_SEND`.

4. **Não-Android nesta fase** — RESOLVED: 03-06. Snapshot/local/gateway `unavailable` fora de Android; compromisso Android-first.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | build/test | ✓ (não no PATH desta sessão) | 3.44.0 @ `C:\src\flutter` | usar `C:\src\flutter\bin\flutter.bat` |
| Dart SDK | analyze/test | ✓ via Flutter | 3.12.0 | — |
| Android SDK | snapshot nativo / device | ✓ | `local.properties` `C:\Users\Rodrigo\AppData\Local\Android\sdk` | — |
| JDK | Gradle | ✓ | Temurin 21.0.7 (compile do app = 17) | — |
| AGP / Gradle / Kotlin | Android | ✓ | 8.11.1 / 8.14.2 / 2.2.21 | não subir nesta fase |
| pub.dev `dio` | HTTPS | ✓ | 5.11.0 | — |
| slopcheck | legitimidade | ✓ mas sem pub.dev | 0.6.1 | auditoria manual Context7+pub.dev |
| Device Android físico | QUAL-09 | não exigido agora | — | Phase 4 |
| ipify / gstatic | DIAG-05/07 em device | rede externa | — | fakes em QUAL-08; outage = parcial |

**Missing dependencies with no fallback:** nenhum para QUAL-08 (tudo fakeável).

**Missing dependencies with fallback:** Flutter no PATH — usar o SDK em `C:\src\flutter`.

Step 2.6 note: `flutter`/`dart` não estão no PATH do PowerShell desta sessão; o SDK local está instalado e responde em `C:\src\flutter\bin\`.

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no | App sem conta |
| V3 Session Management | no | Sem sessão de usuário; só `runId` local |
| V4 Access Control | no | Sem backend |
| V5 Input Validation | yes | JSON ipify: tipo, tamanho, `InternetAddress.tryParse`, só IPv4; status HTTPS do probe; não executar strings de rede como código |
| V6 Cryptography | no extra | TLS via Dio/`dart:io` padrão; não pin custom nesta fase; não hand-roll TLS |
| V7 Error Handling | yes | Falhas parciais; sem stack trace na UI |
| V8 Data Protection | yes | Sem persistência de diagnóstico; sem analytics; clipboard/share só por ação explícita |
| V13 Malicious Clients / Network | yes | Timeouts; sem cascade de vendors; User-Agent honesto |
| Privacy / least privilege | yes | Sem location; INTERNET + ACCESS_NETWORK_STATE only |

### Known Threat Patterns for Flutter/Android diagnostics

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| App pede location “porque Wi-Fi” | Information disclosure | Não SSID/BSSID; QUAL-06 |
| Telemetria acidental (Firebase/crashlytics de resultado) | Information disclosure | Não adicionar SDKs; QUAL-07 |
| SSRF / URL aberta a input do usuário | Spoofing / elevation | URL de IP e probe **compiladas/injetadas em config**, não campo livre na UI desta fase |
| Body JSON enorme / bomb | Denial of service | Limite 2048 bytes no PublicIpSource |
| Redirect para host inesperado | Tampering | `followRedirects: false` |
| Cancel “cosmético” deixa socket aberto | Denial of service (bateria/dados) | CancelToken + ConnectionTask + runId |
| Fingerprint LAN agressivo | Information disclosure | Uma porta, um host (o gateway da rota), user-initiated; sem scan de faixa |
| `ACCESS_LOCAL_NETWORK` cedo | Privacy | Não declarar / não pedir no target 36 |
| Mentir ICMP | Tampering (integridade da evidência) | Labels fixos TCP/HTTPS |
| Logcat com IP público | Information disclosure | Adapters sem `Log` de endereços em release |

## Sources

### Primary (HIGH confidence)

- Context7 `/cfug/dio` — CancelToken, DioExceptionType.cancel, timeouts Duration, README
- Context7 `/dart-lang/sdk` — `Future.timeout` **não** aborta a origem; ConnectionTask no http_impl
- Context7 `/flutter/website` — MethodChannel Kotlin `configureFlutterEngine`
- https://api.dart.dev/stable/dart-io/Socket/startConnect.html — ConnectionTask
- https://api.dart.dev/stable/dart-io/ConnectionTask-class.html e `/cancel.html` — cancel aborta e completa com SocketException
- https://api.dart.dev/stable/dart-io/Socket/destroy.html
- https://api.dart.dev/stable/dart-io/NetworkInterface/list.html — inventário, sem rede ativa
- https://api.dart.dev/stable/dart-io/InternetAddress/tryParse.html
- https://api.flutter.dev/flutter/widgets/AppLifecycleListener-class.html
- https://developer.android.com/develop/connectivity/network-ops/reading-network-state — last updated **2026-06-02** — activeNetwork, Capabilities, LinkProperties, VALIDATED vs INTERNET, CAPTIVE, callback races, unregister
- https://developer.android.com/reference/android/net/NetworkCapabilities — INTERNET, VALIDATED, CAPTIVE_PORTAL, NOT_METERED, TRANSPORT_*
- https://developer.android.com/reference/android/net/ConnectivityManager — `getActiveNetwork` requires ACCESS_NETWORK_STATE
- https://developer.android.com/reference/android/net/LinkProperties — `getLinkAddresses`, `getRoutes` (API 21+)
- https://developer.android.com/reference/android/net/RouteInfo — `isDefaultRoute`, `getGateway`, `hasGateway` (API 21+)
- https://developer.android.com/develop/connectivity/network-ops/connecting — INTERNET + ACCESS_NETWORK_STATE normal permissions
- https://developer.android.com/privacy-and-security/local-network-permission — target 36 vs 37 `ACCESS_LOCAL_NETWORK`
- https://developer.android.com/about/versions/17/behavior-changes-17 — enforcement Android 17
- https://developer.android.com/reference/java/net/InetAddress — isReachable ICMP then TCP echo
- https://pub.dev/packages/dio — 5.11.0 latest
- https://www.ipify.org/ — JSON IPv4 `api.ipify.org?format=json`, claim de no-log
- https://docs.flutter.dev/platform-integration/platform-channels
- Workspace: `pubspec.yaml` (sem dio), manifests, `android/settings.gradle` AGP 8.11.1, `FlutterExtension.kt` min/target 24/36, `flutter --version` 3.44.0

### Secondary (MEDIUM confidence)

- https://pub.dev/packages/connectivity_plus — 7.3.1; transporte ≠ internet; AGP ≥ 8.12.1; recheck on resume
- https://pub.dev/packages/share_plus — 13.3.0; AGP ≥ 8.12.1 desde 12.0.0
- https://pub.dev/packages/dart_ping — 10.0.1 subprocess `ping` no Android; unverified uploader
- https://pub.dev/packages/network_info_plus — SSID/BSSID exigem location; gateway Wi-Fi-only
- https://github.com/flutter/website/.../local-network-permission.md — Flutter reitera target 37 + opt-in teste no 16
- Chrome/Android generate_204 como padrão de captive (HTTP) — independência do probe HTTPS do app

### Tertiary (LOW confidence)

- Uso de gstatic generate_204 **por apps de terceiro** sem ToS dedicado — A1
- Porta 80 como default de gateway — A2
- Blog posts sobre Android 17 LAN (só reforço; primário são docs Google)

## Metadata

**Confidence breakdown:**
- Standard stack: **HIGH** — Flutter/Dart/AGP/minSdk/dio 5.11.0 verificados nesta sessão; Android snapshot APIs nas docs 2026-06-02
- Architecture: **HIGH** — sete contratos batem com D-05 e com as APIs; share nativo vs share_plus é decisão de AGP verificada
- Pitfalls: **HIGH** — late results, mix wifi/mobile, ping label, Future.timeout, NetworkInterface.list, INTERNET só em debug são todos observados no repo ou nas docs
- HTTPS target authorization: **LOW–MEDIUM** — A1
- Gateway TCP meaning: **MEDIUM** — método certo e honesto; taxa de sucesso real varia por CPE

**Research date:** 2026-08-31  
**Valid until:** 2026-09-30 (dio/Android 17/permission LAN podem andar rápido; snapshot APIs são estáveis)

**STACK.md 2026-08-10 — o que mudou / o que confirmou:**
- Confirmado: Flutter 3.44.0, Dart 3.12.0, dio 5.11.0, MethodChannel+ConnectivityManager, Socket.startConnect, ipify, evitar connectivity_plus-as-online, evitar dart_ping, não pedir ACCESS_LOCAL_NETWORK no target ≤36, QUAL device em fase posterior.
- Corrigir/afinar: corpo do STACK cita `api64` e a tabela cita `api.ipify.org` — **usar api.ipify.org** para IPv4.
- **Não** adicionar `integration_test` nesta fase (QUAL-09 = Phase 4).
- **Não** adicionar `share_plus` sem bump de AGP; Intent nativo é o fit.
- minSdk efetivo **24**, não precisa fallback API 21–22.
- EventChannel **não** é necessário no MVP (callback só durante o run).
