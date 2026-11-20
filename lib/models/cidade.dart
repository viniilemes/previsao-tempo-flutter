class Cidade {
  const Cidade({required this.id, required this.nome, required this.uf});
  final String id;
  final String nome;
  final String uf;
  Map<String, dynamic> toJson() => {'id': id, 'nome': nome, 'uf': uf};
  factory Cidade.fromJson(Map<String, dynamic> json) => Cidade(
        id: '${json['id'] ?? ''}',
        nome: '${json['nome'] ?? ''}',
        uf: '${json['uf'] ?? ''}',
      );
}
