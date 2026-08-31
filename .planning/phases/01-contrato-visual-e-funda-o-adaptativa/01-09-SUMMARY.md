---
phase: 01-contrato-visual-e-funda-o-adaptativa
plan: "09"
subsystem: ui
tags: [CopyValueAction, TechnicalValueRow, copyWriter, lifecycle, SnackBar, tdd, gap-closure]

requires:
  - phase: 01-contrato-visual-e-funda-o-adaptativa
    provides: CopyValueAction StatelessWidget com hideCurrentSnackBar; TechnicalValueRow.onCopy morto
provides:
  - CopyValueAction StatefulWidget com ScaffoldFeatureController próprio e guarda mounted após await
  - TechnicalValueRow.copyWriter realmente passado a CopyValueAction e exercitado
  - Testes de dispose silencioso, SnackBar alheio preservado e writer da row com valor exato
affects: [01-10, 01-11]

tech-stack:
  added: []
  patterns:
    - Capturar BuildContext (Element) antes do await; if (!context.mounted) return
    - Fechar só o ScaffoldFeatureController da cópia; nunca hideCurrentSnackBar
    - TechnicalValueRow.copyWriter injetável; CopyValueAction(writer: copyWriter)

key-files:
  created:
    - test/design_system/copy_lifecycle_test.dart
  modified:
    - lib/design_system/copy_value_action.dart
    - lib/design_system/tool_sections.dart
    - test/design_system/tool_components_test.dart

key-decisions:
  - "Capturar BuildContext antes do await para que context.mounted seja Element.mounted — State.context lança após unmount."
  - "SnackBar de cópia fecha só o ScaffoldFeatureController próprio; SnackBars alheios permanecem."
  - "TechnicalValueRow expõe copyWriter (não onCopy) e passa writer: copyWriter para CopyValueAction."

patterns-established:
  - "CopyValueAction é StatefulWidget; feedback pós-await só se context.mounted."
  - "Tooltip Copiar {rótulo} + Icon.semanticLabel; SnackBar de sucesso {Rótulo} copiado; falha com texto de cópia manual."

requirements-completed: [UI-06, UI-09]

duration: 6min
completed: 2026-08-31
---

# Phase 1 Plan 09: Copy lifecycle e TechnicalValueRow.copyWriter Summary

**CopyValueAction stateful com controller próprio (sem hideCurrentSnackBar), guarda mounted após await, e TechnicalValueRow.copyWriter de fato passado ao writer e exercitado no teste.**

## Performance

- **Duration:** 6 min
- **Started:** 2026-08-31T15:57:41Z
- **Completed:** 2026-08-31T16:03:15Z
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments

- Fechou o gap D / CR-03 / D-13 / UI-09: após `await writer.write`, a ação só toca SnackBar se `context.mounted`; fecha somente o `ScaffoldFeatureController` próprio.
- Fechou WR-02: `TechnicalValueRow.copyWriter` substitui `onCopy` morto e é passado como `writer:` para `CopyValueAction`.
- Confirmação acessível: tooltip/semantics `Copiar {rótulo}`; sucesso `{Rótulo} copiado`; falha `Não foi possível copiar. Selecione o valor e copie manualmente.`

## TDD: evidência RED (Task 1 contra HEAD)

`flutter test --no-pub test/design_system/copy_lifecycle_test.dart` falhou com `LASTEXITCODE=1` **antes** de qualquer implementação. Falha de **compile** contra a API alvo `copyWriter` (produção ainda tinha `onCopy`):

```
test/design_system/copy_lifecycle_test.dart:123:15: Error: No named parameter with the name 'copyWriter'.
              copyWriter: writer,
              ^^^^^^^^^^
lib/design_system/tool_sections.dart:141:9: Context: Found this candidate, but the arguments don't match.
  const TechnicalValueRow({
```

O arquivo de teste já continha (contra o HEAD) os três gaps: dispose-before-complete, SnackBar alheio `Aviso não relacionado`, e `RecordingCopyWriter` via `TechnicalValueRow.copyWriter` com valor exato `192.168.1.1`.

Commit RED: `1ca8d71`.

## TDD: GREEN (Task 2)

`CopyValueAction` virou `StatefulWidget`; `if (!context.mounted) return` após cada await; `_copySnackBar?.close()` só no controller próprio; `copyWriter` ligado. Suíte **52 testes, todos passaram** (`copy_lifecycle_test.dart` + `tool_components_test.dart`); `flutter analyze --no-pub` limpo. `hideCurrentSnackBar` ausente em `copy_value_action.dart`. `rg hideCurrentSnackBar lib/design_system/copy_value_action.dart` — sem matches.

Commit GREEN: `ef8c0b7`.

## TDD Gate Compliance

- RED: `test(01-09): add failing tests for copy lifecycle and copyWriter` — `1ca8d71` (compile falhou antes da implementação).
- GREEN: `feat(01-09): make copy lifecycle safe and wire TechnicalValueRow.copyWriter` — `ef8c0b7`.
- REFACTOR: não necessário.

## Task Commits

Each task was committed atomically:

1. **Task 1: Escrever testes de dispose, SnackBar alheio e writer realmente chamado** - `1ca8d71` (test)
2. **Task 2: Tornar CopyValueAction seguro e ligar copyWriter em TechnicalValueRow** - `ef8c0b7` (feat)

**Plan metadata:** (commit de close-out após este SUMMARY)

## Files Created/Modified

- `test/design_system/copy_lifecycle_test.dart` — CompleterCopyWriter, RecordingCopyWriter; dispose, SnackBar alheio, writer da row, tooltip/semantics, falha
- `lib/design_system/copy_value_action.dart` — StatefulWidget, controller próprio, mounted, semanticLabel
- `lib/design_system/tool_sections.dart` — `copyWriter` conectado a `CopyValueAction(writer:)`
- `test/design_system/tool_components_test.dart` — call sites `onCopy:` → `copyWriter:`

## Decisions Made

- Capturar `BuildContext` (Element) antes do await para que `context.mounted` não passe por `State.context` após unmount.
- Ownership do SnackBar: `close()` no controller da cópia; nunca `hideCurrentSnackBar`.
- API pública da row é `CopyValueWriter? copyWriter`, pronta para a galeria do 01-10.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] State.context após unmount lança antes do guarda**
- **Found during:** Task 2 (GREEN)
- **Issue:** `if (!context.mounted)` via getter `State.context` lança `This widget has been unmounted` em debug; o guarda nunca rodava.
- **Fix:** Capturar `final context = this.context` antes do await e usar `context.mounted` no Element; passar esse context para `showSnackBar`.
- **Files modified:** `lib/design_system/copy_value_action.dart`
- **Verification:** teste de dispose silencioso passou; 52 testes verdes.
- **Committed in:** `ef8c0b7` (Task 2)

**2. [Rule 2 - Missing Critical] Semantic label não estava no campo label**
- **Found during:** Task 2 (GREEN)
- **Issue:** Tooltip do Material preenche `Semantics.tooltip`, não `label`; `find.bySemanticsLabel('Copiar endereço de rede')` achava 0 widgets. UI-06 exige semantic label `Copiar {rótulo}`.
- **Fix:** `Icon(Icons.copy, semanticLabel: 'Copiar ${widget.label}')` além do tooltip do `IconButton`.
- **Files modified:** `lib/design_system/copy_value_action.dart`, `test/design_system/copy_lifecycle_test.dart`
- **Verification:** `bySemanticsLabel` + tooltip + SnackBar `Endereço de rede copiado` passam.
- **Committed in:** `ef8c0b7` (Task 2)

---

**Total deviations:** 2 auto-fixed (1 bug, 1 missing critical)
**Impact on plan:** Necessários para o guarda de lifecycle e para UI-06. Sem creep; galeria/goldens/telas intocados.

## Issues Encountered

None.

## Authentication Gates

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Gap D / CR-03 / WR-02 fechados; contrato `copyWriter` pronto para a galeria do 01-10 (fake/no-op).
- Phase 1 permanece incompleta: 01-10 (galeria/goldens) e 01-11 ainda pendentes. Não regenerar goldens neste plano. PRES-* não implementados.

## Known Stubs

None — writer injetável; sem placeholder de cópia.

## Self-Check: PASSED

- `test/design_system/copy_lifecycle_test.dart` FOUND
- `lib/design_system/copy_value_action.dart` FOUND
- `lib/design_system/tool_sections.dart` FOUND
- `test/design_system/tool_components_test.dart` FOUND
- commit `1ca8d71` FOUND
- commit `ef8c0b7` FOUND
- `hideCurrentSnackBar` ABSENT em `copy_value_action.dart`
- `VoidCallback? onCopy` ABSENT em `TechnicalValueRow`

---
*Phase: 01-contrato-visual-e-funda-o-adaptativa*
*Completed: 2026-08-31*
