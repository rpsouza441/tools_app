---
status: partial
phase: 01-contrato-visual-e-funda-o-adaptativa
source:
  - 01-VERIFICATION.md
  - 01-11-SUMMARY.md
started: "2026-08-31T17:20:00Z"
updated: "2026-08-31T17:35:00Z"
---

## Current Test

number: 2
name: Copy no harness após correção do writer
expected: |
  No harness Android, tocar em copiar Hash SHA-256 grava abc123def456
  no clipboard real e só então mostra "Hash SHA-256 copiado".
awaiting: user retest

## Tests

### 1. TalkBack no Android
expected: Percurso TalkBack real no app e no harness.
result: pending
why: Serviço assistivo Android. Não executado.

### 2. Copy no harness
expected: Clipboard real recebe abc123def456; confirmação só depois do write.
result: issue
reported: "aparece a confirmação de que foi copiado; porém o valor NÃO é colocado no clipboard real."
fix: Galeria usava `_NoopCopyWriter` (01-10). Trocado para `ClipboardCopyWriter`. 01-11 permanece não aprovado até reteste humano.

### 3. Calcular rede / Limpar na galeria
expected: Se forem samples de layout, não calculam.
result: pass (deliberado)
reported: Botões não fazem nada.
note: Galeria estática; callbacks vazios. 01-11 não exige calculadora no harness.

## Summary

total: 3
passed: 1
issues: 1
pending: 1
skipped: 0
blocked: 0

## Gaps
