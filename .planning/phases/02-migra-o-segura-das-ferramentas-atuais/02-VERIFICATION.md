---
phase: 02-migra-o-segura-das-ferramentas-atuais
verified: 2026-08-31T19:50:00Z
status: passed
score: 13/13 must-haves verified
overrides_applied: 0
re_verification:
  previous_status: human_needed
  previous_score: 13/13
  gaps_closed:
    - "Densidade visual das três telas de produção (Rede, Armazenamento, Hash) em compacto/largo e claro/escuro"
    - "TalkBack das telas migradas (títulos, campos, CTAs e Copiar)"
  gaps_remaining: []
  regressions: []
---

# Phase 2: Migração segura das ferramentas atuais — Verification Report

**Phase Goal:** Usuários continuam resolvendo as mesmas tarefas nas três ferramentas existentes depois da migração para a nova fundação visual.
**Verified:** 2026-08-31T19:50:00Z
**Status:** passed
**Re-verification:** Yes — after gap closure (HUMAN-UAT `status: complete`, 2/2 pass)
**Mode:** mvp

User-story form (from 02-*-PLAN.md; ROADMAP goal is the locked outcome clause):

> As a profissional ou estudante de TI, I want to continuar resolvendo as mesmas tarefas nas três ferramentas existentes depois da migração para a nova fundação visual, so that eu não perco cálculos IPv4, conversão de armazenamento nem hashes.

## User Flow Coverage

| Step | Expected | Evidence | Status |
|------|----------|----------|--------|
| Abrir o app | Navegação Rede / Armazenamento / Hash no `App()` de produção | `lib/app/app_destinations.dart` pageBuilders → as três telas; `test/screen/tools_preservation_test.dart` bomba `const App()` e navega os três destinos | ✓ |
| Calcular rede | 192.168.1.10 /24 mostra Endereço de Rede 192.168.1.0 (não blob concatenado) | `NetworkCalculatorScreen._calculate` chama `NetworkCalculator`; `test/screen/network_calculator_screen_test.dart` e happy path de `test/app/app_shell_test.dart` | ✓ |
| Analisar capacidade | 1 TB mostra advertised/real/diferença com `NumberFormat('#,##0.000', 'pt_BR')` | `DataConverterScreen` chama `DataConverter.analyze` e formata na UI; `test/screen/data_converter_screen_test.dart` | ✓ |
| Gerar hashes | `abc` mostra MD5, SHA-1, SHA-256 e SHA-512 conhecidos | `HashGeneratorScreen` chama só `HashCalculator.calculate`; widget + `test/hash_calculator_test.dart` | ✓ |
| Copiar resultado | Payload é o valor (ex. `192.168.1.0`, digest), via `CopyValueAction` | FakeCopyWriter nos três `*_screen_test.dart`; `Clipboard.setData` só em `ClipboardCopyWriter` | ✓ |
| Densidade visual | Hierarquia ToolScaffold legível em compacto/largo e claro/escuro | `02-HUMAN-UAT.md` teste 1 `result: pass` após `approved` | ✓ |
| TalkBack | Títulos, campos, CTAs e Copiar anunciados nas três telas | `02-HUMAN-UAT.md` teste 2 `result: pass` após `approved` | ✓ |
| Outcome | Continuar as mesmas três tarefas sem perder IPv4, conversão nem hashes | SCs 1–4 + PRES-01..04 abaixo + UAT humano 2/2 | ✓ |

## Goal Achievement

### Observable Truths

Must-haves = 4 success criteria do ROADMAP + verdades específicas dos PLANs que não restatem o contrato. Verdades *wave-scoped* (ex. “não migrar telas neste plano”, “Hash ainda não migrado”) não entram no score da fase: foram restrições de incremento e o estado final as substitui.

Regressão desta re-verificação: existência + sanity das 13 verdades no código vivo; analyze e suíte completa reexecutados. Nenhum UNCERTAIN copiado do relatório anterior.

| # | Truth | Status | Evidence |
| --- | ------- | ---------- | -------------- |
| 1 | Usuário calcula redes IPv4 e obtém os mesmos resultados válidos de antes da migração. | ✓ VERIFIED | Serviço: `test/network_calculator_test.dart` 192.168.1.10 cidr 24 → rede `192.168.1.0`. UI: `network_calculator_screen.dart` chama `NetworkCalculator` e renderiza `TechnicalValueRow`/`ToolMetric`. Widget + AppShell happy path encontram `192.168.1.0`. |
| 2 | Usuário converte armazenamento decimal e binário e obtém os mesmos resultados válidos de antes da migração. | ✓ VERIFIED | `DataConverter.analyze` na tela; UI formata com `NumberFormat('#,##0.000', 'pt_BR')`. Widget test compara advertised/real/diferença formatados para 1 TB. |
| 3 | Usuário gera hashes MD5, SHA-1, SHA-256 e SHA-512 e obtém os mesmos resultados válidos de antes da migração. | ✓ VERIFIED | `HashCalculator.calculate('abc')` oracles em `test/hash_calculator_test.dart`. Widget test mostra MD5/SHA-1/SHA-256 inteiros e SHA-512 via prefixo + resto (`SelectableText` wrapping). |
| 4 | Usuário encontra entradas, ações, resultados e cópia das três ferramentas disponíveis durante e depois da migração incremental, sem perda de funcionalidade. | ✓ VERIFIED | `tools_preservation_test.dart` via `const App()`: campos, CTAs migrados e aviso MD5. Cópia injetável nas três telas. Destinos de produção inalterados em `app_destinations.dart` (Rede / Armazenamento / Hash). Sem Diagnóstico. |
| 5 | Testes que montam `appDestinations` passam `lightTheme`/`AppTokens` antes de ToolScaffold. | ✓ VERIFIED | Quatro pumps de produção em `app_shell_test.dart` usam `theme: lightTheme`. Happy path usa `const App()`. `wrapScreen` injeta `lightTheme`. |
| 6 | CTA da Calculadora de Rede é Calcular rede; Limpar é secondary; nunca pinta Cancelar. | ✓ VERIFIED | `ToolActionGroup(primary: ElevatedButton(... 'Calcular rede'), secondary: TextButton(... 'Limpar'))`. Sem `onCancel`. |
| 7 | Rede não tem Scaffold/AppBar internos; título Calculadora de Rede vive no ToolScaffold. | ✓ VERIFIED | `build` retorna `ToolScaffold(title: 'Calculadora de Rede', ...)`. `ToolScaffold` usa `Semantics(header: true)` + `SafeArea`, não `AppBar`. Widget: `find.byType(AppBar)` nothing. |
| 8 | CTA é Analisar capacidade (sentence case); Analisar Capacidade desaparece. | ✓ VERIFIED | `Text('Analisar capacidade')` em `data_converter_screen.dart`. Grep `Analisar Capacidade` em `lib/screen` = 0. |
| 9 | A diferença usa `colorScheme.error`, nunca `Colors.red`; não há spinner-only no botão. | ✓ VERIFIED | Span “Diferença "perdida"” usa `Theme.of(context).colorScheme.error`. Grep `Colors.red`, `CircularProgressIndicator` em `lib/screen` = 0. |
| 10 | A cópia educativa “Por que a capacidade parece menor?” e 931 GiB permanece. | ✓ VERIFIED | `_buildExplanationCard` sempre no `ToolScaffold`. Widget test encontra o título e `textContaining('931 GiB')`. |
| 11 | CTA é Gerar hashes; Limpar permanece secondary; Calcular isolado some de `lib/screen`. | ✓ VERIFIED | Hash: `Text('Gerar hashes')` + `Limpar`. Grep `Text('Calcular')` em `lib/screen` = 0. Amostra `Calcular` permanece só em `test/design_system/tool_components_test.dart`. |
| 12 | Copiar usa `TechnicalValueRow.copyWriter` / `CopyValueAction`; payload = valor; sem `Clipboard.setData` em `lib/screen`. | ✓ VERIFIED | Três telas passam `_copyWriter`. `Clipboard.setData` só em `lib/design_system/copy_value_action.dart`. Widget tests: Rede copia `192.168.1.0`; Hash copia MD5 de `abc`. |
| 13 | Aviso “MD5 e SHA-1 servem para conferência, não para proteger senhas.” permanece no input. | ✓ VERIFIED | Texto no `ToolInputSection` de `hash_generator_screen.dart`. Preservação + widget tests encontram a string. |

**Score:** 13/13 truths verified

Wave-scoped (não pontuados): 02-01 “nenhuma tela de produção muda neste plano”, 02-02 “Armazenamento/Hash com chrome ainda não migrado”, 02-03 “Hash ainda não migrado”. No estado final da fase as três telas estão migradas e utilizáveis — isso cumpre PRES-04, não contradiz o goal.

### Required Artifacts

Verificação manual L1–L3 no código vivo (re-verificação de itens já passados: existência + sanity):

| Artifact | Expected | Status | Details |
| -------- | ----------- | ------ | ------- |
| `test/screen/screen_test_harness.dart` | `wrapScreen` + `FakeCopyWriter` | ✓ VERIFIED | Existe, substancial, usado por todos os testes de tela |
| `test/screen/tools_preservation_test.dart` | Fumaça PRES-04 via `const App()` | ✓ VERIFIED | Navega Rede / Armazenamento / Hash com CTAs atuais |
| `test/app/app_shell_test.dart` | Pumps com `lightTheme`; happy path Calcular rede | ✓ VERIFIED | 4 pumps de `appDestinations` + `192.168.1.0` |
| `lib/screen/network_calculator_screen.dart` | ToolScaffold + TechnicalValueRow + Calcular rede | ✓ VERIFIED | Wired em `app_destinations.dart` |
| `test/screen/network_calculator_screen_test.dart` | Happy path, erros, cópia | ✓ VERIFIED | Inclui FakeCopyWriter |
| `lib/screen/data_converter_screen.dart` | ToolScaffold + Analisar capacidade | ✓ VERIFIED | Wired; `NumberFormat` + `DataConverter.analyze` |
| `test/screen/data_converter_screen_test.dart` | Happy path TB, erros, copy educativa | ✓ VERIFIED | |
| `lib/screen/hash_generator_screen.dart` | ToolScaffold + Gerar hashes + copyWriter | ✓ VERIFIED | Wired; só `HashCalculator.calculate` |
| `test/screen/hash_generator_screen_test.dart` | Digests abc + FakeCopyWriter | ✓ VERIFIED | |

### Key Link Verification

| From | To | Via | Status | Details |
| ---- | --- | --- | ------ | ------- |
| `test/app/app_shell_test.dart` | `lib/theme/theme.dart` | `theme: lightTheme` | ✓ WIRED | 4 ocorrências nos pumps de produção |
| `test/screen/tools_preservation_test.dart` | `lib/main.dart` | `const App()` | ✓ WIRED | |
| `lib/screen/network_calculator_screen.dart` | `lib/design_system/tool_scaffold.dart` | `ToolScaffold(` | ✓ WIRED | `return ToolScaffold(` |
| `lib/screen/network_calculator_screen.dart` | `lib/service/network_calculator.dart` | `NetworkCalculator(` | ✓ WIRED | cidr e máscara |
| `test/app/app_shell_test.dart` | Rede screen | tap `Calcular rede` + `192.168.1.0` | ✓ WIRED | |
| `lib/screen/data_converter_screen.dart` | `lib/service/data_converter.dart` | `DataConverter.analyze` | ✓ WIRED | |
| `lib/screen/data_converter_screen.dart` | `package:intl/intl.dart` | `NumberFormat('#,##0.000', 'pt_BR')` | ✓ WIRED | |
| `lib/screen/hash_generator_screen.dart` | `lib/service/hash_calculator.dart` | `HashCalculator.calculate` | ✓ WIRED | única chamada de hash |
| `lib/screen/hash_generator_screen.dart` | `TechnicalValueRow` | `copyWriter` | ✓ WIRED | payload `result.value` |
| `lib/design_system/copy_value_action.dart` | `Clipboard.setData` | `ClipboardCopyWriter` | ✓ WIRED | único `Clipboard.setData` de produção |
| `lib/app/app_destinations.dart` | três screens | `pageBuilder` const | ✓ WIRED | `const NetworkCalculatorScreen()` etc. |

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
| -------- | ------------- | ------ | ------------------ | ------ |
| `network_calculator_screen.dart` | `_networkAddress` e demais | `NetworkCalculator.calculateNetworkAddress()` etc. após CTA | Sim — oracles /24 | ✓ FLOWING |
| `data_converter_screen.dart` | `_result` | `DataConverter.analyze(value, _fromUnit)` | Sim — 1 TB oracle | ✓ FLOWING |
| `hash_generator_screen.dart` | `_results` | `HashCalculator.calculate(input)` | Sim — digests de `abc` | ✓ FLOWING |
| Copy nas três telas | `CopyValueAction.value` | strings computadas acima | Sim — FakeCopyWriter | ✓ FLOWING |

Nenhum prop oco: `copyWriter` opcional cai em `ClipboardCopyWriter`; métricas de hash usam `$_characterCount` / `$_byteCount` / `'${_results.length}'`.

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
| -------- | ------- | ------ | ------ |
| Analyze limpo | `C:\src\flutter\bin\flutter.bat analyze --no-pub` | `No issues found!` (3.5s) | ✓ PASS |
| Suíte completa | `C:\src\flutter\bin\flutter.bat test --no-pub` | `All tests passed!` (185 testes) | ✓ PASS |
| Sem `Clipboard.setData` em telas | grep `lib/screen` | 0 matches; único hit em `copy_value_action.dart` | ✓ PASS |
| Sem Scaffold/AppBar interno | grep `return Scaffold(` / `AppBar(` em `lib/screen` | 0 matches | ✓ PASS |
| Sem `Text('Calcular')` isolado em produção | grep `lib/screen` | 0; amostra só em `tool_components_test.dart` | ✓ PASS |

### Probe Execution

| Probe | Command | Result | Status |
| ----- | ------- | ------ | ------ |
| — | — | Fase não declara probes; nenhum `scripts/*/tests/probe-*.sh` | SKIPPED |

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
| ----------- | ---------- | ----------- | ------ | -------- |
| PRES-01 | 02-02 | IPv4 com os mesmos resultados após migração visual | ✓ SATISFIED | Serviço + widget + AppShell |
| PRES-02 | 02-03 | Conversão decimal/binária com os mesmos resultados | ✓ SATISFIED | Serviço + widget NumberFormat |
| PRES-03 | 02-04 | MD5/SHA-1/SHA-256/SHA-512 iguais | ✓ SATISFIED | Serviço + widget abc |
| PRES-04 | 02-01..04 | Sem perda funcional na migração incremental | ✓ SATISFIED | Preservação das três telas, copy, aviso, copy educativa |

Orphaned vs REQUIREMENTS.md Phase 2: nenhum. DIAG-\* / QUAL-\* / DOC-\* / GATE-\* pertencem às Fases 3–5 — **não são gaps desta fase**.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
| ---- | ---- | ------- | -------- | ------ |
| `test/design_system/tool_components_test.dart` | 213 | `Text('Calcular')` | ℹ️ Info | Amostra da fundação; plano 02-04 manda deixar. Não é CTA de produção. |
| `lib/screen/network_calculator_screen.dart` | 99–105 | Catch `FormatException` / genérico | ℹ️ Info | Caminho de erro legado; mensagens de campo inválido estão cobertas. Não impede o goal. |
| `test/screen/hash_generator_screen_test.dart` | SHA-512 | `find.textContaining` prefixo + resto | ℹ️ Info | Wrapping de `SelectableText`; o valor completo ainda é `result.value` e o oracle do serviço afirma o digest inteiro. |

Sem `TBD` / `FIXME` / `XXX` em arquivos da fase. Sem `onPressed: () {}` em `lib/screen`. Sem Diagnóstico em `lib/`.

### Human Verification Required

Nenhum item pendente.

Os dois exclusivos do relatório anterior (`human_needed`) foram executados e aprovados em `02-HUMAN-UAT.md` (`status: complete`, 2/2 pass, `issues: 0`, `pending: 0`):

1. **Densidade visual** — compacto Android e largura grande; claro e escuro; ToolScaffold/hierarquia/CTAs/resultados legíveis; sem clipping ou overflow problemático; hashes longos permanecem legíveis.
2. **TalkBack** — Calculadora de Rede / Conversor de Armazenamento / Gerador de Hash, campos, CTAs (`Calcular rede` / `Analisar capacidade` / `Gerar hashes`) e Copiar anunciados; navegação utilizável; sem ausência ou duplicação problemática.

Não reabertos. Nenhum concern humano novo encontrado nesta passagem.

### Gaps Summary

Nenhum gap. As 13 verdades automatizadas continuam VERIFIED no código vivo (`analyze` limpo, 185 testes passando). Os dois residuais humanos exclusivos fecharam com evidência registrada. Status `passed`.

DIAG-\* permanece na Fase 3 e não foi tratado como gap.

---

_Verified: 2026-08-31T19:50:00Z_
_Verifier: Claude (gsd-verifier)_
