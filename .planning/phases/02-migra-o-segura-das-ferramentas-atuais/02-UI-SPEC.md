# Phase 2 UI-SPEC — Adoption addendum

**Status:** inherits Phase 1 visual language (no new palette, type, spacing, or components)
**Source:** `.planning/phases/01-contrato-visual-e-funda-o-adaptativa/01-UI-SPEC.md` (approved 2026-08-10, UI checker 6/6)
**Gathered:** 2026-08-31

This is **not** a new visual language. Phase 2 adopts the existing contract on the three production screens.

## Canonical visual language

Downstream agents MUST treat `01-UI-SPEC.md` as the single source of truth for:

- color roles, canvas, accent-only green, elevation 0 cards, radius 4/8/12
- typography (sans for UI, monospace for technical values)
- spacing scale, content max-width, compact/medium/expanded breakpoints
- `ToolScaffold` anatomy: title → input → actions → result/metric → copy
- seven status variants (empty, loading, success, failure, offline, permissionDenied, cancelled) — use only those that already exist in each tool; do not invent diagnostic states
- accessibility: 48×48 targets, semantic labels, text scale 200%, pt-BR
- copy action: `Copiar {rótulo}` / `{Rótulo} copiado`

Do not introduce new tokens, packages, or custom chrome that contradicts Phase 1.

## Phase 2 owns (from 01-UI-SPEC)

- adotar `ToolScaffold`, seções, action group, result/metric/copy nas três telas, **uma por vez**
- substituir cores, radius, rows rígidas e copy local divergentes
- preservar integralmente rede IPv4, conversão e hashes com testes de regressão
- consolidar CTAs específicos sem mudar resultados:
  - Rede: `Calcular rede` (hoje: `Calcular`)
  - Armazenamento: `Analisar capacidade` (hoje: `Analisar Capacidade`)
  - Hash: `Gerar hashes` (hoje: `Calcular`)
- `Limpar` permanece onde já existe (Rede, Hash)

“Calcular” isolado **não** é permitido, inclusive durante a migração incremental.

## Phase 2 does not own

- new navigation architecture (shell already shipped)
- Diagnóstico de Internet
- new features on the three tools
- rewriting services/validators
- new goldens of full production screens unless the planner finds a cheap, stable fixture; foundation goldens stay in `test/design_system/goldens/`

## Checker Sign-Off

Visual dimensions were verified on the parent spec:

- Phase 1 UI-SPEC: 6/6 VERIFIED (2026-08-10)
- This addendum adds no new visual tokens to re-check

**Approval:** adopt `01-UI-SPEC.md` as-is for Phase 2 screen migration.

---

*Phase: 02-migra-o-segura-das-ferramentas-atuais*
*UI contract: adoption of Phase 1*
