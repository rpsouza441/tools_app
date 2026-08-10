# Walking Skeleton — Tools App (adaptação brownfield)

**Phase:** 1
**Generated:** 2026-08-10

## Capability Proven End-to-End

> Um profissional ou estudante de TI abre um destino vindo do catálogo tipado, usa o shell adaptativo e conclui uma interação real em uma ferramenta offline existente sem perder o estado ao navegar ou redimensionar.

## Brownfield Adaptation

Este projeto já é um aplicativo Flutter funcional. O walking skeleton desta fase comprova o stack que realmente existe — catálogo local → shell Flutter → tela existente → serviço Dart offline — e não inventa API, banco de dados, autenticação, persistência ou deploy remoto. Esses elementos são explicitamente desnecessários ou fora do escopo do milestone.

## Architectural Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Framework | Flutter 3.44 + Material 3 existentes | Preserva a base Android-first e evita reescrita. |
| Navigation | Catálogo tipado único + `NavigationBar`/`NavigationRail` + `IndexedStack` | Prova a seleção adaptativa e preserva o estado das ferramentas offline. |
| Data layer | Estado efêmero das screens + services Dart puros existentes; sem persistência | As ferramentas atuais calculam localmente e o ciclo proíbe histórico persistente. |
| Auth | Nenhuma | O produto não possui conta nem recurso protegido por identidade. |
| External API | Nenhuma na Phase 1 | Networking e diagnóstico pertencem à Phase 3. |
| Deployment target | Execução/build Flutter local para Android; `flutter run` e `flutter build apk` | O app já é brownfield; a fase valida a fundação no ambiente existente. |
| Directory layout | `lib/app/` para catálogo/shell, `lib/design_system/` para tokens/primitives, screens/services atuais preservados | Mantém boundaries pequenas e permite migração incremental na Phase 2. |

## Stack Touched in Phase 1

- [x] Scaffold Flutter, build, lint e test runner existentes são preservados.
- [x] Navegação local: um destino real é selecionado pelo catálogo e aberto pelo shell.
- [x] UI: uma interação real chega ao serviço Dart offline existente e exibe o resultado.
- [x] Estado: inputs/resultados sobrevivem a troca de destino e mudança de breakpoint.
- [x] Execução local documentada: `flutter run` exercita o stack aplicável.
- [x] Banco/API/auth: não aplicável por decisão explícita de escopo; nenhum substituto artificial é criado.

## Out of Scope (Deferred to Later Slices)

- Migração completa das três screens para as primitives compartilhadas — Phase 2.
- Diagnóstico de Internet, adapters Android, requests, sockets, lifecycle de I/O e permissões — Phase 3.
- Validação em cenários Android reais e documentação pública — Phase 4.
- Decisão de viabilidade do speed test — Phase 5.
- Backend, contas, sincronização, analytics e histórico persistente — fora do milestone.

## Subsequent Slice Plan

- Phase 2: migrar uma ferramenta por vez para a fundação sem alterar resultados.
- Phase 3: adicionar o destino de diagnóstico com adapters independentes e canceláveis.
- Phase 4: validar Android e publicar documentação fiel ao comportamento.
- Phase 5: registrar `GO` ou `NO-GO` do speed test com evidências.
