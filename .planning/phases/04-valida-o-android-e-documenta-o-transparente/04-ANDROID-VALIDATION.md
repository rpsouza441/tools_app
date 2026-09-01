---
requirement: QUAL-09
phase: 04-valida-o-android-e-documenta-o-transparente
created: "2026-09-01"
status: in_progress
mobile_data: NOT VERIFIED
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
- **Android físico com rede celular real:** indisponível nesta sessão → dados móveis fica NOT VERIFIED.

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
| 2 | **Dados móveis** | — | Parser cobre `transports:['cellular']` em fake; runtime celular não reproduzível em emulador | NOT VERIFIED | **NOT VERIFIED — requer Android físico com rede celular real** | Emulador não fornece rádio celular real (D-06). Único residual humano. |
| 3 | Offline (sem spinner infinito) | Android Emulator + Fakes | Run real com rede desligada → tela "Sem conexão com a internet", botão Repetir, sem spinner. Fake: `diagnostic_session_test.dart` (offline) | Fase termina offline sem travar | **VERIFIED (Android Emulator)** + AUTOMATED-FAKE | QUAL-01 comprovado em runtime. |
| 4 | IPv4 local da rede ativa | Android Emulator + Fakes | Run real: IPv4 local **10.0.2.16** (link real). Fake: `android_network_snapshot_source_test.dart` | IPv4 local real do LinkProperties | **VERIFIED (Android Emulator)** + AUTOMATED-FAKE | DIAG-03: não-link-local preferido; null honesto. |
| 5 | Gateway disponível (rota default) | Android Emulator + Fakes | Run real: Gateway **10.0.2.2** (rota default do emulador). Fake: `android_network_snapshot_source_test.dart` | Gateway real da rota default, não inventado | **VERIFIED (Android Emulator)** + AUTOMATED-FAKE | DIAG-04: da rota default `hasGateway`, nunca 192.168.1.1. |
| 6 | Gateway indisponível | Fakes | `diagnostic_session_test.dart` + `diagnostic_session_probes_test.dart` (sem gateway → probe count 0, status unavailable) | probe pulado, unavailable | AUTOMATED-FAKE | Emulador sempre tem gateway 10.0.2.2; ausência coberta por fake. |
| 7 | IP público (HTTPS ipify) | Android Emulator + Fakes | Run real: IPv4 público **200.101.151.97** via HTTPS api.ipify.org (sucesso). Fake: `public_ip_source_test.dart` (9), `diagnostic_session_public_ip_test.dart` | HTTPS a api.ipify.org bem-sucedido | **VERIFIED (Android Emulator)** + AUTOMATED-FAKE | DIAG-05: proveniência exibida; falha ≠ "sem internet". |
| 8 | TCP connect ao gateway | Android Emulator + Fakes | Run real: Gateway (TCP connect) Indisponível, `10.0.2.2:80`, sucessos 0 de 4, limitação honesta. Fake: `tcp_connect_probe_test.dart` (5) | Probe TCP executado; falha honesta (porta filtrada) | **VERIFIED (Android Emulator)** + AUTOMATED-FAKE | DIAG-06/08: rotulado "TCP connect", nunca ping/ICMP; denominador exibido. |
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

**Defeitos de runtime encontrados:** nenhum. O runtime Android no emulador
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
- **NOT VERIFIED (residual humano):** **dados móveis reais** (cenário #2) e
  captive portal real (R3). Enquanto dados móveis não for executado em Android
  físico com rede celular real, a Phase 4 permanece **`human_needed`** (D-07).
  Cancelamento (#11) e troca de rede mid-run (#12) permanecem AUTOMATED-FAKE
  (não reproduzíveis de forma confiável via automação no emulador), mas a
  lógica está coberta por testes determinísticos verdes.

*Matriz criada em 2026-09-01 (plano 04-01). Seções VERIFIED preenchidas pelo plano 04-02 com execução real no emulador.*
