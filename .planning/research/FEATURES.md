# Pesquisa de Funcionalidades

**Domínio:** Aplicativo móvel Android-first de utilidades técnicas e diagnóstico confiável de conectividade
**Pesquisado em:** 2026-08-10
**Confiança:** ALTA para o diagnóstico básico e acessibilidade; MÉDIA para speed test, que depende de provedor, licença e protocolo ainda não escolhidos

## Panorama de Funcionalidades

### Table Stakes (usuários esperam)

Sem estes comportamentos, a ferramenta parece incompleta ou, pior, produz uma conclusão enganosa.

| Funcionalidade/comportamento | Por que é esperado | Complexidade | Observações de implementação e contrato de UX |
|---|---|---:|---|
| Entrada clara pela área de ferramentas | Com o crescimento de três para quatro ou mais utilidades, o usuário precisa localizar cada ferramenta sem adivinhar em qual aba ela está | MÉDIA | Modernizar a navegação incrementalmente; manter as três ferramentas atuais acessíveis e sem regressões; usar grade/categorias em largura compacta e navegação adaptada em largura ampla conforme o futuro UI-SPEC |
| Componentes e estados visuais consistentes | Uma ferramenta técnica deve usar os mesmos padrões para executar, cancelar, copiar, carregar e apresentar erros | MÉDIA | Criar primitives reutilizáveis para ação principal, progresso, cartão de métrica, resultado, indisponibilidade e ação de cópia; preservar tema claro/escuro |
| Execução explicitamente iniciada pelo usuário | Probes consomem rede, e o speed test poderá consumir muitos dados | BAIXA | Exibir `Iniciar diagnóstico`, `Cancelar` durante execução e `Executar novamente` ao terminar; nunca iniciar speed test automaticamente |
| Progresso por etapa e cancelamento real | Operações de rede podem demorar, falhar ou ficar sem resposta | MÉDIA | Mostrar a etapa corrente e as etapas concluídas; cancelamento deve interromper novos probes, descartar respostas tardias e preservar resultados já concluídos; não apresentar cancelamento como erro |
| Snapshot do transporte e das capacidades da rede | “Wi-Fi conectado” não prova acesso à internet; Android pode relatar múltiplos transportes, VPN, rede medida e capacidades mutáveis | MÉDIA | Nomear `Wi-Fi`, `dados móveis`, `Ethernet`, `VPN` e `outro` somente quando a plataforma os fornecer; distinguir rede configurada para internet (`INTERNET`) de acesso público validado (`VALIDATED`); registrar que é um snapshot |
| Estado de internet pública e portal cativo | Usuários precisam distinguir “sem rede”, “rede local apenas”, “login necessário” e “internet validada” | MÉDIA | Exibir estados separados: sem rede padrão, rede sem capacidade de internet, possível portal cativo, internet validada e estado inconclusivo; não substituir o probe próprio apenas pelo sinal do sistema |
| IPv4 local com escopo | É um dado básico para suporte de rede e para interpretar o alcance ao gateway | MÉDIA | Identificar o endereço IPv4 da rede padrão usada pelo app; não misturar loopback, link-local ou interfaces inativas; se houver VPN/múltiplas interfaces, informar a origem ou indisponibilidade |
| IP público com provedor, timeout e privacidade | O usuário espera comparar endereço local e saída pública, mas a consulta revela o IP ao serviço consultado | MÉDIA | Consultar por HTTPS via adaptador; validar formato; nomear o provedor e incluir link/política aplicável; mostrar `indisponível` sem invalidar outras métricas; evitar afirmar que o IP identifica exatamente o dispositivo |
| Gateway padrão quando disponível | Ajuda a separar problema de LAN/Wi-Fi de problema externo | ALTA | Derivar da rota da rede padrão, não de suposição como `.1`; mostrar `não informado pela plataforma/rede` quando ausente; Android expõe rotas e endereços via `LinkProperties`, mas o comportamento concreto precisa de spike no plugin/platform channel |
| Probe do gateway com método real | Alcance ao primeiro salto é um sinal central para diagnóstico local | ALTA | ICMP não é garantido; usar adaptador com método explicitado (`ICMP`, conexão TCP ou outro); mostrar alvo, porta quando aplicável, timeout e amostras válidas; ausência de gateway não deve derrubar a execução |
| Probe externo com método e alvo reais | É necessário testar além do simples estado do transporte | ALTA | Exibir, por exemplo, `Conexão TCP: host:porta` ou `Requisição HTTPS: URL`, nunca chamar isso de “ping ICMP”; alvo deve ser estável, autorizado e substituível; o teste prova alcance apenas daquele caminho/alvo |
| Série de amostras e agregação compreensível | Uma única amostra é muito sensível a ruído | MÉDIA | Exibir número de tentativas, sucessos/falhas, mínimo, média e máximo em ms; mostrar “perda” apenas com denominador (`2 de 5 falharam, 40%`) e deixar claro que é perda/falha do método, não necessariamente perda ICMP |
| Resultados parciais | Falha no IP público não apaga o fato de que gateway e internet podem estar acessíveis | MÉDIA | Cada etapa termina em sucesso, falha, indisponível, cancelada ou não executada; resumo global nunca descarta evidências concluídas |
| Timestamp e contexto mínimo da execução | Resultados de conectividade envelhecem rapidamente e mudam com a rede | BAIXA | Mostrar início/fim ou `Última execução`; incluir transporte(s), método, alvo e quantidade de amostras no resumo; marcar resultado como pertencente à rede padrão observada no início/fim |
| Resumo copiável/compartilhável em texto | Profissionais precisam enviar evidências a suporte sem transcrever cartões | MÉDIA | Texto legível e estável, em pt-BR, com estados, unidades, horário, métodos e limitações; omitir identificadores desnecessários e permitir revisar antes de compartilhar |
| Timeouts e recuperação em todas as etapas | Offline, DNS quebrado, firewall e serviços indisponíveis são cenários normais do produto | MÉDIA | Definir timeout por adaptador e orçamento total da execução; erro oferece `Tentar novamente`; nenhum spinner infinito ou exceção técnica bruta |
| Tratamento de lifecycle e mudança de rede | Android pode pausar, retomar ou trocar a rede padrão durante uma medição | ALTA | Ao pausar/sair, cancelar ou desacoplar a apresentação; ao trocar de rede, invalidar ou encerrar a amostra e explicar `A rede mudou durante o teste`; liberar callbacks e sockets |
| Acessibilidade verificável | Métricas visuais e estados por cor excluem usuários de leitor de tela, baixa visão ou mobilidade reduzida | MÉDIA | Rótulos semânticos completos (`Latência média: 24 milissegundos`), ordem de foco lógica, estado não comunicado somente por cor, suporte a escala de texto sem corte, contraste mínimo 4,5:1 para texto pequeno e alvos Android de pelo menos 48x48 dp; testar com Guideline API e TalkBack |
| Estados vazios e de falha em linguagem acionável | A tela precisa continuar útil exatamente quando a rede está quebrada | MÉDIA | Ver matriz de estados abaixo; informar o que foi observado, o que não pôde ser medido e uma próxima ação segura, sem culpar ISP/roteador sem evidência |

#### Speed test: table stakes somente após aprovação da fase separada

| Funcionalidade/comportamento | Por que é esperado | Complexidade | Observações de implementação e contrato de UX |
|---|---|---:|---|
| Tela de consentimento antes de cada teste | Transferência ativa pode consumir franquia e enviar IP/resultado ao provedor | MÉDIA | Exibir provedor, política de dados, rede medida/móvel, limite máximo de bytes e duração; confirmar explicitamente; não esconder consentimento em termos gerais |
| Download e upload em Mbps | São as duas métricas centrais de capacidade | ALTA | Apresentar como estimativa do protocolo/servidor usado; separar direções; não converter um fluxo único em promessa de velocidade máxima universal |
| Latência ociosa e, se validada, sob carga | Velocidade sem responsividade não explica chamadas/jogos lentos | ALTA | Não prometer latência sob carga até o protocolo suportá-la e a metodologia ser validada; identificar método e fase da medição |
| Servidor/provedor e metodologia visíveis | A distância, seleção de servidor, TCP e limites do cliente afetam o número | ALTA | Exibir provedor/protocolo, localização quando confiável, seleção automática/manual se suportada, horário, duração, bytes transferidos e aviso de estimativa |
| Progresso, limite de dados/tempo e cancelamento imediato | O usuário deve controlar custo e duração | ALTA | Progresso por download/upload; cap rígido de bytes e duração; uma execução por vez; cancelamento fecha streams/sockets e não publica resultado incompleto como válido |
| Invalidação por troca/perda de rede | Misturar Wi-Fi e dados móveis no mesmo resultado torna a medida sem sentido | ALTA | Encerrar ou marcar inválido quando a rede padrão/transporte muda; nunca combinar amostras de duas redes em um Mbps único |
| Falha e resultado parcial honestos | Upload pode falhar depois de um download válido | MÉDIA | Mostrar direção concluída separadamente e marcar a sessão incompleta; distinguir timeout, cancelamento, limite atingido e falha de servidor |

### Diferenciadores (vantagem competitiva)

| Funcionalidade | Proposta de valor | Complexidade | Observações |
|---|---|---:|---|
| Diagnóstico em camadas (“rede → gateway → internet → serviço externo”) | Ajuda o usuário a localizar a provável camada do problema em vez de receber apenas um semáforo genérico | ALTA | Inferências devem usar linguagem cautelosa: `O gateway respondeu, mas o alvo externo não`; não concluir automaticamente “problema no ISP” |
| Proveniência ao lado de cada métrica | Torna o resultado auditável por técnicos e evita falsa precisão | MÉDIA | Cada métrica carrega método, alvo/provedor, número de amostras, horário e motivo quando indisponível; alinhado ao valor central de transparência |
| Resumo de evidências e limitações | Facilita suporte remoto e ensina o usuário a interpretar o resultado | MÉDIA | Gerar um bloco textual com “observado”, “não medido” e “limitações”; sem jargão excessivo e sem expor dados além dos escolhidos |
| Modo básico de privilégio mínimo | Entrega utilidade sem exigir localização, SSID/BSSID, conta ou varredura de LAN | MÉDIA | Mostrar `Nome da rede não coletado` em vez de pedir permissão; recursos futuros que precisem de nova permissão devem ser opcionais e separados |
| Continuidade visual entre utilidades offline e diagnóstico | Faz o app parecer uma caixa de ferramentas coerente, não uma coleção de telas desconexas | MÉDIA | Mesmos cartões, validação, cópia, unidades, estados e hierarquia em calculadora IPv4, conversor, hashes e diagnóstico |
| Reexecutar somente uma etapa falha, após o MVP | Reduz tempo e tráfego ao testar a recuperação de um serviço específico | MÉDIA | Adicionar somente se o modelo de execução preservar contexto e deixar claro que os timestamps das etapas diferem |
| Indicador de confiança/validade do speed test | Diferencia uma estimativa rápida de um benchmark reproduzível | ALTA | Derivar de critérios explícitos (duração mínima, bytes, estabilidade da rede, fase completa), não de um score opaco |
| Orçamento configurável de speed test | Permite testar com responsabilidade em planos móveis | ALTA | Oferecer perfis como `econômico` e `completo` apenas se a metodologia provar utilidade; sempre mostrar limites concretos, não adjetivos isolados |

### Anti-Features (pedidos comuns que prejudicam este ciclo)

| Anti-feature | Por que é pedido | Por que é problemático | Alternativa recomendada |
|---|---|---|---|
| Conta, login, backend ou sincronização | Facilita “salvar tudo” e usar em vários aparelhos | Acrescenta identidade, segurança, custo operacional e tratamento de dados sem validar valor | Sessão local efêmera e resumo copiável/compartilhável |
| Histórico persistente de diagnósticos | Parece útil para comparar incidentes | Exige retenção, migração, exclusão, contexto de rede e política de privacidade; números de redes diferentes são facilmente comparados de forma errada | Apenas última execução em memória nesta versão; usuário exporta o resumo quando necessário |
| Analytics/telemetria de resultados ou identificadores | Ajuda a observar uso e falhas em produção | IP público, contexto de rede e resultados podem ser sensíveis; contradiz o posicionamento local-first | Testes controlados, logs locais de desenvolvimento sem dados pessoais e feedback voluntário fora do resultado |
| Coletar SSID/BSSID ou pedir localização “por garantia” | Dá um nome conveniente à rede | Android trata campos Wi-Fi como sensíveis à localização; aumenta permissões, fricção e risco sem ser necessário ao MVP | Transporte, IPv4, rota e estado disponibilizados sem nome da rede; explicar que SSID não é coletado |
| Scanner de dispositivos, portas, Wi-Fi vizinho, WHOIS, DNS benchmark ou traceroute já no MVP | Concorrentes reúnem muitas ferramentas de rede | Amplia permissões, superfície de abuso, tempo de execução e escopo; desvia do diagnóstico básico validável | Registrar como backlog separado e só promover com caso de uso, ameaça/permissão e método definidos |
| “Conectado” baseado somente no tipo de transporte | É simples de implementar e comunicar | Wi-Fi/celular pode estar sem internet, atrás de portal cativo ou com DNS quebrado | Estados separados de transporte, capacidade, validação do sistema e probes do app |
| Score único “Internet boa/ruim” | Parece mais fácil que interpretar métricas | Esconde alvo, método, carga e limiares; sugere certeza que os sinais não sustentam | Mostrar evidências, unidades, limiares documentados quando existirem e explicação de limitações |
| Chamar TCP/HTTPS de “ping” ou “perda de pacotes ICMP” | O termo é familiar | É tecnicamente falso e pode levar a diagnóstico incorreto | Nomear `latência de conexão TCP`, `tempo de resposta HTTPS` ou `ICMP`, conforme o adaptador real |
| Afirmar causa (“roteador com defeito”, “ISP fora do ar”) | Usuário quer uma resposta direta | Um teste no telefone e em um único alvo não exclui firewall, DNS, VPN, servidor ou interferência | Usar hipótese condicionada: `Possível problema entre...`; recomendar próximo teste observável |
| Speed test automático, em background ou agendado | Cria histórico sem esforço | Consome dados/bateria, pode incorrer custo e executar em rede móvel sem consentimento | Execução manual, confirmação por teste e limites rígidos |
| Speed test sem cap, duração e bytes visíveis | Pode alcançar links rápidos com mais saturação | Consumo imprevisível e risco de custo; medição pode degradar a própria rede | Orçamento fixo e mostrado antes/depois; interromper ao atingir limite |
| Incorporar uma página pública/`WebView` de speed test sem acordo | Acelera a implementação | Termos, tracking, UX, cancelamento e estabilidade ficam fora do controle; difícil testar e rotular dados | SDK/protocolo licenciado e documentado, ou servidor controlado atrás de adaptador; adiar se não houver solução |
| Publicar resultados em serviço externo por padrão | Alguns protocolos de pesquisa fazem isso | O usuário pode não esperar que IP e resultados sejam retidos/publicados | Provedor com contrato de privacidade compatível, consentimento explícito e alternativa adiada/privada quando necessário |
| Garantir precisão absoluta ou equivalência com Ookla/Fing/ISP | Facilita marketing e comparação | Servidor, TCP, rádio, CPU, VPN e carga alteram o resultado; metodologias não são intercambiáveis | Rotular como estimativa do método usado e documentar condições de validade |
| Paridade prometida entre Android, iOS, web e desktop | Flutter compartilha UI | APIs de rota, gateway, transporte, ICMP, permissões e lifecycle variam | Android-first; capabilities por plataforma e `indisponível nesta plataforma` sem emulação enganosa |
| Reescrita total da UI antes de entregar valor | Parece produzir consistência rapidamente | Aumenta regressões e posterga validação do diagnóstico | Migrar componentes e telas em fatias verificáveis, preservando contratos existentes |

## Contrato de Estados e Falhas

| Estado | O que mostrar | Ações | O que não fazer |
|---|---|---|---|
| Inicial/vazio | Explicação curta do que será consultado e que nenhum teste foi executado | `Iniciar diagnóstico` | Mostrar zeros como se fossem resultados |
| Em execução | Etapa atual, etapas concluídas, tempo decorrido opcional e resultados parciais | `Cancelar` | Bloquear navegação, esconder resultados ou iniciar segunda execução |
| Sem rede padrão | Transporte `nenhum`, demais etapas como não executadas/indisponíveis | `Tentar novamente`; atalho a configurações somente se seguro | Exibir exceção ou spinner infinito |
| Rede local sem internet validada | Transporte e endereço local, estado de validação e possível portal cativo | Repetir após login/ajuste | Declarar “offline” se o estado for apenas inconclusivo |
| Portal cativo | `Login na rede pode ser necessário`, sinal do sistema e probes observados | Orientar abrir fluxo do sistema/configurações quando suportado | Tentar contornar o portal ou afirmar que o app autenticou |
| Gateway ausente | IPv4/transporte preservados; gateway `não informado/disponível` | Continuar probe externo | Tratar toda a execução como falha |
| Serviço de IP público indisponível/inválido | Motivo sanitizado, provedor e timeout; outras métricas preservadas | Repetir só a etapa futuramente ou toda execução no MVP | Confundir falha do provedor com ausência de internet |
| Probe com timeout/falha parcial | Sucessos, falhas e denominador; método/alvo | Repetir | Converter timeout automaticamente em 100% de perda ICMP |
| Rede mudou | Transporte/rede inicial e final quando detectáveis; sessão inválida ou interrompida | Reiniciar na rede atual | Agregar amostras de redes diferentes |
| Cancelado | Horário, etapas concluídas, demais como canceladas/não executadas | `Executar novamente` | Disparar snackbar de erro ou atualizar com respostas tardias |
| App pausado/tela descartada | Na retomada, resultado concluído válido ou estado cancelado conforme política definida | Reiniciar quando necessário | Manter callback/socket órfão ou chamar UI descartada |
| Falha inesperada interna | Mensagem genérica acionável e resultados seguros já concluídos | `Tentar novamente`; copiar detalhes técnicos sanitizados opcionalmente | Mostrar stack trace, token, URL sensível ou travar |
| Speed test em rede medida/móvel | Aviso com cap de dados, duração e provedor | `Continuar` / `Cancelar` | Iniciar por countdown automático ou consentimento implícito |
| Speed test incompleto | Direção concluída separada; sessão `incompleta` | Reexecutar com novo consentimento | Apresentar um único resultado “final” válido |

## Dependências entre Funcionalidades

```text
Design contract + componentes reutilizáveis
    ├──habilita──> Migração sem regressão das 3 ferramentas existentes
    └──habilita──> Tela e estados do diagnóstico

Adaptadores testáveis de plataforma/rede
    ├──habilitam──> Snapshot de transporte/capacidades
    ├──habilitam──> IPv4 local + gateway
    ├──habilitam──> Probe do gateway
    └──habilitam──> Probe externo + IP público

Snapshot de rede + modelo de execução cancelável
    ├──habilitam──> Resultados parciais e lifecycle seguro
    ├──habilitam──> Detecção de troca de rede
    └──habilitam──> Agregação de múltiplas amostras

Métricas tipadas + proveniência
    ├──habilitam──> Cartões acessíveis
    └──habilitam──> Resumo copiável/compartilhável

Decisão de provedor/licença/privacidade + protocolo validado
    └──exigidos por──> Speed test
                         ├──exige──> Consentimento + orçamento de dados/tempo
                         ├──exige──> Progresso + cancelamento + exclusão mútua
                         └──exige──> Validação por rede estável e servidor controlado/simulável

Coleta de SSID/BSSID/localização ──conflita com──> MVP de privilégio mínimo
Histórico/telemetria ──conflitam com──> escopo local-first e privacidade do ciclo
```

### Notas de dependência

- **A UI foundation precede a expansão:** componentes e estados comuns reduzem duplicação e permitem migrar as telas existentes antes de adicionar mais uma experiência de execução assíncrona.
- **A captura de contexto precede as métricas:** transporte, rede padrão e timestamp precisam ser associados à execução; sem isso, uma troca Wi-Fi/celular pode produzir um agregado inválido.
- **A proveniência é parte do modelo, não decoração:** método, alvo, provedor, amostras e motivo de indisponibilidade devem existir nos modelos de domínio para alimentar UI, testes e resumo textual.
- **Gateway e probes precisam de adapters separados:** a ausência de uma rota/gateway não deve impedir IP público ou probe externo, e uma falha de um endpoint não deve invalidar os demais.
- **Speed test depende de uma decisão externa bloqueante:** não planejar implementação antes de validar termos/licença, política de dados, sustentabilidade do servidor, seleção geográfica, limite de transferência e compatibilidade Android/Flutter.
- **Acessibilidade atravessa todas as fases:** estados, métricas, progresso e ações precisam de semântica/testes desde o componente base; não é uma fase de polimento posterior.

## Definição do MVP

### Entregar no v1 deste ciclo

- [ ] Navegação/arquitetura visual moderna e adaptativa, com componentes reutilizáveis e temas claro/escuro — sustenta as ferramentas atuais e futuras.
- [ ] Migração sem regressão da calculadora IPv4, conversor de armazenamento e gerador de hashes — preserva valor existente.
- [ ] Tela de diagnóstico com execução manual, progresso por etapa, cancelamento, repetição e última execução — contrato mínimo de controle.
- [ ] Transporte/capacidades, IPv4 local, IP público e gateway quando disponível — contexto mínimo de rede com indisponibilidade honesta.
- [ ] Probe do gateway e externo, com método/alvo explícitos e múltiplas amostras — núcleo diagnóstico.
- [ ] Mínimo/média/máximo, sucessos/falhas, resultados parciais e matriz completa de falhas — evita falsa certeza.
- [ ] Resumo copiável/compartilhável com proveniência e limitações — principal fluxo de suporte.
- [ ] Acessibilidade e lifecycle verificados em Android, Wi-Fi, dados móveis e offline — qualidade funcional, não opcional.
- [ ] Documentação de permissões, provedor de IP público e privacidade — requisito de confiança.

### Adicionar após validar o diagnóstico básico (v1.x)

- [ ] Reexecutar uma etapa específica — adicionar se testes com usuários mostrarem valor e o modelo suportar timestamps mistos claramente.
- [ ] Recomendações de próxima ação baseadas em regras simples e auditáveis — somente após validar que não produzem conclusões causais excessivas.
- [ ] Mais de um alvo/provedor como fallback — somente com termos, privacidade e semântica de comparação definidos.

### Consideração futura (v2+; fase independente)

- [ ] Speed test de download/upload — apenas após gate técnico, legal, financeiro e de privacidade.
- [ ] Latência sob carga e indicador de confiança — depois de validar protocolo e servidor controlado/simulável.
- [ ] Orçamento configurável de dados — depois de provar que perfis menores continuam produzindo estimativas úteis.
- [ ] DNS lookup/traceroute e outras ferramentas avançadas — cada uma como utilidade separada com permissões, ameaça e método próprios.

**Deferir explicitamente:** contas/backend, histórico persistente, telemetria, SSID/BSSID/localização, varredura de LAN/portas, execução automática e paridade multiplataforma não verificada.

## Matriz de Priorização

| Funcionalidade | Valor para usuário | Custo | Prioridade |
|---|---:|---:|---:|
| Componentes/estados e navegação adaptativa | ALTO | MÉDIO | P1 |
| Preservação das três ferramentas atuais | ALTO | MÉDIO | P1 |
| Execução/cancelamento/lifecycle | ALTO | ALTO | P1 |
| Transporte, capacidades e captive portal | ALTO | MÉDIO | P1 |
| IPv4 local e gateway quando disponível | ALTO | ALTO | P1 |
| IP público com disclosure | MÉDIO | MÉDIO | P1 |
| Probes por método real + múltiplas amostras | ALTO | ALTO | P1 |
| Resultados parciais e falhas acionáveis | ALTO | MÉDIO | P1 |
| Resumo compartilhável com proveniência | ALTO | MÉDIO | P1 |
| Acessibilidade verificável | ALTO | MÉDIO | P1 |
| Reexecutar uma única etapa | MÉDIO | MÉDIO | P2 |
| Regras de próxima ação | MÉDIO | MÉDIO | P2 |
| Speed test com consentimento e caps | ALTO | ALTO | P3 / gateado |
| Latência sob carga/confiança | MÉDIO | ALTO | P3 |
| Scanner/traceroute/DNS avançado | BAIXO neste ciclo | ALTO | Fora do escopo |

**Chave:** P1 = obrigatório para lançar o diagnóstico básico; P2 = após validação; P3 = futuro condicionado.

## Análise de Referências do Ecossistema

| Comportamento | Fing Mobile | Network Analyzer | M-Lab NDT | Abordagem do Tools App |
|---|---|---|---|---|
| Organização | Agrupa desempenho, segurança e troubleshooting | Coleção de ferramentas técnicas | Teste focado de capacidade | Caixa de ferramentas coesa, mas escopo inicial estreito e categorizado |
| Diagnóstico básico | Conectividade, ping/traceroute, outages e outras funções | Ping, traceroute, DNS, portas e dados Wi-Fi | Não é diagnóstico local; mede bulk transport | Rede/gateway/internet em camadas, métodos explícitos e resultados parciais |
| Speed test | Download/upload/latência; também recursos de histórico/conta em níveis do produto | Não é o foco principal | Download/upload e métricas de latência em fluxo único | Adiar; se aprovado, estimativa limitada, cancelável, com cap e metodologia visível |
| Privacidade/dados | Produto amplo com conta/monitoramento em algumas ofertas | Ferramenta local ampla | Coleta IP e resultados; publica resultados sob sua política | Sem conta/telemetria; disclosure do provedor externo e consentimento específico |
| Permissões/escopo | Scanner e Wi-Fi trazem superfície maior | Scanner/portas/Wi-Fi trazem superfície maior | Requer tráfego externo significativo | Privilégio mínimo; sem SSID/BSSID/localização ou varredura no MVP |
| Diferenciação proposta | Muitos recursos e inteligência de rede | Profundidade de ferramentas tradicionais | Infraestrutura/protocolo de medição | Transparência, proveniência, falhas honestas, acessibilidade e resumo de suporte |

**Leitura competitiva:** ping, traceroute, DNS, varredura de dispositivos/portas, outages e histórico são comuns em suítes maduras, mas não são table stakes para este MVP estreito. Tentar igualar a amplitude de Fing/Network Analyzer sacrificaria o diferencial definido pelo projeto: medições auditáveis e local-first com pouca permissão. Download/upload/latência são table stakes apenas se a fase de speed test for aprovada, não para lançar o diagnóstico básico.

## Implicações para Requisitos e Aceite

1. Critérios de aceite devem verificar **o rótulo do método**, não apenas o número retornado.
2. Todo caso de teste deve afirmar quais resultados permanecem visíveis após falha/cancelamento.
3. “Internet disponível” deve ser modelado como evidências separadas: capacidade declarada, validação do Android e probe próprio.
4. Acessibilidade deve incluir testes automatizados de alvo/rótulo/contraste e validação manual com TalkBack e escala de fonte grande.
5. Matriz Android mínima: Wi-Fi validado, dados móveis, offline, portal cativo, VPN quando possível, gateway ausente, DNS falho, serviço de IP inválido/timeout, troca de rede, pausa/retomada e cancelamento.
6. Para speed test, o plano da fase deve começar com uma decisão de viabilidade. Se não houver solução estável, licenciada, sustentável e simulável, o resultado correto é adiar a funcionalidade.

## Fontes

### Primárias e documentação oficial

- [Android Developers — Read network state](https://developer.android.com/develop/connectivity/network-ops/reading-network-state) — **ALTA confiança**, consultado em 2026-08-10. Documenta rede padrão, `NetworkCapabilities`, `LinkProperties`, múltiplos transportes, rede medida, distinção `INTERNET`/`VALIDATED`, portal cativo, callbacks e liberação de callbacks.
- [Android Developers — LinkProperties API](https://developer.android.com/reference/android/net/LinkProperties) — **ALTA confiança**, consultado em 2026-08-10. Documenta endereços, rotas, DNS e dados de link disponíveis ao app.
- [Android Developers — WifiInfo API](https://developer.android.com/reference/android/net/wifi/WifiInfo) — **ALTA confiança**, consultado em 2026-08-10. Confirma que SSID/BSSID e outros campos são sensíveis à localização e retornam valores redigidos sem autorização.
- [Android Developers — Local network permission](https://developer.android.com/privacy-and-security/local-network-permission) — **ALTA confiança**, consultado em 2026-08-10. Explica o risco de fingerprint/localização no acesso à LAN e a evolução das proteções de rede local.
- [Flutter — UI design & styling for accessibility](https://docs.flutter.dev/ui/accessibility/ui-design-and-styling) — **ALTA confiança**, consultado em 2026-08-10. Orienta contraste, escala de fonte e alvos de toque; documentação refletia Flutter 3.44.7 em 2026-05-05.
- [Flutter — Accessibility testing](https://docs.flutter.dev/ui/accessibility/accessibility-testing) — **ALTA confiança**, consultado em 2026-08-10. Documenta Guideline API para tamanho de alvo, rótulo semântico e contraste, além de ferramentas de inspeção.
- [M-Lab — NDT](https://www.measurementlab.net/tests/ndt/) — **ALTA confiança sobre o protocolo**, consultado em 2026-08-10. Define NDT como medição single-stream de capacidade de bulk transport, reporta upload/download/latência, oferece limite opt-in no ndt7 e informa coleta de IP/resultados e publicação de resultados.
- [M-Lab — Tests](https://www.measurementlab.net/tests/) — **ALTA confiança**, consultado em 2026-08-10. Esclarece que os testes geram tráfego sintético e exige leitura da política de privacidade antes da medição.

### Produtos de referência (fontes oficiais do fornecedor/loja)

- [Fing — Tools Page](https://help.fing.com/hc/en-us/articles/6720318761618-Tools-Page) — **MÉDIA confiança para landscape competitivo**, atualizado em 2026-03-26. Lista speed test e agrupamento de conectividade/troubleshooting.
- [Fing — App Features](https://help.fing.com/hc/en-us/articles/4418790433426-Fing-App-Features) — **MÉDIA confiança para landscape competitivo**. Lista ping, traceroute, DNS, portas, outages, scanner, histórico e recursos de conta.
- [Network Analyzer — Google Play](https://play.google.com/store/apps/details?id=net.techet.netanalyzerlite.an) — **MÉDIA confiança para landscape competitivo**. Lista ping, traceroute, port scanner, DNS lookup e whois.

### Limites de confiança

- Nenhum provedor de IP público, método de gateway/probe ou solução de speed test foi selecionado nesta pesquisa de funcionalidades; capacidades concretas e permissões dependem de spike técnico e das versões Android suportadas.
- A disponibilidade de gateway e ICMP não deve ser inferida apenas das APIs documentadas. O requisito correto é `quando disponível`, com fallback e rótulo do método.
- A análise competitiva verifica presença declarada de funções, não qualidade, precisão ou popularidade relativa.

---
*Pesquisa de funcionalidades para: Tools App — Diagnóstico de Internet e Evolução da UI*
*Pesquisado em: 2026-08-10*
