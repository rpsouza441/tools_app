---
phase: 01-contrato-visual-e-funda-o-adaptativa
reviewed: 2026-08-31T14:23:22Z
depth: standard
files_reviewed: 18
files_reviewed_list:
  - lib/main.dart
  - lib/app/app_destinations.dart
  - lib/app/app_shell.dart
  - lib/design_system/app_breakpoints.dart
  - lib/design_system/app_tokens.dart
  - lib/design_system/copy_value_action.dart
  - lib/design_system/tool_scaffold.dart
  - lib/design_system/tool_sections.dart
  - lib/design_system/tool_status_panel.dart
  - lib/screen/network_calculator_screen.dart
  - lib/theme/theme.dart
  - test/app/destination_catalog_test.dart
  - test/app/app_shell_test.dart
  - test/design_system/accessibility_test.dart
  - test/design_system/design_system_gallery.dart
  - test/design_system/design_system_golden_test.dart
  - test/design_system/tool_components_test.dart
  - test/manual/design_system_app.dart
findings:
  critical: 4
  warning: 6
  info: 0
  total: 10
status: issues_found
---

# Phase 01: Code Review Report

**Reviewed:** 2026-08-31T14:23:22Z  
**Depth:** standard  
**Files Reviewed:** 18  
**Status:** issues_found

## Summary

Os 18 arquivos foram lidos integralmente e confrontados com UI-01..UI-09 e com o contrato visual da fase. `flutter analyze` terminou sem diagnósticos e a suíte completa terminou com 100 testes aprovados, mas esses resultados são falsos verdes para partes essenciais do contrato: o rail esconde destinos, `semanticLabel` nunca chega à UI, a ação de cópia não é segura após descarte, as cópias canônicas dos estados estão incorretas e as fixtures de teste evitam justamente esses caminhos.

Não foram encontrados segredos, injeção ou chamadas de shell. Os riscos mais altos são de comportamento incorreto, acessibilidade e lifecycle.

## Narrative Findings (AI reviewer)

## Critical Issues

### CR-01: O overflow compacto também substitui os destinos do NavigationRail

**Classificação:** BLOCKER  
**File:** `C:\ws\tools_app\lib\app\app_shell.dart:24-39,229-265`  
**Issue:** `_useOverflow` depende somente da quantidade de destinos e `_buildNavigationRail` reutiliza a lista compacta de três prioridades mais “Ferramentas”. Com cinco ou mais destinos, os layouts medium e expanded deixam de listar todos os destinos e passam a abrir um bottom sheet. Isso viola diretamente UI-01/UI-02 e o contrato da fase (“Rail médio/expandido lista todos os destinos e pode rolar verticalmente”). Também muda a ordem do rail para `compactPriority`, embora a ordem larga deva continuar sendo a do catálogo.

**Fix:** Limitar o overflow à construção da `NavigationBar`. O rail deve mapear `widget.destinations` na ordem original, usar o índice real do catálogo e habilitar rolagem. Como o índice visual compacto não é o índice real, separar os handlers compacto e largo:

```dart
NavigationRail(
  extended: extended,
  scrollable: true,
  selectedIndex: _actualDestinationIndex,
  onDestinationSelected: _selectActualDestination,
  destinations: widget.destinations.map(_buildRailDestination).toList(),
)
```

Adicionar testes com cinco destinos em 600, 839 e 840 px, verificando cinco entradas no rail, ausência de “Ferramentas” e seleção correta após redimensionar a partir de um destino não fixado.

### CR-02: O catálogo declara rótulos semânticos, mas o shell nunca os usa

**Classificação:** BLOCKER  
**Files:** `C:\ws\tools_app\lib\app\app_destinations.dart:25-29,50-79`; `C:\ws\tools_app\lib\app\app_shell.dart:193-217,232-257`  
**Issue:** `semanticLabel` é obrigatório no modelo, porém não existe nenhuma leitura desse campo em código de produção. Bar e rail recebem apenas `label`; o rail recolhido também não recebe o tooltip completo exigido. Ao mesmo tempo, o catálogo usa nomes longos (“Calculadora de Rede”, “Conversor de Dados”, “Gerador de Hash”) como labels visíveis, em vez das labels compactas “Rede”, “Armazenamento” e “Hash” definidas pelo UI-SPEC. Em 360 px isso permite truncamento/ellipsis de informação essencial e o leitor de tela não se beneficia da separação entre label curta e nome completo, falhando UI-01/UI-06/UI-07.

**Fix:** Usar labels visíveis curtas no catálogo, passar `tooltip: d.semanticLabel` para `NavigationDestination` e envolver o ícone do rail recolhido em `Tooltip`/`Semantics` com `d.semanticLabel`, evitando nós duplicados. Os testes devem inspecionar a árvore semântica do `AppShell` real e confirmar os nomes completos, não apenas que a string foi preenchida no modelo.

### CR-03: A conclusão assíncrona da cópia pode acessar UI descartada e remover SnackBars alheios

**Classificação:** BLOCKER  
**File:** `C:\ws\tools_app\lib\design_system\copy_value_action.dart:59-81`  
**Issue:** `_copy` captura o `ScaffoldMessengerState`, aguarda uma operação assíncrona e depois o usa sem `context.mounted`. Se a árvore for descartada durante `writer.write`, a conclusão tardia tenta modificar um messenger desmontado, podendo gerar `setState() called after dispose`. Além disso, `hideCurrentSnackBar()` remove qualquer aviso atual da tela, inclusive uma falha ou orientação não relacionada à cópia; o plano exigia fechar somente o feedback de cópia anterior. Isso viola o contrato de lifecycle e a garantia de feedback único de UI-09.

**Fix:** Tornar o componente stateful, verificar `context.mounted` depois do `await` tanto no sucesso quanto no erro, e guardar o `ScaffoldFeatureController` retornado pelo próprio `showSnackBar` para fechar apenas esse controller antes de outro feedback:

```dart
await effectiveWriter.write(widget.value);
if (!context.mounted) return;
_copySnackBar?.close();
_copySnackBar = ScaffoldMessenger.of(context).showSnackBar(copySnackBar);
```

Adicionar teste com writer controlado por `Completer`, desmontar o widget antes da conclusão e verificar ausência de exceção; adicionar outro teste com SnackBar não relacionado que não seja removido pela cópia.

### CR-04: Seis dos sete estados públicos divergem da cópia e/ou semântica canônica

**Classificação:** BLOCKER  
**File:** `C:\ws\tools_app\lib\design_system\tool_status_panel.dart:31-66,100-105`  
**Issue:** O componente que deveria fechar UI-05/UI-08 publica estados diferentes do contrato aprovado. Exemplos: empty usa “Pronto” em vez de “Nenhum resultado ainda”; loading usa `hourglass_empty` e “Processando...” em vez do indicador/heading canônico; failure usa “Falha”; offline usa `cloud_off` e “Sem conexão”; cancelled usa “Cancelado” e omite que resultados concluídos permanecem disponíveis. Permission denied usa cor neutra, embora o contrato determine error role no ícone. Os testes repetem essas strings incorretas e por isso passam.

**Fix:** Substituir `_statusMap` pelos valores exatos do UI-SPEC e ajustar `_iconColor`, incluindo ao menos:

- empty: “Nenhum resultado ainda” / “Preencha os campos e execute a ferramenta para ver os resultados.”
- loading: “Processando” / “Aguarde enquanto concluímos esta etapa.”
- failure: “Não foi possível concluir” / “Confira os dados e tente novamente.”
- offline: `wifi_off` / “Sem conexão com a internet”
- permissionDenied: ícone em `colorScheme.error`
- cancelled: “Operação cancelada” / “Os resultados concluídos continuam disponíveis.”

Corrigir primeiro as expectativas de `tool_components_test.dart` para produzir RED contra a implementação atual.

## Warnings

### WR-01: O tema não implementa os anchors, shapes e elevações aprovados

**Classificação:** WARNING  
**File:** `C:\ws\tools_app\lib\theme\theme.dart:12-13,31-35,79-82,122-129,140-170`  
**Issue:** Os temas dependem de `ColorScheme.fromSeed` sem sobrescrever os papéis exatos e usam canvases `#FBFDF8`/`#1A1C19`, diferentes de `#F7F9F7`/`#0F1511`. Cards estáticos têm elevation 1 (o contrato exige 0 e borda neutra), AppBar pode ganhar elevation 1 ao rolar, botões usam radius 12 em vez de 8 e chips radius 8 em vez de 4. Isso torna os goldens consistentes com uma implementação que não corresponde ao design contract e enfraquece UI-04.

**Fix:** Construir/ajustar os dois `ColorScheme` com os roles exatos do UI-SPEC; aplicar elevation 0 a Card/AppBar/nav/rail, borda neutra de 1 px nos cards, radius 8 nos botões e radius 4 nos chips. Criar assertions exatas para cada role, shape e elevation, além dos testes de contraste.

### WR-02: `TechnicalValueRow.onCopy` é um callback público morto

**Classificação:** WARNING  
**File:** `C:\ws\tools_app\lib\design_system\tool_sections.dart:140-160,200`  
**Issue:** O chamador fornece `onCopy`, mas o widget nunca o invoca; a não nulidade serve apenas como booleano para criar outro `CopyValueAction`. Isso é uma API enganosa: callbacks de auditoria, tratamento específico ou writers fake passados pelo consumidor são silenciosamente ignorados. Os testes verificam apenas a presença do botão e nunca tocam nele através de `TechnicalValueRow`.

**Fix:** Remover o callback morto e modelar explicitamente `copyable` + `CopyValueWriter?`, ou aceitar um `CopyValueAction`/factory. Se a intenção for callback, conectá-lo diretamente ao botão. O teste deve tocar a ação composta e provar que o contrato fornecido pelo chamador foi executado.

### WR-03: Atualizações do catálogo deixam índices inválidos e recriam todas as páginas

**Classificação:** WARNING  
**Files:** `C:\ws\tools_app\lib\app\app_destinations.dart:49-81`; `C:\ws\tools_app\lib\app\app_shell.dart:55-83`  
**Issue:** `appDestinations` é uma `List` global mutável, apesar do contrato exigir coleção imutável. `didUpdateWidget` somente recria `_pages`; não reconcilia `_selectedIndex` nem `_overflowSelectedActualIndex`. Trocar de menos de cinco para cinco destinos mantém o índice de overflow em `-1`; tocar “Ferramentas” pode produzir índice inválido no `IndexedStack`. Encolher o catálogo pode deixar `selectedIndex` fora do número de destinos. A reconstrução total também perde o estado das páginas em uma atualização legítima do catálogo.

**Fix:** Expor `List.unmodifiable`, validar ids/prioridades e guardar seleção por `id` estável. Em `didUpdateWidget`, preservar widgets existentes por id, materializar somente destinos novos e normalizar a seleção/overflow quando um id desaparecer. Adicionar testes de crescimento, redução e reordenação durante a vida do mesmo `AppShell`.

### WR-04: `ToolMetric` pode gerar overflow horizontal com fonte ampliada

**Classificação:** WARNING  
**File:** `C:\ws\tools_app\lib\design_system\tool_sections.dart:94-117`  
**Issue:** Cada métrica é um `Row(mainAxisSize: min)` com dois `Text` não flexíveis. O `Wrap` externo só move a linha inteira; ele não permite que label ou valor quebrem. Labels técnicas maiores e “Indisponível” em escala 2.0 podem ultrapassar a largura compacta, contrariando UI-07 e a regra de ausência de overflow horizontal.

**Fix:** Usar `Flexible`/`Expanded` com wrap para label e valor ou mudar para coluna/`Wrap` quando a largura intrínseca não couber. Testar a primitive real em 360 px com escala 2.0, label longa e valor indisponível, verificando ausência de exceção e alcance por scroll vertical.

### WR-05: A suíte de acessibilidade/visual testa réplicas e não os caminhos que afirma cobrir

**Classificação:** WARNING  
**Files:** `C:\ws\tools_app\test\design_system\accessibility_test.dart:8-95,151-160,318-347`; `C:\ws\tools_app\test\design_system\design_system_golden_test.dart:112-145`; `C:\ws\tools_app\test\design_system\tool_components_test.dart:365-415`  
**Issue:** A matriz de escala usa uma fixture própria, sem `AppShell`, `ToolScaffold`, `ToolActionGroup`, `ToolMetric` ou catálogo real. A fixture declara `semanticLabel` mas também nunca o usa. Os goldens largos têm somente três labels curtas, então não detectam o overflow indevido do rail nem as labels longas reais. O teste “same semantic color roles” apenas verifica propriedades Dart não nulas, e os testes de status copiam literalmente os valores errados da implementação. A suíte passa sem demonstrar UI-01..UI-09.

**Fix:** Exercitar `AppShell` e `DesignSystemGallery` reais em toda a matriz 360/720/1024 × 1.0/2.0; adicionar cenário de cinco destinos nos rails; inspecionar semantics/tooltip usando `semanticLabel`; comparar roles do tema com hexadecimais exatos; derivar as expectativas de estado do UI-SPEC, não da implementação.

### WR-06: A galeria usada por goldens e TalkBack omite cópia e contém copy não canônica

**Classificação:** WARNING  
**Files:** `C:\ws\tools_app\test\design_system\design_system_gallery.dart:50-78,84-100`; `C:\ws\tools_app\test\manual\design_system_app.dart:22-28`  
**Issue:** A galeria afirma renderizar todos os primitives, mas `TechnicalValueRow` é criado sem ação de cópia, portanto UI-09 não aparece em nenhum golden nem no harness TalkBack. Ela ainda mostra “Calcular” (CTA proibida pelo contrato; deveria ser verbo + objeto) e o heading inglês “Status Panels”; o app manual também usa título inglês. Assim, a evidência visual/manual não cobre a interface pt-BR e a ação acessível que pretende aprovar.

**Fix:** Após corrigir a API de `TechnicalValueRow`, injetar writer fake/no-op e renderizar a ação de copiar; trocar para “Calcular rede”, “Painéis de status” e um título pt-BR. Regenerar os quatro goldens somente depois de revisar a diferença esperada.

---

_Reviewed: 2026-08-31T14:23:22Z_  
_Reviewer: the agent (gsd-code-reviewer)_  
_Depth: standard_
