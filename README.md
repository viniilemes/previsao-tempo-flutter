# Atividade 2 – Previsão do tempo

**Autor:** Vinícius Lemes dos Santos  
**Disciplina:** Programação para Dispositivos Móveis II  
**Professor:** Arley

Aplicativo Flutter individual para consultar a previsão do tempo de cidades brasileiras usando o serviço XML do CPTEC/INPE. O aplicativo não possui backend próprio, autenticação ou banco remoto.

## Funcionalidades

- Pesquisa por cidade usando o parâmetro `city` e seleção pelo `id` retornado pelo CPTEC.
- Previsão com data, mínimas, máximas, condição, ícone e IUV quando informado.
- Atualização manual, carregamento, timeout, erros HTTP/XML/conexão e tentativa novamente.
- Cache JSON em `shared_preferences`, com a cidade, previsão e data/hora de armazenamento.
- Gráfico de mínimas e máximas usando os mesmos valores dos cartões.
- Interface Material 3 em português, rolável e adaptada a telas pequenas.

## Executar no Android

Pré-requisitos: Flutter 3.24 ou superior, Dart 3.5 ou superior e Android SDK configurado.

```bash
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run
```

Para instalar o APK debug já gerado em um celular com depuração USB autorizada:

```bash
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

## Dependências

- `http`: requisições ao serviço XML.
- `xml`: leitura segura da resposta XML.
- `shared_preferences`: persistência local do último cache.
- `fl_chart`: gráfico das temperaturas.

## Integração CPTEC/INPE

Referência oficial: [Serviços Web — Previsão em XML do CPTEC/INPE](https://servicos.cptec.inpe.br/XML/).

Endpoints usados:

- `https://servicos.cptec.inpe.br/XML/listaCidades?city=...`
- `https://servicos.cptec.inpe.br/XML/cidade/{id}/previsao.xml`

A documentação informa que a previsão pode retornar até quatro registros, mas a aplicação renderiza exatamente os dias recebidos. A busca remove acentos conforme a regra do serviço e a biblioteca `Uri` faz o escape dos parâmetros.

O serviço documenta os endpoints em HTTP, mas a validação real em 20/11/2026 confirmou redirecionamento para HTTPS; o aplicativo usa HTTPS diretamente. A permissão de internet e a configuração restrita de cleartext permanecem no Android para compatibilidade com o endpoint documentado.

## Organização

- `lib/models`: modelos de cidade e previsão.
- `lib/services/cptec_service.dart`: HTTP, timeout e parser XML.
- `lib/services/cache_service.dart`: serialização e cache local.
- `lib/services/condicoes.dart`: tabela centralizada de siglas, descrições e ícones.
- `lib/screens`: pesquisa e previsão.
- `lib/widgets/temperature_chart.dart`: gráfico.
- `test`: testes locais de XML e campos numéricos ausentes.

## Cache e erros

Uma resposta online só substitui o cache depois de ser parseada e conter dias de previsão. Quando a atualização falha, os dados anteriores permanecem na tela e são identificados como salvos. Cache ausente ou corrompido é ignorado com segurança.

## Capturas de tela

Não foram encontradas capturas reais no workspace nem em seus anexos disponíveis. A validação manual no celular foi informada pelo autor, mas nenhuma imagem foi inventada. Para completar esta seção, adicionar as imagens reais em `docs/screenshots/` usando estes nomes sugeridos:

- `docs/screenshots/pesquisa.png` — tela de pesquisa e resultados.
- `docs/screenshots/previsao-grafico.png` — previsão e gráfico.
- `docs/screenshots/cache.png` — recuperação de dados salvos.

Depois de adicionadas, inserir os caminhos relativos acima nesta seção. A ausência das capturas é a única pendência documental desta entrega.

## Validação realizada

SDK usado: cópia gravável de `/home/vin-cius-lemes/snap/flutter/common/flutter` em `/tmp/codex-flutter-sdk`, Flutter 3.47.7 e Dart 3.13.5. A cópia foi necessária porque o SDK original está montado como somente leitura.

| Comando | Resultado |
|---|---|
| `flutter pub get` | Passou; 62 dependências resolvidas. |
| `dart format lib test` | Passou; nenhum arquivo pendente após a formatação final. |
| `flutter analyze` | Passou; `No issues found!`. |
| `flutter test` | Passou; 5 testes, incluindo XML ISO-8859-1, campos ausentes, cache e gráfico. |
| `flutter build apk --debug` | Passou; APK gerado. |
| Consulta real CPTEC | Passou via HTTPS: `São Paulo` retornou ID `244`; previsão retornou atualização, 4 dias, temperaturas, siglas e IUV. |
| Validação manual no celular | Realizada pelo autor; a execução visual não foi reproduzida neste ambiente. |

APK debug: `build/app/outputs/flutter-apk/app-debug.apk`.

Para instalar em um celular Android com depuração USB autorizada:

```bash
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

## Requisitos e arquivos

| Requisito | Implementação |
|---|---|
| Pesquisa e identificador CPTEC | `lib/screens/pesquisa_page.dart`, `lib/services/cptec_service.dart` |
| Previsão XML e siglas | `lib/models/previsao.dart`, `lib/services/condicoes.dart` |
| Atualização e erros | `lib/screens/previsao_page.dart`, `lib/services/cptec_service.dart` |
| Persistência/cache | `lib/services/cache_service.dart` |
| Gráfico | `lib/widgets/temperature_chart.dart` |
| Material 3 e navegação | `lib/main.dart`, `lib/screens/` |
| Testes locais | `test/cptec_service_test.dart` |
