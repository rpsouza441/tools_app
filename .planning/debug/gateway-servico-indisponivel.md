---
status: resolved
created: 2026-09-09
updated: 2026-09-09
trigger: Usuário observa que ausência de serviço 80/443 é resultado da análise, não falha da Internet; gateway celular não deve pressupor página administrativa.
---

# Semântica da verificação do gateway

## Current Focus

expected: Distinguir disponibilidade do serviço de falha do diagnóstico.
root_cause: O resumo TCP sem conexões elevava a sessão a `partialFailure` mesmo com Internet/IP público OK. Além disso, um TCP connect cru na porta 80/443 nunca prova que a página do gateway abre (ex.: modem que serve HTTPS na 443 com certificado autoassinado responde ao usuário mas não a um handshake TCP interpretado como "serviço"), gerando falso negativo confuso.

## Resolution

decision: Com o usuário, definido que o Diagnóstico de Internet é um **resumo honesto da rede para o técnico avaliar o Wi-Fi**, não um teste pass/fail. Como (a) o probe TCP do gateway quase sempre dá indisponível, (b) confunde o usuário, e (c) latência de roteamento real (ICMP) está fora do escopo do MVP por restrição do projeto, o probe TCP do gateway foi **removido**.
fix:
- Removidos GatewayProbe, TcpConnectGatewayProbe, UnavailableGatewayProbe, GatewayProbeConfig, TcpPortResult.
- ProbeOutcome movido para internet_probe.dart (sem portResults).
- gatewayProbe/gatewayLatency/gatewayPorts removidos de run state, sessão, formatter e tela.
- O **endereço** do gateway (state.gateway) continua exibido como fato útil.
- UI padronizada ao centro: ToolStatusPanel mostra preservedChild também no success (largura total), então o card de resultados fica centralizado em todos os estados (antes ficava à esquerda só no success).
verification: 235 testes passam, flutter analyze limpo (lib + test). APK debug gerado. Commit da mudança de código: 6561e48.
