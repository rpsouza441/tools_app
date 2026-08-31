---
status: partial
phase: 01-contrato-visual-e-funda-o-adaptativa
source:
  - 01-VERIFICATION.md
  - 01-11-SUMMARY.md
started: "2026-08-31T17:20:00Z"
updated: "2026-08-31T17:31:00Z"
---

## Current Test

number: 1
name: TalkBack no Android
expected: |
  Com TalkBack ligado, percorrer o app real e o harness
  (`flutter run -t test/manual/design_system_app.dart`): navegação com
  semanticLabel, headings, campos, ações, sete estados, resultado/métrica,
  Copiar {rótulo} e exatamente um {Rótulo} copiado. Ordem compreensível,
  sem nós essenciais ausentes, sem duplicação.
awaiting: user response

## Tests

### 1. TalkBack no Android
expected: Percurso TalkBack real no app e no harness.
result: pending
why: Serviço assistivo Android. Não executado.

### 2. Copy no harness
expected: Clipboard real recebe abc123def456; confirmação só depois do write.
result: pass
reported: "abc123def456"
fix: `_NoopCopyWriter` → `ClipboardCopyWriter`. Reteste humano colou o valor exibido.

### 3. Calcular rede / Limpar na galeria
expected: Se forem samples de layout, não calculam.
result: pass (deliberado)
reported: Botões não fazem nada.
note: Galeria estática; callbacks vazios. 01-11 não exige calculadora no harness.

## Summary

total: 3
passed: 2
issues: 0
pending: 1
skipped: 0
blocked: 0

## Gaps
