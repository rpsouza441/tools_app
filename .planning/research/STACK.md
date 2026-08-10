# Stack Research

**Domain:** Flutter/Android-first connectivity diagnostics with a separately gated speed test
**Researched:** 2026-08-10
**Confidence:** HIGH for the diagnostic MVP; MEDIUM for gateway latency; LOW for speed-test infrastructure until an endpoint/legal decision is made

## Recommendation in One Sentence

Keep the existing Flutter 3.44/Material 3 application, add `dio` 5.11.0 for cancellable HTTPS work, and expose Android's own `ConnectivityManager`, `NetworkCapabilities`, and `LinkProperties` through one narrow platform adapter for the active network snapshot; do not make a generic connectivity plugin, an ICMP subprocess package, or a public speed-test endpoint the source of truth.

## Recommended Stack

### Core Technologies

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| Flutter + Material 3 | Existing Flutter 3.44.0 | App shell, responsive UI, accessibility, lifecycle | Already established and current. This milestone needs incremental components and controllers, not a framework rewrite. |
| Dart | Existing SDK 3.12.0; keep `sdk: ^3.8.1` unless the project intentionally raises its floor | Domain models, orchestration, statistics, async I/O | The installed SDK provides cancelable `Socket.startConnect`, `NetworkInterface`, records/sealed types, and mature test support. Keep measurement logic in Dart and outside widgets. |
| Android `ConnectivityManager` + `NetworkCapabilities` + `LinkProperties`/`RouteInfo` | API 23+ primary path; API 21-22 fallback only if the resolved `minSdk` still includes them; Kotlin 2.2.21 already configured | Active transport, validated/captive status, metered state, active local addresses, and default-route gateway | These are the authoritative Android APIs. `LinkProperties` exposes link addresses and routes; `RouteInfo` identifies a default route and its gateway. This is more accurate for a diagnostic app than a Wi-Fi-only convenience API and handles mobile/VPN/null results honestly. |
| Flutter `MethodChannel` + optional `EventChannel` | Flutter SDK | Narrow Android network snapshot/changes adapter | Keep one typed Dart interface such as `PlatformNetworkSnapshotSource`; Kotlin returns serializable facts only. A method call is sufficient for start/resume snapshots; an event channel is useful only if live foreground updates are a product requirement. |
| `dio` | `5.11.0` | Public-IP HTTPS call, application-level reachability/latency, cancellation, strict timeouts, and later bounded streaming | Current primary package documentation verifies `CancelToken`, connect/send/receive timeouts, `ResponseType.stream`, and send/receive progress. One injected `Dio` instance plus a per-run `CancelToken` gives real HTTP cancellation and testable adapters. |
| `dart:io` `Socket.startConnect` / `ConnectionTask` | Dart 3.12 SDK | Cancellable TCP-connect probes | `Socket.startConnect` returns a `ConnectionTask` whose `cancel()` aborts an in-flight connection attempt. Time it with `Stopwatch`, enforce a separate `Timer`, and always `destroy()` a connected socket. Label the result **TCP connect**, never ICMP ping. |

### Supporting Libraries and Built-ins

| Library/API | Version | Purpose | When to Use |
|-------------|---------|---------|-------------|
| `AppLifecycleListener` | Flutter SDK | Pause/resume/dispose cleanup | Own it at the screen/controller boundary. On pause or disposal, cancel the run; on resume, request a fresh platform snapshot because Android does not guarantee background connectivity broadcasts. |
| `flutter_test` | Flutter SDK | Unit and widget tests | Use handwritten fakes for `NetworkSnapshotSource`, `PublicIpSource`, `LatencyProbe`, and `SpeedTestEngine`. No mocking framework is required for the MVP. |
| `integration_test` | Flutter SDK, dev dependency only when Android device tests are added | Wi-Fi/mobile/offline, lifecycle, and permission tests | Add in the diagnostic phase, not merely for pure-Dart unit tests. Run against physical Android devices because emulator network behavior does not cover route/gateway realities. |
| `connectivity_plus` | `7.3.1`, optional alternative | Cross-platform transport stream | Use only if the roadmap prioritizes a common non-Android transport API over Android diagnostic fidelity. Its docs explicitly say transport availability does not prove Internet access and Android background updates must be rechecked on resume. It requires AGP 8.12.1+, while this repo currently uses 8.11.1. |
| `network_info_plus` | `8.2.1`, optional Wi-Fi-only alternative | Wi-Fi IPv4 and Wi-Fi gateway | Use only if avoiding the small Kotlin snapshot adapter is more important than active-network accuracy. `getWifiGatewayIP()` is explicitly Wi-Fi-scoped and can return `null`; it is not a mobile/VPN gateway solution. Do not call SSID/BSSID methods, which trigger location-related requirements. |

### Development Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| `flutter analyze` | Static quality gate | Must remain clean after adding platform channels and adapters. |
| `flutter test` | Pure Dart/controller/widget regression suite | Cover success, invalid IP JSON, partial results, timeout, cancellation-before-start, cancellation-in-flight, late completion, pause/resume, and aggregation. |
| Android instrumented/device checks | Verify real route, captive portal, Wi-Fi/mobile transitions, and future LAN permission behavior | Test API 26+, current target SDK, Android 16 local-network restriction opt-in, and eventually Android 17 target SDK 37 behavior. |

## Dependency Installation

Preferred Android-first stack:

```bash
flutter pub add dio:^5.11.0
```

When device-level integration tests are introduced, add `integration_test` under `dev_dependencies` with `sdk: flutter`; it is an SDK package rather than a hosted package.

No dependency is required for the Android network snapshot: implement it with the Flutter SDK channel API and Android framework APIs.

If the team explicitly chooses the convenience-plugin variant instead, first raise `com.android.application` from 8.11.1 to at least 8.12.1 (the repo's Gradle 8.14.2 and Java 17 already satisfy AGP 8.12 requirements), then add:

```bash
flutter pub add connectivity_plus:^7.3.1 network_info_plus:^8.2.1
```

Do not install both the native snapshot adapter and both convenience plugins without a documented ownership rule; competing network “truths” create contradictory UI states.

## Prescribed Adapter Boundaries

| Interface | Backing implementation | Cancellation/timeout contract |
|-----------|------------------------|-------------------------------|
| `NetworkSnapshotSource` | Android platform adapter over active `Network`, `NetworkCapabilities`, and `LinkProperties` | Snapshot calls are short platform reads. Ignore late results with a run generation ID; unregister callbacks/listeners on dispose. |
| `PublicIpSource` | `Dio` GET to an injected provider URL | Per-run `CancelToken`; short connect and receive timeouts; validate status, content type/body size, JSON shape, and `InternetAddress.tryParse`. |
| `TcpLatencyProbe` | `Socket.startConnect(host, port)` | Register `ConnectionTask.cancel()` with the run cancellation scope; a timer cancels on timeout; destroy successful sockets. |
| `HttpsLatencyProbe` | `Dio` with an injected, approved target | Per-sample or per-run `CancelToken`; document whether the metric is headers/TTFB or full small-response time and whether connections are warm/reused. |
| `IcmpLatencyProbe` | No production implementation in MVP | Capability reports unavailable until a native-engine spike proves Android behavior, immediate cancellation, maintenance, and testability. |
| `SpeedTestEngine` | No production implementation until infrastructure gate passes | Interface exists only to isolate the later phase. Any implementation must cancel all streams/requests, bound bytes/time/concurrency, and expose progress without allocating the full payload. |

The orchestration layer should own a single per-run cancellation scope. Cancellation must invoke every registered abort action (`CancelToken.cancel`, `ConnectionTask.cancel`, timers and subscriptions), then move to a terminal `cancelled` state. A generation/run ID must prevent a late platform or network result from mutating a newer run.

`package:async`'s `CancelableOperation` may be useful for suppressing completion, but it does **not** automatically abort arbitrary underlying I/O. Do not treat it as the cancellation mechanism for sockets or HTTP.

## Public IP Provider

Use a provider adapter, not a package wrapper. The initial provider should be:

```text
https://api64.ipify.org?format=json
```

Why:

- ipify's primary documentation defines the HTTPS JSON response and a universal IPv4/IPv6 endpoint, states unlimited use, publishes its source, and states that visitor information is not logged.
- Direct `Dio` use preserves cancellation, timeout, response-size limits, and dependency injection; a one-purpose IP wrapper adds no useful abstraction.
- `api64` returns the address family used for that request, not both addresses. If the product specifically promises public IPv4, use `https://api.ipify.org?format=json` and name the field “IPv4 público”.

Limits:

- The marketing availability statements are not a contractual SLA. Treat outage as a partial diagnostic result, not “no Internet”.
- Disclose the hostname in the privacy policy because the service necessarily observes the requesting public IP even if it states it does not log visitors.
- Do not silently cascade through several public-IP vendors. If a fallback is ever added, make the provider list configurable/testable and disclose every recipient.
- A valid ipify response is evidence that this HTTPS request succeeded. It is not proof that every Internet destination is reachable.

## Reachability and Latency Semantics

Use three separate facts rather than one `isOnline` boolean:

1. **Transport available:** platform transport(s), with VPN and multiple-transport nuance.
2. **Android system validation:** `NET_CAPABILITY_INTERNET` plus `NET_CAPABILITY_VALIDATED`; separately surface `NET_CAPABILITY_CAPTIVE_PORTAL` when present.
3. **Application probe:** the actual outcome and method of the configured TCP or HTTPS operation.

For numeric latency, prefer a configured TCP 443 target or an approved small HTTPS endpoint. The UI must say `TCP 443` or `HTTPS`, because DNS, TCP, TLS, server processing, connection reuse, and captive portals affect these numbers differently from ICMP round-trip time.

Gateway discovery and gateway latency must also be separated. The Android adapter can reliably return a default-route gateway when the active link exposes one. A gateway frequently has no TCP service open, so a failed TCP connect does not prove the gateway is unreachable. Until an ICMP implementation passes the spike below, show the gateway address and “latência indisponível para este método” rather than manufacturing packet loss.

### ICMP Gate (Phase-Specific Research Required)

No currently surveyed Flutter ICMP package is strong enough to be a default dependency under this project's constraints:

- `dart_ping` 10.0.1 is current and supports cancellation by stopping its stream/process, but on Android it explicitly runs the OS `ping` subprocess and parses command output. That conflicts with the desired shell-independent, portable diagnostic core and adds an unverified publisher to a sensitive path.
- `flutter_icmp_ping` 3.1.3 uses a native plugin, but its latest release is two years old and its cancellation/toolchain behavior has not been verified against Flutter 3.44 and current Android lifecycle requirements.
- Android `InetAddress.isReachable(timeout)` attempts ICMP and falls back to TCP echo, but it returns only best-effort reachability; timing the blocking call does not create a clean, immediately cancellable ICMP metric.

If gateway ICMP is mandatory, schedule a device spike before committing to a package. Required proof: five+ Android vendors/API levels, no UI-thread blocking, multiple samples, accurate timeout/loss, cancellation under 250 ms, pause/dispose cleanup, no leaked process/socket, and explicit fallback labeling. Confidence: MEDIUM that a native adapter is feasible; LOW that an off-the-shelf package currently satisfies all requirements unchanged.

## Speed Test: Deliberately Deferred Stack

Do not add a Flutter speed-test package in the diagnostic MVP. The transport client (`dio`) can later support a controlled protocol, but the endpoint and measurement contract are the real product dependency.

Adopt a speed-test implementation only when all of these are decided:

- licensed/authorized download and upload endpoints, geographic selection, capacity and operational owner;
- maximum bytes, maximum duration, concurrency, warm-up, outlier policy and mobile-data consent;
- server timing behavior and whether results are estimates or benchmarks;
- privacy disclosure and whether any provider collects completed measurements;
- a controlled integration-test endpoint or fully simulatable protocol adapter.

If that gate passes, implement bounded download with `ResponseType.stream` and count bytes as they arrive; implement upload with a generated byte stream and explicit `Content-Length`, never one giant in-memory buffer. Use `CancelToken` for every request, cap parallelism explicitly, and stop all workers on cancellation/network change. Keep aggregation in Dart; ordinary async socket I/O does not require an isolate.

Cloudflare's official `@cloudflare/speedtest` is a JavaScript/browser engine that depends on browser resource-timing APIs and states that completed measurements are collected. Its public repository is useful methodological reference, not a drop-in Flutter SDK or proof that third-party native use of its public endpoints is authorized. If no controlled/licensed endpoint is available, the roadmap should defer speed test.

## Android Permissions and Platform Compatibility

### Current target (SDK 36 or lower)

Declare only:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

Both are normal install-time permissions; Android does not show a runtime prompt. `ACCESS_NETWORK_STATE` covers the `ConnectivityManager` snapshot. Do not request location, `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`, SSID/BSSID, phone state, or background network permissions for the specified feature set.

### Android 17 / target SDK 37 forward-compatibility flag

Android's current documentation says direct outgoing LAN TCP/UDP is blocked by default for apps targeting Android 17 (SDK 37)+ unless the new `ACCESS_LOCAL_NETWORK` runtime permission is declared and granted. Public Internet access is unaffected. Therefore:

- reading the default gateway can remain a snapshot operation;
- actively probing a private gateway becomes a permission-gated feature at target SDK 37;
- model `permissionDenied` now, but do not add/request `ACCESS_LOCAL_NETWORK` while targeting SDK 36 or lower;
- run Android 16's opt-in local-network restriction test before the target-SDK migration.

This is a roadmap-level compatibility item, not a reason to request location.

## Lifecycle Rules

- On `pause`, `hide`, screen disposal, explicit cancel, or start of a replacement run: cancel HTTP tokens, socket connection tasks, timers, stream subscriptions, and any platform callback owned by that run.
- On `resume`: request a fresh Android snapshot before enabling probes. Do not assume the last stream event still describes the active network.
- Do not automatically restart a cancelled diagnostic or speed test after resume. Preserve partial completed samples and require an explicit user action.
- Network change during a run terminates remaining samples with a distinct reason; do not aggregate measurements across Wi-Fi and mobile into one result.
- Never call `setState` from adapters. The controller publishes immutable run state; widgets render it and check mounted/disposal only at the UI boundary.

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|-------------------------|
| Android framework snapshot adapter | `connectivity_plus` 7.3.1 | When cross-platform transport parity matters more than active-route addresses, validation/captive signals, and Android-specific diagnostics. Still perform real requests and resume checks. |
| Android `LinkProperties` default route | `network_info_plus` 8.2.1 | When only Wi-Fi IPv4/gateway is in scope and `null` on mobile/VPN is acceptable. Avoid SSID/BSSID calls to avoid location requirements. |
| Direct `Dio` call to ipify | `dart_ipify` or another wrapper | Only if the wrapper demonstrably exposes the same cancellation, timeout, body validation, and injection controls; otherwise it adds dependency risk without capability. |
| TCP/HTTPS probes with explicit labels | ICMP plugin | Only after the ICMP device spike passes and ICMP adds enough user value to justify native/subprocess risk. |
| Controlled speed-test protocol | Public/default endpoints embedded by a Flutter package | Only with written provider authorization, verified endpoint behavior, privacy review, controlled data budget, and an integration-test strategy. |

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| `connectivity_plus` as `isOnline` | Its own docs state that a transport does not guarantee Internet access or exclude a captive portal. | Android validation facts plus an actual cancellable application probe. |
| `NetworkInterface.list()` as the authoritative active Android interface | It can return multiple Wi-Fi, mobile, VPN and virtual interfaces with no authoritative default-network selection. | `ConnectivityManager.activeNetwork` + `LinkProperties`; retain `NetworkInterface.list` only as a non-Android/fallback inventory. |
| `dart_ping` as the default Android probe | It spawns/parses the OS `ping` process; behavior depends on platform binary/output and conflicts with the shell-independent core. | Cancellable `Socket.startConnect`/Dio probes, with an ICMP spike if required. |
| `internet_speed_test` 1.5.0 | Published five years ago and its documented defaults use third-party plain-HTTP test URLs. | No speed-test dependency until controlled/licensed HTTPS endpoints exist. |
| `flutter_internet_speed_test` 1.5.0 | Unverified publisher, last release two years ago, endpoint/methodology remain the critical risk. | A project-owned `SpeedTestEngine` adapter over an approved protocol. |
| `flutter_network_speed_test` 0.2.0 | Very new/unverified with minimal adoption and dependencies on ping/server-selection machinery that has not passed this project's legal and lifecycle gate. | Phase-specific endpoint/protocol research, then a bounded Dio implementation or vetted SDK. |
| `Future.timeout` or `CancelableOperation` alone | They can stop waiting while the underlying request/socket continues consuming resources. | Abort the underlying `CancelToken`/`ConnectionTask`, then guard late results with a run ID. |
| Automatic speed test | Surprise data usage, especially on metered/mobile networks. | Explicit consent, estimated maximum data/time, one run at a time, immediate cancel. |

## Version Compatibility

| Component | Compatible With | Notes |
|-----------|-----------------|-------|
| Project baseline | Flutter 3.44.0, Dart 3.12.0, Java 17, Kotlin 2.2.21, AGP 8.11.1, Gradle 8.14.2 | Verified from the workspace and local Flutter checkout on 2026-08-10. Preserve this base unless selecting Plus plugins. |
| `dio` 5.11.0 | Dart >=2.18; current Flutter/Dart | No Android Gradle plugin constraint; fits the current project. |
| `connectivity_plus` 7.3.1 | Flutter >=3.19, Dart >=3.3 <4, Java 17, AGP >=8.12.1, Gradle >=8.13 | Requires the repo's AGP 8.11.1 to move to 8.12.1+. |
| `network_info_plus` 8.2.1 | Flutter >=3.38.1, Dart >=3.10 <4, Java 17, Kotlin 2.2.0, AGP >=8.12.1, Gradle >=8.13 | Current Flutter/Dart/Kotlin/Gradle fit; AGP needs the same small upgrade. Version 7.0.0 is compatible with older Dart but pinning an older plugin merely to avoid a small AGP update is not the preferred long-term choice. |
| AGP 8.12.1 | Gradle >=8.13, JDK 17, API <=36 | The repo's Gradle 8.14.2 and Java 17 fit. Make this upgrade only if a selected plugin requires it; the preferred native adapter works on the current AGP. |

## Confidence Assessment

| Area | Confidence | Basis |
|------|------------|-------|
| Existing Flutter/Dart/Android toolchain | HIGH | Verified directly in the workspace/local SDK. |
| Dio cancellation/streaming/timeouts | HIGH | Context7 plus current pub.dev primary documentation. |
| Android active network/local IPv4/default route/validation | HIGH | Current official Android API and connectivity documentation. |
| Public IP through ipify | MEDIUM | Primary provider documentation is clear, but it is still an external service without a contractual project SLA. |
| TCP/HTTPS latency | HIGH for implementation; MEDIUM for interpretation | Dart cancellation is documented; target ownership and metric wording still require product decisions. |
| Gateway ICMP latency | MEDIUM feasibility / LOW package choice | Android best-effort and packages exist, but no surveyed option yet meets every cancellation, lifecycle, maintenance and portability constraint. |
| Speed test | LOW until gated | Client primitives are available; infrastructure rights, geography, privacy, capacity and methodology are unresolved. |

## Sources

- [Dio 5.11.0 on pub.dev](https://pub.dev/packages/dio) — current version, cancellation, timeout and streaming APIs. **HIGH confidence.**
- [Connectivity Plus 7.3.1](https://pub.dev/packages/connectivity_plus) — current requirements, transport-only caveat, platform matrix and Android resume behavior. **HIGH confidence.**
- [Network Info Plus 8.2.1](https://pub.dev/packages/network_info_plus) — current requirements, Wi-Fi gateway scope and SSID/BSSID permission notes. **HIGH confidence.**
- [Dart `Socket.startConnect`](https://api.dart.dev/dart-io/Socket/startConnect.html) and [`ConnectionTask`](https://api.dart.dev/dart-io/ConnectionTask-class.html) — cancelable TCP connection attempts. **HIGH confidence.**
- [Dart `NetworkInterface.list`](https://api.dart.dev/dart-io/NetworkInterface/list.html) — interface inventory behavior and filtering. **HIGH confidence.**
- [Android: read network state](https://developer.android.com/develop/connectivity/network-ops/reading-network-state) — `NetworkCapabilities`, `LinkProperties`, validated/captive distinctions and callback behavior. **HIGH confidence.**
- [Android `ConnectivityManager`](https://developer.android.com/reference/android/net/ConnectivityManager), [`LinkProperties`](https://developer.android.com/reference/android/net/LinkProperties), and [`RouteInfo`](https://developer.android.com/reference/android/net/RouteInfo) — active network, link addresses, routes, default route and gateway APIs. **HIGH confidence.**
- [Android network permissions](https://developer.android.com/develop/connectivity/network-ops/connecting) — `INTERNET` and `ACCESS_NETWORK_STATE` are normal install-time permissions. **HIGH confidence.**
- [Android local network permission](https://developer.android.com/privacy-and-security/local-network-permission) — SDK 36 behavior and Android 17/target 37 `ACCESS_LOCAL_NETWORK` enforcement. **HIGH confidence.**
- [Android `InetAddress.isReachable`](https://developer.android.com/reference/java/net/InetAddress#isReachable(int)) — best-effort ICMP then TCP echo behavior and limitations. **HIGH confidence.**
- [Flutter `AppLifecycleListener`](https://api.flutter.dev/flutter/widgets/AppLifecycleListener-class.html) — pause/resume/dispose hooks. **HIGH confidence.**
- [ipify API](https://www.ipify.org/) — IPv4/universal JSON endpoints, stated unlimited usage/open source/no visitor logging. **MEDIUM confidence** because availability/privacy statements are provider claims, not a project SLA.
- [`dart_ping` 10.0.1](https://pub.dev/packages/dart_ping) — current package and Android subprocess implementation. **HIGH confidence about implementation; LOW recommendation confidence.**
- [`internet_speed_test` versions](https://pub.dev/packages/internet_speed_test/versions), [`flutter_internet_speed_test` versions](https://pub.dev/packages/flutter_internet_speed_test/versions), and [`flutter_network_speed_test`](https://pub.dev/packages/flutter_network_speed_test) — package recency, publisher and dependency/default-endpoint review. **MEDIUM confidence.**
- [Cloudflare Speedtest repository](https://github.com/cloudflare/speedtest) — browser engine, methodology, public endpoints and measurement collection disclosure. **HIGH confidence for the JS engine; no conclusion that native third-party endpoint use is authorized.**
- [Android Gradle Plugin 8.12 compatibility](https://developer.android.com/build/releases/agp-8-12-0-release-notes) — Gradle 8.13 and JDK 17 minimums. **HIGH confidence.**

---
*Stack research for: Tools App — Internet diagnostics and UI evolution*
*Researched: 2026-08-10*
