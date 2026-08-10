# Pesquisa de Armadilhas

**Domínio:** Aplicativo Flutter Android-first de utilidades técnicas, diagnóstico de conectividade e speed test condicional
**Pesquisado em:** 2026-08-10
**Confiança:** ALTA para Android, Flutter, conectividade, lifecycle, permissões e privacidade do Google Play; MÉDIA-ALTA para metodologia de latência; MÉDIA para speed test até que um provedor/protocolo seja escolhido e validado

## Resumo Executivo

O maior risco deste produto é apresentar uma observação estreita como uma conclusão ampla. “Há Wi-Fi”, “a rede tem capacidade `INTERNET`, “o Android validou a rede”, “um socket TCP abriu” e “um endpoint HTTPS respondeu” são evidências diferentes. Nenhuma delas, isoladamente, prova que “a internet está funcionando”. Portal cativo, VPN, troca de rede, filtragem por destino, DNS quebrado e indisponibilidade do próprio endpoint produzem falsos positivos e falsos negativos. O produto deve mostrar evidências, método, alvo, horário e limitações, não um semáforo absoluto.

O segundo risco é implementar cancelamento apenas na apresentação. Ignorar uma `Future` ou impedir `setState` depois de `dispose` não encerra socket, requisição, stream, timer ou callback Android. Cada adaptador precisa possuir e abortar os recursos que abriu. Toda atualização deve carregar um identificador de execução; respostas de uma execução antiga ou de outra rede devem ser descartadas. A tela preserva resultados parciais, mas nunca mistura duas execuções.

O terceiro risco é tratar a licença de uma biblioteca cliente como autorização para usar a infraestrutura que ela consulta. São contratos distintos. Um speed test também pode publicar IP e resultados, consumir centenas de megabytes ou mais em links rápidos e ainda medir apenas capacidade de transporte até um servidor específico. A Fase 3 deve começar com uma decisão técnica, jurídica, financeira e de privacidade documentada. Sem endpoint autorizado, protocolo estável, cancelamento comprovado, consentimento e orçamento rígido de dados, a decisão correta é adiar.

## Armadilhas Críticas

### Armadilha 1: Confundir transporte disponível com internet acessível

**O que dá errado:**
O aplicativo mostra “Conectado” ao detectar Wi-Fi ou dados móveis, embora a rede esteja sem rota pública, sem DNS, atrás de portal cativo ou filtrando o destino testado.

**Por que acontece:**
APIs e plugins de conectividade fornecem transporte e capacidades, não uma garantia universal. O Android documenta que `NET_CAPABILITY_INTERNET` significa que a rede está configurada para alcançar a internet, enquanto `NET_CAPABILITY_VALIDATED` registra que o sistema conseguiu validar acesso público em sua última verificação. Mesmo `VALIDATED` pode envelhecer imediatamente ou não representar o destino específico do app. O próprio `connectivity_plus` alerta que tipo de conexão não garante acesso à internet.

**Como evitar:**
Modele separadamente: rede padrão presente; transporte(s); capacidade `INTERNET`; validação do sistema; sinal de portal cativo; DNS; e resultado de cada probe do aplicativo. Use estados como `sem rede`, `rede local`, `portal cativo possível`, `internet validada`, `alvo específico indisponível` e `inconclusivo`. A conclusão deve ser evidencial: “Android validou acesso público, mas o alvo HTTPS não respondeu”, por exemplo.

**Sinais de alerta:**
- Um único booleano `isConnected` dirige toda a tela.
- A palavra “online” vem diretamente de `ConnectivityResult.wifi`/`mobile`.
- Testes passam somente em Wi-Fi doméstico e falham em hotel, empresa, VPN ou rede com DNS filtrado.
- A UI não possui estado `inconclusivo`.

**Fase para tratar:**
Fase 2 — contrato de estados antes do primeiro adapter de conectividade; validar em Wi-Fi, dados móveis, offline, portal cativo e VPN.

**Confiança:** ALTA — Android e o plugin mantido documentam explicitamente a distinção.

---

### Armadilha 2: Detectar portal cativo com um “canário” próprio e tratá-lo como verdade

**O que dá errado:**
Uma requisição HTTP/HTTPS a um URL fixo classifica redes normais como cativas quando o endpoint está fora do ar ou bloqueado, e classifica redes cativas como livres quando o portal libera ou imita o canário.

**Por que acontece:**
Checks por resposta fixa são simples, mas dependem de interceptação, DNS, allowlists e comportamento do portal. A arquitetura CAPPORT do IETF registra que redes maliciosas ou mal configuradas podem deixar o canário passar ou imitá-lo, produzindo falso negativo. Um HTTPS não interceptado pode apenas falhar com certificado/timeout; isso não identifica a causa.

**Como evitar:**
Use primeiro os sinais do Android (`VALIDATED` e `CAPTIVE_PORTAL`) e apresente-os como avaliação do sistema, não como certeza eterna. Um probe próprio deve testar a capacidade que o app realmente precisa e ser relatado separadamente. Não implemente redirecionamento HTTP inseguro, bypass de TLS ou abertura automática de páginas capturadas. Se futuramente houver suporte CAPPORT, use os mecanismos padronizados e TLS; não invente descoberta por URLs estáticas.

**Sinais de alerta:**
- Qualquer resposta diferente de `204` vira automaticamente “portal cativo”.
- O app desabilita validação TLS para “funcionar no hotel”.
- O endpoint do canário não tem proprietário, SLA ou contrato de uso.
- O diagnóstico discorda do Android sem mostrar os dois sinais.

**Fase para tratar:**
Fase 2 — matriz de decisão e cenários de portal cativo; spike Android antes de redigir o texto final da UI.

**Confiança:** ALTA — Android e RFC 8952/8908 descrevem capacidades e limitações.

---

### Armadilha 3: Chamar TCP ou HTTPS de “ping” e falha de requisição de “perda de pacotes”

**O que dá errado:**
O app exibe “ping 40 ms” para uma conexão TCP ou uma transação HTTPS, ou informa “20% de perda” porque uma resposta HTTP falhou. Usuários comparam esse número com ICMP e tiram conclusões erradas.

**Por que acontece:**
“Ping” é familiar, mas cada método mede trabalho diferente. TCP connect mede estabelecimento até `host:porta`; HTTPS pode incluir DNS, TCP, TLS, redirecionamento e processamento do servidor; ICMP Echo mede outra classe de pacote. Firewalls e destinos tratam cada protocolo de modo diferente. `InetAddress.isReachable`, por exemplo, pode tentar ICMP quando há privilégio e recorrer a TCP Echo na porta 7, logo nem esse nome garante o método desejado.

**Como evitar:**
Registre no modelo `method`, `target`, `port`, `sampleCount`, `timeout`, se a amostra é fria/quente e quais fases entram no relógio. Rotule exatamente `ICMP Echo RTT`, `tempo de conexão TCP a host:porta` ou `tempo de transação HTTPS a URL`. Para TCP/HTTPS, use “tentativas sem resposta/falhas do probe”, não “perda de pacotes”. Calcule taxa de falha como `falhas / tentativas`; nunca inclua timeout como zero nem esconda falhas ao calcular a média dos sucessos.

**Sinais de alerta:**
- O modelo possui apenas `latencyMs` e não possui método/alvo.
- O resumo copiável diz “ping” sem protocolo e porta.
- DNS/TLS às vezes entram na primeira amostra, mas não nas seguintes, sem distinção.
- `min/avg/max` não informa quantas tentativas falharam.

**Fase para tratar:**
Fase 2 — contrato do `ProbeAdapter`, modelo de amostra e cópia pt-BR antes da UI de métricas.

**Confiança:** ALTA para a distinção de protocolo; MÉDIA-ALTA para a interpretação estatística, alinhada às métricas IPPM.

---

### Armadilha 4: Inferir alcance do gateway a partir de um protocolo que ele não oferece

**O que dá errado:**
O gateway é encontrado corretamente, mas o app conclui “roteador inacessível” porque ICMP foi filtrado ou porque tentou uma porta TCP fechada. Em redes móveis, VPNs, IPv6 ou rotas diretamente conectadas, pode não existir um gateway IPv4 exibível.

**Por que acontece:**
O endereço do próximo salto e a resposta a um protocolo são fatos diferentes. `LinkProperties` pode conter várias rotas; uma rota padrão pode ter gateway nulo quando é diretamente conectada. O primeiro endereço `.1` da sub-rede não é uma regra. VPN e troca de rede também mudam a rota padrão.

**Como evitar:**
Derive o gateway das rotas da rede padrão, selecione explicitamente a rota IPv4 default e aceite `indisponível`. Nunca adivinhe `.1`. Um probe de gateway só pode afirmar que o método específico respondeu ou não respondeu. Se não houver método confiável e honesto para a plataforma/rede, mostre o endereço/rota sem prometer teste de alcance. Não confunda DHCP server, DNS server e gateway.

**Sinais de alerta:**
- Gateway calculado a partir do IP e máscara.
- `null` vira `0.0.0.0` ou falha global.
- TCP em porta 80/443 fechada vira “gateway offline”.
- Resultados não indicam VPN/interface/rede padrão usada.

**Fase para tratar:**
Fase 2 — spike de `LinkProperties`/plugin em aparelhos reais e fixtures com rota direta, VPN, celular, Wi-Fi e IPv6-only.

**Confiança:** ALTA para rotas Android; MÉDIA para disponibilidade concreta até o spike nos níveis de API suportados.

---

### Armadilha 5: Escolher “o primeiro IPv4” e “o IP público do aparelho”

**O que dá errado:**
O app exibe loopback, link-local, interface inativa ou endereço de uma VPN como “IPv4 local”. O serviço de IP externo retorna o endereço do proxy, VPN, CGNAT ou NAT64 e a UI o apresenta como endereço exclusivo do aparelho.

**Por que acontece:**
Android pode manter múltiplas redes e transportes; a rede padrão pode mudar durante a leitura. Endereço público é, na prática, o endereço de saída observado pelo serviço para aquela requisição. Uma rede pode ser IPv6-only, ter múltiplos endereços ou não possuir IPv4 local/público atribuível ao aparelho.

**Como evitar:**
Associe endereços a um objeto/rede padrão e às `LinkProperties` desse snapshot. Filtre família e escopo explicitamente, preservando `indisponível` em vez de buscar outra interface arbitrária. Rotule o externo como `IPv4 público observado pelo provedor X` e explique VPN/proxy/CGNAT. Force e valide a família prometida; uma resposta IPv6 não pode preencher o campo IPv4. Capture rede no início/fim e invalide a etapa se ela mudar.

**Sinais de alerta:**
- Uso de `NetworkInterface.list()` seguido de `.first` sem vínculo à rede padrão.
- O app sempre espera um IPv4.
- Resultado de IP público não registra provedor nem família.
- VPN ligada não altera a explicação.

**Fase para tratar:**
Fase 2 — modelo de proveniência e testes em multihoming/VPN/IPv6-only; UI deve suportar ausência.

**Confiança:** ALTA para a natureza dinâmica/multitransporte; MÉDIA-ALTA para filtros concretos até validar o adapter.

---

### Armadilha 6: “Cancelar” apenas impede a atualização visual

**O que dá errado:**
O botão muda para “Cancelado”, mas download, upload, DNS, sockets, timers e callbacks continuam. Depois chegam resultados tardios, dados móveis continuam sendo consumidos, um teste novo recebe eventos do teste antigo ou recursos vazam.

**Por que acontece:**
Uma `Future` do Dart não fornece cancelamento físico por si só. `mounted` evita atualizar widget descartado, mas não fecha o recurso. Até `CancelableOperation` precisa de um `onCancel` que interrompa a operação subjacente. APIs concretas possuem seus próprios mecanismos: `HttpClientRequest.abort`, cancelamento de subscriptions, `Socket.destroy`, fechamento de clientes e `unregisterNetworkCallback`.

**Como evitar:**
Crie um `OperationScope` por execução, com deadline total, token de cancelamento e registro idempotente de recursos. Cada adapter deve documentar e testar seu `cancel/close`. Ao cancelar: pare de agendar amostras, aborte requisições/sockets, cancele streams/timers, desregistre callbacks e emita estado terminal uma vez. Use `runId` crescente em todos os eventos e aceite atualização somente se `runId == activeRunId`.

**Sinais de alerta:**
- `cancel()` apenas seta `_isCancelled = true`.
- Chamadas de alto nível `http.get` não expõem handle para abortar.
- Tráfego continua após o botão cancelar.
- Testes ficam flaky por callbacks tardios.
- Abrir/fechar a tela repetidamente aumenta timers, sockets ou callbacks.

**Fase para tratar:**
Fase 2 — infraestrutura de operação e contract tests antes de integrar providers; Fase 3 reutiliza e endurece o mesmo contrato.

**Confiança:** ALTA — APIs Dart/Flutter/Android documentam abort, dispose e unregister explicitamente.

---

### Armadilha 7: Lifecycle e troca de rede misturam resultados ou deixam trabalho órfão

**O que dá errado:**
O usuário inicia em Wi-Fi, o app vai para background, a rede muda para celular e a sessão termina com um único resultado como se medisse a mesma conexão. Alternativamente, a tela é descartada, mas a sessão continua. O Android mata o processo sem que o app receba cleanup.

**Por que acontece:**
Lifecycle de Flutter não é transação. A documentação alerta que notificações podem ser puladas e que o app não recebe evento antes de algumas terminações abruptas. A rede padrão também pode mudar a qualquer momento; sockets existentes podem continuar temporariamente na rede anterior e novas conexões usar a nova.

**Como evitar:**
Não execute diagnóstico/speed test em background neste milestone. Em `inactive/hidden/paused`, cancele com motivo `app em segundo plano`; em `dispose`, sempre feche o escopo. Observe a rede padrão durante a execução e encerre/invalide ao mudar seu identificador/capacidades. Na retomada, mostre resultado parcial cancelado e exija nova ação. Não dependa de callback final para persistir ou liberar tudo: evite persistência e use recursos limitados pelo SO/escopo.

**Sinais de alerta:**
- Teste continua consumindo dados com a tela apagada.
- Não há caso de teste para `pause`, `dispose` ou troca Wi-Fi→celular.
- Um único `transport` é lido apenas no início e tratado como constante.
- O código assume que `onPause` sempre ocorrerá.

**Fase para tratar:**
Fase 2 — política lifecycle e testes de controlador; Fase 3 — teste físico de troca de rede e background com medição de bytes.

**Confiança:** ALTA — Flutter e Android documentam estados e mutabilidade da rede.

---

### Armadilha 8: Vazar callbacks Android, streams, clientes HTTP e memória de payload

**O que dá errado:**
Após várias execuções, o app recebe eventos duplicados, excede limite de callbacks, mantém conexões abertas, consome bateria ou sofre OOM ao criar arquivos/blobs grandes para o speed test.

**Por que acontece:**
`registerDefaultNetworkCallback` continua ativo até ser desregistrado ou o processo terminar; Android limita requests/callbacks pendentes por UID. Streams e timers Dart também exigem cancelamento. Para velocidade, alocar um `Uint8List` enorme ou acumular o corpo do download escala com o volume transferido.

**Como evitar:**
Tenha ownership explícito: quem registra fecha. Reutilize um cliente HTTP dentro do escopo apropriado, mas não entre provedores com políticas distintas; feche no término. Download deve contar bytes e descartá-los em streaming; upload deve gerar chunks limitados sem construir o payload inteiro. Defina limites simultâneos de bytes, tempo e memória. Teste 100 ciclos start/cancel/dispose e monitore contagem de callbacks, timers, sockets e heap.

**Sinais de alerta:**
- Cada rebuild/execução chama `listen` ou registra callback.
- `dispose` não cancela subscription nem chama `unregisterNetworkCallback`.
- Payload do speed test é uma lista de dezenas/centenas de MB.
- Uso de memória cresce com a velocidade medida.

**Fase para tratar:**
Fase 2 — teste de soak leve para callbacks; Fase 3 — streaming, heap profiling e cancelamento sob carga.

**Confiança:** ALTA — Android documenta lifetime/limite de callbacks; Dart expõe destruição de sockets e streams.

---

### Armadilha 9: Endpoint externo vira ponto único de falha, privacidade e interpretação

**O que dá errado:**
Indisponibilidade, rate limit, mudança de resposta, redirecionamento de portal cativo ou bloqueio regional faz o app dizer que a internet caiu. Uma resposta HTML enorme é aceita como IP. Fallbacks silenciosos enviam o endereço do usuário a novos terceiros.

**Por que acontece:**
Sem backend próprio, IP público e probes dependem de serviços de terceiros. Sucesso prova somente aquele caminho; falha pode ser do serviço. Toda requisição revela ao menos IP de origem e metadados de conexão ao operador. Um fallback altera o destinatário e o contrato de privacidade.

**Como evitar:**
Crie adapters independentes e uma allowlist versionada de endpoints aprovados. Exija HTTPS, status esperado, limite pequeno de corpo, timeout por fase, política de redirects, content type quando aplicável e parser estrito de IP. Exiba provedor e erro da etapa. Não transforme falha do provedor em “sem internet”. Qualquer fallback deve ser previamente aprovado, documentado na política e testado; não faça rotação oportunista entre APIs públicas encontradas na web.

**Sinais de alerta:**
- URL literal espalhada por widget/service.
- Parser usa `response.body.trim()` sem validar IP/tamanho/status.
- Endpoint gratuito não tem termos, privacidade, limite ou contato.
- Adicionar fallback não dispara revisão de política/Data Safety.

**Fase para tratar:**
Fase 2 — decisão do provedor de IP/probe e testes de contrato; revisão em cada release.

**Confiança:** ALTA para segurança e interpretação; MÉDIA para disponibilidade/termos de cada serviço até escolher o fornecedor.

---

### Armadilha 10: Permissões excessivas ou ausentes no manifesto mesclado

**O que dá errado:**
O diagnóstico falha porque `INTERNET`/`ACCESS_NETWORK_STATE` não estão no manifest, ou uma dependência adiciona localização/nearby devices que o produto não usa. A equipe testa apenas debug e não audita o manifest final de release.

**Por que acontece:**
O manifest atual do projeto não declara permissões de rede. Android exige `INTERNET` e `ACCESS_NETWORK_STATE` para operações/estado de rede; são permissões normais e não pedem prompt runtime. Já SSID/BSSID, scans e certas APIs Wi-Fi podem requerer `ACCESS_FINE_LOCATION` ou `NEARBY_WIFI_DEVICES`, dependendo da API e versão. Plugins também têm manifests próprios que são mesclados.

**Como evitar:**
Declare somente `INTERNET` e `ACCESS_NETWORK_STATE` para o MVP, salvo evidência concreta de outra necessidade. Não colete SSID/BSSID nem faça scan. Audite o merged manifest do APK/AAB release e a árvore de dependências. Se um plugin exige permissão sensível para uma função não usada, substitua-o ou remova essa permissão de forma testada; nunca peça “por garantia”. Documente cada permissão, finalidade e comportamento quando negada antes de publicar.

**Sinais de alerta:**
- Runtime prompt de localização para mostrar IP/gateway.
- `READ_PHONE_STATE`, localização, nearby ou storage aparecem sem requisito.
- Só o manifest fonte é revisado, não o merged manifest.
- App funciona em debug mas falha em release.

**Fase para tratar:**
Fase 2 — spike de adapter + auditoria do manifest; gate de release em todas as fases com dependência nova.

**Confiança:** ALTA — documentação Android atual explicita permissões normais e Wi-Fi sensível.

---

### Armadilha 11: Privacidade “sem analytics” é confundida com “nenhum dado sai do aparelho”

**O que dá errado:**
A política diz que nada é coletado, mas o app consulta IP público ou executa speed test em terceiro. O terceiro recebe IP, horário, metadados e possivelmente resultados; no caso de M-Lab NDT, IP e resultados são coletados e publicados. A tela de compartilhar também pode expor IP local/público sem revisão.

**Por que acontece:**
Ausência de conta, backend e telemetry reduz riscos, mas não elimina transmissão a fornecedores. Google Play atribui ao desenvolvedor a responsabilidade pelo código/SDK de terceiros e exige Data Safety/política coerentes; localização inferida de IP pode precisar ser declarada conforme o uso. A LGPD define dado pessoal amplamente como informação relacionada a pessoa identificada ou identificável — a classificação e base legal concretas precisam de revisão jurídica, não de suposição técnica.

**Como evitar:**
Mantenha inventário por fluxo: dado, destino, finalidade, retenção/publicação, base/consentimento e link de política. A política e o Data Safety devem refletir o comportamento real de release. Antes de cada speed test, mostre provedor, dados enviados/publicados, limite de bytes e solicite ação explícita; para M-Lab, aceite da política é requisito do cliente oficial. O resumo compartilhável deve ter preview e opção de omitir IPs/endpoints sensíveis; copiar/compartilhar nunca é automático. Logs de produção não devem conter IPs/resultados.

**Sinais de alerta:**
- Política afirma “processamento 100% local” depois da adição de HTTPS.
- SDK/provedor novo não gera revisão de Data Safety.
- Consentimento é implícito ao abrir a tela.
- Resumo inclui IPs completos sem preview/redação.

**Fase para tratar:**
Fase 2 — política para consulta de IP/probes e compartilhamento; Fase 3 — revisão jurídica/Play e consentimento específico do provedor antes da implementação pública.

**Confiança:** ALTA para Play/M-Lab; MÉDIA para aplicação jurídica da LGPD a um fluxo específico, que exige aconselhamento jurídico.

---

### Armadilha 12: Licença do package é tratada como licença do serviço

**O que dá errado:**
Uma biblioteca MIT/Apache é incorporada e seus endpoints Fast.com/Ookla/Cloudflare/M-Lab são usados em produção sem confirmar autorização, quotas, marca, privacidade, manutenção ou suporte. O app quebra quando um endpoint interno muda ou é bloqueado; um token/segredo embutido é extraído do APK.

**Por que acontece:**
A licença cobre o código distribuído, não necessariamente infraestrutura, API, dados, marca ou uso automatizado. Há packages Flutter de uploader não verificado que anunciam APIs públicas/defaults de terceiros, mas isso não constitui autorização desses provedores. Serviços documentados também mudam autenticação: o NDT7 do M-Lab exige token emitido pelo Locate API, e clientes/integradores têm obrigações de política de dados.

**Como evitar:**
Para cada candidato, arquive: licença do código e transitivas; termos da API/SDK; permissão para distribuição comercial; política de marca; limites/custos; SLA/depreciação; regiões; dados/retention; autenticação; e contato. Não coloque segredo duradouro no app; com a restrição “sem backend”, descarte ofertas que exijam segredo confidencial. Prefira protocolo e cliente oficial com integração documentada. Se nenhum candidato passar, registre “Fase 3 adiada”.

**Sinais de alerta:**
- A justificativa é apenas “o package é MIT”.
- Endpoint foi copiado do código de um site/WebView.
- Não existe documento oficial de integração para clientes terceiros.
- Chave API está em Dart, manifest ou assets.

**Fase para tratar:**
Fase 3 — gate zero, antes de qualquer tela ou dependência de speed test.

**Confiança:** ALTA para a separação código/serviço e requisitos M-Lab; MÉDIA para qualquer provedor ainda não selecionado.

---

### Armadilha 13: Resultado de speed test parece mais preciso do que o método permite

**O que dá errado:**
O app promete “velocidade da internet” ou compara diretamente com plano do ISP, mas mediu capacidade de um ou poucos fluxos até um servidor específico, sob Wi-Fi/VPN/carga/CPU específicos. Resultados variam com distância, rota, seleção de servidor, slow start, congestionamento, duração, concorrência e aquecimento.

**Por que acontece:**
Mbps parece absoluto. Na prática, protocolos medem constructos diferentes. O M-Lab descreve NDT como capacidade de transporte bulk de um único stream e alerta que uma medição isolada não caracteriza a rede; testes multistream podem se aproximar mais da capacidade do link, mas esconder impacto de perda. O servidor escolhido e sua topologia também fazem parte da medida.

**Como evitar:**
Defina antes da implementação: constructo medido; stream count; seleção de servidor; duração/aquecimento; caps; bytes computados e em qual lado; intervalo incluído; conexões frias/quentes; tratamento de outliers; latência ociosa/sob carga; critérios de invalidade; e precisão esperada por faixa. Exiba protocolo, servidor/região quando confiável, bytes, duração, rede/VPN, completude e rótulo `estimativa`. Compare contra implementação de referência em laboratório controlado e em vários aparelhos/velocidades; não calibre para “bater” em outro app sem metodologia equivalente.

**Sinais de alerta:**
- Um único download HTTP de arquivo fixo é chamado benchmark.
- Teste curto retorna valores impossíveis ou muito variáveis em links rápidos.
- Upload/download não registram bytes e duração reais.
- QA aceita se “parece próximo do Speedtest” em um aparelho.

**Fase para tratar:**
Fase 3 — specification/methodology e harness controlado antes da UX final.

**Confiança:** ALTA para limitações do NDT documentadas; MÉDIA para precisão do futuro protocolo não escolhido.

---

### Armadilha 14: Limite de dados nominal não é um limite real

**O que dá errado:**
O texto promete “até 20 MB”, mas retries, download e upload, headers, TLS, descoberta de servidor e concorrência ultrapassam o valor. Em links de 1 Gbit/s, dez segundos de transferência podem chegar a aproximadamente 1,25 GB por direção antes de overhead, tornando um teste por duração especialmente arriscado.

**Por que acontece:**
Equipes limitam tamanho de um arquivo, não o orçamento agregado da sessão. Bibliotecas podem abrir múltiplos fluxos, repetir fases ou usar payload adaptativo. Cancelamento tardio também continua transferindo buffers já em voo.

**Como evitar:**
Imponha contador agregado no nível mais baixo possível para bytes de payload enviados/recebidos e um deadline monotônico, com margem explícita para overhead. O aviso deve dizer `limite de payload` ou `estimativa total`, conforme o que realmente é controlável. Não faça retry automático de speed test. Mostre bytes finais por direção e motivo `limite atingido`. Em rede medida, exija confirmação reforçada e permita recusar sem perder o diagnóstico básico.

**Sinais de alerta:**
- Cap existe apenas como texto ou tamanho do arquivo de download.
- Upload, descoberta e retries não entram no contador.
- Dois testes podem rodar em paralelo.
- QA mede Mbps, mas não bytes no dispositivo/servidor.

**Fase para tratar:**
Fase 3 — requisito de segurança mensurável; teste de integração com contador independente.

**Confiança:** ALTA para aritmética/risco; MÉDIA para overhead até escolher protocolo.

---

### Armadilha 15: Orquestrador “fail-fast” apaga evidências úteis

**O que dá errado:**
Falha no serviço de IP público cancela gateway e probes, ou uma exceção tardia substitui resultados já exibidos por uma tela genérica de erro. Cancelar é tratado como falha; etapa não suportada é tratada como offline.

**Por que acontece:**
`Future.wait` com erro e modelos globais simples são convenientes. Mas diagnóstico é deliberadamente composto por capacidades independentes e falhas parciais são o caso normal.

**Como evitar:**
Cada etapa tem estado terminal próprio: sucesso, falha, timeout, indisponível/não suportada, cancelada ou não executada por dependência. O orquestrador mescla snapshots imutáveis e preserva sucesso. Somente erro de programação vira falha global. Use dependências reais: não consultar IP público sem rota externa, mas gateway ausente não impede probe HTTPS. O resumo global lista observado/não medido/limitações.

**Sinais de alerta:**
- Um único `try/catch` ao redor de todo o diagnóstico.
- Falha em qualquer `Future.wait` limpa a UI.
- `null` significa simultaneamente não suportado, timeout e ainda carregando.
- Testes verificam apenas sucesso total e falha total.

**Fase para tratar:**
Fase 2 — modelo de estado e testes de todas as combinações parciais antes dos widgets finais.

**Confiança:** ALTA — decorre diretamente do objetivo e das fronteiras arquiteturais do projeto.

---

### Armadilha 16: Testes dependem da rede real e não conseguem provocar as falhas importantes

**O que dá errado:**
Testes passam na máquina do desenvolvedor e ficam flaky no CI. Timeout, resposta tardia, troca de rede, portal cativo, rota sem gateway, cancelamento durante stream e parciais raramente são exercitados. Um teste com endpoint público comprova apenas que aquele serviço estava acessível naquele instante.

**Por que acontece:**
Plugins estáticos e chamadas de rede dentro de widgets são rápidos para prototipar, mas escondem relógio, cliente, provider e lifecycle. Falhas de rede são não determinísticas; tentar reproduzi-las desligando Wi-Fi manualmente não valida ordering, cleanup nem limites de bytes.

**Como evitar:**
Defina interfaces pequenas para conectividade, rede local, IP público, probes, speed transport, relógio monotônico e lifecycle. Injete adapters e use fakes roteirizados capazes de: concluir, falhar, ficar pendentes, responder após cancelamento, trocar rede e emitir chunks além do cap. Agregação e state machine ficam puras. Mantenha três camadas: unit tests determinísticos; contract tests de cada adapter; e poucos testes instrumentados Android/reais marcados como integration, nunca como única cobertura. Capture `runId` e sequência de eventos nas asserções.

**Sinais de alerta:**
- Teste unitário precisa de internet ou `Future.delayed` longo.
- Widget cria plugin/`HttpClient` diretamente.
- Não é possível simular response depois de cancelamento ou duas redes concorrentes.
- CI ignora testes quando endpoint externo falha.
- A única validação de cap lê o contador apresentado pelo próprio código testado.

**Fase para tratar:**
Fase 2 — seams e harness antes dos adapters concretos; Fase 3 — servidor controlado/reference client e contador independente antes de aceitar precisão/cap.

**Confiança:** ALTA — requisito derivado das falhas obrigatórias do produto e das fronteiras necessárias para reproduzi-las.

## Padrões de Dívida Técnica

| Atalho | Benefício imediato | Custo de longo prazo | Quando aceitável |
|---|---|---|---|
| URL/provedor hardcoded no widget | Demo rápida | Impossível trocar, simular, revisar privacidade ou distinguir falha do fornecedor | Nunca |
| Booleanos `loading/error/connected` | Pouco código | Estados impossíveis, perda de proveniência e parciais | Nunca no diagnóstico |
| `Future.wait` fail-fast para todas as etapas | Orquestração curta | Uma falha apaga evidências independentes | Somente em grupo de tarefas realmente atômico; não aqui |
| Guardar somente média | UI simples | Oculta falhas, amostra e assimetria; impossível auditar | Nunca; guardar amostras cruas apenas em memória durante a sessão e resumo agregado completo |
| Um timeout global por conveniência | Configuração mínima | DNS pode consumir tudo; cancelamento imprevisível; etapas rápidas ficam lentas | Somente além de timeouts por adapter, como deadline superior |
| Ignorar resultado tardio sem abortar I/O | Evita `setState after dispose` | Tráfego, bateria e recursos continuam | Nunca |
| Usar singleton de plugin/checker | Acesso fácil | Configuração global, lifecycle obscuro, testes interferentes | Apenas wrapper app-scoped com ownership e dispose claros; nunca singleton oculto do package |
| Coletar SSID/BSSID para “melhor contexto” | Nome amigável | Permissão sensível, localização, política e rejeição do usuário | Fora deste milestone |
| WebView de speed test público | Protótipo visual rápido | Tracking, termos, cancelamento, acessibilidade e estabilidade fora de controle | Protótipo descartável privado, jamais release |
| Salvar último resultado em storage | Sobrevive reinício | Retenção, migração e exposição sem valor validado | Fora deste milestone; a última execução pode ficar só em memória |
| Usar `DateTime.now()` para duração | Fácil | Mudança de relógio produz duração errada | Nunca; usar relógio monotônico/`Stopwatch`, mantendo wall clock só para timestamp |
| Atualizar plugin sem checar requisitos | Recebe fixes | Pode exigir Flutter/Dart/AGP/Java superiores ou permissões novas | Nunca sem matriz de compatibilidade e manifest diff |

## Problemas de Integração

| Integração | Erro comum | Abordagem correta |
|---|---|---|
| `ConnectivityManager` | Ler snapshot síncrono e tratá-lo como estável | Registrar callback da rede padrão, reagir a capabilities/link properties e desregistrar no lifecycle |
| `NetworkCallback` | Chamar getters síncronos dentro de `onAvailable`, criando race | Esperar `onCapabilitiesChanged` e `onLinkPropertiesChanged`, como recomenda Android |
| `connectivity_plus` | Usar transporte como internet | Usar somente como informação de transporte e manter probes/timeouts independentes |
| `network_info_plus` ou similar | Usar SSID/BSSID e herdar permissões por conveniência | Consumir apenas IP/gateway necessários, validar compatibilidade e auditar manifest; preferir adapter Android focado se o plugin ampliar escopo |
| IP público | Aceitar qualquer body 200 | HTTPS, body cap, status/content-type/política de redirect, parse estrito, família e provedor explícitos |
| Endpoint de reachability | Concluir internet global a partir de um host | Reportar `alvo X acessível`; combinar com validação Android e manter falha inconclusiva |
| Gateway | Supor `.1` ou porta aberta | Ler rota default da rede; aceitar ausência; probe específico nunca prova indisponibilidade total |
| Cliente HTTP | Usar chamada top-level sem handle/ownership | Injetar cliente/adapter abortável, configurar timeouts e fechar deterministicamente |
| M-Lab NDT7 | Rodar sem consentimento ou tratar dados como privados | Usar cliente/protocolo oficial, Locate token atual, aceite da política e informar que IP/resultados são coletados/publicados |
| Package de speed test | Confiar em README/defaults de Fast/Ookla | Verificar oficialmente SDK/API, termos, autenticação, marca, dados e suporte; package license não basta |
| Compartilhamento/clipboard | Copiar automaticamente todos os identificadores | Preview, ação explícita e opção de redigir IP local/público e detalhes do alvo |
| TLS | Desativar hostname/certificado para portal cativo | HTTPS normal e falha explícita; nunca implementar `badCertificateCallback` permissivo |

## Armadilhas de Desempenho e Precisão

| Armadilha | Sintomas | Prevenção | Quando quebra |
|---|---|---|---|
| Trabalho pesado/callback Android na isolate/thread de UI | Frames perdidos, botão Cancelar demora | Callbacks apenas capturam snapshot; parsing/agregação pura e I/O assíncrono fora do build | Já com rajadas de eventos ou payloads grandes |
| Polling de conectividade | Bateria, eventos perdidos, requests constantes | Callbacks de rede + probe somente por ação do usuário | Uso contínuo, mesmo com poucos usuários |
| Payload inteiro em memória | Pico de heap/OOM | Streaming e chunks limitados | Pode quebrar em dezenas/centenas de MB, dependendo do aparelho |
| Acumular download para medir bytes | Memória cresce com throughput | Contar e descartar chunks | Quanto mais rápida a rede, pior; potencialmente segundos |
| Várias execuções simultâneas | Mbps inflado/degradado, UI intercalada, custo duplicado | Single-flight por controller; iniciar novo exige cancelar/aguardar cleanup do anterior | Duas execuções já invalidam a medição |
| Retry automático | Uso de dados maior, causa mascarada | Sem retry automático em speed test; retry de probe leve, se houver, faz parte da amostra e é visível | Primeira falha em rede móvel já duplica custo |
| Misturar cold e warm requests | Primeira amostra muito maior | Definir se DNS/TCP/TLS fazem parte; manter ou separar aquecimento | Qualquer conexão com DNS/TLS/keep-alive |
| Média só dos sucessos | Aparência de ótima latência com muitas falhas | Sucessos e falhas separados, denominador visível; median/p95 apenas com amostra suficiente | Ex.: 1 sucesso rápido em 5 tentativas |
| Timeout como latência máxima/zero | Estatística sem significado | Latência indefinida para falha; taxa de falha separada | Na primeira falha |
| Servidor distante/saturado | Resultado baixo e variável | Locate/seleção documentada, registrar servidor, validar capacidade do servidor | Especialmente em regiões com pouca cobertura ou links rápidos |
| CPU/cripto/radio do aparelho vira gargalo | Plateau por modelo de telefone | Benchmark de client overhead e aparelhos representativos; declarar limite | Links rápidos e aparelhos modestos |
| Cap curto demais | Resultado dominado por slow start/aquecimento | Perfil de teste validado por faixa; marcar confiança baixa/inválido | Links de alta latência ou alta capacidade |
| Progresso baseado em tempo apenas | 100% antes de cleanup ou após cap | Progresso por fase + orçamento real, com estado final separado | Cancelamento, stall ou throughput variável |

## Erros de Segurança e Privacidade

| Erro | Risco | Prevenção |
|---|---|---|
| HTTP cleartext para probes | Interceptação/manipulação e falso diagnóstico | HTTPS; manter cleartext desabilitado; nenhuma exceção global de Network Security Config |
| Validador TLS permissivo | MITM em Wi-Fi hostil | Trust store normal; nunca aceitar todos os certificados/hostnames |
| Resposta sem limite/validação | Memória, parser abuse, portal HTML interpretado como dado | Status/schema/body cap/content-type/redirect e parser estrito |
| Segredo no APK | Extração e abuso da conta/quota | Não usar provedor que exija segredo no cliente; sem backend, isso é critério de exclusão |
| Logs com IP, URL assinada/token ou resultados | Exposição via log/suporte | Redação por padrão; logging de desenvolvimento opt-in e sem payload sensível |
| Política desatualizada | Violação Play/expectativa do usuário | Inventário de fluxos e checklist obrigatório a cada provider/SDK/release |
| Consentimento genérico de speed test | Usuário não entende dados/custo/publicação | Disclosure imediatamente antes do teste, específico ao provedor e por ação explícita |
| Compartilhamento integral padrão | Divulgação de rede interna/egress | Preview e modo redigido default/recomendado |
| Dependência não verificada | Permissões, trackers, endpoints ou native code inesperados | Publisher/repo/release cadence/license/transitives/manifest e análise do código crítico |
| Consultar múltiplos IP services “para redundância” | Amplia terceiros que veem IP | Um provider aprovado; fallback somente se política e necessidade justificarem |

## Armadilhas de UX

| Armadilha | Impacto no usuário | Melhor abordagem |
|---|---|---|
| Semáforo único “boa/ruim” | Falsa certeza e diagnóstico incorreto | Evidências em camadas, linguagem condicional e estado inconclusivo |
| Spinner global até tudo terminar | Parece travado; oculta parciais | Progresso por etapa e resultados concluídos permanecem visíveis |
| Cancelamento como erro vermelho | Usuário acha que algo quebrou | Estado neutro `Cancelado`, motivo e resultados parciais preservados |
| Reexecutar apaga resultados antes de iniciar | Perde evidência se nova execução falhar | Manter anterior marcado como antigo até primeira snapshot da nova; nunca misturar runs |
| Status apenas por cor/ícone | Inacessível e ambíguo | Texto, Semantics, unidades faladas e contraste; anunciar progresso/resultado sem chatter excessivo |
| Min/média/máx sem amostra/falhas | Números não auditáveis | Mostrar `n sucessos de m tentativas`, método, alvo e timeout |
| Erro técnico bruto | Usuário não sabe agir | `O alvo HTTPS não respondeu em 3 s`; detalhes técnicos opcionais e copiáveis |
| Mostrar `0 ms`, `0.0.0.0` ou `—` para indisponível | Parece medição real | Texto explícito `não disponível`, `não suportado` ou `não medido` |
| Speed test inicia ao abrir | Custo e surpresa | CTA manual + disclosure/consentimento antes de cada execução |
| Prometer cap impreciso | Quebra confiança/franquia | Informar exatamente o que é limitado, margem e bytes reais após teste |
| Layout de cards corta texto grande | Métricas ilegíveis | Responsividade por constraints, wrap, text scale e testes com fontes grandes |
| Atualizações rápidas falam sem parar no TalkBack | Experiência caótica | Anunciar mudança de fase e conclusão/erro, não cada amostra; status programaticamente determinável |
| Copiar sem confirmação visual/sem preview | Vaza dados ou parece não funcionar | Preview compartilhável, opção redigida e confirmação acessível |

## “Parece Pronto, Mas Não Está”

- [ ] **Conectividade:** Wi-Fi/celular não é usado como sinônimo de internet; `INTERNET`, `VALIDATED`, `CAPTIVE_PORTAL` e probe do app aparecem separados.
- [ ] **Portal cativo:** cenários de hotel/empresa, endpoint whitelisted, endpoint fora do ar e DNS interceptado não produzem conclusão absoluta.
- [ ] **Método:** cada latência mostra protocolo, alvo/porta, timeout, tentativas e se inclui DNS/TLS.
- [ ] **Estatística:** falhas têm denominador; média usa somente sucessos e não esconde o número de falhas; amostra vazia não vira zero.
- [ ] **Gateway:** vem da rota default, aceita ausência e não presume `.1` nem porta aberta.
- [ ] **Endereço:** IPv4 local está vinculado à rede padrão; IP público é descrito como egress observado pelo provedor.
- [ ] **Parciais:** timeout de IP público não apaga gateway/transporte/probes concluídos.
- [ ] **Cancelamento:** tráfego cessa, sockets/requests/streams/timers são fechados e nenhum evento tardio altera a UI.
- [ ] **Lifecycle:** pause, background, dispose, rotação/recriação e process kill foram considerados; retomada não continua sessão silenciosamente.
- [ ] **Troca de rede:** Wi-Fi→celular, VPN on/off e perda/reconexão invalidam a sessão em vez de misturar amostras.
- [ ] **Recursos:** soak de 100 start/cancel/dispose não aumenta callbacks, timers, sockets ou heap continuamente.
- [ ] **Permissões:** APK/AAB release contém somente permissões justificadas; `INTERNET` e `ACCESS_NETWORK_STATE` presentes; localização/nearby ausentes.
- [ ] **Segurança:** sem cleartext, sem TLS permissivo, sem secret no app e com limite/validação de resposta.
- [ ] **Privacidade:** provider, política, Data Safety e tela in-app concordam; logs e resumo não expõem IP sem ação/revisão.
- [ ] **Acessibilidade:** TalkBack anuncia fase/resultado, alvos têm tamanho adequado, text scaling não corta e estados não dependem só de cor.
- [ ] **Regressão:** as três ferramentas existentes têm characterization/widget tests antes da migração visual e continuam acessíveis na navegação.
- [ ] **Speed gate:** existe documento aprovado de protocolo, serviço, licença/termos, privacidade, custos, regiões, autenticação e depreciação — ou a fase está explicitamente adiada.
- [ ] **Dados do speed test:** cap agregado de payload e deadline são testados independentemente; retries não multiplicam tráfego; bytes finais aparecem.
- [ ] **Precisão:** metodologia foi comparada com implementação de referência e servidor controlado em aparelhos/redes representativos; resultado diz `estimativa`.
- [ ] **Publicação:** README, política de privacidade, permissões, limitações e fontes/provedores foram atualizados antes do release.

## Estratégias de Recuperação

| Armadilha encontrada tarde | Custo | Recuperação |
|---|---:|---|
| Booleano global de conectividade | MÉDIO | Introduzir modelo de evidências/capabilities, adaptar UI e adicionar fixtures de estados antes de novos probes |
| Probe mislabeled como ping | BAIXO-MÉDIO | Migrar modelo/cópia para método+alvo; versionar formato do resumo; corrigir docs sem preservar termo enganoso |
| Gateway adivinhado | MÉDIO | Remover inferência, implementar adapter de rota; enquanto não validado, exibir `indisponível` |
| Cancelamento cosmético | ALTO | Descer cancelamento a cada adapter, expor handles abortáveis e criar soak/lifecycle tests antes de release |
| Callback/stream leak | MÉDIO | Centralizar ownership em `OperationScope`, tornar cleanup idempotente, verificar contadores/heap |
| Provider de IP instável | BAIXO-MÉDIO | Desabilitar somente a etapa via configuração/release; manter parciais; substituir após nova revisão de privacidade/termos |
| Permissão sensível acidental | MÉDIO | Auditar merged manifest/dependências, remover/substituir plugin, atualizar Data Safety se alguma versão já foi publicada |
| Política/Data Safety incorretos | ALTO | Suspender feature/release afetado, corrigir fluxo e disclosures, buscar revisão jurídica/política antes de republicar |
| Endpoint de speed test sem autorização | ALTO | Remover/desabilitar fase, não “trocar URL” às pressas; reabrir seleção formal de provider ou adiar |
| Resultados de velocidade inconsistentes | ALTO | Rebaixar para experimental/estimativa, registrar metodologia, criar harness controlado e recalibrar critérios de validade |
| Cap de dados excedido | CRÍTICO | Desabilitar teste, implementar budget no transport layer e validação independente antes de restaurar |
| Regressão de ferramenta existente | BAIXO-MÉDIO | Reverter apenas a migração visual da tela afetada, manter componentes novos isolados e corrigir com characterization tests |

## Mapeamento Armadilha → Fase

| Armadilha | Fase de prevenção | Verificação obrigatória |
|---|---|---|
| Regressão na modernização | Fase 1 — fundação/UI | Characterization + widget/golden dos fluxos existentes, tema claro/escuro, compact/large e text scale |
| Estado técnico comunicado apenas visualmente | Fase 1 — componentes de estado | Semantics/TalkBack, status anunciado, contraste e toque ≥ 48 dp |
| Transporte ≠ internet / portal cativo | Fase 2 — modelo Android | Matriz offline/Wi-Fi/celular/portal/VPN/DNS quebrado com estados distintos |
| IPv4/gateway errados | Fase 2 — adapter de rede local | Fixtures de rotas + aparelhos reais; default route, ausência, multihoming e IPv6-only |
| Probe mislabeled / estatística enganosa | Fase 2 — probe domain | Contract tests por método; snapshots/resumo contêm target, timeout, attempts e failures |
| Endpoint/IP provider frágil | Fase 2 — provider decision | Testes de status, timeout, redirect, HTML, body grande, IPv6 e outage; falha permanece parcial |
| Cancelamento/lifecycle/leaks | Fase 2 — operation runtime | Testes cancel-before/during/after, pause/dispose/network switch e soak repetido |
| Testes acoplados à rede real | Fase 2 — interfaces/harness | Unit tests sem rede e sem delays reais; contract tests por adapter; integração Android separada |
| Permissões excessivas | Fase 2 + cada dependency gate | Diff do merged manifest de release e teste sem location/nearby |
| Privacy/Play inconsistente | Fase 2 release docs | Inventário de transmissão, política in-app/store e Data Safety revisados |
| Serviço/licença de speed test | Fase 3 gate zero | ADR com evidência oficial de integração, termos, custos, privacidade, auth e plano de saída |
| Precisão e server selection | Fase 3 methodology | Harness controlado, referência, múltiplos devices/links, servidor/protocolo e confidence criteria |
| Cap real de bytes/duração | Fase 3 transport | Contador independente confirma teto; cancelamento interrompe tráfego; nenhum retry automático |
| Memória/CPU sob velocidade | Fase 3 performance | Streaming/chunking, heap e frame profiling em link rápido/aparelho modesto |
| Dados publicados/consentimento | Fase 3 privacy gate | Disclosure imediatamente anterior, aceite exigido pelo provider, bytes e publicação explícitos |
| Drift de endpoint/policy/plugin | Todo release | Contract smoke test, revisão de changelog/termos/política/manifest e kill switch por capacidade |

## Perguntas que Devem Bloquear Planejamento Detalhado

### Antes da Fase 2

1. Quais versões Android/minSdk/targetSdk serão suportadas, e qual API/plugin expõe rede padrão, `NetworkCapabilities` e `LinkProperties` sem ampliar permissões?
2. Como o adapter identifica de forma estável a rede padrão durante uma sessão e informa troca?
3. Qual provider de IPv4 público tem documentação, privacidade, autorização de uso e resposta testável? Há fallback aprovado ou apenas estado indisponível?
4. Qual probe externo é autorizado e o que exatamente seu sucesso/falha permite afirmar?
5. Existe método honesto para probe do gateway nos aparelhos-alvo? Se não, o roadmap deve entregar apenas descoberta de rota.
6. Quais timeouts por fase, intervalo de amostra e deadline total equilibram utilidade e falsa “perda”?

### Gate zero da Fase 3

1. O serviço aceita integração por aplicativo terceiro, inclusive distribuição comercial, sem segredo embutido nem backend?
2. O que é coletado, retido e publicado? Consentimento por execução é obrigatório? Há transferência internacional relevante?
3. Qual protocolo/versão e cliente oficial serão usados? Quem mantém Android/Flutter binding e por quanto tempo?
4. Como servidor é selecionado e o que ocorre sem servidor próximo? Há quota, prioridade, custo ou token?
5. Qual teto agregado de payload e duração, incluindo download/upload/discovery/retry/overhead, será prometido?
6. Qual constructo o resultado representa: single-stream bulk throughput, multistream link estimate ou outro?
7. Qual faixa de velocidade o aparelho e servidor conseguem medir antes de CPU, TLS, radio ou capacidade do servidor dominarem?
8. Quais critérios tornam uma sessão inválida/incompleta? Como rede móvel, VPN, background e troca de rede são tratados?
9. Qual plano de desligamento preserva o app quando provider, termos, preço ou endpoint mudar?

Se qualquer resposta crítica permanecer sem evidência oficial e teste, a recomendação é **adiar a Fase 3**, não preencher lacunas com endpoints públicos informais.

## Fontes Primárias e Confiança

### Android e Flutter — ALTA

- [Android: Read network state](https://developer.android.com/develop/connectivity/network-ops/reading-network-state) — rede padrão dinâmica, `LinkProperties`, transportes múltiplos, `INTERNET` versus `VALIDATED`, `CAPTIVE_PORTAL`, callbacks, race conditions e cleanup.
- [Android: `NetworkCapabilities`](https://developer.android.com/reference/android/net/NetworkCapabilities) — significado oficial das capabilities e aviso de que `INTERNET` pode não fornecer conectividade real.
- [Android: `ConnectivityManager`](https://developer.android.com/reference/android/net/ConnectivityManager) — lifetime, `unregisterNetworkCallback`, permissão e limite de callbacks/requests.
- [Android: `LinkProperties`](https://developer.android.com/reference/android/net/LinkProperties) e [`RouteInfo`](https://developer.android.com/reference/android/net/RouteInfo) — endereços, rotas, default route e gateway possivelmente nulo.
- [Android: Connect to the network](https://developer.android.com/develop/connectivity/network-ops/connecting) — `INTERNET`/`ACCESS_NETWORK_STATE` normais, HTTPS, repository e trabalho fora da UI.
- [Android: Wi-Fi permissions](https://developer.android.com/develop/connectivity/wifi/wifi-permissions) — `NEARBY_WIFI_DEVICES`, localização e APIs Wi-Fi protegidas.
- [Android: Cleartext communications](https://developer.android.com/privacy-and-security/risks/cleartext-communications) — risco de interceptação/manipulação e mitigação HTTPS.
- [Flutter: `AppLifecycleState`](https://api.flutter.dev/flutter/dart-ui/AppLifecycleState.html) e [`AppLifecycleListener`](https://api.flutter.dev/flutter/widgets/AppLifecycleListener-class.html) — estados, callbacks, dispose e ausência de garantia de todas as notificações.
- [Dart: `HttpClientRequest.abort`](https://api.dart.dev/dart-io/HttpClientRequest/abort.html) e [`Socket.destroy`](https://api.dart.dev/dart-io/Socket/destroy.html) — cancelamento físico dos recursos.

### Captive portal e métricas — ALTA/MÉDIA-ALTA

- [RFC 8952: Captive Portal Architecture](https://www.rfc-editor.org/rfc/rfc8952.html) — limitações e falsos negativos de canary HTTP; motivação para CAPPORT.
- [RFC 8908: Captive Portal API](https://www.rfc-editor.org/rfc/rfc8908.html) e [RFC 8910](https://www.rfc-editor.org/rfc/rfc8910.html) — estado captive padronizado, descoberta e TLS.
- [RFC 6673: Round-Trip Packet Loss Metrics](https://www.rfc-editor.org/rfc/rfc6673.html) — taxa de perda com denominador e parâmetros explícitos.
- [RFC 6703: Reporting IP Network Performance Metrics](https://www.rfc-editor.org/rfc/rfc6703.html) — separar loss/delay e tratamento de amostras perdidas.
- [Java `InetAddress.isReachable`](https://docs.oracle.com/en/java/javase/12/docs/api/java.base/java/net/InetAddress.html) — implementação pode usar ICMP privilegiado ou TCP Echo; o método real não deve ser presumido.

### Flutter packages — MÉDIA-ALTA (documentação do mantenedor, ainda requer spike)

- [`connectivity_plus`](https://pub.dev/packages/connectivity_plus) — avisa explicitamente que tipo de conectividade não garante internet.
- [`network_info_plus`](https://pub.dev/packages/network_info_plus) — capacidades, requisitos atuais de toolchain e permissões para dados Wi-Fi protegidos; validar compatibilidade antes de adotar.
- [`async` `CancelableOperation`](https://pub.dev/documentation/async/latest/async/CancelableOperation-class.html) — operação cancelável exige callback de cancelamento; por si só não prova aborto do transporte.
- [`flutter_speed_test_plus`](https://pub.dev/packages/flutter_speed_test_plus) — exemplo do risco: package de uploader não verificado, licença MIT do código e defaults de serviços terceiros não substituem autorização/termos oficiais.

### Speed test, dados e integração — ALTA para M-Lab; MÉDIA para provider ainda não escolhido

- [M-Lab: NDT](https://www.measurementlab.net/tests/ndt/) e [NDT7 protocol](https://www.measurementlab.net/tests/ndt/ndt7/) — single-stream bulk transport, métricas e dados coletados.
- [M-Lab: FAQ](https://www.measurementlab.net/frequently-asked-questions/) — IP/resultados publicados e retidos, duração típica e limitações.
- [M-Lab: Experimenter requirements](https://www.measurementlab.net/experimenter-requirements-guidelines/) — consentimento, minimização e política pública.
- [M-Lab: NDT7 access tokens](https://www.measurementlab.net/blog/why-access-tokens/) — Locate API token e suporte de clientes.
- [M-Lab: Locate API](https://www.measurementlab.net/develop/locate-v1/) — seleção de servidor, cache/invalidation e geolocalização.
- [M-Lab: Limits of single-stream interpretation](https://www.measurementlab.net/blog/measurement-observations-on-network-performance-during-the-COVID-19-pandemic-in-Northern-Italy/) — bulk transport não equivale automaticamente à capacidade anunciada do acesso e uma medição isolada não caracteriza a rede.
- [M-Lab: transfer-limit analysis](https://website.mlab-sandbox.measurementlab.net/blog/short-ndt/) — ordem de grandeza de dados em links rápidos e trade-off entre cap e precisão.

### Privacidade, políticas e acessibilidade — ALTA para requisitos publicados; revisão jurídica necessária para aplicação

- [Google Play User Data policy](https://support.google.com/googleplay/android-developer/answer/10144311) e [Data Safety](https://support.google.com/googleplay/android-developer/answer/10787469) — responsabilidade por SDKs/terceiros, transmissão off-device e inferência por IP.
- [Google Play: SDKs safely](https://support.google.com/googleplay/android-developer/answer/13326895) — coleta de SDK deve ser tratada como coleta do app.
- [Lei Geral de Proteção de Dados, Lei 13.709/2018](https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709compilado.htm) — definição legal de dado pessoal e bases de tratamento; aplicação concreta deve ser revisada juridicamente.
- [Android accessibility](https://developer.android.com/guide/topics/ui/accessibility/views/apps-views) — alvo de toque recomendado de 48 dp e descrições acessíveis.
- [W3C WCAG 2.2: Status Messages](https://www.w3.org/WAI/WCAG22/Understanding/status-messages.html) — progresso, sucesso e erro precisam ser programaticamente percebidos por tecnologia assistiva.

## Lacunas e Limites da Pesquisa

- Nenhum provider de IP público ou probe externo foi selecionado; termos, privacidade, SLA e quotas continuam sendo gate da Fase 2.
- Nenhum protocolo/provider de speed test foi escolhido. M-Lab é evidência concreta de trade-offs, não recomendação automática.
- Não foi encontrada documentação oficial suficiente que autorize usar APIs internas/defaults de Fast.com ou Ookla por meio de packages comunitários. Ausência de evidência não prova proibição; prova que a integração não deve entrar no roadmap como aprovada.
- A disponibilidade de gateway e capacidades exatas por versão Android precisa de spike em devices reais e no minSdk/targetSdk final.
- Classificação e base legal de cada fluxo sob LGPD dependem de finalidade, provider, retenção e distribuição; obter revisão jurídica antes da Fase 3 pública.

---
*Pesquisa de armadilhas para: Tools App — Diagnóstico de Internet e Evolução da UI*
*Pesquisado em: 2026-08-10*
