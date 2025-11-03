// lib/models/crianca.dart

class Crianca {
  int? id;
  String nome;
  String dataNascimento;
  String? nomeResponsavel; 
  String? observacoes;     

  Crianca({
    this.id,
    required this.nome,
    required this.dataNascimento,
    this.nomeResponsavel, 
    this.observacoes,     
  });

  // Converte um objeto Crianca num Map (para guardar no banco de dados)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'dataNascimento': dataNascimento,
      'nomeResponsavel': nomeResponsavel,
      'observacoes': observacoes,         
    };
  }

  // Converte um Map (vindo do banco de dados) num objeto Criança
  factory Crianca.fromMap(Map<String, dynamic> map) {
    return Crianca(
      id: map['id'],
      nome: map['nome'],
      dataNascimento: map['dataNascimento'],
      nomeResponsavel: map['nomeResponsavel'], 
      observacoes: map['observacoes'],        
    );
  }
}