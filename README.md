# Tools App — Ferramenta de TI

Aplicativo Flutter, **Android-first**, com utilidades para profissionais e
estudantes de TI. A interface é em português do Brasil, com Material 3 e temas
claro/escuro. O aplicativo funciona localmente sempre que possível: não há conta,
backend próprio, analytics nem histórico persistente. Consulte a
[Política de Privacidade](PRIVACY.md).

## Ferramentas

- **Calculadora de Rede (IPv4)** — calcula rede, broadcast, faixa de hosts e
  máscara a partir de um IP e máscara/CIDR.
- **Conversor de Armazenamento** — converte capacidade entre unidades decimais e
  binárias e explica a diferença entre valor anunciado e valor real.
- **Gerador de Hash** — gera MD5, SHA-1, SHA-256 e SHA-512 de um texto.
- **Diagnóstico de Internet** — coleta evidências independentes de conectividade
  (descrito abaixo).

## Diagnóstico de Internet

O diagnóstico é iniciado manualmente pelo usuário (um por vez) e coleta fatos
independentes, deixando explícito o método de cada medição. Ele **não** é um
simples indicador "online": "internet acessível" combina sinais da plataforma
com um teste real.

O que é medido:

- **Transporte e capacidades** — transporte ativo (Wi-Fi, celular, VPN,
  Ethernet), capacidade `INTERNET`, validação da rede pelo Android e indício de
  portal cativo, quando a plataforma os fornece. Capacidades ausentes aparecem
  como *indisponível*, nunca como zero ou falha global.
- **IPv4 local** — endereço IPv4 da rede ativa, ou *indisponível* quando não há
  (nunca inventado).
- **Gateway** — endereço do gateway da rota padrão quando disponível; nunca
  presume um endereço convencional (ex.: 192.168.1.1).
- **IP público** — consultado por HTTPS a `api.ipify.org`, exibindo o provedor,
  o horário e uma falha independente se o serviço não responder ou retornar
  conteúdo inválido. Uma falha aqui **não** significa "sem internet".
- **Probe TCP do gateway** — tentativa de conexão TCP ao gateway (`TCP connect`).
  Falha TCP não prova que o gateway está inalcançável em L3 (roteadores costumam
  filtrar portas).
- **Probe HTTPS externo** — requisição HTTPS a
  `https://www.gstatic.com/generate_204` esperando HTTP 204. É um sinal
  best-effort de conectividade da aplicação, **não** um ping e **não** ICMP.
- **Métricas de latência** — para múltiplas amostras, mínimo, média, máximo e o
  total de tentativas/sucessos/falhas com denominador explícito.

Comportamento:

- **Cancelamento** — a execução pode ser cancelada, encerrando requests,
  sockets, timers e callbacks subjacentes; respostas tardias não alteram o
  estado cancelado.
- **Resultados parciais** — fatos concluídos permanecem visíveis mesmo quando
  outra medição falha, fica indisponível ou é cancelada.
- **Troca de rede** — se a conectividade muda durante uma execução, as amostras
  em voo são marcadas como tal; métricas de redes diferentes não são agregadas.
- **Sessão** — o último resultado fica disponível apenas na sessão atual; não há
  histórico persistente.
- **Resumo** — o usuário pode **copiar** ou **compartilhar** um resumo textual
  com timestamp, contexto de rede, métricas, proveniência, falhas e limitações;
  o compartilhamento ocorre apenas por ação explícita.

### Limitações

- **ICMP indisponível** — o aplicativo não realiza ping ICMP; probes TCP e HTTPS
  nunca são rotulados como ICMP.
- **Teste de velocidade** — não faz parte deste milestone.
- **Sem varredura de LAN, traceroute ou DNS avançado.**
- Um probe HTTPS bem-sucedido comprova que aquela requisição funcionou; não prova
  que todo destino da internet está acessível.

### Plataformas verificadas

- **Android** é a plataforma-alvo. O comportamento de runtime foi verificado em
  **emulador Android (API 36)**: leitura de transporte/capabilities, IPv4 local
  e gateway reais, consulta de IP público por HTTPS, probes TCP/HTTPS com
  métricas, comportamento offline e ciclo de vida. Consulte
  `.planning/phases/04-*/04-ANDROID-VALIDATION.md` para a matriz de evidências.
- **Dados móveis reais** ainda **não** foram verificados em Android físico com
  rede celular real (marcado como *não verificado* na matriz).
- Em plataformas não-Android, o diagnóstico usa implementações que reportam
  honestamente *indisponível* — este ciclo não promete paridade multiplataforma.

## Permissões Android

O aplicativo usa somente as permissões necessárias no estado atual (princípio de
privilégio mínimo). O manifest de produção declara:

- **`android.permission.INTERNET`** — necessária para as requisições HTTPS ao
  serviço de IP público (`api.ipify.org`) e ao probe de conectividade
  (`www.gstatic.com/generate_204`).
- **`android.permission.ACCESS_NETWORK_STATE`** — necessária para ler o estado e
  as capacidades da rede ativa (`ConnectivityManager`, `NetworkCapabilities`,
  `LinkProperties`), incluindo transporte, validação, IPv4 local e gateway.

Ausências intencionais:

- **Sem permissão de localização** (`ACCESS_FINE_LOCATION` /
  `ACCESS_COARSE_LOCATION`).
- **Sem leitura de SSID/BSSID** — o diagnóstico não coleta identificadores de
  Wi-Fi, portanto não exige localização.
- **Sem `ACCESS_LOCAL_NETWORK`** no estado atual (target SDK ≤ 36).
- Sem armazenamento, sem localização em segundo plano, sem permissões de
  analytics.

Permissões futuras **não** são documentadas como se já fossem utilizadas. Os
manifests de *debug* e *profile* adicionam apenas `INTERNET`, exigida pela
ferramenta Flutter para hot reload/depuração durante o desenvolvimento — não são
permissões extras de runtime do aplicativo.

## Privacidade

O aplicativo não usa conta, backend próprio, analytics, telemetria nem histórico
persistente; os resultados existem apenas na sessão atual e o compartilhamento é
sempre iniciado pelo usuário. O diagnóstico envia requisições HTTPS a serviços de
terceiros (`api.ipify.org`, `www.gstatic.com`), que necessariamente observam o IP
público da conexão. Detalhes e a divulgação de terceiros estão em
[PRIVACY.md](PRIVACY.md).

## Desenvolvimento

- Flutter + Material 3, Dart SDK `^3.8.1`.
- Análise estática: `flutter analyze`.
- Testes: `flutter test` (unitários e de widget com dependências simuladas).
