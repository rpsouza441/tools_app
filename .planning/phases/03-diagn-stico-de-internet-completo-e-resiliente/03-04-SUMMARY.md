---
phase: 03-diagn-stico-de-internet-completo-e-resiliente
plan: "04"
status: complete
completed: "2026-09-01"
requirements:
  - DIAG-05
  - QUAL-01
  - QUAL-08
---

# 03-04 SUMMARY — dio + DioPublicIpSource (ipify)

## What was built

Adicionada a dependência `dio: ^5.11.0` (única nova hosted dep) e o
`PublicIpSource` real contra ipify, cancelável, validado e com falha
independente. **Não** ligado em `DiagnosticDefaults` (fica para 03-06).

### Dependência
- `pubspec.yaml`: `dio: ^5.11.0` (caret, não pin 5.9.2). Sem connectivity_plus/network_info_plus/dart_ping/share_plus. `pubspec.lock` principal atualizado; `pubspec.lock-old` intocado (D-14).

### `lib/diagnostic/public_ip/`
- `PublicIpConfig`: url default `https://api.ipify.org?format=json` (IPv4, não api64), timeouts 5s, `maxBodyBytes` 2048, userAgent honesto `ToolsApp-Diagnostic/1.1.1`, `thirdParty` ipify. Sem segundo vendor.
- `DioPublicIpSource implements PublicIpSource`:
  - GET HTTPS com `CancelToken` registrado em `scope.register` (D-07).
  - `followRedirects=false`, `persistentConnection=false`, `validateStatus < 600` (caller decide).
  - Validação: status 200; Content-Length e bytes reais ≤ 2048; `jsonDecode` → Map com `ip` String; `InternetAddress.tryParse` type IPv4; senão `failure` (nunca exceção vazando).
  - Mapeamento: connect/send/receive timeout → `timeout`; `CancelToken.isCancel` → `cancelled`; outros → `failure` ("serviço indisponível"). Outage ≠ sem internet.
  - Provenance HTTPS/api.ipify.org com limitação de privacidade. Sem log de IP.

### Testes
- `public_ip_source_test.dart` (adapter Dio manuscrito, sem rede/mockito): IPv4 ok, ip inválido, HTML/JSON malformado, IPv6→failure, Content-Length>2048, payload>2048, receiveTimeout→timeout, connectionError→failure, cancel→cancelled.
- `diagnostic_session_public_ip_test.dart` (NOVO, sem conflito): public IP failure → `partialFailure` com `localIpv4` intacto (DIAG-10).

## Verification
- `flutter test --no-pub public_ip_source_test.dart diagnostic_session_public_ip_test.dart diagnostic_session_test.dart` → **16/16 passed** (10/10 dos novos isolados).
- `flutter analyze --no-pub` (arquivos novos) → **No issues found**.
- `pubspec.yaml`: só `dio` como nova hosted dep; nenhum pacote proibido.
- `pubspec.lock-old` intocado (D-14).

## Deviations
- `flutter pub add` gravou pin exato `dio: 5.11.0`; ajustado manualmente para `^5.11.0` conforme o plano e re-resolvido.

## Self-Check: PASSED
