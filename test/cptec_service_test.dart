import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:previsao_tempo_cptec/models/cidade.dart';
import 'package:previsao_tempo_cptec/models/previsao.dart';
import 'package:previsao_tempo_cptec/services/cache_service.dart';
import 'package:previsao_tempo_cptec/services/cptec_service.dart';
import 'package:previsao_tempo_cptec/widgets/temperature_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeClient extends http.BaseClient {
  FakeClient(this.body, {this.statusCode = 200}) : rawBytes = null;
  FakeClient.bytes(this.rawBytes, {this.statusCode = 200}) : body = null;
  final String? body;
  final List<int>? rawBytes;
  final int statusCode;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async =>
      http.StreamedResponse(
        Stream.value(rawBytes ?? utf8.encode(body!)),
        statusCode,
        headers: {'content-type': 'application/xml'},
      );
}

void main() {
  test('interpreta XML de cidades e preserva o id retornado', () async {
    final service = CptecService(
      client: FakeClient(
        '<?xml version="1.0"?><cidades><cidade><nome>São Paulo</nome><uf>SP</uf><id>244</id></cidade></cidades>',
      ),
    );
    final cidades = await service.buscarCidades('São Paulo');
    expect(cidades.single.id, '244');
    expect(cidades.single.nome, 'São Paulo');
    expect(cidades.single.uf, 'SP');
    service.dispose();
  });

  test('campos numéricos ausentes não viram zero', () async {
    final service = CptecService(
      client: FakeClient(
        '<?xml version="1.0"?><cidade><nome>Teste</nome><uf>SP</uf><atualizacao>2025-01-01</atualizacao><previsao><dia>2025-01-02</dia><tempo>cl</tempo><maxima></maxima><minima>18</minima></previsao></cidade>',
      ),
    );
    final previsao = await service.buscarPrevisao(
      const Cidade(id: '9', nome: 'Teste', uf: 'SP'),
    );
    expect(previsao.dias.single.maxima, isNull);
    expect(previsao.dias.single.minima, 18);
    service.dispose();
  });

  test('decodifica a resposta ISO-8859-1 do CPTEC com acentos', () async {
    final xml =
        "<?xml version='1.0' encoding='ISO-8859-1'?><cidades><cidade><nome>São Paulo</nome><uf>SP</uf><id>244</id></cidade></cidades>";
    final bytes = latin1.encode(xml);
    final service = CptecService(client: FakeClient.bytes(bytes));
    final cidades = await service.buscarCidades('sao paulo');
    expect(cidades.single.nome, 'São Paulo');
    service.dispose();
  });

  test('salva e recupera cidade, previsão e data do cache', () async {
    SharedPreferences.setMockInitialValues({});
    final cidade = const Cidade(id: '244', nome: 'São Paulo', uf: 'SP');
    final previsao = const Previsao(
      nome: 'São Paulo',
      uf: 'SP',
      atualizacao: '2025-01-01',
      dias: [
        DiaPrevisao(dia: '2025-01-02', tempo: 'cl', maxima: 30, minima: 20)
      ],
    );
    final cache = CacheService();
    await cache.salvar(cidade, previsao);
    final recuperado = await cache.ler();
    expect(recuperado?.cidade.id, '244');
    expect(recuperado?.previsao.dias.single.maxima, 30);
    expect(recuperado?.salvoEm, isNotNull);
  });

  testWidgets('gráfico usa as temperaturas retornadas', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: TemperatureChart(dias: [
          DiaPrevisao(dia: '2025-01-01', tempo: 'cl', maxima: 30, minima: 20),
          DiaPrevisao(dia: '2025-01-02', tempo: 'c', maxima: 26, minima: 18),
        ]),
      ),
    ));
    expect(find.text('Temperaturas (°C)'), findsOneWidget);
    expect(find.text('Mínima'), findsOneWidget);
    expect(find.text('Máxima'), findsOneWidget);
  });
}
