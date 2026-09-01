---
phase: 03-diagn-stico-de-internet-completo-e-resiliente
plan: "02"
status: complete
completed: "2026-09-01"
requirements:
  - DIAG-02
  - DIAG-03
  - DIAG-04
  - QUAL-06
---

# 03-02 SUMMARY — Snapshot Android (Kotlin MethodChannel)

## What was built

Snapshot autoritativo da rede ativa via Kotlin + MethodChannel, com permissões
normais no manifest main e privilégio mínimo (sem localização/LAN, sem SSID/BSSID).

### Android (Kotlin, package `br.dev.rodrigopinheiro.tools_app`)
- `NetworkSnapshotPlugin.kt` (em `com/example/tools_app/` — pasta **não** movida, Pitfall 12): lê `activeNetwork` + `NetworkCapabilities` + `LinkProperties`/`RouteInfo`.
  - transports: wifi/cellular/vpn/ethernet via `hasTransport`.
  - capabilities: INTERNET, VALIDATED, CAPTIVE_PORTAL, NOT_METERED.
  - `localIpv4`: primeiro Inet4Address não-link-local; só cai para 169.254/16 se for o único; senão null (DIAG-03).
  - `gatewayIpv4`: `RouteInfo.isDefaultRoute && hasGateway`, Inet4Address; senão null — nunca 192.168.1.1 (DIAG-04).
  - `networkHandle` para QUAL-03.
  - `startWatching`/`stopWatching`: `registerDefaultNetworkCallback` só sob demanda; capabilities lidas em `onCapabilitiesChanged`/`onLinkPropertiesChanged` (não em `onAvailable`); unregister idempotente.
- `MainActivity.kt`: `configureFlutterEngine` registra o canal `br.dev.rodrigopinheiro.tools_app/network_snapshot` (getSnapshot/startWatching/stopWatching) e reencaminha mudanças de rede via `onNetworkChanged`.
- `AndroidManifest.xml` (main): adiciona **apenas** INTERNET + ACCESS_NETWORK_STATE; sem localização, sem ACCESS_LOCAL_NETWORK (QUAL-06, D-11, target ≤36).

### Dart (`lib/diagnostic/platform/android_network_snapshot_source.dart`)
- `kNetworkSnapshotChannel` constante.
- `AndroidSnapshotFacts` (mapa Kotlin 1:1, IPv4 anuláveis) + `NetworkSnapshotMapParser.parse`.
- `AndroidNetworkSnapshotSource` com MethodChannel: `currentFacts()`, `startWatching`/`stopWatching`, recebe `onNetworkChanged`.
- **Deliberadamente não** `implements NetworkSnapshotSource` (design travado do plano) — 03-06 faz o wrap. Sem `NetworkInterface.list`, sem plugins plus.

### Testes (`test/diagnostic/android_network_snapshot_source_test.dart`)
- Parser: mapa completo 1:1; sem IPs → null (nunca 192.168.1.1); sem rede ativa → transports vazio/IPs null.
- Canal: `currentFacts()` propaga getSnapshot; startWatching/stopWatching invocam os métodos. Fakes via `TestDefaultBinaryMessengerBinding`, sem mockito.

## Verification
- `flutter test --no-pub test/diagnostic/android_network_snapshot_source_test.dart` → **5/5 passed**.
- `flutter analyze --no-pub` (projeto inteiro) → **No issues found**.
- Manifest main: exatamente INTERNET + ACCESS_NETWORK_STATE; grep de tokens de localização/LAN/SSID/BSSID só aparece em comentários negativos.
- Sem `NetworkInterface.list`, sem `192.168.1.1`, sem connectivity_plus/network_info_plus.
- `pubspec.lock-old` intocado (D-14).

## Deviations
- Nenhuma além do design travado (adapter Dart puro, wrap em 03-06).

## Self-Check: PASSED
