# Teste físico Android — Phase 4 / QUAL-09

APK: `build/app/outputs/flutter-apk/app-debug.apk` (debug).
Estado inicial: Phase 4 `human_needed`; dados móveis ainda não verificados.

## Preparação

- [ ] Instalar o APK no Android físico e abrir o Tools App.
- [ ] Anotar modelo, versão do Android, operadora, data/hora e se há VPN ativa. Para o teste básico, usar rede sem VPN.
- [ ] Usar SIM/eSIM ativo, ligar dados móveis e desligar Wi-Fi. Confirmar acesso a uma página pelo navegador usando essa rede.

## Obrigatório — diagnóstico em dados móveis reais

- [ ] Abrir Diagnóstico de Internet e tocar em Iniciar.
- [ ] Transporte identifica rede celular (`cellular`); não mostra o Wi-Fi anterior.
- [ ] A execução termina sem crash, travamento ou carregamento interminável; registrar duração aproximada.
- [ ] Capacidades Android (INTERNET, Validado, Portal cativo) aparecem como fatos da rede; registrar os valores observados.
- [ ] IPv4 local e gateway exibem valores reais ou indisponibilidade explícita. Ausência desses campos em rede celular, especialmente IPv6, não reprova sozinha.
- [ ] IPv4 público apresenta resultado/provedor ou falha explícita. Falha do serviço de IP público não apaga outros resultados nem prova, sozinha, ausência de Internet.
- [ ] Internet (HTTPS) apresenta mínimo/média/máximo e sucessos/tentativas quando há amostras válidas, ou falha/timeout explícito quando não há.
- [ ] Gateway é identificado como TCP connect; pode estar indisponível ou com zero sucessos sem invalidar o HTTPS. ICMP permanece indisponível.
- [ ] Resultados concluídos permanecem visíveis se uma etapa falhar; não há conclusão global enganosa.
- [ ] Tocar em Repetir funciona e produz nova execução, sem misturar resultados anteriores.
- [ ] Copiar resumo funciona. Guardar resumo/capturas para registrar o teste; IPs podem ser ocultados antes de compartilhar a evidência.
- [ ] App não pede localização.

Se qualquer etapa falhar, registrar o que foi feito, o resultado esperado e o observado. Não marcar a fase como aprovada automaticamente: revisar a evidência e eventuais falhas parciais primeiro.

## Complementares — aumentar a cobertura no aparelho

Esses itens complementam a rodada; o residual formal atual é dados móveis reais.

- [ ] Cancelar durante uma execução: para, preserva o concluído e não muda sozinho para sucesso depois.
- [ ] Enviar o app ao segundo plano durante execução e voltar: não reinicia automaticamente; permite iniciar outra execução manualmente.
- [ ] Alternar Wi-Fi/dados móveis durante execução: encerra com indicação de mudança de rede, sem combinar amostras de redes diferentes. Se terminar antes da troca, registrar não exercitado.
- [ ] Desligar Wi-Fi e dados móveis, executar: informa falta de conexão e termina. Restaurar dados móveis e repetir: recupera.
- [ ] Compartilhar abre o seletor Android com o resumo; é possível cancelar sem enviar.

## Registro para retorno

```text
Modelo / Android:
Operadora / SIM ou eSIM / VPN:
Data e hora:
Wi-Fi desligado e navegador funcionando em dados móveis: sim/não
Transporte mostrado:
INTERNET / Validado / Portal cativo:
IPv4 local / gateway: disponíveis ou indisponíveis
IP público: sucesso ou mensagem de falha
Internet HTTPS: sucessos/tentativas e métricas ou mensagem de falha
Gateway TCP: sucessos/tentativas ou indisponível
Duração / resultado final:
Repetir / copiar / solicitação de localização:
Testes complementares realizados:
Problemas observados:
Resumo copiado / capturas (IPs podem ser ocultados):
```
