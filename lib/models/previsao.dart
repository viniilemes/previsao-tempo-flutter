class DiaPrevisao {
  const DiaPrevisao({
    required this.dia,
    required this.tempo,
    required this.maxima,
    required this.minima,
    this.iuv,
  });
  final String dia;
  final String tempo;
  final double? maxima;
  final double? minima;
  final double? iuv;
  Map<String, dynamic> toJson() => {
        'dia': dia,
        'tempo': tempo,
        'maxima': maxima,
        'minima': minima,
        'iuv': iuv,
      };
  factory DiaPrevisao.fromJson(Map<String, dynamic> json) => DiaPrevisao(
        dia: '${json['dia'] ?? ''}',
        tempo: '${json['tempo'] ?? 'nd'}',
        maxima: _number(json['maxima']),
        minima: _number(json['minima']),
        iuv: _number(json['iuv']),
      );
  static double? _number(dynamic value) =>
      value is num ? value.toDouble() : double.tryParse('$value');
}

class Previsao {
  const Previsao({
    required this.nome,
    required this.uf,
    required this.atualizacao,
    required this.dias,
  });
  final String nome;
  final String uf;
  final String atualizacao;
  final List<DiaPrevisao> dias;
  Map<String, dynamic> toJson() => {
        'nome': nome,
        'uf': uf,
        'atualizacao': atualizacao,
        'dias': dias.map((d) => d.toJson()).toList(),
      };
  factory Previsao.fromJson(Map<String, dynamic> json) => Previsao(
        nome: '${json['nome'] ?? 'Não informado'}',
        uf: '${json['uf'] ?? ''}',
        atualizacao: '${json['atualizacao'] ?? ''}',
        dias: (json['dias'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(DiaPrevisao.fromJson)
            .toList(),
      );
}
