# Política de Privacidade — Tools App

*Última atualização: 2026-09-01*

O Tools App é um aplicativo local-first de utilidades de TI. Esta política
descreve, de forma factual, como o aplicativo trata dados no estado atual. Ela é
coerente com o comportamento realmente implementado.

## Princípios

- **Sem conta e sem cadastro** — o aplicativo não pede login, e-mail nem
  qualquer identificação de usuário.
- **Sem backend próprio** — não há servidor do projeto que receba ou armazene
  dados do usuário.
- **Sem analytics e sem telemetria** — o aplicativo não envia identificadores,
  resultados de diagnóstico nem eventos de uso a serviços de análise.
- **Sem histórico persistente** — os resultados do diagnóstico existem apenas na
  sessão atual, em memória. Ao sair da tela ou encerrar o app, não há registro
  salvo.
- **Compartilhamento só por ação explícita** — o resumo textual do diagnóstico é
  copiado ou compartilhado apenas quando o usuário toca em "Copiar" ou
  "Compartilhar". O compartilhamento usa o seletor nativo do Android
  (`Intent.ACTION_SEND`); o destino é escolhido pelo usuário.

## Permissões Android

- **`INTERNET`** — para as requisições HTTPS descritas abaixo.
- **`ACCESS_NETWORK_STATE`** — para ler o estado e as capacidades da rede ativa
  (transporte, validação, IPv4 local e gateway) via `ConnectivityManager`.

O aplicativo **não** solicita permissão de localização e **não** lê SSID/BSSID.
Consulte o README para a lista completa de ausências intencionais.

## Requisições a serviços de terceiros

O diagnóstico envia requisições HTTPS a dois serviços de terceiros. Como toda
requisição de rede, o servidor de destino **necessariamente observa** o endereço
IP público de onde a conexão parte. O Tools App **não controla** as práticas de
retenção ou registro desses provedores; consulte a documentação e a política de
cada serviço para detalhes. Ambos os provedores são **substituíveis** na
configuração do aplicativo (`PublicIpConfig` e `HttpsProbeConfig`).

### api.ipify.org (descoberta de IP público)

- **Endpoint:** `https://api.ipify.org?format=json` (HTTPS GET).
- **Finalidade:** descobrir o endereço IP público da conexão atual.
- **Dado exposto ao provedor:** ao consultar o serviço, ele observa o IP público
  da requisição — esse é justamente o dado que o endpoint retorna.
- **Sobre registro (logging):** o material de marketing da ipify afirma não
  registrar informações de visitantes, enquanto a política de privacidade do
  próprio provedor declara registrar dados como IP, tipo de navegador e horários
  de acesso. Essas afirmações são inconsistentes entre si. O Tools App não pode
  garantir nem controlar o que o provedor registra; as afirmações do provedor
  **não** constituem um SLA ou garantia contratual para este projeto. Consulte a
  política oficial da ipify para o texto vigente.

### www.gstatic.com/generate_204 (probe HTTPS de conectividade)

- **Endpoint:** `https://www.gstatic.com/generate_204` (HTTPS GET, espera
  HTTP 204).
- **Finalidade:** obter um sinal independente de conectividade da aplicação
  (probe HTTPS). **Não** é um ping e **não** é ICMP.
- **Dado exposto ao provedor:** ao fazer a requisição, o servidor observa o IP
  público da conexão.
- **Limitações:** um resultado bem-sucedido comprova apenas que aquela
  requisição HTTPS funcionou; não prova acesso a toda a internet nem prova
  ausência de portal cativo. Uma falha do probe **não** equivale automaticamente
  a "sem internet".
- **Terceiro best-effort:** é um endpoint público de terceiros usado em regime
  best-effort. O projeto **não** assume nem afirma qualquer SLA, disponibilidade
  contratada ou autorização específica de uso, e o endpoint pode ser
  **substituído** futuramente.

## Alterações nesta política

Esta política evolui junto com o comportamento do aplicativo. Alterações
relevantes de coleta ou de terceiros serão refletidas aqui.
