---
status: partial
phase: 02-migra-o-segura-das-ferramentas-atuais
source:
  - 02-VERIFICATION.md
started: "2026-08-31T19:25:00Z"
updated: "2026-08-31T19:25:00Z"
---

## Current Test

number: 1
name: Densidade visual das três telas de produção
expected: |
  Hierarquia ToolScaffold alinhada ao UI-SPEC: título sem AppBar interno,
  seções de entrada/ação/resultado, CTAs Calcular rede / Analisar capacidade /
  Gerar hashes, cards sem chrome antigo empilhado, hashes longos legíveis.
awaiting: user response

## Tests

### 1. Densidade visual das três telas de produção
expected: Abrir Rede, Armazenamento e Hash no app de produção em compacto e largo, claro e escuro. Densidade/hierarquia alinhadas ao 01-UI-SPEC após o wrap.
result: pending

### 2. TalkBack das telas migradas
expected: Percorrer título, campos, CTA e Copiar. TalkBack anuncia Calculadora de Rede / Conversor de Armazenamento / Gerador de Hash, campos, CTAs novos e Copiar {rótulo}. Não repetir o gate TalkBack do shell/galeria da Fase 1.
result: pending

## Summary

total: 2
passed: 0
issues: 0
pending: 2
skipped: 0
blocked: 0

## Gaps
