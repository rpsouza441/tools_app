---
phase: 03-diagn-stico-de-internet-completo-e-resiliente
plan: "06"
status: complete
completed: "2026-09-01"
requirements:
  - DIAG-02
  - DIAG-03
  - DIAG-04
  - DIAG-05
  - DIAG-08
  - DIAG-09
  - DIAG-10
  - DIAG-11
  - QUAL-01
  - QUAL-05
  - QUAL-08
---

# 03-06 SUMMARY — Wiring de produção + honestidade da UI

## What was built

O default do app deixou de ser stub: no Android, um run de produção mede
snapshot + IP público + probes TCP/HTTPS reais. A UI mostra fatos independentes,
provenance honesta, agregados e ICMP indisponível.

### Composição (`lib/diagnostic/diagnostic_defaults.dart`)
- Gate `!kIsWeb && isAndroidPlatform()` (conditional import `diagnostic_platform_io.dart` / `_web.dart` — web nunca importa `dart:io`).
- Android: `AndroidNetworkSnapshotSource` + `SnapshotLocalIpv4Source` + `SnapshotDefaultGatewaySource` + `DioPublicIpSource(Dio(), PublicIpConfig())` + `TcpConnectGatewayProbe(GatewayProbeConfig())` + `DioHttpsInternetProbe(Dio(), HttpsProbeConfig())` + `LatencyAggregator()`.
- Não-Android/web: `UnsupportedNetworkSnapshotSource` + `Unavailable*` (D-04, QUAL-05 — nunca inventa 0 ms/gateway).
- Sete contratos permanecem tipos distintos; sem `NetworkService`.

### `AndroidNetworkSnapshotSource implements NetworkSnapshotSource`
- `current()` mapeia `AndroidSnapshotFacts` → `NetworkSnapshot` (captive→captivePortal etc.).
- `startWatching(onChanged)` agora entrega `NetworkSnapshot` fresco a cada `onNetworkChanged` do canal; `currentFacts()` preservado.

### UI (`lib/screen/internet_diagnostic_screen.dart`)
- Fatos separados: Transporte / INTERNET / Validado / Portal cativo (nunca badge Online único, D-13).
- Endereços (IPv4 local/gateway/**IPv4 público**) via `TechnicalValueRow` com provenance (método/alvo/timeout/**ipify**).
- Probes: `ToolMetric` do resumo + `ToolMetricLayout` mín/média/máx + denominador (ex.: "3 de 4", DIAG-09) + provenance com limitação (TCP não-L3 / HTTPS conexão fria).
- ICMP `ToolMetric` value null "Indisponível neste MVP"; **nunca** ping.
- phase→variant inclui offline; permissionDenied só se um fato local o reportar (não pede ACCESS_LOCAL_NETWORK). preservedChild em loading/failure/cancelled; success = card irmão (DIAG-11).

### Sessão
- `DiagnosticSessionImpl` já mapeava `!hasActiveNetwork → offline` (03-01); mantido, sem spinner eterno (QUAL-01).

### Testes
- `android_network_snapshot_source_test.dart`: callback de watch agora `(_) {}`; parser/canal verdes.
- `internet_diagnostic_screen_test.dart`: novos casos offline (Repetir habilitado, sem CircularProgressIndicator), parcial (ipify falha + HTTPS ok, ambos visíveis, sem alegação de internet completa), agregado 3/4 (denominador visível), ICMP sem "ping".

## Verification
- `flutter test --no-pub` (suíte inteira) → **230/230 passed**.
- `flutter analyze --no-pub` → **No issues found**.
- Widget tests usam `FakeDiagnosticSession` (sem rede real); produção não-Android usa stubs.
- `pubspec.lock-old` intocado (D-14); nenhum pacote novo.

## Deviations
- Detecção de plataforma via conditional import (`isAndroidPlatform()`) em vez de `dart:io` direto no arquivo, para manter o default compilável/limpo em web (kIsWeb → não-Android).

## Self-Check: PASSED
