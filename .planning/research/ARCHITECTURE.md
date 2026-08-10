# Architecture Research

**Domain:** Flutter Android-first technical utilities app with network diagnostics and a later, conditional speed test
**Researched:** 2026-08-10
**Confidence:** HIGH for Flutter structure, state, lifecycle, cancellation semantics, and test seams; MEDIUM for concrete network adapters until Android capability research selects and validates implementations

## Recommendation

Evolve the current app in place. Keep the existing pure/synchronous calculators and their tests, add a shared Material 3 presentation system, and introduce a small application layer only for operations that are asynchronous, multi-step, cancellable, or platform-dependent.

The diagnostic feature should use **unidirectional data flow**:

1. A screen sends commands to a screen-scoped controller.
2. The controller owns presentation state and one active diagnostic run.
3. A diagnostic orchestrator coordinates independent capability interfaces.
4. Adapters perform Android, socket, and HTTPS work and own the resources that can actually be aborted.
5. Pure aggregators convert raw samples into immutable metrics.
6. The orchestrator emits incremental snapshots, so one failed capability never erases successful results.

Do not introduce a backend, persistence repository, global service locator, or app-wide reactive state framework for this milestone. Manual constructor injection from the app composition root plus `ChangeNotifier`/`Listenable` is sufficient. Reconsider a broader state-management package only if multiple routes later need to edit the same diagnostic state.

## Existing Architecture and Safe Evolution

The repository already has useful boundaries:

- `lib/screen/` owns widgets and transient form state.
- `lib/service/` owns synchronous calculation logic.
- `lib/model/` contains structured calculation results.
- `lib/theme/` owns light and dark Material 3 themes.
- `test/` directly tests the three existing services and validators.

The main architectural debt is localized rather than systemic:

- navigation and dependency construction are both in `main.dart`;
- screens duplicate input, action, card, metric, and result presentation;
- some formatting and validation remain embedded in screen state;
- no application boundary exists for a long-running operation;
- no adapter boundary exists for platform/network capabilities;
- there are currently service unit tests but no widget, lifecycle, adapter-contract, or integration tests.

Preserve the current service APIs during UI modernization. Migration should be screen-by-screen, with characterization widget tests around each current tool before its layout changes. Network diagnostics is the first feature that justifies an explicit controller and orchestration layer; retrofitting all existing tools to MVVM before delivering value would add churn without solving a present problem.

## Standard Architecture

### System Overview

```text
┌──────────────────────────────────────────────────────────────────────┐
│ Presentation                                                         │
│                                                                      │
│ AppShell ── adaptive NavigationBar / NavigationRail                  │
│    │                                                                 │
│    ├── Existing tool screens ── existing synchronous services        │
│    │                                                                 │
│    └── DiagnosticScreen                                              │
│          ├── shared Tool/Status/Metric/Result widgets                │
│          └── DiagnosticController (screen-scoped state owner)        │
└───────────────────────────────┬──────────────────────────────────────┘
                                │ commands / immutable snapshots
┌───────────────────────────────▼──────────────────────────────────────┐
│ Application + domain                                                  │
│                                                                      │
│ DiagnosticOrchestrator ── OperationScope / run deadline              │
│    ├── dependency-aware work graph                                   │
│    ├── partial-result merge                                          │
│    └── event/snapshot stream                                         │
│                                                                      │
│ ProbeMetricsAggregator (pure)  Diagnostic models (immutable)         │
└─────────┬───────────────────┬────────────────────┬───────────────────┘
          │                   │                    │
┌─────────▼───────────────────▼────────────────────▼───────────────────┐
│ Capability interfaces and infrastructure adapters                    │
│                                                                      │
│ ConnectivityCapability  LocalNetworkCapability  PublicIpProvider     │
│ ProbeAdapter             Clock/Stopwatch           (later) SpeedTest │
│                                                                      │
│ Android plugin/channel │ dart:io socket/HTTPS │ controlled endpoint  │
└──────────────────────────────────────────────────────────────────────┘
```

Dependency direction is downward only. Widgets know the controller, the controller knows the orchestrator abstraction, and the orchestrator knows capability interfaces. Infrastructure implements interfaces but must not import screens or presentation state.

### Component Responsibilities

| Component | Owns | Must not own |
|-----------|------|--------------|
| `App` composition root | Concrete adapter construction and dependency wiring | Run state, permissions prompts, network logic |
| `AppShell` | Destination catalog, selected destination, width-based navigation shell | Diagnostic orchestration or tool calculations |
| Shared UI components | Material 3 rendering for inputs, actions, metrics, errors, loading, copying, empty/unsupported/cancelled states | Network calls or feature-specific business rules |
| Existing tool screens | Text controllers, field validation feedback, rendering of existing service results | New cross-app state framework |
| `DiagnosticScreen` | View lifecycle bridge and rendering immutable state | Direct plugin, socket, HTTP, or timer access |
| `DiagnosticController` | `DiagnosticViewState`, one active run/subscription, start/cancel/repeat commands, last in-memory execution | Probe algorithms or Android API calls |
| `DiagnosticOrchestrator` | Work ordering, concurrency, deadlines, per-step failure capture, incremental snapshots | Widget lifecycle, strings, colors, snack bars |
| Capability interfaces | Stable contracts for transport, local network, gateway, public IP, probes | UI-specific status or provider-specific response shapes |
| Infrastructure adapters | Plugin/platform/HTTP/socket resources, parsing at boundary, per-operation timeout, real abort/close behavior | Aggregating metrics or deciding how results are displayed |
| `ProbeMetricsAggregator` | Pure min/mean/max, attempts, success count, loss/failure count | I/O, timers, formatting, mutable state |
| Immutable result models | Typed values, status, method/provenance, timestamps/durations | `BuildContext`, localized labels, exceptions from third-party libraries |

## Recommended Project Structure

```text
lib/
├── app/
│   ├── app.dart                         # MaterialApp and composition root
│   ├── app_shell.dart                   # adaptive navigation
│   └── app_destination.dart             # single destination catalog
├── design_system/
│   ├── app_theme.dart                   # evolved current theme/theme.dart
│   ├── layout_breakpoints.dart
│   └── widgets/
│       ├── tool_page.dart
│       ├── tool_input_card.dart
│       ├── tool_actions.dart
│       ├── status_panel.dart
│       ├── metric_card.dart
│       └── copy_result_action.dart
├── features/
│   ├── network_calculator/              # migrate incrementally; keep service API
│   ├── storage_converter/
│   ├── hash_generator/
│   └── internet_diagnostics/
│       ├── presentation/
│       │   ├── diagnostic_screen.dart
│       │   ├── diagnostic_controller.dart
│       │   ├── diagnostic_view_state.dart
│       │   └── widgets/
│       ├── application/
│       │   ├── diagnostic_orchestrator.dart
│       │   ├── diagnostic_run.dart
│       │   └── operation_scope.dart
│       ├── domain/
│       │   ├── diagnostic_snapshot.dart
│       │   ├── measurement.dart
│       │   ├── probe_sample.dart
│       │   ├── probe_metrics.dart
│       │   └── probe_metrics_aggregator.dart
│       └── infrastructure/
│           ├── connectivity_adapter.dart
│           ├── local_network_adapter.dart
│           ├── public_ip_adapter.dart
│           └── tcp_or_https_probe_adapter.dart
└── main.dart                             # runApp only

test/
├── existing service tests
├── design_system/                        # widget + selective golden tests
├── features/internet_diagnostics/
│   ├── domain/                           # metrics and model invariants
│   ├── application/                      # work graph, timeout, cancellation
│   ├── presentation/                     # state transitions and widgets
│   └── infrastructure/                   # adapter contract tests
└── support/
    ├── fakes.dart
    ├── fake_clock.dart
    └── diagnostic_fixtures.dart

integration_test/
└── internet_diagnostics_android_test.dart
```

This is the target organization, not a prerequisite big-bang move. Existing files can remain where they are until each screen is migrated and its tests pass. Avoid empty `repository`, `use_case`, or `core` folders that add naming ceremony without a real boundary.

## Architectural Patterns

### 1. Adaptive app shell with feature-owned screens

Use one catalog of destinations and one shell. At compact widths render Material 3 `NavigationBar` or a tools home if the design contract chooses category-first navigation; at medium/expanded widths render `NavigationRail`. Branch on available window width, not device identity or orientation.

The shell owns only navigation. A tool feature owns its page body and state. Do not let `main.dart` grow a switch containing feature logic.

Important lifecycle implication: if the shell uses `IndexedStack`/`Offstage` to preserve form state, a hidden diagnostic page might not be disposed. Therefore the shell must notify the diagnostic feature when its destination becomes inactive, or the diagnostic destination must deliberately not be retained while a run is active. Cancellation must not depend on `dispose()` alone.

### 2. Screen-scoped controller and immutable state machine

Use a controller with a small Flutter-native observable surface. A `ChangeNotifier` is adequate and introduces no state-management dependency. Construct it outside the widget and inject its orchestrator; the screen owns and disposes it unless a route-level owner does so.

Recommended states:

```text
Idle
  └── start ──> Running(partial snapshot)
                  ├── update ──> Running(richer partial snapshot)
                  ├── cancel ──> Cancelling ──> Cancelled(partial snapshot)
                  └── finish ──> Completed(snapshot with mixed outcomes)

Running ── repeat/start ──> cancel and await old run ──> new Running(runId)
```

There should normally be no whole-screen `Failed` state. Network and platform failures belong to individual measurements. Reserve fatal state for an internal invariant failure that prevents the orchestrator from producing any snapshot.

Keep state immutable and attach a monotonically increasing `runId`. The controller ignores events from an older run even if a third-party operation reports late. This generation guard complements cancellation; it is not a substitute for closing resources.

### 3. Capability interfaces around unstable boundaries

Define interfaces according to product capabilities, not packages:

```dart
abstract interface class ConnectivityCapability {
  Future<TransportSnapshot> inspect(OperationScope scope);
}

abstract interface class LocalNetworkCapability {
  Future<LocalAddressResult> localIpv4(OperationScope scope);
  Future<GatewayResult> defaultGateway(OperationScope scope);
}

abstract interface class PublicIpProvider {
  Future<PublicIpResult> fetch(OperationScope scope);
}

abstract interface class ProbeAdapter {
  ProbeMethod get method; // for example tcpConnect or httpsRequest
  Future<ProbeSample> sample(ProbeTarget target, OperationScope scope);
}
```

Return app-owned models. Translate plugin exceptions, socket errors, malformed responses, and unsupported-platform responses inside the adapter into a small failure taxonomy. Never expose a plugin's enum or exception type to the controller or UI.

Keep transport observation separate from internet reachability. A Wi-Fi/mobile signal means a transport exists; it does not prove usable internet, and an HTTPS response might be a captive portal. The model and UI must be able to show these as distinct facts.

The future speed test should get a separate `SpeedTestAdapter` and `SpeedTestOrchestrator`. Reuse the operation scope and metric/value conventions, but do not add a placeholder production implementation to the basic diagnostic feature.

### 4. Cooperative cancellation with resource ownership

Dart `Future.timeout` changes what the caller observes but does not cancel the source operation; the source can still complete later. Therefore cancellation must be implemented at every layer:

- The controller cancels and awaits the active run/subscription.
- The orchestrator cancels its `OperationScope` and stops scheduling dependent work.
- Each adapter registers cleanup for the resource it owns: stream subscription, socket, HTTP request/client, timer, method-channel request if the plugin supports cancellation, or isolate.
- Cleanup runs in `finally`/`whenComplete` and cancellation completion is awaited.
- Every adapter has an operation timeout; the orchestrator additionally has a bounded run deadline.
- The controller uses `runId` to reject late results from inherently non-cancellable platform calls.

An operation scope should expose at least `isCancelled`, `whenCancelled`, `throwIfCancelled()`, and cleanup registration. Calling `Future.any` with a cancellation future is only a notification mechanism; without adapter cleanup it leaks work.

For a `Stream`-based diagnostic run, cancel the `StreamSubscription` and have the stream's `finally` block cancel its operation scope. Dart specifies that cancellation of an `async*` stream executes its `finally` cleanup, which makes this a useful orchestration seam.

### 5. Partial-result accumulator, not fail-fast aggregation

Model every diagnostic field independently:

```dart
enum MeasurementStatus {
  pending,
  success,
  unavailable,
  unsupported,
  skipped,
  timedOut,
  failed,
  cancelled,
}

class Measurement<T> {
  final MeasurementStatus status;
  final T? value;
  final ProbeMethod? method;
  final Duration? elapsed;
  final FailureCode? failureCode;
}
```

`DiagnosticSnapshot` should contain independent measurements for transport, local IPv4, gateway, public IP, gateway probe, and internet probe, plus `startedAt`, optional `finishedAt`, and `runId`. Copy/share formatting derives from this structured snapshot; do not store the share string as the source of truth.

Do not use `Future.wait` in fail-fast mode over the entire run. Catch and normalize failure at each capability boundary, merge the outcome, and publish a new snapshot. A public-IP timeout must not remove local-address or probe results.

### 6. Pure sample aggregation

Store raw attempts for the duration of a run and aggregate in a pure function. Define the denominator explicitly:

- `attempted`: all scheduled samples;
- `succeeded`: samples with a usable duration;
- `failedOrLost`: attempted minus succeeded, including timeout/refusal according to the chosen product definition;
- min/mean/max: computed only from successful samples;
- no successful samples: metrics remain unavailable rather than using zero;
- method and target: retained alongside metrics so TCP/HTTPS is never mislabeled ICMP;
- durations: measure with a monotonic stopwatch, not wall-clock time;
- display rounding: presentation concern only.

Make the sample count, spacing, per-sample timeout, and overall deadline part of an immutable `DiagnosticRequest`. This makes behavior explicit and testable.

## Explicit Data Flow

### Start and incremental result flow

```text
User taps "Iniciar"
  ↓
DiagnosticController.start()
  ├── cancel + await any previous run
  ├── allocate runId and publish Running(all pending)
  └── DiagnosticOrchestrator.start(request)
        ↓
      inspect transport
        ├── no transport: mark external steps skipped; still inspect local facts
        └── transport present/unknown:
              ├── local IPv4 ───────────────┐
              ├── default gateway ──┐       │
              │                     └── gateway probe (only if gateway exists)
              ├── public IP HTTPS ──────────┤ independent, bounded tasks
              └── internet probe ───────────┘
                         ↓ after every completed step/sample
                 merge immutable snapshot
                         ↓
                 controller receives event if runId is current
                         ↓
                 notifyListeners() → widgets render partial state
                         ↓
                 finalize Completed or Cancelled with last partial snapshot
```

The orchestrator may run independent branches concurrently, but must honor dependencies: a gateway probe cannot start without a valid gateway; external calls can be skipped when transport is definitively absent. An `unknown` transport result should not automatically suppress probes because platform transport APIs are hints, not proof of reachability.

### Cancel flow

```text
User cancel / destination hidden / app paused / screen disposed
  ↓
DiagnosticController.cancel(reason)
  ├── publish Cancelling
  ├── activeRun.cancel(reason)
  │     ├── operation scope becomes cancelled
  │     ├── pending branches stop scheduling
  │     ├── adapters close owned resources
  │     └── cleanup futures are awaited
  ├── ignore any late event whose runId is stale
  └── publish Cancelled(last partial snapshot)
```

### Repeat flow

Repeat is not a concurrent second run. It cancels and awaits cleanup of the current run, then allocates a new `runId`. This prevents two runs from competing for sockets, endpoint quotas, UI progress, and later speed-test bandwidth.

## State Ownership

| State | Owner | Lifetime |
|-------|-------|----------|
| Selected destination | `AppShell` | App session |
| Theme selection (if user-selectable later) | App-level settings owner | App session; persistence only if separately approved |
| Existing form text/dropdowns | Existing tool `State` | Screen/retained destination |
| Diagnostic view state and last execution | `DiagnosticController` | Diagnostic screen session only |
| Active subscriptions/resources | `DiagnosticRun` and concrete adapters | One run; always bounded and cancellable |
| Raw probe samples | Active run snapshot/accumulator | One run |
| Aggregated probe metrics | Immutable `DiagnosticSnapshot` | Last in-memory result |
| Copy/share text | Formatter invoked on demand | Ephemeral |
| Provider endpoints and limits | Injected configuration | App build/session |

No result history is persisted in the MVP. "Last execution" means the last execution held by the current controller/app session, not an implied durable audit record.

## Android Lifecycle Policy

Bridge Flutter lifecycle events in the presentation host with `AppLifecycleListener` (or `WidgetsBindingObserver` where required by the supported Flutter version). Keep Flutter lifecycle types out of the orchestrator.

Recommended policy:

| Event | Basic diagnostics | Later speed test |
|-------|-------------------|------------------|
| Destination becomes hidden | Cancel; preserve partial snapshot | Cancel immediately |
| `inactive` | Do not start new work; wait for a definitive transition | Pause/cancel policy must be tested; safest default is cancel |
| `hidden` or `paused` | Cancel and await cleanup; label run interrupted | Cancel immediately and close transfers |
| `detached` | Best-effort cancel/cleanup | Best-effort cancel/cleanup |
| `resumed` | Do not auto-run; retain interrupted result and let user repeat | Never auto-resume data-consuming test |
| Widget/controller `dispose` | Remove listener, cancel run, reject late events | Same |

Do not assume every lifecycle notification will arrive before process death. The architecture must remain correct without final callbacks: no important correctness state is stored only during cleanup, and external resources must already be bounded by timeout. Because history persistence is out of scope, losing the in-memory last result after process death is acceptable and should not be disguised as durable behavior.

## UI Modernization Boundaries

Modernize through reusable primitives, not a universal "smart form" abstraction:

- `ToolPage`: consistent max content width, scroll behavior, padding, title/help placement.
- `ToolInputCard`: visual container only; feature supplies fields.
- `ToolActions`: primary/secondary/cancel layout with minimum touch targets.
- `StatusPanel`: semantic empty/loading/offline/unsupported/cancelled/error presentation.
- `MetricCard`/`MetricGrid`: label, value, unit, method, and unavailable state.
- `CopyResultAction`: clipboard feedback and semantics, with feature formatter injected.

Keep feature-specific validation, domain wording, and result composition in the feature. This avoids a parameter-heavy generic widget that becomes harder to test than the duplicated code it replaces.

Use theme `ColorScheme` roles rather than hard-coded semantic colors inside screens. In particular, the current dark theme maps broad body text and `onSurface` to bright green; the design contract should verify contrast, hierarchy, and disabled/error states before those tokens become shared dependencies.

## Testing Architecture

### Test pyramid and seams

| Level | What to test | Seam |
|-------|--------------|------|
| Pure unit | Metrics, status merges, failure mapping, copy-summary formatting | Immutable fixtures; no Flutter binding |
| Controller unit | idle/start/progress/cancel/repeat, stale run rejection, dispose behavior | Fake orchestrator and controllable run stream |
| Orchestrator unit | dependency order, concurrency, timeouts, partial failures, cancellation cleanup | Fake capability adapters, fake clock/stopwatch |
| Adapter contract | valid/invalid provider response, timeout, unsupported capability, socket/HTTP cleanup | Controlled local server or mocked platform channel, not a public internet dependency |
| Widget | Every visible state, button enabling, partial results, method labels, text scale, semantics, copy feedback | Inject fake controller/orchestrator |
| Golden | Shared metric/status/input components in light/dark and compact/wide cases | Stable fonts and fixed surface size |
| Integration/device | Android Wi-Fi, mobile data, offline, network transition, app background/return | Real Android device/emulator plus controlled endpoint where possible |

Continue running the existing service tests unchanged throughout UI work. Add characterization widget tests before moving each legacy screen. Goldens should cover stable shared components rather than full network-result pages whose timestamps and platform typography create noisy diffs.

### Required orchestration scenarios

At minimum, automated tests should prove:

1. all-success run publishes progressive snapshots then completes;
2. public-IP invalid response fails only that measurement;
3. gateway unavailable skips gateway probe without affecting internet probe;
4. one sample timeout contributes to loss/failure but preserves successful min/mean/max;
5. all samples fail and metrics remain unavailable rather than zero;
6. cancellation closes resources and produces no post-cancel UI mutation;
7. repeat waits for prior cleanup and ignores stale events;
8. pause/hidden and destination change cancel the run;
9. resume does not automatically consume network or restart work;
10. offline and captive-portal-like responses are represented without crashing or claiming verified internet.

## Anti-Patterns to Avoid

### Calling plugins or `dart:io` from widgets

This couples UI tests to platform channels, scatters timeout handling, and makes lifecycle cleanup unreliable. Widgets should issue commands to the controller; adapters own I/O.

### Treating timeout as cancellation

`Future.timeout` can return a timeout while the source continues. Close or abort the underlying resource, await cleanup, and reject late results by `runId`.

### One nullable result plus one error string

That model cannot represent pending, unsupported, timeout, cancelled, and partial success simultaneously. Use per-capability typed outcomes inside an immutable snapshot.

### `Future.wait` over the entire diagnostic

A single exception can hide valid sibling results. Normalize errors per adapter/capability and merge incrementally.

### Equating connectivity type with internet access

Wi-Fi/mobile describes transport, not successful external reachability. Keep transport, DNS/HTTPS reachability, captive portal indication, and public IP as separate claims.

### Calling every latency result "ping"

Preserve `ProbeMethod`, target, port/URL class, sample count, and timeout in the result. Label TCP connect and HTTPS timings precisely.

### Global controller singleton

It survives screens unexpectedly, complicates disposal, and makes tests order-dependent. Scope the controller to the diagnostic destination and inject its dependencies.

### Big-bang folder/framework rewrite

Moving all three working tools before shared components are proven increases regression risk. Add the app shell and primitives, migrate one screen at a time, then build diagnostics through the new seam.

## Integration Points

### External and Platform Boundaries

| Boundary | Integration pattern | Architectural constraint |
|----------|---------------------|--------------------------|
| Android transport information | Capability adapter over selected maintained plugin/platform API | Map to app-owned transport enum; transport is not reachability |
| Local IPv4/default gateway | Android-aware adapter behind `LocalNetworkCapability` | Unsupported/unavailable are valid outcomes; no location permission unless a separately approved feature requires SSID/BSSID |
| Public IP service | Injected HTTPS provider adapter | Strict HTTPS, response validation, timeout, privacy documentation, replaceable endpoint |
| Gateway/internet latency | `ProbeAdapter` selected by verified method | Own sockets/requests and expose exact method/provenance |
| Copy/share | Presentation service/action | Generate from snapshot and exclude unintended identifiers |
| Later speed-test endpoint | Separate, injected adapter and policy configuration | Explicit consent, data/time budget, legal/operational validation before implementation |

### Internal Boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| App shell ↔ feature | Destination selection/visibility callback | Hidden diagnostic must cancel even if widget is retained |
| Screen ↔ controller | Commands and `Listenable` state | No raw futures handled in build methods |
| Controller ↔ orchestrator | `DiagnosticRun` handle + snapshot stream | Controller owns subscription and current `runId` |
| Orchestrator ↔ adapters | Capability interfaces + `OperationScope` | Every call bounded; each result normalized independently |
| Orchestrator ↔ aggregator | Pure function call | Raw successful durations only; failure counts passed explicitly |
| Domain ↔ presentation | Immutable models + formatter | Domain contains no localized strings or Flutter types |

## Build Order and Roadmap Implications

1. **Regression harness and design contract**
   - Add characterization widget tests for current screens and retain all existing service tests.
   - Decide compact/wide navigation, shared states, accessibility criteria, and theme tokens.
   - This reduces risk before structural UI changes.

2. **Shared presentation primitives and adaptive shell**
   - Create destination catalog, `AppShell`, breakpoints, `ToolPage`, action/status/metric components.
   - Migrate the three existing tools one at a time; analyze and test after each migration.
   - Do not add network dependencies yet.

3. **Diagnostic domain contract**
   - Define measurement statuses, failure codes, method/provenance, snapshot, request, raw samples, and pure aggregator.
   - Build fixtures and exhaustive pure unit tests first; these contracts drive both adapters and UI.

4. **Cancellation and capability seams**
   - Implement `OperationScope`, `DiagnosticRun`, capability interfaces, fake adapters, fake clock/stopwatch.
   - Prove cleanup, deadline, partial merge, and stale-event behavior using fakes before touching platform plugins.

5. **Concrete adapters, one capability at a time**
   - Transport/local IPv4 → gateway → public IP → selected TCP/HTTPS probes.
   - Give each adapter contract tests and an explicit unsupported path. Gateway discovery and exact probe technique require phase-specific technical research.

6. **Orchestrator and diagnostic UI vertical slice**
   - Wire controller, lifecycle bridge, progressive rendering, start/cancel/repeat, copy/share, and last in-memory execution.
   - Verify partial results before styling polish; the snapshot model should make every state renderable.

7. **Android integration and documentation gate**
   - Test Wi-Fi, mobile data, offline, background/return, destination changes, unavailable gateway, invalid public-IP response, and endpoint failure.
   - Update manifest permissions, README, and privacy text based on actual adapters, not planned ones.

8. **Separate speed-test feasibility/design phase**
   - Decide infrastructure, licensing, geography, consent, data/time budgets, and accuracy target.
   - Reuse cancellation and metric primitives only after feasibility passes. Do not let speed-test uncertainty block the basic diagnostic milestone.

The dependency-critical order is: **typed outcomes → cancellation scope → fake adapters → orchestrator tests → concrete adapters → UI integration**. Building the screen first would force network/platform behavior into widgets and make partial results and cancellation expensive to retrofit.

## Scaling Considerations

This is a local-first app, so server user-count scaling is not the primary concern. Scale the architecture by feature and operational cost:

| Growth point | Adjustment |
|--------------|------------|
| 4–8 local tools | Current feature folders, adaptive shell, manual DI are sufficient |
| More async diagnostic tools | Reuse operation scope/status conventions; keep one controller per destination |
| Shared results across routes | Introduce a route/app-scoped owner deliberately; do not promote every controller globally |
| Persistent history | Add an explicit repository only when approved, including schema/privacy/retention work |
| Provider redundancy | Compose multiple provider adapters behind a policy object; record which provider/method produced a result |
| Speed-test throughput | Controlled infrastructure, concurrency/data budget, isolate only for demonstrated CPU-heavy aggregation—not ordinary async I/O |

The first likely bottleneck is external endpoint reliability and policy, not Flutter rendering. The second is unmanaged concurrent work during repeat/background/network changes. Adapter replaceability and operation scoping address both without premature distributed-system complexity.

## Confidence and Research Flags

| Area | Confidence | Reason / next validation |
|------|------------|--------------------------|
| Incremental Flutter layering | HIGH | Matches the existing code and official Flutter architecture guidance on views/view models, immutable data, DI, repositories/services, and testable boundaries |
| Adaptive shell | HIGH | Official Flutter examples switch navigation by available width; exact UX remains a design-contract decision |
| Lifecycle policy | HIGH | Flutter exposes app lifecycle observers/listeners, including `hidden`; device testing still required because callbacks are not a process-death guarantee |
| Cancellation architecture | HIGH | Dart stream cancellation/cleanup and `Future.timeout` semantics require resource-level cooperative cancellation |
| Partial-result and metrics model | HIGH | Pure domain design directly follows the product requirements and is independently testable |
| Connectivity/local IP/gateway adapters | MEDIUM | Boundary is clear, but plugin/native implementation and platform limits need phase research and Android verification |
| TCP/HTTPS probe implementation | MEDIUM | Interface and labeling are clear; target, timeout, captive-portal interpretation, and fallback policy remain product/technical decisions |
| Speed-test implementation | LOW until feasibility phase | Infrastructure, terms, cost, endpoint selection, data budget, and accuracy are deliberately unresolved |

## Sources

- [Flutter architecture guide](https://docs.flutter.dev/app-architecture/guide) — official guidance for UI/data separation, views, view models, repositories/services, immutable models, dependency injection, and testability. **HIGH confidence.**
- [Flutter adaptive and responsive design](https://docs.flutter.dev/ui/adaptive-responsive/general) — official guidance to adapt to available space and platform capabilities. **HIGH confidence.**
- [Flutter adaptive navigation example](https://github.com/flutter/website/blob/main/examples/ui/adaptive_app_demos/lib/main_app_scaffold.dart) — official example switching compact and wider navigation by window width. **HIGH confidence.**
- [Flutter `AppLifecycleListener` API](https://api.flutter.dev/flutter/widgets/AppLifecycleListener-class.html) and [lifecycle `hidden` migration](https://docs.flutter.dev/release/breaking-changes/add-applifecyclestate-hidden) — lifecycle observation and the complete current state set. **HIGH confidence.**
- [Dart `Future.timeout` API](https://api.dart.dev/dart-async/Future/timeout.html) — the source future can complete after the timeout result, so timeout alone is not resource cancellation. **HIGH confidence.**
- [Dart asynchronous streams](https://dart.dev/libraries/async/using-streams) and [creating streams](https://dart.dev/libraries/async/creating-streams) — subscription cancellation and `async*` cleanup behavior. **HIGH confidence.**
- [Flutter testing overview](https://docs.flutter.dev/testing/overview) — unit, widget, and integration test roles. **HIGH confidence.**

---
*Architecture research for: Tools App — internet diagnostics and UI evolution*
*Researched: 2026-08-10*
