---
phase: 03-diagn-stico-de-internet-completo-e-resiliente
plan: "05"
status: complete
completed: "2026-09-01"
requirements:
  - DIAG-06
  - DIAG-07
  - DIAG-08
  - DIAG-09
  - QUAL-02
  - QUAL-08
---

# 03-05 SUMMARY — Probes reais (TCP gateway + HTTPS internet)

## What was built

Probes de produção do contrato 5, com provenance honesta, amostras agregáveis e
cancelamento físico. **Não** ligados em `DiagnosticDefaults` (fica para 03-06).

### `lib/diagnostic/probes/probe_config.dart`
- `GatewayProbeConfig`: porta 80 (injetável), 4 amostras sequenciais, timeout 2s, `limitations` L3 obrigatória.
- `HttpsProbeConfig`: url default `https://www.gstatic.com/generate_204` (injetável), expectedStatus 204, 4 amostras, timeout 5s, userAgent honesto, `limitations` (3xx/200 ≠ internet completa/portal cativo).

### `TcpConnectGatewayProbe implements GatewayProbe` (DIAG-06/08, D-07, D-10)
- `Socket.startConnect` via `ConnectStarter` injetável (default real); N amostras sequenciais.
- Timer de timeout chama `ConnectionTask.cancel()` — não `Future.timeout` sozinho.
- Sucesso: `Stopwatch` + `socket.destroy()` imediato. cancel→cancelled, timeout→timeout, SocketException→failure.
- `provenance.method = 'TCP connect'` (nunca ping). Host vazio → `ArgumentError` (não inventa IP).

### `DioHttpsInternetProbe implements InternetProbe` (DIAG-07/08, D-10, D-12)
- N GETs sequenciais frios (`persistentConnection=false`), `followRedirects=false`, `maxRedirects=0`, timeouts 5s.
- `CancelToken` por amostra registrado no scope; `DioException` cancel→cancelled, timeout→timeout.
- Status == 204 → success (Stopwatch até status); 200-HTML/3xx → failure (não success, não captive). `method='HTTPS'`, host de gstatic; **nunca** api.ipify.org.

Ambos agregam via `LatencyAggregator` (DIAG-09).

### Testes
- `tcp_connect_probe_test.dart`: 4 sucessos via loopback ServerSocket; timeout/cancel via `Socket.startConnect` a TEST-NET-1 `192.0.2.1` (não-roteável, sem hang); host vazio→ArgumentError; provenance sem "ping". Sem mockito.
- `dio_https_probe_test.dart`: 204×4→success; 200-HTML→failure; 302→failure; receiveTimeout→timeout; cancel→cancelled; url default gstatic (não ipify). Adapter manuscrito.
- `diagnostic_session_probes_test.dart` (NOVO): sem gateway → `gatewayProbe.calls == 0`; gateway timeout não impede o internet probe (DIAG-10).

## Verification
- `flutter test --no-pub tcp_connect_probe_test.dart dio_https_probe_test.dart diagnostic_session_probes_test.dart` → **13/13 passed**.
- `flutter analyze --no-pub` (projeto inteiro) → **No issues found**.
- `grep` em `lib/diagnostic/probes`: `dart_ping`/`isReachable`/`ping` só em comentários negativos.
- `pubspec.lock-old` intocado (D-14); nenhum pacote novo (reusa dio).

## Deviations
- Testes TCP de timeout/cancel usam `Socket.startConnect` a `192.0.2.1` (TEST-NET-1) em vez de fingir `ConnectionTask` — `ConnectionTask` é `final` e não pode ser implementada fora da lib. Continua sem rede externa real e determinístico.

## Self-Check: PASSED
