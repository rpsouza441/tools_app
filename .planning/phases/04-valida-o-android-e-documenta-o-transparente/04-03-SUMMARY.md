---
plan: 04-03
status: complete
requirements: [DOC-01, DOC-02]
---

# Summary 04-03 — README real (DOC-01) + permissões (DOC-02)

Substituído o boilerplate "A new Flutter project" (typo "tolls_app") por um
README factual, Android-first, enxuto e sem marketing.

- **DOC-01:** documenta as 4 ferramentas (Calculadora IPv4, Conversor de
  Armazenamento, Gerador de Hash, Diagnóstico de Internet); o funcionamento do
  diagnóstico com métodos reais (transporte/capabilities, IPv4 local, gateway,
  IP público ipify HTTPS, TCP connect, HTTPS gstatic 204, métricas
  min/média/máx + denominador, cancelamento, parciais, resumo copiar/
  compartilhar); limitações (ICMP indisponível, TCP≠ping, HTTPS≠ICMP, speed test
  fora do milestone, sem LAN/traceroute/DNS); plataformas verificadas (VERIFIED
  em emulador API 36; dados móveis não verificado); e link para PRIVACY.md.
- **DOC-02:** seção "Permissões Android" com INTERNET e ACCESS_NETWORK_STATE
  (motivo de cada) + ausências explícitas (localização, SSID/BSSID,
  ACCESS_LOCAL_NETWORK, storage, background, analytics). Reflete o manifest real
  verificado por `dumpsys` no emulador (R2). Nota sobre debug/profile só
  adicionarem INTERNET (dev tooling), não permissões de runtime extras.

Verificações: README não contém mais "A new Flutter project"/"tolls_app";
link para PRIVACY.md presente; nenhuma claim não verificada.
Nenhuma mudança de código de produção.
