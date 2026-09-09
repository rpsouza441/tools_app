---
status: awaiting_human_verification
created: 2026-09-09
updated: 2026-09-09
trigger: Usuário observa que ausência de serviço 80/443 é resultado da análise, não falha da Internet; gateway celular não deve pressupor página administrativa.
---

# Semântica da verificação do gateway

## Current Focus

expected: Distinguir disponibilidade do serviço de falha do diagnóstico; considerar HTTP e HTTPS, com método explícito.
root_cause: Resumo TCP sem conexões recebia `failure` e elevava toda a sessão a `partialFailure`, mesmo com Internet/IP público funcionando. Só havia porta 80 configurada.
next_action: Decisão de escopo (resposta HTTP/HTTPS real da página vs. apenas conexão TCP 80/443) continua pendente com o usuário. Nenhuma mudança de UI foi feita para expor a segunda porta — os dados já existem em `DiagnosticRunState.gatewayPorts`, aguardando essa decisão antes de qualquer exibição.

## Resolution (parcial — sessão retomada após interrupção)

Estado encontrado ao retomar: mudanças de código não commitadas e incompletas (não compilava — `GatewayProbeConfig.port` removido mas ainda referenciado em 3 pontos de `tcp_connect_probe.dart`; suíte de testes não executava).

Trabalho concluído nesta sessão, alinhado apenas às decisões já confirmadas pelo usuário (não à decisão pendente de escopo HTTP/HTTPS):

- `TcpConnectGatewayProbe` migrado para `config.ports` (lista `[80, 443]`), probing sequencial por porta (nunca concorrente, nunca agregado entre portas — `TcpPortResult` por porta).
- Resultado sem nenhuma conexão TCP passou de `failure` para `unavailable`, com mensagem específica ("Serviço TCP indisponível na porta N") — consistente com a decisão já confirmada "gateway sem serviço não prova falta de Internet nem defeito de rede" e "resultado negativo deve ser informativo e específico ao método/endereço/porta".
- `DiagnosticRunState.gatewayPorts` armazena o resultado por porta; a primeira porta (80) continua sendo `gatewayProbe`/`gatewayLatency` para compatibilidade com o resto da UI/resumo.
- **Revertido**: um bypass que pulava inteiramente a probe do gateway quando o transporte era `cellular` (marcando "Não se aplica à conexão celular"). Essa era uma decisão de produto não confirmada pelo usuário — a pergunta de escopo enviada ainda não teve resposta registrada. Os testes de regressão (`diagnostic_session_refresh_test.dart`) ainda esperam que o probe rode em `cellular` e o revert restaurou esse comportamento.

verification: 242 testes passam, `flutter analyze` limpo. Nenhuma mudança visível na UI (a segunda porta e a semântica final ainda não têm decisão de escopo).
