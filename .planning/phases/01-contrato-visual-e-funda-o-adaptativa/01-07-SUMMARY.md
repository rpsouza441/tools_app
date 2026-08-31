---
phase: 01-contrato-visual-e-funda-o-adaptativa
plan: "07"
subsystem: ui
tags: [navigation, semanticLabel, tdd, gap-closure, material3]

requires:
  - phase: 01-contrato-visual-e-funda-o-adaptativa
    provides: AppShell Bar/Rail, catálogo tipado, IndexedStack
provides:
  - Overflow Ferramentas somente na NavigationBar compacta
  - Rail médio/expandido com catálogo completo, scrollable, sem Ferramentas
  - Labels curtas Rede/Armazenamento/Hash e semanticLabel consumido
  - appDestinations imutável e seleção por id em didUpdateWidget
affects: [01-08, 01-10, 01-11]

tech-stack:
  added: []
  patterns:
    - overflow só na Bar; rail mapeia o catálogo inteiro
    - seleção por AppDestination.id, não por índice visual
    - tooltip=semanticLabel na Bar; Icon.semanticLabel + Tooltip no rail recolhido

key-files:
  created: []
  modified:
    - lib/app/app_destinations.dart
    - lib/app/app_shell.dart
    - test/app/app_shell_test.dart
    - test/app/destination_catalog_test.dart

key-decisions:
  - "Overflow D-03 (3 pins + Ferramentas) aplica-se somente à NavigationBar compacta; medium 600–839 e expanded >=840 listam todos os destinos na ordem do catálogo, com scrollable: true."
  - "Labels visíveis do catálogo são Rede / Armazenamento / Hash; semanticLabel completo vai para tooltip da Bar e para tooltip/semantics do rail recolhido, sem Semantics extra duplicado."
  - "appDestinations é List.unmodifiable; o shell guarda _selectedId e reconcilia páginas por id em didUpdateWidget."

patterns-established:
  - "Handlers de Bar e Rail separados: Bar usa índice visual (overflow); Rail usa índice real do catálogo."
  - "No rail recolhido, Tooltip(excludeFromSemantics) no ícone + Icon.semanticLabel evita nós duplicados; o label visível permanece curto."

requirements-completed: [UI-01, UI-02, UI-06, UI-08]

duration: 12min
completed: 2026-08-31
---

# Phase 1 Plan 07: Navegação adaptativa e semântica Summary

**Catálogo imutável com labels curtas Rede/Armazenamento/Hash, overflow só na NavigationBar compacta, rail completo e semanticLabel consumido em tooltip/semantics.**

## Performance

- **Duration:** 12 min
- **Started:** 2026-08-31T15:33:41Z
- **Completed:** 2026-08-31T15:45:00Z
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments

- Fechou o gap A / CR-01: com 5 destinos, compacta <600 mostra 3 prioridades + Ferramentas; medium e expanded listam os 5 na ordem do catálogo, sem Ferramentas.
- Fechou CR-02: `semanticLabel` chega a `NavigationDestination.tooltip` e ao rail recolhido (tooltip + semantics), sem Tooltip+Semantics empilhados com o mesmo rótulo.
- Fechou WR-03: `List.unmodifiable`, seleção por id estável, reconciliação de páginas, fallback se o id desaparecer, IndexedStack sem índice inválido.
- Títulos das screens de produção intactos (`Calculadora de Rede` na AppBar); nenhuma tela migrada para primitives.

## TDD: evidência RED (Task 1 contra HEAD)

A suíte `flutter test --no-pub test/app/destination_catalog_test.dart test/app/app_shell_test.dart` falhou com `LASTEXITCODE=1` **antes** de qualquer implementação. Falhas observadas (14), pelos gaps certos — não por erro de compile/fixture:

| Teste | Por que falhou (HEAD) |
|-------|------------------------|
| `labels are the short pt-BR catalog names` | Actual `['Calculadora de Rede', 'Conversor de Dados', 'Gerador de Hash']` em vez de `['Rede', 'Armazenamento', 'Hash']` |
| `appDestinations rejects mutation` | `add` não lançou `UnsupportedError` (lista mutável) |
| `at 360x800: NavigationBar present, network calc works, state preserved` | `tap(find.text('Armazenamento'))` — 0 widgets (labels ainda longas) |
| `production compact bar uses short labels and full semantic tooltips` | `find.text('Rede')` — 0 widgets |
| `600px + 5 destinations lists all catalog items on a collapsed rail` | `Ferramentas` presente no rail (`_useOverflow` também no rail) |
| `839px + 5 destinations lists all catalog items on a collapsed rail` | Idem: overflow no rail |
| `840px + 5 destinations lists all catalog items on an extended rail` | Idem: overflow no rail |
| `compact bar exposes semanticLabel as tooltip on pinned destinations` | `tooltip` nulo; `semanticLabel` não fluía |
| `collapsed rail tooltip and semantics expose semanticLabel once` | Sem Tooltip/`semanticLabel` no rail |
| `production collapsed rail announces full names without Ferramentas` | Labels longas no rail; semanticLabel morto |
| `reordering destinations keeps the selected id` | Seleção por índice visual, não por id |
| `removing the selected destination falls back to the first remaining id` | `NavigationBar`: `'0 <= selectedIndex && selectedIndex < destinations.length'` false (`app_shell.dart` LayoutBuilder) |
| `resize from compact unpinned selection to 600 keeps catalog id on the rail` | `Ferramentas` ainda no rail após resize |
| `resize from compact unpinned selection to 840 keeps catalog id on the rail` | `selectedIndex` actual `3` (índice visual Ferramentas) em vez de `4` (id real Prio5) |

Commit RED: `c0bf348`.

## TDD: GREEN (Task 2)

Implementação mínima que tornou a suíte verde (33 testes) e `flutter analyze --no-pub` limpo nos arquivos do plano.

Commit GREEN: `7d52fa6`.

## TDD Gate Compliance

- RED: `test(01-07): add failing tests for adaptive nav gap` — `c0bf348` (testes falharam antes da implementação).
- GREEN: `feat(01-07): implement adaptive rail catalog and semanticLabel` — `7d52fa6`.
- REFACTOR: não necessário.

## Task Commits

Each task was committed atomically:

1. **Task 1: Escrever testes que falham contra o overflow no rail, labels longas e semanticLabel morto** - `c0bf348` (test)
2. **Task 2: Corrigir catálogo imutável e shell** - `7d52fa6` (feat)

**Plan metadata:** (commit de close-out após este SUMMARY)

## Files Created/Modified

- `lib/app/app_destinations.dart` — labels curtas; semanticLabels completos; `List.unmodifiable`; ids inalterados
- `lib/app/app_shell.dart` — overflow só na Bar; rail completo `scrollable: true`; `_selectedId`; reconciliação por id; consumo de `semanticLabel`
- `test/app/destination_catalog_test.dart` — contrato de labels curtas, semanticLabels e imutabilidade
- `test/app/app_shell_test.dart` — 599/600/839/840 × 5 destinos, semantics/tooltip, didUpdateWidget, happy path com labels curtas

## Decisions Made

- Overflow D-03 não é reutilizado no rail: Bar e Rail têm handlers e índices separados.
- No rail recolhido, Tooltip no ícone com `excludeFromSemantics: true` e `Icon.semanticLabel` para o nome completo uma vez; label visível continua curto.
- Material 3 anuncia destino + índice de tab; os testes de semantics usam `RegExp` para inspecionar a árvore sem exigir match exato isolado do rótulo de tab.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Semantics do rail não era encontrada por label exato**
- **Found during:** Task 2 (GREEN)
- **Issue:** `find.bySemanticsLabel('Prioridade 1')` retornava 0 porque o `NavigationRail` funde o rótulo do destino com o índice de tab. `Text.semanticsLabel` no label escondido (`SizedBox.shrink`) também não fluía.
- **Fix:** `Icon.semanticLabel` no rail recolhido; Tooltip com `excludeFromSemantics: true`; testes passam a usar `RegExp` na árvore semântica.
- **Files modified:** `lib/app/app_shell.dart`, `test/app/app_shell_test.dart`
- **Verification:** suíte 33/33 verde
- **Committed in:** `7d52fa6` (Task 2)

**2. [Rule 3 - Blocking] SemanticsHandle vazava no fim do teste**
- **Found during:** Task 2
- **Issue:** `addTearDown(handle.dispose)` rodava depois da verificação do tester; o teste compacto falhava com “A SemanticsHandle was active at the end of the test”.
- **Fix:** remover `ensureSemantics` do teste da Bar (só tooltip); `try/finally { handle.dispose(); }` nos testes de rail.
- **Files modified:** `test/app/app_shell_test.dart`
- **Verification:** analyzer limpo; testes de semantics passam
- **Committed in:** `7d52fa6` (Task 2)

---

**Total deviations:** 2 auto-fixed (1 bug, 1 blocking)
**Impact on plan:** Ajustes necessários para inspecionar a árvore semântica real do Material 3 e para o analyzer/teste ficarem limpos. Sem scope creep.

## Issues Encountered

None beyond the auto-fixes above. O happy path e o AppBar da calculadora continuam `Calculadora de Rede`.

## Authentication Gates

None.

## Known Stubs

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Gap A / CR-01 / CR-02 / WR-03 fechados em código e testes.
- Pronto para 01-08 (tema canônico e sete estados). Phase 1 permanece incompleta (01-08..01-11 pendentes).
- Gate TalkBack real continua 01-11; estes testes de widget não substituem o dispositivo.

---
*Phase: 01-contrato-visual-e-funda-o-adaptativa*
*Completed: 2026-08-31*

## Self-Check: PASSED

- `lib/app/app_destinations.dart` FOUND
- `lib/app/app_shell.dart` FOUND
- `test/app/app_shell_test.dart` FOUND
- `test/app/destination_catalog_test.dart` FOUND
- `01-07-SUMMARY.md` FOUND
- Commit `c0bf348` FOUND
- Commit `7d52fa6` FOUND
