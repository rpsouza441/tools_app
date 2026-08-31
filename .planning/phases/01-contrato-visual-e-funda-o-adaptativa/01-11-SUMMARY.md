---
phase: 01-contrato-visual-e-funda-o-adaptativa
plan: "11"
subsystem: testing
tags: [human-verify, android, goldens, talkback, gap-closure]
status: complete

requires:
  - phase: 01-contrato-visual-e-funda-o-adaptativa
    provides: Fundação 01-06..01-10 (shell, tema, estados, copy, galeria, goldens)
provides:
  - Aprovação humana visual representativa (compacta Android + harness claro/escuro + viewport larga)
  - Cruzamento dos sete checks com evidência humana + testes + goldens + código
  - Correção de headings de status para onSurface (accent/error só no ícone)
  - Gate humano fechado: visual + copy + TalkBack no emulador Android (`approved`)
affects: [phase-1-verification]

tech-stack:
  added: []
  patterns:
    - Inspeção visual representativa + testes de boundary não exigem matriz de screenshots por breakpoint
    - TalkBack real não é substituível por widget tests; fechado só com `approved` humano após percurso no emulador

key-files:
  created:
    - .planning/phases/01-contrato-visual-e-funda-o-adaptativa/01-11-SUMMARY.md
  modified:
    - lib/design_system/tool_status_panel.dart
    - test/design_system/tool_components_test.dart
    - test/design_system/goldens/shell_medium_light.png

key-decisions:
  - "Usuário APPROVED evidência visual representativa; não exigir screenshots 599/600/720/839/840/1024."
  - "Boundaries de shell, 5 destinos, semantics, reflow e 200% usam testes automatizados existentes."
  - "UI-SPEC: accent apenas no ícone (success) e error role no ícone (permissionDenied); headings passam a onSurface."
  - "TalkBack no emulador Android: foco, labels de campos, interação, Máscara inválida acessível, galeria percorrível, sem nós essenciais ausentes nem duplicações problemáticas. Usuário respondeu approved."

patterns-established:
  - "Headings de ToolStatusPanel usam onSurface; ícone/progress carregam primary/error/onSurface."

requirements-completed: []

duration: 40min
completed: 2026-08-31
---

# Phase 1 Plan 11: Gate humano — `approved`

**Checks 1–7 fechados com evidência humana + testes. TalkBack no emulador Android aprovado pelo usuário. Phase 1 ainda depende da re-verificação oficial (não Complete por este SUMMARY sozinho).**

## Performance

- **Duration:** ~40 min (cruzamento + correção de headings + re-preflight)
- **Started:** 2026-08-31T16:16:00Z
- **Completed:** 2026-08-31T17:40:00Z
- **Tasks:** 1 checkpoint humano (`approved`)
- **Files modified:** 3 (correção de headings + golden medium)

## Accomplishments

- Cruzou os sete checks do 01-11 com evidência humana APPROVED, testes automatizados, goldens canônicos e código.
- Corrigiu headings `Concluído` / `Não foi possível concluir` / `Permissão necessária` para `onSurface` (UI-SPEC: accent/error no ícone).
- Falha humana: copy no harness mostrava confirmação sem clipboard (`_NoopCopyWriter`). Corrigido para `ClipboardCopyWriter`. Reteste humano colou `abc123def456`.
- TalkBack no emulador Android: usuário respondeu `approved` (foco, labels, campos, erro, galeria percorrível, sem nós essenciais ausentes nem duplicações problemáticas).
- Não aplicou waiver. Não iniciou Phase 2.

## Check results

| Check | Status | Evidência |
|-------|--------|-----------|
| 1 Larguras | PASS (cruzado) | Humano: Android compacta, 3 destinos, Bar, sem clipping. Automatizado: 599 Bar, 600/839 rail recolhido, 840 rail extended, 5 destinos, Ferramentas só na Bar. Chrome largo: inspeção complementar de max-width, não substitui 600/840. |
| 2 Preservação | PASS (automatizado) | `IndexedStack preserves page state on navigation/resize`; happy path calcula rede e preserva. Sem repetição manual. |
| 3 Temas | PASS (cruzado) | Humano: app real claro + harness escuro APPROVED (corpo neutro, verde só no acento, cards com borda). Automatizado: `theme_contract_test.dart` hex/elevation/radius. |
| 4 Texto 200% | PASS (automatizado) | `accessibility_test` 360/720/1024 × 1.0/2.0 em widgets públicos; `tool_metric_reflow_test` 360 + scaler 2.0. Sem gap visual nas evidências. |
| 5 TalkBack | PASS (humano) | Emulador Android. Foco TalkBack; campos e rótulos anunciados; interação com campos; “Máscara inválida” acessível; ações/galeria percorríveis; sem nós essenciais ausentes nem duplicações problemáticas. Copy já retestado (`abc123def456`). `approved`. |
| 6 Anúncios/targets (exceto TalkBack) | PASS (reteste humano) | Falha `_NoopCopyWriter` corrigida. Usuário colou `abc123def456` do clipboard. `Calcular rede`/`Limpar` permanecem samples. |
| 7 Goldens | PASS (cruzado) | Quatro PNGs em `test/design_system/goldens/`. Aprovação humana da direção visual nesta sessão. `shell_medium_light.png` regenerado só após correção dos headings. `test/goldens/` ausente. |

## Heading color gap

UI-SPEC State Contract: success **“accent apenas no ícone”**; permissionDenied **“error role no ícone”**. Failure usa **error role** no ícone (testes 01-08). Headings estavam com `copyWith(color: iconColor)`.

- RED: success/failure/permissionDenied heading ≠ `onSurface` (primary `#006D2C` / error `#BA1A1A` no claro).
- GREEN: heading `onSurface`; ícone inalterado.
- Golden: só `shell_medium_light.png` divergiu (0.54%); primitives compactos não mostravam esses headings (abaixo da dobra).

## TalkBack / waiver

TalkBack no emulador Android foi executado e o usuário respondeu `approved`. Override **não aplicado** (não era necessário). GSD `overrides:` **não suprime `human_needed`** e não foi usado para fechar o gate.

## Preflight

- `flutter analyze --no-pub` — No issues found
- `dart format --output=none --set-exit-if-changed` — 0 changed
- `flutter test --no-pub` — 162/162
- Goldens — 4/4 em `test/design_system/goldens/`

## Self-Check

- Requirements: 01-11 não marca UI-01..UI-09 complete em REQUIREMENTS.md
- Key links: harness → galeria; main → AppShell
- Threat model: T-01-G11-01 (sem autoaprovação de TalkBack); T-01-G11-03 (correção de headings autorizada pelo usuário após o checkpoint)
- 80/20: 01-11 fechado com `approved`; Phase 1 só Complete após verifier `passed`
- Phase 2 não iniciada. PRES-* não implementados.
