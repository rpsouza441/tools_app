# Phase 3 UI-SPEC — Diagnostic screen addendum

**Status:** inherits Phase 1 visual language; adds Diagnóstico destination and diagnostic anatomy
**Source:** `01-UI-SPEC.md` (approved 2026-08-10, 6/6)
**Gathered:** 2026-08-31

Not a new palette. Use ToolScaffold, seven status variants, TechnicalValueRow/copy, 48×48, pt-BR, claro/escuro.

## Catalog (Phase 3 owns the insertion)

Initial catalog was rede → armazenamento → hash. Phase 3 **inserts** Diagnóstico de Internet.

Recommended order: `rede`, `armazenamento`, `hash`, `diagnostico` (label curta **Diagnóstico**, semanticLabel **Diagnóstico de Internet**). Four destinations: compact `NavigationBar` shows **all four** (overflow “Ferramentas” only at five+).

Do not add speed-test destination.

## Diagnostic anatomy

ToolScaffold title: Diagnóstico de Internet.

1. Ação primária: iniciar (um run por vez). Secundária: cancelar quando running. Depois de terminal: repetir.
2. Progresso por etapa sem apagar fatos já obtidos.
3. Facts independentes (cada um pode ser sucesso / indisponível / falha / cancelado):
   - transporte / INTERNET / validated / captive (quando a plataforma fornecer)
   - IPv4 local
   - gateway (rota default; nunca 192.168.1.1 inventado)
   - IPv4 público + provedor + horário
   - probe gateway (método real, alvo, porta, timeout)
   - probe externo (método real, URL/host, timeout)
4. Agregação de amostras: min / média / máx, tentativas, sucessos, falhas com denominador.
5. Resumo copiável/compartilhável da sessão atual.

Labels de método: **TCP connect**, **HTTPS**, nunca “ping” para TCP/HTTPS. ICMP: “Indisponível” no MVP.

Estados: empty (nenhum resultado ainda), loading (processando), success, failure, offline, cancelled. permissionDenied só se um fato local exigir permissão futura — não pedir `ACCESS_LOCAL_NETWORK` enquanto target SDK ≤ 36.

## Checker Sign-Off

Visual language inherited from Phase 1 (6/6). This addendum specifies catalog insertion and diagnostic information architecture only.

---

*Phase: 03-diagn-stico-de-internet-completo-e-resiliente*
