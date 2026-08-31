# Requirements: Tools App — Diagnóstico de Internet e Evolução da UI

**Defined:** 2026-08-10
**Core Value:** Oferecer diagnósticos técnicos úteis e honestos em uma interface clara, sem ocultar limitações de plataforma, método de medição ou falhas parciais.

## User Stories

- Como profissional ou estudante de TI, quero encontrar rapidamente cada ferramenta para resolver uma tarefa sem navegar por uma barra superlotada.
- Como pessoa usando tema claro, escuro ou fonte ampliada, quero ler e operar todas as ferramentas com conforto e acessibilidade.
- Como usuário diagnosticando uma conexão, quero ver evidências independentes e o método de cada medição para não receber conclusões enganosas.
- Como usuário em uma rede instável, quero cancelar, repetir e conservar resultados parciais para continuar entendendo o que funcionou.
- Como usuário em dados móveis, quero decidir conscientemente antes de qualquer futuro teste de velocidade que gere tráfego relevante.

## v1 Requirements

### Interface e navegação

- [x] **UI-01**: Usuário pode abrir qualquer ferramenta por uma arquitetura de navegação que permaneça clara em largura compacta e larga.
- [x] **UI-02**: Usuário recebe NavigationBar, NavigationRail ou home categorizada conforme o espaço disponível e o design contract aprovado.
- [x] **UI-03**: Usuário encontra hierarquia consistente de títulos, entradas, ações, cards e resultados em todas as ferramentas.
- [x] **UI-04**: Usuário pode usar o aplicativo nos temas claro e escuro sem perda de contraste ou significado.
- [x] **UI-05**: Usuário identifica estados vazio, carregando, sucesso, falha, sem conexão, permissão negada e operação cancelada por componentes consistentes.
- [x] **UI-06**: Usuário pode tocar ações por alvos de tamanho acessível e navegar com leitores de tela por rótulos semânticos úteis.
- [x] **UI-07**: Usuário pode ampliar a fonte sem perder conteúdo, ações ou compreensão em larguras compactas e largas.
- [x] **UI-08**: Usuário recebe toda a interface e mensagens do ciclo em português do Brasil.
- [x] **UI-09**: Usuário pode copiar valores e resultados por uma ação consistente com confirmação acessível.

### Preservação das ferramentas

- [x] **PRES-01**: Usuário continua calculando redes IPv4 com os mesmos resultados válidos após a migração visual.
- [x] **PRES-02**: Usuário continua convertendo armazenamento decimal e binário com os mesmos resultados válidos após a migração visual.
- [ ] **PRES-03**: Usuário continua gerando hashes MD5, SHA-1, SHA-256 e SHA-512 com os mesmos resultados válidos após a migração visual.
- [ ] **PRES-04**: Usuário não perde funcionalidades existentes enquanto as três telas são migradas em incrementos verificáveis.

### Diagnóstico de conectividade

- [ ] **DIAG-01**: Usuário pode iniciar manualmente um único diagnóstico por vez.
- [ ] **DIAG-02**: Usuário vê separadamente o transporte disponível, a capacidade INTERNET, a validação Android e indícios de portal cativo quando a plataforma os fornece.
- [ ] **DIAG-03**: Usuário vê o endereço IPv4 local associado à rede ativa ou um estado explícito de indisponibilidade.
- [ ] **DIAG-04**: Usuário vê o endereço do gateway padrão quando tecnicamente disponível, sem presumir um endereço convencional.
- [ ] **DIAG-05**: Usuário vê o IP público consultado por HTTPS, junto do provedor, horário e falha independente quando o serviço não responde ou retorna conteúdo inválido.
- [ ] **DIAG-06**: Usuário pode executar um teste de alcance e latência do gateway quando houver alvo e método tecnicamente disponíveis.
- [ ] **DIAG-07**: Usuário pode executar um teste de alcance e latência de um alvo externo autorizado e substituível.
- [ ] **DIAG-08**: Usuário vê método, alvo, porta ou URL, timeout e limitações reais de cada probe, sem TCP/HTTPS ser rotulado como ICMP.
- [ ] **DIAG-09**: Usuário vê, para múltiplas amostras, mínimo, média, máximo, total de tentativas, sucessos e falhas com denominador explícito.
- [ ] **DIAG-10**: Usuário vê resultados concluídos mesmo quando outra capability falha, fica indisponível ou é cancelada.
- [ ] **DIAG-11**: Usuário vê progresso por etapa durante a execução sem que resultados parciais já obtidos desapareçam.
- [ ] **DIAG-12**: Usuário pode cancelar a execução e impedir que respostas tardias alterem o estado cancelado.
- [ ] **DIAG-13**: Usuário pode repetir o diagnóstico depois de sucesso, falha parcial ou cancelamento.
- [ ] **DIAG-14**: Usuário vê o horário e o último resultado da sessão atual sem criação de histórico persistente.
- [ ] **DIAG-15**: Usuário pode copiar e compartilhar um resumo textual com timestamp, contexto de rede, métricas, proveniência, falhas e limitações.

### Resiliência, privacidade e qualidade

- [ ] **QUAL-01**: Usuário não enfrenta travamento ou spinner infinito em modo offline, dados móveis, gateway ausente, portal cativo ou serviço externo indisponível.
- [ ] **QUAL-02**: Usuário pode interromper toda operação de rede, encerrando requests, sockets, timers, streams e callbacks subjacentes.
- [ ] **QUAL-03**: Usuário não recebe métricas agregadas de redes diferentes quando a conectividade muda durante uma execução.
- [ ] **QUAL-04**: Usuário retorna de pausa, troca de destino ou descarte da tela sem recursos órfãos, execução automática ou atualização de UI descartada.
- [ ] **QUAL-05**: Usuário recebe apenas fatos suportados pela plataforma; capabilities ausentes aparecem como indisponíveis, e não como zero ou falha global.
- [ ] **QUAL-06**: Usuário utiliza o diagnóstico sem conceder localização enquanto SSID/BSSID não fizerem parte do escopo.
- [ ] **QUAL-07**: Usuário não tem identificadores, resultados ou conteúdo do diagnóstico enviados a analytics.
- [ ] **QUAL-08**: Usuário recebe comportamento verificado por testes de sucesso, timeout, offline, resposta inválida, cancelamento, troca de rede, lifecycle e resultados parciais com dependências simuladas.
- [ ] **QUAL-09**: Usuário recebe comportamento verificado em Android real ou ambiente controlado nos cenários Wi-Fi, dados móveis e offline.

### Documentação e decisão externa

- [ ] **DOC-01**: Usuário pode consultar no README as capacidades, limitações e plataformas realmente verificadas.
- [ ] **DOC-02**: Usuário pode consultar quais permissões Android são usadas e por que são necessárias.
- [ ] **DOC-03**: Usuário pode consultar qual serviço externo fornece IP público, quais dados recebe e qual política de privacidade se aplica.
- [ ] **DOC-04**: Usuário recebe uma política de privacidade coerente com a ausência de conta, telemetria e histórico persistente.
- [ ] **GATE-01**: Usuário só recebe um plano de speed test após decisão documentada sobre provedor ou protocolo, licença e termos, custos e capacidade, geografia, privacidade, retenção/publicação, metodologia, precisão, testabilidade e seleção de servidor.
- [ ] **GATE-02**: Usuário recebe uma decisão explícita de adiar o speed test quando qualquer critério obrigatório de viabilidade não tiver evidência suficiente.

## v2 Requirements

### Speed test condicionado a GO

- **SPD-01**: Usuário confirma cada teste após ver estimativa e limite rígido de consumo de dados e duração, especialmente em rede móvel ou medida.
- **SPD-02**: Usuário vê download e upload em Mbps e latência ociosa em ms pelo protocolo e provedor aprovados.
- **SPD-03**: Usuário vê progresso, método, servidor, bytes transferidos, tempo decorrido e limites durante o teste.
- **SPD-04**: Usuário pode cancelar imediatamente e liberar todos os recursos da medição.
- **SPD-05**: Usuário não pode iniciar dois testes simultâneos nem continuar agregando após troca ou perda de rede.
- **SPD-06**: Usuário vê sessão incompleta quando apenas parte do teste conclui, sem resultado final enganoso.
- **SPD-07**: Usuário vê resultados identificados como estimativas e as condições que limitam sua precisão.
- **SPD-08**: Usuário pode obter latência sob carga somente se a metodologia aprovada a medir de forma confiável.
- **SPD-09**: Usuário recebe comportamento verificado por agregadores unitários e integração com servidor controlado ou adaptador simulável.

### Evoluções posteriores

- **EVO-01**: Usuário pode repetir uma única etapa do diagnóstico com contexto temporal claramente identificado.
- **EVO-02**: Usuário recebe recomendações de próxima ação somente por regras auditáveis e sem causalidade não comprovada.
- **EVO-03**: Usuário pode usar fallback adicional de IP/probe somente após termos, privacidade e semântica comparável serem aprovados.

## Out of Scope

| Feature | Reason |
|---------|--------|
| Backend, contas e sincronização | A base local-first não precisa de identidade ou serviço remoto próprio neste ciclo. |
| Histórico persistente | Adiciona persistência e implicações de privacidade antes de o valor ser validado. |
| Telemetria/analytics de diagnósticos | Conflita com a minimização de dados definida. |
| SSID, BSSID e localização | Não são necessários ao diagnóstico básico e ampliam permissões e superfície de privacidade. |
| Scanner de LAN/portas, traceroute e DNS avançado | Expandem ameaças e escopo além do diagnóstico estreito deste ciclo. |
| Execução automática ou em background | Pode consumir dados e bateria sem consentimento e complica lifecycle. |
| WebView ou endpoint público informal de speed test | Termos, tracking, estabilidade, cancelamento e testabilidade ficam fora de controle. |
| Paridade multiplataforma não verificada | APIs e permissões de rede variam; o compromisso é Android-first. |
| Alegações de precisão absoluta ou equivalência com concorrentes | Metodologias, servidores, rádio, VPN e carga tornam resultados não intercambiáveis. |

## Definition of Done

- `flutter analyze` termina sem problemas.
- Todos os testes existentes e novos são aprovados.
- As três ferramentas existentes permanecem funcionais e cobertas contra regressão.
- O fluxo de diagnóstico é verificado em Android com Wi-Fi, dados móveis e modo offline.
- A UI é verificada em largura compacta e larga, temas claro/escuro, escala de fonte ampliada e leitor de tela.
- Toda operação externa tem timeout, cancelamento físico, provider substituível e falha parcial testada.
- README, privacidade e permissões refletem apenas o comportamento realmente entregue.
- Cada requirement v1 está mapeado a exatamente uma fase e possui evidência de verificação antes de ser marcado completo.

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| UI-01 | Phase 1 | Complete |
| UI-02 | Phase 1 | Complete |
| UI-03 | Phase 1 | Complete |
| UI-04 | Phase 1 | Complete |
| UI-05 | Phase 1 | Complete |
| UI-06 | Phase 1 | Complete |
| UI-07 | Phase 1 | Complete |
| UI-08 | Phase 1 | Complete |
| UI-09 | Phase 1 | Complete |
| PRES-01 | Phase 2 | Complete |
| PRES-02 | Phase 2 | Complete |
| PRES-03 | Phase 2 | Pending |
| PRES-04 | Phase 2 | Pending |
| DIAG-01 | Phase 3 | Pending |
| DIAG-02 | Phase 3 | Pending |
| DIAG-03 | Phase 3 | Pending |
| DIAG-04 | Phase 3 | Pending |
| DIAG-05 | Phase 3 | Pending |
| DIAG-06 | Phase 3 | Pending |
| DIAG-07 | Phase 3 | Pending |
| DIAG-08 | Phase 3 | Pending |
| DIAG-09 | Phase 3 | Pending |
| DIAG-10 | Phase 3 | Pending |
| DIAG-11 | Phase 3 | Pending |
| DIAG-12 | Phase 3 | Pending |
| DIAG-13 | Phase 3 | Pending |
| DIAG-14 | Phase 3 | Pending |
| DIAG-15 | Phase 3 | Pending |
| QUAL-01 | Phase 3 | Pending |
| QUAL-02 | Phase 3 | Pending |
| QUAL-03 | Phase 3 | Pending |
| QUAL-04 | Phase 3 | Pending |
| QUAL-05 | Phase 3 | Pending |
| QUAL-06 | Phase 3 | Pending |
| QUAL-07 | Phase 3 | Pending |
| QUAL-08 | Phase 3 | Pending |
| QUAL-09 | Phase 4 | Pending |
| DOC-01 | Phase 4 | Pending |
| DOC-02 | Phase 4 | Pending |
| DOC-03 | Phase 4 | Pending |
| DOC-04 | Phase 4 | Pending |
| GATE-01 | Phase 5 | Pending |
| GATE-02 | Phase 5 | Pending |

**Coverage:**

- v1 requirements: 43 total
- Mapped to phases: 43
- Unmapped: 0
- Duplicate mappings: 0
- v2 `SPD-*` requirements remain outside the current phase mappings.

---
*Requirements defined: 2026-08-10*
*Last updated: 2026-08-10 after roadmap creation*
