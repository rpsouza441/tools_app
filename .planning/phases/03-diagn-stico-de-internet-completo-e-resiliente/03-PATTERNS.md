# Phase 3: Diagnóstico de Internet completo e resiliente - Pattern Map

**Mapped:** 2026-08-31
**Files analyzed:** 38
**Analogs found:** 26 / 38

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `lib/diagnostic/models/diagnostic_fact.dart` | model | transform | `lib/service/hash_calculator.dart` (`HashResult`) | role-match |
| `lib/diagnostic/models/diagnostic_run_state.dart` | model | event-driven | `lib/service/hash_calculator.dart` (`HashResult`) | role-match |
| `lib/diagnostic/models/latency_aggregate.dart` | model | transform | `lib/service/hash_calculator.dart` (`HashResult`) | role-match |
| `lib/diagnostic/models/probe_provenance.dart` | model | transform | `lib/service/hash_calculator.dart` (`HashResult`) | role-match |
| `lib/diagnostic/contracts/network_snapshot_source.dart` | service | request-response | `lib/design_system/copy_value_action.dart` (`CopyValueWriter`) | role-match |
| `lib/diagnostic/contracts/public_ip_source.dart` | service | request-response | `lib/design_system/copy_value_action.dart` (`CopyValueWriter`) | role-match |
| `lib/diagnostic/contracts/gateway_probe.dart` | service | request-response | `lib/design_system/copy_value_action.dart` (`CopyValueWriter`) | role-match |
| `lib/diagnostic/contracts/internet_probe.dart` | service | request-response | `lib/design_system/copy_value_action.dart` (`CopyValueWriter`) | role-match |
| `lib/diagnostic/contracts/diagnostic_session.dart` | controller | event-driven | `lib/design_system/copy_value_action.dart` (`CopyValueWriter`) | partial |
| `lib/diagnostic/contracts/share_text_port.dart` | service | request-response | `lib/design_system/copy_value_action.dart` (`CopyValueWriter`) | exact |
| `lib/diagnostic/aggregation/latency_aggregator.dart` | utility | transform | `lib/service/network_calculator.dart` | exact |
| `lib/diagnostic/session/diagnostic_session_impl.dart` | controller | event-driven | — | none |
| `lib/diagnostic/session/cancellation_scope.dart` | utility | event-driven | — | none |
| `lib/diagnostic/public_ip/public_ip_config.dart` | config | request-response | — | none |
| `lib/diagnostic/public_ip/dio_public_ip_source.dart` | service | request-response | — | none |
| `lib/diagnostic/probes/probe_config.dart` | config | request-response | — | none |
| `lib/diagnostic/probes/tcp_connect_probe.dart` | service | request-response | — | none |
| `lib/diagnostic/probes/dio_https_probe.dart` | service | request-response | — | none |
| `lib/diagnostic/platform/android_network_snapshot_source.dart` | service | request-response | `lib/design_system/copy_value_action.dart` (`ClipboardCopyWriter`) | partial |
| `lib/diagnostic/platform/unsupported_network_snapshot_source.dart` | service | request-response | `lib/design_system/copy_value_action.dart` (`ClipboardCopyWriter`) | role-match |
| `lib/diagnostic/platform/android_share_text_port.dart` | service | request-response | `lib/design_system/copy_value_action.dart` (`ClipboardCopyWriter`) | exact |
| `lib/screen/internet_diagnostic_screen.dart` | component | event-driven | `lib/screen/network_calculator_screen.dart` + `hash_generator_screen.dart` | role-match |
| `lib/app/app_destinations.dart` | config | request-response | `lib/app/app_destinations.dart` (extend) | exact |
| `lib/app/app_shell.dart` | component | event-driven | `lib/app/app_shell.dart` (extend) | exact |
| `lib/main.dart` | config | request-response | `lib/main.dart` (likely unchanged) | exact |
| `pubspec.yaml` | config | — | `pubspec.yaml` (`crypto: ^3.0.7`) | exact |
| `android/app/src/main/kotlin/com/example/tools_app/MainActivity.kt` | config | request-response | itself (empty `FlutterActivity`) | exact |
| `android/app/src/main/kotlin/.../NetworkSnapshotPlugin.kt` | service | request-response | — | none |
| `android/app/src/main/kotlin/.../ShareTextPlugin.kt` | service | request-response | — | none |
| `android/app/src/main/AndroidManifest.xml` | config | — | `android/app/src/debug/AndroidManifest.xml` | partial |
| `test/diagnostic/fakes.dart` | test | request-response | `test/screen/screen_test_harness.dart` (`FakeCopyWriter`) | exact |
| `test/diagnostic/latency_aggregator_test.dart` | test | transform | `test/network_calculator_test.dart` | exact |
| `test/diagnostic/diagnostic_session_test.dart` | test | event-driven | `test/design_system/copy_lifecycle_test.dart` (`CompleterCopyWriter`) | role-match |
| `test/diagnostic/public_ip_source_test.dart` | test | request-response | `test/hash_calculator_test.dart` | role-match |
| `test/screen/internet_diagnostic_screen_test.dart` | test | event-driven | `test/screen/network_calculator_screen_test.dart` | exact |
| `test/app/destination_catalog_test.dart` | test | request-response | itself (update 3→4) | exact |
| `test/app/app_shell_test.dart` | test | event-driven | itself (production bar labels) | exact |
| `test/screen/tools_preservation_test.dart` | test | event-driven | itself (PRES-04 + 4º destino) | exact |

Local IPv4 and gateway remain **separate Dart contracts** (D-05) even if both are filled from one Android snapshot. Do not invent `NetworkService`. Do not add `lib/service/network_*.dart` next to the existing calculators — new diagnostic code lives under `lib/diagnostic/`.

---

## Pattern Assignments

### `lib/diagnostic/contracts/*.dart` + `ShareTextPort` (service, request-response)

**Analog:** `lib/design_system/copy_value_action.dart` — the **only** injectable port in production today.

**Imports pattern** (lines 1-2):
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
```
New contracts under `lib/diagnostic/` should stay Flutter-free when possible (`dart:async` only). `ShareTextPort` may stay Dart-only; the Android adapter imports `flutter/services.dart` for `MethodChannel`. Package imports always use `package:tools_app/...`, never relative `../`.

**Port pattern** (lines 4-21) — copy this shape for all seven contracts:
```dart
/// Abstract clipboard interface for testing.
///
/// Inject a fake implementation in tests to verify copy behavior
/// without relying on the system clipboard.
abstract class CopyValueWriter {
  Future<void> write(String value);
}

/// Default implementation using [Clipboard.setData].
class ClipboardCopyWriter implements CopyValueWriter {
  const ClipboardCopyWriter();

  @override
  Future<void> write(String value) {
    return Clipboard.setData(ClipboardData(text: value));
  }
}
```

Planner actions:
- One abstract class per contract (`NetworkSnapshotSource`, `PublicIpSource`, `GatewayProbe`, `InternetProbe`, `DiagnosticSession`, `ShareTextPort`).
- Default production impl in a sibling file (`ClipboardCopyWriter` style: `const` constructor, no Flutter in domain adapters).
- Constructor injection on the screen, optional with production default — see `NetworkCalculatorScreen.copyWriter` below.
- **Do not** add mockito. Tests implement the abstract class by hand.

**Apply to:** every new contract + `android_share_text_port.dart` + `unsupported_network_snapshot_source.dart`.

---

### `lib/diagnostic/models/*.dart` (model, transform)

**Analog:** `lib/service/hash_calculator.dart` lines 5-16 (`HashResult`) and `lib/model/analysis_result.dart` lines 3-32.

**Immutable result record** (hash_calculator.dart 5-16):
```dart
class HashResult {
  final String algorithm;
  final String value;
  final int bits;
  final String strength;

  const HashResult({
    required this.algorithm,
    required this.value,
    required this.bits,
    required this.strength,
  });
}
```

**Multi-field result bag** (analysis_result.dart 10-32):
```dart
class AnalysisResult {
  final List<ConversionData> manufacturerConversions;
  final List<ConversionData> systemConversions;
  final double advertisedValue;
  final String advertisedUnit;
  final double realValue;
  final String realUnit;
  final double differenceValue;
  final String differenceUnit;

  AnalysisResult({
    required this.manufacturerConversions,
    required this.systemConversions,
    required this.advertisedValue,
    required this.advertisedUnit,
    required this.realValue,
    required this.realUnit,
    required this.differenceValue,
    required this.differenceUnit,
  });
}
```

Planner actions:
- Keep diagnostic models `const` + `final` like `HashResult`.
- There is **no `copyWith` in the repo**. Add `copyWith` on `DiagnosticRunState` (new pattern; RESEARCH Pattern 2). Do not mutate fields in place like `NetworkCalculator` (`String ipAddress;` is mutable — **do not copy that** for run state).
- `DiagnosticFact.status` is a new enum (`success` / `unavailable` / `failure` / `cancelled` / `timeout` / `networkChanged` / `permissionDenied`). Closest UI enum is `ToolStatusVariant` in `tool_status_panel.dart` lines 8-16 — **do not reuse that enum** for facts; map run phase → `ToolStatusVariant` at the widget boundary.
- `ProbeProvenance` fields (`method`, `target`, `portOrUrl`, `timeout`, `limitations`, `thirdParty`) have no analog; follow RESEARCH DIAG-08.
- Never invent `0` for missing metrics — `ToolMetric` already renders `null` as `'Indisponível'` (tool_sections.dart 84-92). Fact `unavailable` must pass `value: null` into `ToolMetric`.

---

### `lib/diagnostic/aggregation/latency_aggregator.dart` (utility, transform)

**Analog:** `lib/service/network_calculator.dart` — pure Dart, no Flutter, no I/O.

**Imports:** none (file starts at class). Hash calculator imports only `dart:convert` + `package:crypto`.

**Core pattern** — pure functions / class methods, deterministic, unit-tested without widgets:
```dart
class NetworkCalculator {
  String ipAddress;
  int? cidr;
  String? subnetMask;

  NetworkCalculator({required this.ipAddress, this.cidr, this.subnetMask}) {
    if (cidr == null && subnetMask == null) {
      throw ArgumentError('É necessário fornecer CIDR ou Máscara de Sub-rede.');
    }
    cidr ??= _maskToCidr(subnetMask!);
    subnetMask ??= _cidrToMask(cidr!);
  }
  // ... calculateNetworkAddress / calculateBroadcastAddress / calculateUsableHostCount
}
```

**Prefer HashCalculator style** (static, immutable in/out) over NetworkCalculator mutability:
```dart
class HashCalculator {
  static List<HashResult> calculate(String input) {
    final bytes = utf8.encode(input);
    return [ /* HashResult(...) */ ];
  }
}
```

**Validation analog** for IP strings: `lib/utils/network_utils.dart` `isValidIp` (regex + octet range). Public IP validation in production **must** use `InternetAddress.tryParse` (RESEARCH), not this regex — keep `network_utils.dart` for the Rede tool only.

**Error handling:** throw `ArgumentError` on programmer misuse; aggregator should not throw on empty success lists — return `unavailable` / null min-avg-max (QUAL-05).

**Test analog:** `test/network_calculator_test.dart` lines 4-36 — `group` + `test` + `expect` on known inputs. `test/hash_calculator_test.dart` lines 4-25 for known digest fixtures.

---

### `lib/diagnostic/session/diagnostic_session_impl.dart` + `cancellation_scope.dart` (controller, event-driven)

**Analog:** none in `lib/`. Closest *injection* habit is `CopyValueWriter`; closest *late-result* test is `CompleterCopyWriter`.

**Do not copy** screen-local `setState` orchestration from `NetworkCalculatorScreen._calculate` (lines 45-108). That tool is synchronous. Diagnostic I/O must live outside widgets (D-06). RESEARCH Pattern 2 is the source of truth:

- `start()` increments `runId`, publishes immutable `DiagnosticRunState`.
- Register abort closures (`CancelToken.cancel`, `ConnectionTask.cancel`, `Timer.cancel`, unregister callback) in `CancellationScope`.
- Ignore completions whose `runId` ≠ current.
- `start()` is no-op while `running`.
- Fan-out after snapshot with errors captured per fact (DIAG-10).
- Publish via `ValueListenable` / `ChangeNotifier` that **does not** call `setState`. No analog for this in the repo — introduce it here.

**Late-completion analog to copy into session tests** (`test/design_system/copy_lifecycle_test.dart` lines 9-16, 46-80):
```dart
class CompleterCopyWriter implements CopyValueWriter {
  CompleterCopyWriter(this.completer);
  final Completer<void> completer;
  @override
  Future<void> write(String value) => completer.future;
}

// dispose before writer completes does not throw
await tester.pumpWidget(/* widget using writer */);
await tester.tap(find.byIcon(Icons.copy));
await tester.pump();
await tester.pumpWidget(const SizedBox.shrink());
completer.complete();
await tester.pump();
expect(tester.takeException(), isNull);
```

Session tests must do the same: complete a fake probe **after** `cancel()` / `dispose()` and assert state stays `cancelled` (QUAL-08 / Pitfall 1).

**Lifecycle analog:** **none**. Repo has zero `AppLifecycleListener` / `WidgetsBindingObserver`. Copy RESEARCH snippet onto the **screen** (or a thin host), not into adapters.

---

### `lib/diagnostic/public_ip/dio_public_ip_source.dart` + `lib/diagnostic/probes/dio_https_probe.dart` (service, request-response)

**Analog:** none. No `dio`, no HTTP client, no `CancelToken` in the repo.

**Port shape:** copy `CopyValueWriter` (abstract + injectable config).

**I/O + validation:** copy RESEARCH.md “Dio CancelToken + timeouts Duration” and ipify rules (status 200, body ≤ 2048, `InternetAddress.tryParse`, IPv4 only). HTTPS probe: `followRedirects: false`, `persistentConnection: false`, success = expected status (204).

**Error handling analog** at UI boundary only (`copy_value_action.dart` 74-95) — catch, then touch the tree only if still valid:
```dart
try {
  await effectiveWriter.write(widget.value);
  if (!context.mounted) return;
  _showOwnedSnackBar(/* success */);
} on Exception {
  if (!context.mounted) return;
  _showOwnedSnackBar(/* fallback */);
}
```
Adapters **must not** call `setState` or `SnackBar`. They return fact statuses. Session ignores stale `runId`. Dio cancel → fact `cancelled`, not `failure`.

**Config files** (`public_ip_config.dart`, `probe_config.dart`): no analog. Keep URL/timeout/expectedStatus as injected value objects (D-12, no silent vendor cascade).

---

### `lib/diagnostic/probes/tcp_connect_probe.dart` (service, request-response)

**Analog:** none. No `dart:io` `Socket` in `lib/`.

Copy RESEARCH “TCP connect cancelável”: `Socket.startConnect` + `Timer` that calls `task.cancel()` + `socket.destroy()`. Label **TCP connect**, never ping. If gateway IPv4 is null → fact `unavailable`, do not connect.

Gateway address fact and gateway probe fact are independent (DIAG-10 / Pitfall 6) — same independence as Hash rows: one algorithm failing would not apply here because Hash is sync; model it as separate `DiagnosticFact`s in run state.

---

### `lib/diagnostic/platform/android_network_snapshot_source.dart` + `unsupported_network_snapshot_source.dart`

**Analog for interface + default impl:** `ClipboardCopyWriter`.

**Analog for MethodChannel:** **none**.

**Unsupported path (QUAL-05):** return every field `unavailable`. Closest UI copy: `ToolMetric` `'Indisponível'` (tool_sections.dart 84-111). Do not invent `0 ms` or fake IPs.

**Android snapshot facts:** RESEARCH Pattern 1 (Kotlin map). Dart adapter deserializes the map; it does not call `NetworkInterface.list()`.

---

### `lib/screen/internet_diagnostic_screen.dart` (component, event-driven)

**Analog A (chrome):** `lib/screen/network_calculator_screen.dart` + `lib/screen/hash_generator_screen.dart`

**Imports pattern** (network_calculator_screen.dart 1-6):
```dart
import 'package:flutter/material.dart';
import 'package:tools_app/design_system/copy_value_action.dart';
import 'package:tools_app/design_system/tool_scaffold.dart';
import 'package:tools_app/design_system/tool_sections.dart';
import 'package:tools_app/service/network_calculator.dart';
import 'package:tools_app/utils/network_utils.dart';
```
Diagnostic screen imports `tool_status_panel.dart` as well (the three tools never use it in production — only gallery/tests). Domain import becomes `package:tools_app/diagnostic/...`, not `service/`.

**Injectable writer + default** (network_calculator_screen.dart 8-33):
```dart
class NetworkCalculatorScreen extends StatefulWidget {
  const NetworkCalculatorScreen({super.key, this.copyWriter});
  final CopyValueWriter? copyWriter;
  // ...
}
CopyValueWriter get _copyWriter =>
    widget.copyWriter ?? const ClipboardCopyWriter();
```
Copy this for `session`, `sharePort`, and `copyWriter`. Tests inject fakes; production `pageBuilder` in the catalog can use `const InternetDiagnosticScreen()` with defaults **or** a composition root — catalog today always uses `const Screen()` with no deps (`app_destinations.dart` 83-88). If session needs Android channels, inject inside the screen’s `initState` (like `ClipboardCopyWriter`), not in `AppDestination.pageBuilder`, unless planner introduces a factory. Prefer screen-owned defaults to keep `pageBuilder` a one-liner like the other three.

**ToolScaffold + actions + result card** (network_calculator_screen.dart 128-207):
```dart
return ToolScaffold(
  title: 'Calculadora de Rede',
  children: [
    ToolInputSection(/* fields */),
    const SizedBox(height: 24),
    ToolActionGroup(
      primary: ElevatedButton(
        onPressed: _calculate,
        child: const Text('Calcular rede'),
      ),
      secondary: TextButton(
        onPressed: _clearFields,
        child: const Text('Limpar'),
      ),
    ),
    if (_networkAddress != null) ...[
      const SizedBox(height: 24),
      ToolResultCard(
        child: Column(
          children: [
            TechnicalValueRow(label: '...', value: ..., copyWriter: _copyWriter),
            ToolMetric(label: 'Hosts utilizáveis', value: _usableHosts),
          ],
        ),
      ),
    ],
  ],
);
```

Diagnostic mapping (UI-SPEC + existing widgets):
- Title: `'Diagnóstico de Internet'` (UI-SPEC). Optional `summary` on `ToolScaffold` (tool_scaffold.dart 23-25) for honesty copy.
- **No** `ToolInputSection` form. Actions only.
- `ToolActionGroup` (`tool_sections.dart` 32-62):
  - primary: Iniciar / Repetir (`ElevatedButton`)
  - `onCancel:` when running — widget already renders `TextButton` `'Cancelar'` (lines 56-59). **Use `onCancel`, do not invent a second cancel button.** Existing tools pass `secondary: Limpar` and never `onCancel`; diagnostic is the first production user of `onCancel`.
  - Disable primary while `running` (`onPressed: null`) — DIAG-01. Hash/Rede always leave primary enabled; this is new.
- After terminal: primary becomes Repetir; `ToolStatusPanel.onRetry` already shows `'Tentar novamente'` (`tool_status_panel.dart` 151-157). Prefer **one** retry affordance: either `ToolActionGroup` primary “Repetir” **or** `onRetry`, not both. UI-SPEC says primary = iniciar, then repetir after terminal — copy Rede’s primary CTA pattern; use `onRetry: null`.

**Analog B (status + partials):** `lib/design_system/tool_status_panel.dart`

Seven variants already exist (lines 8-16, 27-62). Map run phase:
- no run → `empty`
- running → `loading` (`progress` optional)
- all required facts ok → `success`
- independent failures with some success → `failure` (partial) **with** `preservedChild`
- no active network → `offline` (do not collapse all facts into one bool)
- user/lifecycle cancel → `cancelled`
- `permissionDenied` only if a local fact needs it later — do not request `ACCESS_LOCAL_NETWORK`

**Critical `preservedChild` rule** (tool_status_panel.dart 109-112, 167-169; tests 516-576):
```dart
bool get _showsPreservedChild =>
    variant == ToolStatusVariant.loading ||
    variant == ToolStatusVariant.failure ||
    variant == ToolStatusVariant.cancelled;
```
`preservedChild` is **hidden** for `success`, `empty`, `offline`, `permissionDenied`. Therefore:
- While `loading` / `failure` / `cancelled`: put the facts card in `preservedChild` (DIAG-11).
- On `success`: put the facts card as a **sibling below** `ToolStatusPanel`, like Rede’s `ToolResultCard` after actions — not as `preservedChild`.

**Facts rendering:**
- Addresses: `TechnicalValueRow` + `copyWriter` (hash_generator_screen.dart 115-123 also uses `metadata:` for extra line — use that for method/target/timeout/provider).
- Aggregates: `ToolMetric` + `ToolMetricLayout` (hash_generator_screen.dart 107-113). `value: null` → `'Indisponível'`.
- ICMP: `ToolMetric(label: 'ICMP', value: null)` plus metadata “Indisponível neste MVP”. Widget test must `findsNothing` for `'ping'` on TCP/HTTPS facts (Pitfall 3).

**Share (DIAG-15):** no share widget exists. Add an `IconButton` 48×48 next to copy (CopyValueAction constraints, copy_value_action.dart 63-64: `minWidth: 48, minHeight: 48`). Call `ShareTextPort`. Copy of the **session summary** uses existing `CopyValueWriter` / `CopyValueAction` — do not add a second clipboard channel.

**dispose:** Rede disposes controllers (network_calculator_screen.dart 120-125). Diagnostic must `session.cancel()`, dispose `AppLifecycleListener`, and cancel visibility subscription.

**Do not** compute in the widget. Listen to session state and rebuild. `HashGeneratorScreen._calculate` calling `HashCalculator.calculate` in `setState` is OK for sync tools; **not** for this screen.

---

### `lib/app/app_destinations.dart` (config) — MODIFY

**Analog:** the file itself.

**Enum + entry shape** (lines 7-47, 50-81):
```dart
enum AppDestinationCategory { rede, armazenamento, hash }

final List<AppDestination> appDestinations = List.unmodifiable([
  AppDestination(
    id: 'network_calculator',
    label: 'Rede',
    semanticLabel: 'Calculadora de Rede',
    icon: Icons.network_check_outlined,
    selectedIcon: Icons.network_check,
    category: AppDestinationCategory.rede,
    compactPriority: 1,
    pageBuilder: _buildNetworkCalculator,
  ),
  // data_converter compactPriority: 2
  // hash_generator compactPriority: 3
]);

Widget _buildHashGenerator(BuildContext context) => const HashGeneratorScreen();
```

Planner actions (D-03 + RESEARCH Pattern 4 + UI-SPEC):
- Add `AppDestinationCategory.diagnostico`.
- Append **after Hash** (do not reorder Rede/Armazenamento/Hash):
  - `id: 'internet_diagnostic'`
  - `label: 'Diagnóstico'`
  - `semanticLabel: 'Diagnóstico de Internet'`
  - outlined + filled icon pair (catalog test requires `icon != selectedIcon`, destination_catalog_test.dart 56-65)
  - `compactPriority: 4`
  - `pageBuilder` → `const InternetDiagnosticScreen()`
- Keep `List.unmodifiable`. Overflow remains `length > 4` (`app_shell.dart` 28-29) — 4 destinations show **all** on the compact bar.

---

### `lib/app/app_shell.dart` (component, event-driven) — MODIFY

**Analog:** the file itself.

**IndexedStack preserves State** (lines 176-180, 91-99, 109-118):
```dart
final body = IndexedStack(
  key: _stackKey,
  index: pageIndex,
  children: _pages,
);

void _onBarDestinationSelected(int index) {
  // ...
  setState(() {
    _selectedId = _barUsesOverflow
        ? _pinnedDestinations[index].id
        : widget.destinations[index].id;
  });
}
```

There is **no visibility callback today**. UI-SPEC Phase 1 + QUAL-04 require one. Add the smallest hook, e.g. `ValueNotifier<String> selectedId` or notify the diagnostic page when `_selectedId` changes. When `selectedId != 'internet_diagnostic'` and a run is `running` → `session.cancel()`. Do not auto-`start()` on resume.

**Do not** change overflow math (`_barUsesOverflow => length > 4`). Tests in `test/app/app_shell_test.dart` 192-216 cover 5-destination overflow; 4-destination production bar tests (lines 310-340) currently expect exactly `['Rede', 'Armazenamento', 'Hash']` — update those to include `'Diagnóstico'` / tooltip `'Diagnóstico de Internet'`.

`lib/main.dart` 20: `home: AppShell(destinations: appDestinations)` — no change unless shell constructor grows a listener; prefer shell-internal notification so `App` stays as-is.

---

### Android `MainActivity.kt` + plugins

**Analog:** `android/app/src/main/kotlin/com/example/tools_app/MainActivity.kt` (entire file, 5 lines):
```kotlin
package br.dev.rodrigopinheiro.tools_app

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity()
```

**Pitfall 12 (do not “fix” the folder unless required):** Gradle `namespace` / `applicationId` = `br.dev.rodrigopinheiro.tools_app` (`android/app/build.gradle` 7, 21). Source lives under `com/example/tools_app/` with matching `package` declaration. Keep `package` aligned with namespace. Register channels in `configureFlutterEngine` (RESEARCH MethodChannel snippet). Put `NetworkSnapshotPlugin.kt` and `ShareTextPlugin.kt` **next to** `MainActivity.kt` in the same directory so the existing package declaration stays valid. Do **not** move MainActivity in this phase just to match the folder name.

**No Kotlin analog** for ConnectivityManager or `Intent.ACTION_SEND`. Copy RESEARCH Pattern 1 and Share snippet. Keep snapshot work short (main thread). No SSID/BSSID, no `FLAG_INCLUDE_LOCATION_INFO`, no `Log` of public IP in release.

Channel names (suggested, match RESEARCH):
- `br.dev.rodrigopinheiro.tools_app/network_snapshot`
- `br.dev.rodrigopinheiro.tools_app/share_text`

---

### `android/app/src/main/AndroidManifest.xml` (config) — MODIFY

**Analog (INTERNET already declared, but only debug/profile):** `android/app/src/debug/AndroidManifest.xml` lines 1-7:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
</manifest>
```

**Main manifest today** (`android/app/src/main/AndroidManifest.xml` lines 1-45) has **zero** `uses-permission`. Add **before** `<application>` (Pitfall 8):
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```
Do not add location, nearby-wifi, `ACCESS_LOCAL_NETWORK`, or `CHANGE_NETWORK_STATE`. Existing `<queries>` for `PROCESS_TEXT` stays; share chooser needs no extra queries (RESEARCH).

---

### `pubspec.yaml` (config) — MODIFY

**Analog:** hosted dep pin style at lines 36-40:
```yaml
  cupertino_icons: ^1.0.8
  google_fonts: ^6.2.1
  crypto: ^3.0.7
  intl: ^0.20.2
```

Add `dio: ^5.11.0` next to those. Do not add connectivity_plus, network_info_plus, dart_ping, share_plus, permission_handler, integration_test. Version stays `1.1.1+4` unless product asks otherwise. Do not touch `pubspec.lock-old` (D-14).

---

### Tests

**Harness analog:** `test/screen/screen_test_harness.dart` entire file (lines 1-27):
```dart
Widget wrapScreen(Widget child) {
  return MaterialApp(
    theme: lightTheme,
    home: Scaffold(body: child),
  );
}

class FakeCopyWriter implements CopyValueWriter {
  String? lastValue;
  int callCount = 0;
  bool shouldThrow = false;

  @override
  Future<void> write(String value) async {
    callCount++;
    if (shouldThrow) throw Exception('Clipboard failure');
    lastValue = value;
  }
}
```

Reuse `wrapScreen` + `FakeCopyWriter` for the diagnostic screen. Put diagnostic-specific fakes in `test/diagnostic/fakes.dart` implementing the seven contracts (same style: fields for last call, `shouldThrow`, `Completer` for in-flight). Duplicate `FakeCopyWriter` already exists in `tool_components_test.dart` — do not create a third copy unless needed; screen tests import the harness.

**Catalog test analog:** `test/app/destination_catalog_test.dart` lines 18-40, 68-80 — lists are exact equality. Update to 4 ids/labels/semanticLabels/categories/page types. `_FakeBuildContext extends Fake` (line 90) is the handwritten-fake style for `pageBuilder`.

**Shell production bar analog:** `test/app/app_shell_test.dart` 321-336 (labels + tooltips). Add Diagnóstico. Overflow tests with `_buildFiveDestinations()` stay valid.

**Preservation analog:** `test/screen/tools_preservation_test.dart` 29-118 — smoke that Rede/Armazenamento/Hash still work via `const App()`. Extend to tap `'Diagnóstico'` and assert ToolScaffold title `'Diagnóstico de Internet'` **without** dropping the three existing assertions.

**Widget screen analog:** `test/screen/network_calculator_screen_test.dart` 9-21 (no AppBar, ToolScaffold heading), 121-140 (inject `FakeCopyWriter`). Diagnostic screen tests: inject fake session; assert Iniciar disabled while running; Cancelar via `ToolActionGroup.onCancel`; no `'ping'`; `'Indisponível'` for ICMP.

**Unit analog:** `test/hash_calculator_test.dart` / `test/network_calculator_test.dart` — `group` + `test`, no `mockito`.

**QUAL-08 coverage mapping to fakes (not integration_test):**
| Case | Fake behavior to copy |
|------|------------------------|
| success | all ports return facts `success` |
| offline | snapshot transports empty / no active network |
| timeout | Completer never completes until scope timer / probe returns `timeout` |
| invalid JSON | PublicIpSource returns `failure` (invalid) |
| gateway absent | snapshot `gatewayIpv4: null` → probe not called |
| public IP down | PublicIpSource `failure`; other facts still success (DIAG-10) |
| partial failure | one probe fails, siblings succeed |
| cancel | `session.cancel()`; Completer completes late → ignored (`copy_lifecycle_test`) |
| network change | snapshot fake emits new handle/transports → remaining samples `networkChanged` |
| lifecycle/dispose | pumpWidget shrink after start (copy_lifecycle_test 74-80) |
| simultaneous start | second `start()` no-op while running |
| aggregation | pure unit tests on `LatencyAggregator` |

---

## Shared Patterns

### Injectable ports + handwritten fakes
**Source:** `lib/design_system/copy_value_action.dart` 8-21; `test/screen/screen_test_harness.dart` 14-26
**Apply to:** all seven diagnostic contracts, share, copy, screen tests
```dart
abstract class CopyValueWriter {
  Future<void> write(String value);
}
class ClipboardCopyWriter implements CopyValueWriter {
  const ClipboardCopyWriter();
  @override
  Future<void> write(String value) {
    return Clipboard.setData(ClipboardData(text: value));
  }
}
```

### Package imports
**Source:** every `lib/**/*.dart` production file
**Apply to:** all new Dart files
```dart
import 'package:tools_app/design_system/tool_scaffold.dart';
```
Never `../design_system/...`.

### Tool anatomy (do not duplicate design_system)
**Source:** `tool_scaffold.dart`, `tool_sections.dart`, `tool_status_panel.dart`, `copy_value_action.dart`
**Apply to:** `internet_diagnostic_screen.dart` only
- `ToolScaffold(title:, summary:, children:)`
- `ToolActionGroup(primary:, onCancel:)` — first production `onCancel`
- `ToolStatusPanel` + `preservedChild` only for loading/failure/cancelled
- `TechnicalValueRow` + `ToolMetric` / `ToolMetricLayout` / `ToolResultCard`
- `CopyValueWriter` for copy; new `ShareTextPort` for share
- 48×48 targets (`CopyValueAction` constraints)
- pt-BR copy; never show `0` for missing (`ToolMetric` null → `'Indisponível'`)

### Catalog + IndexedStack
**Source:** `lib/app/app_destinations.dart`, `lib/app/app_shell.dart`
**Apply to:** 4th destination + visibility cancel
- Typed `AppDestination`, `List.unmodifiable`, `compactPriority` 1–4
- `_barUsesOverflow => length > 4`
- IndexedStack **keeps** `State` — must cancel diagnostic I/O when hidden (new shell hook)

### Pure Dart domain
**Source:** `lib/service/network_calculator.dart`, `lib/service/hash_calculator.dart`
**Apply to:** models, aggregator, session (no widgets, no `setState`)
- Place new code in `lib/diagnostic/`, not `lib/service/`
- Do not mutate run state in place (`NetworkCalculator` fields are a negative example)

### Error / mounted guard (UI only)
**Source:** `copy_value_action.dart` 68-95
**Apply to:** screen after await (share/copy/lifecycle)
```dart
final context = this.context;
await effectiveWriter.write(widget.value);
if (!context.mounted) return;
```
Adapters return facts; session drops stale `runId`.

### Test style
**Source:** `test/screen/*`, `test/app/destination_catalog_test.dart`, `test/hash_calculator_test.dart`
**Apply to:** all QUAL-08 tests
- `flutter_test` only; `group`/`test`/`testWidgets`
- `wrapScreen` + lightTheme
- Handwritten `implements` fakes; `Fake` from flutter_test only as in `_FakeBuildContext`
- Viewport setup: `tester.view.physicalSize` + `addTearDown` reset (`app_shell_test.dart` 29-32)

### Android identity
**Source:** `android/app/build.gradle` 7, 21; `MainActivity.kt` line 1
**Apply to:** Kotlin plugins + MethodChannel names
```
namespace / applicationId / Kotlin package: br.dev.rodrigopinheiro.tools_app
file path today: android/app/src/main/kotlin/com/example/tools_app/
```

### Permissions
**Source:** debug/profile manifests have INTERNET only; main has none
**Apply to:** main `AndroidManifest.xml` — add INTERNET + ACCESS_NETWORK_STATE; nothing else

---

## No Analog Found

Files with no close match in the codebase (planner should use RESEARCH.md patterns instead):

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| `lib/diagnostic/session/diagnostic_session_impl.dart` | controller | event-driven | No run-id session, `ValueListenable`, or cancel-scope in `lib/` |
| `lib/diagnostic/session/cancellation_scope.dart` | utility | event-driven | No token/task/timer registry |
| `lib/diagnostic/public_ip/dio_public_ip_source.dart` | service | request-response | No Dio/HTTP client |
| `lib/diagnostic/public_ip/public_ip_config.dart` | config | request-response | No third-party URL config objects |
| `lib/diagnostic/probes/dio_https_probe.dart` | service | request-response | No Dio; no HTTPS probe |
| `lib/diagnostic/probes/tcp_connect_probe.dart` | service | request-response | No `Socket.startConnect` / `ConnectionTask` |
| `lib/diagnostic/probes/probe_config.dart` | config | request-response | No probe config |
| `lib/diagnostic/platform/android_network_snapshot_source.dart` | service | request-response | No `MethodChannel` in Dart |
| `NetworkSnapshotPlugin.kt` | service | request-response | MainActivity is empty `FlutterActivity`; no ConnectivityManager |
| `ShareTextPlugin.kt` | service | request-response | No `Intent.ACTION_SEND` / share sheet |

`AppLifecycleListener` also has **zero** usages — attach it on the diagnostic screen using RESEARCH.md; do not invent a global observer in `App`.

---

## Metadata

**Analog search scope:** `lib/` (27 Dart files), `android/app/src/main` (Kotlin + manifests), `test/` (26 Dart files), `pubspec.yaml`, `android/app/build.gradle`
**Files scanned:** 53 production/test sources + 3 phase docs
**Pattern extraction date:** 2026-08-31

**Negative space (do not copy into Phase 3):**
- `NetworkCalculator` mutable fields as a template for run state
- `setState` wrapping I/O (Rede/Hash are sync)
- `NetworkInterface.list` / `connectivity_plus` / `share_plus`
- `ToolStatusPanel.preservedChild` on `success` (it will not show)
- Relocating `MainActivity.kt` solely to match folder vs package
- `pubspec.lock-old`
- Speed test / ICMP production / location permissions
