---
plan: 04-04
status: complete
requirements: [DOC-03, DOC-04]
---

# Summary 04-04 — PRIVACY.md (DOC-04) + terceiros (DOC-03)

Criado `PRIVACY.md` coerente com o comportamento real; README já aponta para ele.

- **DOC-04:** princípios — sem conta/cadastro, sem backend próprio, sem
  analytics/telemetria, sem histórico persistente (resultados só na sessão em
  memória), compartilhamento só por ação explícita (Intent.ACTION_SEND nativo).
  Seção de permissões (INTERNET, ACCESS_NETWORK_STATE). Nenhum dado fictício de
  empresa/e-mail/controlador inventado.
- **DOC-03 ipify:** `api.ipify.org` (HTTPS GET), finalidade descobrir IP público,
  o provedor observa o IP público da conexão. **Não** afirma "não registra";
  documenta factual e curtamente a contradição marketing-vs-privacy-policy;
  claims != SLA; provedor substituível (PublicIpConfig).
- **DOC-03 gstatic:** `www.gstatic.com/generate_204` (HTTPS GET, espera 204),
  finalidade probe HTTPS de conectividade — nunca ping/ICMP; limitações (não
  prova internet completa nem portal cativo; falha != "sem internet");
  best-effort, sem SLA/autorização assumida, substituível (HttpsProbeConfig).

Verificações: sem claim "não registra" isolada; README linka PRIVACY.md.
Nenhuma mudança de código de produção.
