// lib/models/crianca.dart

class Crianca {
  int? id; // O ID será gerado pelo banco de dados, por isso é opcional (?)
  String nome;
  String dataNascimento;

  Crianca({
    this.id,
    required this.nome,
    required this.dataNascimento,
  });

  // Converte um objeto Crianca num Map (para guardar no banco de dados)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'dataNascimento': dataNascimento,
    };
  }

  // Converte um Map (vindo do banco de dados) num objeto Crianca
  factory Crianca.fromMap(Map<String, dynamic> map) {
    return Crianca(
      id: map['id'],
      nome: map['nome'],
      dataNascimento: map['dataNascimento'],
    );
  }
}