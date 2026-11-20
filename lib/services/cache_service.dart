import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/cidade.dart';
import '../models/previsao.dart';

class CacheData {
  const CacheData({
    required this.cidade,
    required this.previsao,
    required this.salvoEm,
  });
  final Cidade cidade;
  final Previsao previsao;
  final DateTime salvoEm;
}

class CacheService {
  static const _key = 'ultimo_cache_cptec';
  Future<void> salvar(Cidade cidade, Previsao previsao) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode({
        'cidade': cidade.toJson(),
        'previsao': previsao.toJson(),
        'salvoEm': DateTime.now().toIso8601String(),
      }),
    );
  }

  Future<CacheData?> ler() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final salvoEm = DateTime.tryParse('${json['salvoEm']}');
      final cidade = Cidade.fromJson(
        Map<String, dynamic>.from(json['cidade'] as Map),
      );
      final previsao = Previsao.fromJson(
        Map<String, dynamic>.from(json['previsao'] as Map),
      );
      if (salvoEm == null || cidade.id.isEmpty || previsao.dias.isEmpty)
        return null;
      return CacheData(cidade: cidade, previsao: previsao, salvoEm: salvoEm);
    } catch (_) {
      return null;
    }
  }
}
