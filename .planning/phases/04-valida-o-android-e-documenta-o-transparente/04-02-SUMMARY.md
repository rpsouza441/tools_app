---
plan: 04-02
status: complete
requirements: [QUAL-09]
---

# Summary 04-02 — Verificação de runtime no emulador Android (camada VERIFIED)

Executado o app de produção (`app-debug.apk`) no emulador `emulator-5554`
(AVD `Medium_Phone_API_36.0`, API 36). Build+instalação limpos; app abre sem
crash.

## VERIFIED (Android Emulator) — evidência observada

- **R1** MethodChannel registrado: FlutterJNI carrega, Dart VM ativo, sem MissingPluginException/FATAL; a tela de Diagnóstico obteve snapshot real via canal.
- **R2** Manifest instalado: `dumpsys package` → INTERNET + ACCESS_NETWORK_STATE (+ DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION signature auto-gerada); sem localização.
- **#1 Wi-Fi:** Transporte wifi, INTERNET Sim, Validado Sim, Portal cativo Não.
- **#4 IPv4 local:** 10.0.2.16 (link real).
- **#5 Gateway:** 10.0.2.2 (rota default real, não inventado).
- **#7 IP público:** 200.101.151.97 via HTTPS api.ipify.org (sucesso).
- **#8 TCP connect gateway:** 10.0.2.2:80, sucessos 0 de 4, limitação honesta (porta filtrada) — probe executado, rotulado "TCP connect".
- **#9 HTTPS probe:** média 1016 ms (mín 264/máx 1847), sucessos 4 de 4, gstatic.com/generate_204 — rotulado HTTPS, nunca ICMP; ICMP exibido como Indisponível.
- **#10 Resultado parcial:** gateway TCP falhou mas todos os demais fatos preservados e exibidos.
- **#3 Offline:** rede desligada (svc wifi/data disable, "Active default network: none") → "Sem conexão com a internet", botão Repetir, sem spinner infinito.
- **#13 Lifecycle:** navegação entre abas (IndexedStack) preserva resultado, não reinicia.
- Timestamps Início/Fim e ícones Copiar/Compartilhar presentes.

## NOT VERIFIED (residual)

- **#2 Dados móveis:** emulador não fornece rádio celular real → NOT VERIFIED (D-06). Requer Android físico com SIM/rede celular.
- **R3 Captive portal real:** não reproduzível de forma confiável no emulador.
- **#11 Cancelamento / #12 troca de rede mid-run:** permanecem AUTOMATED-FAKE (não automatizáveis de forma confiável via adb), lógica coberta por testes verdes.

## Defeitos de runtime

Nenhum defeito encontrado. Nenhuma mudança de código de produção necessária.
`pubspec.lock-old` intocado.
