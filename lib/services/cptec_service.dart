import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import '../models/cidade.dart';
import '../models/previsao.dart';

class CptecException implements Exception {
  const CptecException(this.message);
  final String message;
  @override
  String toString() => message;
}

class CptecService {
  CptecService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;
  static const _base = 'https://servicos.cptec.inpe.br/XML';

  Future<List<Cidade>> buscarCidades(String termo) async {
    final valor = termo.trim();
    if (valor.isEmpty)
      throw const CptecException('Digite o nome de uma cidade.');
    final uri = Uri.parse('$_base/listaCidades')
        .replace(queryParameters: {'city': _semAcentos(valor)});
    final document = await _getXml(uri);
    return document
        .findAllElements('cidade')
        .map((node) {
          String value(String name) =>
              node.getElement(name)?.innerText.trim() ?? '';
          return Cidade(id: value('id'), nome: value('nome'), uf: value('uf'));
        })
        .where((cidade) => cidade.id.isNotEmpty && cidade.nome.isNotEmpty)
        .toList();
  }

  Future<Previsao> buscarPrevisao(Cidade cidade) async {
    final uri = Uri.parse(
      '$_base/cidade/${Uri.encodeComponent(cidade.id)}/previsao.xml',
    );
    final document = await _getXml(uri);
    final root = document.rootElement;
    final dias = root.findElements('previsao').map((node) {
      String value(String name) =>
          node.getElement(name)?.innerText.trim() ?? '';
      final tempo = value('tempo');
      return DiaPrevisao(
        dia: value('dia'),
        tempo: tempo.isEmpty ? 'nd' : tempo,
        maxima: _parseNumber(value('maxima')),
        minima: _parseNumber(value('minima')),
        iuv: _parseNumber(value('iuv')),
      );
    }).toList();
    if (dias.isEmpty)
      throw const CptecException('Previsão indisponível para esta cidade.');
    return Previsao(
      nome: root.getElement('nome')?.innerText.trim() ?? cidade.nome,
      uf: root.getElement('uf')?.innerText.trim() ?? cidade.uf,
      atualizacao: root.getElement('atualizacao')?.innerText.trim() ?? '',
      dias: dias,
    );
  }

  Future<XmlDocument> _getXml(Uri uri) async {
    try {
      final response =
          await _client.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode < 200 || response.statusCode >= 300)
        throw CptecException(
          'Serviço CPTEC retornou HTTP ${response.statusCode}.',
        );
      final preview = ascii
          .decode(response.bodyBytes.take(160).toList(), allowInvalid: true)
          .toLowerCase();
      final text = preview.contains('iso-8859-1') || preview.contains('latin-1')
          ? latin1.decode(response.bodyBytes, allowInvalid: true)
          : utf8.decode(response.bodyBytes, allowMalformed: true);
      try {
        return XmlDocument.parse(text);
      } on XmlException {
        throw const CptecException(
          'A resposta do serviço não é um XML válido.',
        );
      }
    } on CptecException {
      rethrow;
    } catch (error) {
      throw CptecException(
        error.toString().contains('Timeout')
            ? 'Tempo esgotado ao consultar o CPTEC.'
            : 'Não foi possível conectar ao CPTEC/INPE.',
      );
    }
  }

  static double? _parseNumber(String value) =>
      double.tryParse(value.replaceAll(',', '.'));
  static String _semAcentos(String value) => value
      .replaceAll(RegExp('[áàâãäÁÀÂÃÄ]'), 'a')
      .replaceAll(RegExp('[éèêëÉÈÊË]'), 'e')
      .replaceAll(RegExp('[íìîïÍÌÎÏ]'), 'i')
      .replaceAll(RegExp('[óòôõöÓÒÔÕÖ]'), 'o')
      .replaceAll(RegExp('[úùûüÚÙÛÜ]'), 'u')
      .replaceAll(RegExp('[çÇ]'), 'c');
  void dispose() => _client.close();
}
