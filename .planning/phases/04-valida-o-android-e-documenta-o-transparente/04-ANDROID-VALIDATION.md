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

| # | Cenário | Ambiente | Evidência | Resultado | Nível | Observações / Limitações |
|---|---------|----------|-----------|-----------|-------|--------------------------|
| 1 | Wi-Fi (transporte + capabilities) | Fakes + Emulador | `diagnostic_session_test.dart` (start success) + `android_network_snapshot_source_test.dart` (parser wifi) | (VERIFIED preenchido em 04-02) | AUTOMATED-FAKE | Emulador usa Wi-Fi virtual do host; captive/validated dependem do host. |
| 2 | **Dados móveis** | — | Parser cobre `transports:['cellular']` em fake; runtime celular não reproduzível em emulador | NOT VERIFIED | **NOT VERIFIED — requer Android físico com rede celular real** | Emulador não fornece rádio celular real (D-06). Único residual humano provável. |
| 3 | Offline (sem spinner infinito) | Fakes + Emulador | `diagnostic_session_test.dart` (offline → phase offline) | (VERIFIED preenchido em 04-02) | AUTOMATED-FAKE | QUAL-01: fase termina em `offline`, não trava. |
| 4 | IPv4 local da rede ativa | Fakes + Emulador | `android_network_snapshot_source_test.dart` (localIpv4 do link, null nunca inventado) | (VERIFIED preenchido em 04-02) | AUTOMATED-FAKE | DIAG-03: preferido não-link-local; null honesto. |
| 5 | Gateway disponível (rota default) | Fakes + Emulador | `android_network_snapshot_source_test.dart` (gatewayIpv4 mapeado) | (VERIFIED preenchido em 04-02) | AUTOMATED-FAKE | DIAG-04: da rota default `hasGateway`, nunca 192.168.1.1. |
| 6 | Gateway indisponível | Fakes + Emulador | `diagnostic_session_test.dart` + `diagnostic_session_probes_test.dart` (sem gateway → probe count 0, status unavailable) | (VERIFIED preenchido em 04-02) | AUTOMATED-FAKE | DIAG-06: probe pulado; nunca inventa endereço. |
| 7 | IP público (HTTPS ipify) | Fakes + Emulador | `public_ip_source_test.dart` (9 casos: sucesso/timeout/JSON inválido/IPv4) + `diagnostic_session_public_ip_test.dart` | (VERIFIED preenchido em 04-02) | AUTOMATED-FAKE | DIAG-05: HTTPS a api.ipify.org; falha ≠ "sem internet". |
| 8 | TCP connect ao gateway | Fakes + Emulador | `tcp_connect_probe_test.dart` (5 casos) | (VERIFIED preenchido em 04-02) | AUTOMATED-FAKE | DIAG-06/08: rotulado "TCP connect", nunca ping/ICMP. |
| 9 | HTTPS probe externo (gstatic 204) | Fakes + Emulador | `dio_https_probe_test.dart` (6 casos) | (VERIFIED preenchido em 04-02) | AUTOMATED-FAKE | DIAG-07/08: HTTPS GET esperando 204; nunca ICMP. |
| 10 | Resultado parcial preservado | Fakes + Emulador | `diagnostic_session_test.dart` (publicIp falha → partialFailure, demais preservados) + `diagnostic_session_probes_test.dart` (gateway timeout não bloqueia internet) | (VERIFIED preenchido em 04-02) | AUTOMATED-FAKE | DIAG-10: fatos concluídos sobrevivem a falha independente. |
| 11 | Cancelamento (aborta I/O em voo) | Fakes + Emulador | `diagnostic_session_test.dart` (cancel + resposta tardia mantém cancelled; publicIp.aborted) | (VERIFIED preenchido em 04-02) | AUTOMATED-FAKE | DIAG-12/QUAL-02: abort físico; tardio não reverte estado. |
| 12 | Mudança/perda de rede mid-run | Fakes + Emulador | `diagnostic_session_lifecycle_test.dart` (networkChanged → status networkChanged, sem mistura) | (VERIFIED parcial em 04-02) | AUTOMATED-FAKE | QUAL-03: não agrega redes diferentes. Troca Wi-Fi↔celular real não reproduzível em emulador. |
| 13 | Pause / resume / dispose | Fakes + Emulador | `diagnostic_session_lifecycle_test.dart` (dispose após start ignora tardio) | (VERIFIED preenchido em 04-02) | AUTOMATED-FAKE | QUAL-04: sem órfãos; resume não reinicia automaticamente. |

### Cenários de plataforma auxiliares (runtime)

| # | Item | Ambiente | Evidência | Resultado | Nível | Observações |
|---|------|----------|-----------|-----------|-------|-------------|
| R1 | MethodChannel Kotlin realmente registrado | Emulador | (04-02) app inicia, tela obtém snapshot sem MissingPluginException | (04-02) | NOT VERIFIED → VERIFIED em 04-02 | Compilar Kotlin não prova registro; exige execução. |
| R2 | Manifest final instalado = INTERNET + ACCESS_NETWORK_STATE | Emulador | (04-02) `adb shell dumpsys package` / merged manifest | (04-02) | NOT VERIFIED → VERIFIED em 04-02 | DOC-02 documenta o mesmo conjunto. |
| R3 | Captive portal real | — | Não reproduzível de forma confiável no emulador | NOT VERIFIED | NOT VERIFIED | Requer rede com portal cativo real. |

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
- **VERIFIED (Android Emulator):** ver seção preenchida pelo plano 04-02.
- **NOT VERIFIED (residual humano):** **dados móveis reais** (cenário #2) e
  captive portal real (R3). Enquanto dados móveis não for executado em Android
  físico com rede celular real, a Phase 4 permanece **`human_needed`** (D-07).

*Matriz criada em 2026-09-01 (plano 04-01). Seções VERIFIED preenchidas pelo plano 04-02.*
