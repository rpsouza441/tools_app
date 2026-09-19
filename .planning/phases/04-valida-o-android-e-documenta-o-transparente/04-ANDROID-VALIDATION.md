---
requirement: QUAL-09
phase: 04-valida-o-android-e-documenta-o-transparente
created: "2026-09-01"
updated: "2026-09-19"
status: verified
mobile_data: VERIFIED (Android físico, relato do usuário)
physical_final_checks: VERIFIED (2026-09-19 — gateway probe removido, alinhamento centralizado, preservação de contexto ao retomar)
---

# QUAL-09 — Matriz de Validação Android

Comprova o comportamento do Diagnóstico de Internet (Phase 3) nos cenários
Android-alvo. A matriz separa **rigidamente** três níveis de evidência e
**nunca** promove um a outro.

## Níveis de evidência (regra de honestidade)

| Nível | Significa | Não significa |
|-------|-----------|---------------|
| **VERIFIED** | Executado e observado em Android real (físico ou emulador). A observação (tela e/ou `adb logcat`) confirma o comportamento. | — |
| **AUTOMATED-FAKE** | Coberto por teste determinístico com fakes manuscritos (unit/widget), verde na Phase 3. Prova a lógica fora da UI. | **Não** prova o runtime da plataforma. Fake ≠ verificado em Android. |
| **NOT VERIFIED** | Não executado / não comprovado neste ciclo. | — |

**Regra absoluta (D-02, D-03):** um item AUTOMATED-FAKE **jamais** é rotulado
VERIFIED. Dados móveis só podem ser VERIFIED com Android físico e rede celular
real (D-06). Se qualquer cenário humano obrigatório não for executado, a fase
permanece `human_needed` (D-07).

**Ambientes desta rodada:**

- **AUTOMATED-FAKE:** `flutter test --no-pub` → 235/235 verdes (Phase 3), analyze limpo.
- **VERIFIED (Android Emulator):** AVD `Medium_Phone_API_36.0` (API 36), rede via Wi-Fi virtual do host. Preenchido pelo plano 04-02 apenas quando realmente executado.
- **Android físico com rede celular real:** Redmi Note 12 Pro, teste 4G relatado pelo usuário em 2026-09-09; resumo copiado registra `cellular`. Versão Android e operadora não informadas. Ver adendo físico abaixo.

---

## Matriz de cenários

Execução VERIFIED: app de produção (`app-debug.apk`) instalado e executado no
emulador `emulator-5554` (AVD `Medium_Phone_API_36.0`, API 36) em 2026-09-01.
Um run real produziu (observado na tela e por `adb`): Transporte **wifi**,
INTERNET **Sim**, Validado **Sim**, Portal cativo **Não**, IPv4 local
**10.0.2.16**, Gateway **10.0.2.2**, IPv4 público **200.101.151.97** via
`HTTPS · api.ipify.org · timeout 5s`, Gateway (TCP connect) **Indisponível**
(`10.0.2.2:80`, sucessos 0 de 4, com limitação honesta), Internet (HTTPS)
**média 1016 ms** (mín 264 / máx 1847, sucessos 4 de 4) via
`https://www.gstatic.com/generate_204`, **ICMP Indisponível**, Início/Fim
carimbados, ícones Copiar/Compartilhar presentes. Segundo run com rede
desligada (`svc wifi/data disable`, "Active default network: none") terminou em
**"Sem conexão com a internet"** sem spinner infinito.

| # | Cenário | Ambiente | Evidência | Resultado | Nível | Observações / Limitações |
|---|---------|----------|-----------|-----------|-------|--------------------------|
| 1 | Wi-Fi (transporte + capabilities) | Android Emulator + Fakes | Run real: Transporte wifi, INTERNET Sim, Validado Sim, Portal cativo Não. Fake: `diagnostic_session_test.dart`, `android_network_snapshot_source_test.dart` | Transporte/capabilities reais lidos via canal | **VERIFIED (Android Emulator)** + AUTOMATED-FAKE | Emulador usa Wi-Fi virtual do host. |
| 2 | **Dados móveis** | Redmi Note 12 Pro, 4G informado pelo usuário | Resumo real 2026-09-09 16:40:06–16:40:14: cellular, INTERNET/Validado Sim, Portal cativo Não, IP público ok, HTTPS 4/4 (média 262 ms), gateway TCP 0/4 | Medições concluídas; defeito de mensagem geral identificado | **VERIFIED (Android físico, relato do usuário)** | Correção da mensagem parcial aguarda reteste; Android/operadora não informados. |
| 3 | Offline (sem spinner infinito) | Android Emulator + Fakes | Run real com rede desligada → tela "Sem conexão com a internet", botão Repetir, sem spinner. Fake: `diagnostic_session_test.dart` (offline) | Fase termina offline sem travar | **VERIFIED (Android Emulator)** + AUTOMATED-FAKE | QUAL-01 comprovado em runtime. |
| 4 | IPv4 local da rede ativa | Android Emulator + Fakes | Run real: IPv4 local **10.0.2.16** (link real). Fake: `android_network_snapshot_source_test.dart` | IPv4 local real do LinkProperties | **VERIFIED (Android Emulator)** + AUTOMATED-FAKE | DIAG-03: não-link-local preferido; null honesto. |
| 5 | Gateway disponível (rota default) | Android Emulator + Fakes | Run real: Gateway **10.0.2.2** (rota default do emulador). Fake: `android_network_snapshot_source_test.dart` | Gateway real da rota default, não inventado | **VERIFIED (Android Emulator)** + AUTOMATED-FAKE | DIAG-04: da rota default `hasGateway`, nunca 192.168.1.1. |
| 6 | Gateway indisponível | Fakes | `diagnostic_session_test.dart` + `diagnostic_session_probes_test.dart` (sem gateway → probe count 0, status unavailable) | probe pulado, unavailable | AUTOMATED-FAKE | Emulador sempre tem gateway 10.0.2.2; ausência coberta por fake. |
| 7 | IP público (HTTPS ipify) | Android Emulator + Fakes | Run real: IPv4 público **200.101.151.97** via HTTPS api.ipify.org (sucesso). Fake: `public_ip_source_test.dart` (9), `diagnostic_session_public_ip_test.dart` | HTTPS a api.ipify.org bem-sucedido | **VERIFIED (Android Emulator)** + AUTOMATED-FAKE | DIAG-05: proveniência exibida; falha ≠ "sem internet". |
| 8 | TCP connect ao gateway | Android Emulator + Fakes | Run real: Gateway (TCP connect) Indisponível, `10.0.2.2:80`, sucessos 0 de 4, limitação honesta. Fake: `tcp_connect_probe_test.dart` (5) | Probe TCP executado; falha honesta (porta filtrada) | **VERIFIED (Android Emulator)** *(histórico 2026-09-01)* | DIAG-06/08: rotulado "TCP connect", nunca ping/ICMP; denominador exibido. **Nota (2026-09-09):** este probe foi **removido da UI** após a validação física (DIAG-06 descopado na Phase 4). A linha permanece como registro histórico da rodada de emulador; a build atual não exibe o probe TCP do gateway — só o endereço (PF-1). |
| 9 | HTTPS probe externo (gstatic 204) | Android Emulator + Fakes | Run real: Internet (HTTPS) média 1016 ms (mín 264/máx 1847), sucessos 4 de 4, `gstatic.com/generate_204`. Fake: `dio_https_probe_test.dart` (6) | HTTPS GET 204 real com métricas | **VERIFIED (Android Emulator)** + AUTOMATED-FAKE | DIAG-07/08: HTTPS esperando 204; nunca ICMP; limitação exibida. |
| 10 | Resultado parcial preservado | Android Emulator + Fakes | Run real: gateway TCP falhou mas todos os demais fatos (IP local/gateway/público/HTTPS) preservados e exibidos. Fake: `diagnostic_session_test.dart`, `diagnostic_session_probes_test.dart` | Fatos concluídos sobrevivem a falha independente | **VERIFIED (Android Emulator)** + AUTOMATED-FAKE | DIAG-10: verdict parcial sem apagar fatos. |
| 11 | Cancelamento (aborta I/O em voo) | Fakes | `diagnostic_session_test.dart` (cancel + resposta tardia mantém cancelled; publicIp.aborted) | abort físico; tardio não reverte | AUTOMATED-FAKE | DIAG-12/QUAL-02. Emulador conclui rápido demais para cancelar de forma confiável via adb; lógica coberta por fake determinístico. |
| 12 | Mudança/perda de rede mid-run | Fakes | `diagnostic_session_lifecycle_test.dart` (networkChanged → status networkChanged, sem mistura) | não agrega redes diferentes | AUTOMATED-FAKE | QUAL-03. Troca Wi-Fi↔celular real não reproduzível em emulador. |
| 13 | Pause / resume / dispose | Android Emulator + Fakes | Run real: navegação entre abas (IndexedStack) e volta não reinicia nem trava; resultado preservado. Fake: `diagnostic_session_lifecycle_test.dart` (dispose-after-start) | sem órfãos; resume não reinicia | **VERIFIED (Android Emulator)** + AUTOMATED-FAKE | QUAL-04. |

### Cenários de plataforma auxiliares (runtime)

| # | Item | Ambiente | Evidência | Resultado | Nível | Observações |
|---|------|----------|-----------|-----------|-------|-------------|
| R1 | MethodChannel Kotlin realmente registrado | Android Emulator | App inicia (FlutterJNI ok, Dart VM ativo, sem MissingPluginException/FATAL no logcat) e a tela de Diagnóstico obteve snapshot real via canal | Registrado e funcional | **VERIFIED (Android Emulator)** | Compilar Kotlin não bastava; execução comprova o registro. |
| R2 | Manifest final instalado = INTERNET + ACCESS_NETWORK_STATE | Android Emulator | `adb shell dumpsys package` → requested permissions: android.permission.INTERNET, android.permission.ACCESS_NETWORK_STATE (+ DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION, signature). Sem localização ("location is error") | Confere com DOC-02 | **VERIFIED (Android Emulator)** | DYNAMIC_RECEIVER é auto-gerada pelo AndroidX (signature), não é privacidade. |
| R3 | Captive portal real | — | Não reproduzível de forma confiável no emulador | NOT VERIFIED | NOT VERIFIED | Requer rede com portal cativo real. |

**Defeitos na rodada do emulador (2026-09-01):** nenhum. O runtime Android no emulador
reproduziu o comportamento esperado sem crash, sem MissingPluginException, sem
gateway inventado e sem spinner infinito offline.

---

## Camada AUTOMATED-FAKE — resumo

Fonte: `03-VERIFICATION.md` (235 testes verdes, analyze limpo). Contagem por
arquivo relevante ao QUAL-09:

- `diagnostic_session_test.dart` — 6 casos (success, concurrent no-op, partial, gateway ausente, cancel+tardio, offline)
- `diagnostic_session_lifecycle_test.dart` — 2 casos (networkChanged, dispose-after-start)
- `diagnostic_session_probes_test.dart` — 2 casos (gateway ausente, gateway timeout não bloqueia internet)
- `diagnostic_session_public_ip_test.dart` — 1 caso
- `android_network_snapshot_source_test.dart` — 5 casos (parser + canal getSnapshot/startWatching/stopWatching)
- `public_ip_source_test.dart` — 9 casos
- `dio_https_probe_test.dart` — 6 casos
- `tcp_connect_probe_test.dart` — 5 casos
- `latency_aggregator_test.dart` — 3 casos
- `diagnostic_summary_formatter_test.dart` — 1 caso
- `internet_diagnostic_screen_test.dart` — 9 casos (widget)

Estes provam a **lógica** fora da UI. Não substituem a verificação de runtime
Android (camada VERIFIED).

---

## Status da fase

- **AUTOMATED-FAKE:** completo (Phase 3, 235 testes verdes).
- **VERIFIED (Android Emulator):** completo para Wi-Fi (#1), offline (#3),
  IPv4 local (#4), gateway disponível (#5), IP público (#7), TCP connect (#8),
  HTTPS probe (#9), resultado parcial (#10), pause/resume/dispose (#13) e os
  itens de runtime R1 (canal registrado) e R2 (manifest instalado). Nenhum
  defeito de runtime encontrado.
- **VERIFIED (Android físico, relato do usuário em 2026-09-09):** dados móveis reais
  (#2) e execução Wi-Fi no Redmi Note 12 Pro, com IP público e HTTPS bem-sucedidos.
- **VERIFIED (Android físico, 2026-09-19):** checks finais PF-1 (probe TCP do gateway
  removido, endereço mantido), PF-2 (estados "Concluído"/"Processando" centralizados)
  e PF-3 (4G → Wi-Fi → retomar sem Repetir preserva o resultado cellular, sem mistura
  de redes). Ver "Validação física final — 2026-09-19".
- **Residual humano:** **RESOLVIDO** em 2026-09-19. A preservação do contexto da
  execução ao trocar rede e retomar (sem Repetir) foi confirmada em device físico
  (PF-3). QUAL-09 = **verified**; Phase 4 pode ser fechada como `passed`.
  Captive portal real (R3) permanece NOT VERIFIED (fora da Definition of Done da fase;
  requer rede com portal cativo real). Cancelamento (#11) e troca de rede mid-run (#12)
  permanecem AUTOMATED-FAKE (não reproduzíveis de forma confiável por automação), com
  a lógica coberta por testes determinísticos verdes.

*Matriz criada em 2026-09-01 (plano 04-01). Seções VERIFIED preenchidas pelo plano 04-02 com execução real no emulador.*

## Adendo — teste físico de 2026-09-09

Fonte: resumos copiados pelo usuário nesta conversa; aparelho informado: Redmi Note 12 Pro.
Versão Android, operadora e VPN não informadas. IPs públicos omitidos deste adendo.

| Rede | Início / fim | Capacidades | IP público | Gateway TCP | HTTPS |
|------|--------------|-------------|------------|-------------|-------|
| 4G (`cellular`) | 16:40:06 / 16:40:14 | INTERNET Sim, Validado Sim, Portal cativo Não | Sucesso via ipify | 0/4, porta 80, timeout 2s | 4/4; mín 251 / média 262 / máx 267 ms |
| Wi-Fi (`wifi`) | 16:41:50 / 16:41:58 | INTERNET Sim, Validado Sim, Portal cativo Não | Sucesso via ipify | 0/4, porta 80, timeout 2s | 4/4; mín 150 / média 168 / máx 182 ms |

As duas execuções terminaram em 8 segundos e preservaram as medições HTTPS e IP público
apesar da falha TCP. Não é possível determinar por esse resultado por que a porta não respondeu.
O usuário identificou a mensagem genérica "Não foi possível concluir / Confira os dados e tente
novamente". A investigação confirmou mapeamento inadequado do estado parcial e ausência do
motivo de falha do probe na tela. Correção e regressão registradas em
`../../debug/diagnostico-falha-parcial.md`. Nova mensagem confirmada nas capturas de 16:52;
não promover cancelamento/troca de rede para runtime verificado com esses dois resumos.

### Reteste e capturas — 16:51–16:52

- Resumo Wi-Fi: 16:51:26–16:51:34; IP público ok; TCP 0/4; HTTPS 4/4, mín 192/média 298/máx 579 ms.
- Resumo cellular: 16:51:49–16:51:57; IP público ok; TCP 0/4; HTTPS 4/4, mín 185/média 248/máx 348 ms.
- As capturas mostram título parcial correto, mensagem da falha TCP e medições preservadas: defeito de apresentação anterior resolvido.
- Novo defeito visível: cabeçalho wifi/gateway 192.168.22.1 com probe 192.0.0.1:80 e horários/métricas da execução cellular. Não é evidência de agregação durante uma execução: investigação local identificou sobrescrita do snapshot no `refreshSnapshotOnly` ao retomar, mantendo medições antigas.
- Correção: snapshot de execução permanece associado aos resultados. `Repetir` coleta nova rede; refresh só publica fatos enquanto idle, com proteção contra resultado tardio e descarte. Sessão: `../../debug/diagnostico-rede-ao-retomar.md`.
- Reteste necessário: concluir em 4G, mudar para Wi-Fi e retomar; último resultado deve continuar cellular com gateway celular e mesmos horários/métricas. Depois de Repetir, todo o novo resultado deve ser Wi-Fi.

### Reteste — 17:04–17:05

Quatro capturas e dois resumos fornecidos pelo usuário confirmam consistência
entre a tela e o resumo em novas execuções no Redmi Note 12 Pro:

| Rede | Início / fim | Gateway e alvo TCP | HTTPS |
|------|--------------|-------------------|-------|
| Wi-Fi | 17:04:11 / 17:04:20 | 192.168.22.1 / 192.168.22.1:80 | 4/4; mín 148 / média 302 / máx 663 ms |
| Cellular | 17:05:02 / 17:05:11 | 192.0.0.1 / 192.0.0.1:80 | 4/4; mín 220 / média 1096 / máx 3647 ms |

Ambas: IP público obtido, gateway TCP 0/4, mensagem parcial correta e motivo TCP
visível. Nenhuma mistura observada nessas execuções. Ainda falta confirmação do
passo específico de retomar após mudar a rede, sem Repetir; as imagens não
documentam esse intervalo. Phase 4 permanecia human_needed até essa confirmação
— **superado em 2026-09-19** pela seção "Validação física final" abaixo (PF-3
confirmou o passo de retomar após troca de rede sem Repetir).

## Validação física final — 2026-09-19 (residual humano resolvido)

Fonte: confirmação textual do usuário nesta conversa (2026-09-19). Os três checks
físicos que faltavam para fechar a Phase 4 passaram no Android físico
(Redmi Note 12 Pro). Estes checks eliminam o residual humano remanescente e não
podiam ser reproduzidos por automação (troca real de transporte 4G↔Wi-Fi e
renderização visual em device).

| # | Check físico | Resultado observado pelo usuário | Nível | Cobertura em código |
|---|--------------|----------------------------------|-------|---------------------|
| PF-1 | "Gateway (TCP connect)" não aparece mais; endereço do gateway continua exibido | Linha do probe TCP ausente; endereço do gateway presente como fato | **VERIFIED (Android físico)** | `lib/screen/internet_diagnostic_screen.dart` — `_address(context, 'Gateway', state.gateway)` (endereço mantido); nenhum `_probe` de gateway; único probe é `Internet (HTTPS)` |
| PF-2 | "Concluído" e "Processando" centralizados corretamente | Ambos os cabeçalhos aparecem centralizados em todos os estados | **VERIFIED (Android físico)** | `lib/design_system/tool_status_panel.dart` — headings `Processando`/`Concluído` com `textAlign: TextAlign.center` em coluna centralizada; `preservedChild` full-width preserva o card |
| PF-3 | 4G → sair → ativar Wi-Fi → voltar **sem tocar em Repetir** preserva o resultado 4G, sem mistura de resultados entre redes | Último resultado permaneceu cellular ao retomar; nenhuma sobrescrita de contexto observada | **VERIFIED (Android físico)** | Correção `refreshSnapshotOnly` — refresh só publica fatos enquanto `idle`, com proteção contra resultado tardio/descarte; snapshot da execução permanece associado ao resultado. Sessão: `../../debug/diagnostico-rede-ao-retomar.md` |

PF-3 é exatamente o passo que faltava documentar nos retestes anteriores
(retomar após mudar a rede **sem** Repetir). Com ele confirmado, não há mistura
de redes na apresentação do último resultado.

**Evidência de verificação oficial (2026-09-19), reexecutada localmente:**

- `flutter analyze --no-pub` → **No issues found!** (limpo).
- `flutter test --no-pub` → **235/235 — All tests passed!** (EXIT=0, reexecutado
  duas vezes para determinismo).

*Nota de contagem de testes:* relatos intermediários de 2026-09-09 citaram 242
testes durante o trabalho de correção do contexto de rede; a suíte autoritativa
atual reporta **235** verdes. Registra-se 235 como a contagem de fechamento da
Phase 4.

Com PF-1/PF-2/PF-3 VERIFIED em Android físico e a suíte verde, o **residual
humano de QUAL-09 está resolvido** e a Phase 4 pode ser fechada como `passed`.
