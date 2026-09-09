---
status: awaiting_human_verification
trigger: 'No Wi-Fi: Não foi possivel concluir confira os dados e tente novamente'
created: 2026-09-09
updated: 2026-09-09
---

# Diagnóstico: mensagem de falha parcial

## Symptoms

expected: Execução concluída com falha independente deve preservar resultados e explicar a conclusão parcial.
actual: Tela mostra aviso genérico de ferramenta com dados de entrada inválidos; resumo copiado informa corretamente falhas parciais.
reproduction: Executar diagnóstico em rede cujo gateway não responde TCP na porta 80, com IP público e HTTPS bem-sucedidos.
timeline: Reportado no teste físico do APK debug 1.1.1+4 em 2026-09-09.
device: Redmi Note 12 Pro; versão Android e operadora não informadas.

## Current Focus

hypothesis: partialFailure usa ToolStatusVariant.failure e herda título/corpo genéricos.
test: Reproduzir em widget com gateway timeout e HTTPS/IP público válidos, verificar texto, fatos preservados e resumo.
expecting: Teste falha antes da correção e passa com mensagem específica de diagnóstico.
next_action: Usuário instala APK atualizado e confirma mensagem parcial e falha TCP visível com resultados preservados.

## Evidence

- 4G informado pelo usuário: 2026-09-09 16:40:06–16:40:14; transporte cellular; INTERNET/Validado Sim; Portal cativo Não; IPv4 público via ipify bem-sucedido; gateway TCP 0/4; HTTPS 4/4, mín 251 / média 262 / máx 267 ms. Endereços públicos omitidos do registro.
- Wi-Fi informado pelo usuário: 16:41:50–16:41:58; transporte wifi; INTERNET/Validado Sim; Portal cativo Não; IPv4 público via ipify bem-sucedido; gateway TCP 0/4; HTTPS 4/4, mín 150 / média 168 / máx 182 ms. Endereços públicos omitidos do registro.
- Código: InternetDiagnosticScreen._variant mapeia partialFailure para failure. ToolStatusPanel usa o título "Não foi possível concluir" e corpo "Confira os dados e tente novamente.".
- Código: DiagnosticSummaryFormatter já usa "Concluído com falhas parciais"; a derivação de fase preserva falhas independentes corretamente.
- Alterações preexistentes do usuário no CHECKLIST-ANDROID.md serão preservadas e não incluídas no commit da correção.

## Resolution

root_cause: Mensagem genérica inadequada no painel de resultado parcial, divergente do resumo.
fix: ToolStatusPanel aceita título/corpo opcionais; diagnóstico usa "Concluído com falhas parciais" e explicação específica. Motivo de falha do probe agora aparece na tela. Métodos, timeouts e derivação das medições preservados.
verification: Regressão reproduziu título incorreto antes da correção. Teste também detectou motivo de falha ausente na tela, corrigido. 57 testes focados passaram; analyze limpo; suíte completa 236/236 passou; APK debug compilado com exit code 0. Reteste físico pendente.
files_changed: lib/design_system/tool_status_panel.dart; lib/screen/internet_diagnostic_screen.dart; test/screen/internet_diagnostic_screen_test.dart; documentação de evidência/estado.

## APK de reteste

- Caminho: `build/app/outputs/flutter-apk/app-debug.apk`.
- Versão: `1.1.1+4` (debug); gerado em 2026-09-09 16:46:49.
- SHA-256: `9E06F67BFBEC9EDDB177A2E8A1734F5BF60B6E6DC829582FB1A6B560408BE46A`.
- Mesmo caminho do APK anterior, agora com a correção. O hash do resumo da quick task anterior é histórico.
- Reteste: iniciar em Wi-Fi ou 4G; se gateway TCP falhar, ver título "Concluído com falhas parciais", motivo "Sem resposta TCP do gateway" e resultados HTTPS/IP público preservados.
