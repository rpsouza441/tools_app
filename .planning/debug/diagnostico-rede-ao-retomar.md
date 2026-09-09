---
status: awaiting_human_verification
created: 2026-09-09
updated: 2026-09-09
trigger: Capturas mostram transporte/gateway Wi-Fi junto com probe TCP celular do último diagnóstico.
---

# Contexto de rede misturado ao retomar

## Evidence

- Novo reteste do usuário em 2026-09-09, quatro capturas e dois resumos: Wi-Fi 17:04:11–17:04:20 com gateway/alvo TCP 192.168.22.1:80, HTTPS 4/4 mín 148/média 302/máx 663 ms; cellular 17:05:02–17:05:11 com gateway/alvo 192.0.0.1:80, HTTPS 4/4 mín 220/média 1096/máx 3647 ms. IP público obtido nas duas redes; gateway TCP 0/4. Telas e resumos coerentes em cada execução.
- Essas capturas mostram novas execuções coerentes, mas não documentam o intervalo após trocar rede/retomar e antes de Repetir. Aguardar confirmação textual desse passo específico; nenhuma nova falha identificada nesta rodada.

- Capturas fornecidas pelo usuário às 16:52 mostram mensagem parcial corrigida e motivo TCP visível (correção anterior confirmada).
- Na mesma tela: transporte wifi e gateway 192.168.22.1; alvo do probe 192.0.0.1:80, HTTPS média 248 ms, início 16:51:49/fim 16:51:57. Estes últimos correspondem ao resumo cellular enviado pelo usuário.
- Resumos do reteste: Wi-Fi 16:51:26–16:51:34, HTTPS 4/4 mín 192/média 298/máx 579 ms; cellular 16:51:49–16:51:57, HTTPS 4/4 mín 185/média 248/máx 348 ms. Ambos IP público bem-sucedido e gateway TCP 0/4.
- refreshSnapshotOnly, chamado em onResume, publica novo snapshot/transporte/IP local/gateway dentro do último DiagnosticRunState sem renovar medições/horários.

## Current Focus

hypothesis: Resume sobrescreve o contexto de uma execução já concluída, misturando redes na tela e no próximo resumo copiado.
test: Concluir em cellular, trocar snapshot para Wi-Fi, chamar refreshSnapshotOnly, verificar preservação integral da execução e que Repetir obtém a nova rede.
next_action: Confirmar se, após mudar de rede e voltar ao app sem Repetir, o último resultado manteve transporte, gateway, horários e medições originais. Novas execuções já confirmadas coerentes nas capturas de 17:04–17:05.

## Resolution

root_cause: Confirmada por regressões. refreshSnapshotOnly substituía contexto local de execução concluída ou em andamento; também mantinha endereços obsoletos ao atualizar idle para offline e publicava após dispose.
fix: Refresh só publica no estado idle, sem nova execução concorrente e sem descarte. Execuções mantêm snapshot original; start lê nova rede. Refresh no idle atualiza indisponibilidade local quando offline.
verification: Cinco regressões falharam antes e passaram depois; proteção já existente contra refresh anterior a novo run também coberta. 8 testes focados passaram. Analyze limpo, suíte completa 242/242, build debug exit 0. Reteste físico ainda pendente.

## APK atualizado

- `build/app/outputs/flutter-apk/app-debug.apk`, versão debug 1.1.1+4.
- SHA-256: `277AC96F10A6D12D95D628919EE305929E3BDEAAB4C1154CA74159B947FB80BE`.
- pubspec.lock-old permanece intocado; checklist alterado pelo usuário preservado fora deste commit.
