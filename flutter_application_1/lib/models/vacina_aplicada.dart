// lib/models/vacina_aplicada.dart

class VacinaAplicada {
  int? id;
  final int criancaId; // Chave estrangeira para ligar à criança
  final String nomeVacina;
  String dataAplicacao;

  VacinaAplicada({
    this.id,
    required this.criancaId,
    required this.nomeVacina,
    required this.dataAplicacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'criancaId': criancaId,
      'nomeVacina': nomeVacina,
      'dataAplicacao': dataAplicacao,
    };
  }

  factory VacinaAplicada.fromMap(Map<String, dynamic> map) {
    return VacinaAplicada(
      id: map['id'],
      criancaId: map['criancaId'],
      nomeVacina: map['nomeVacina'],
      dataAplicacao: map['dataAplicacao'],
    );
  }
}