// lib/data/lista_vacinas.dart

// Uma classe para representar a informação estática de cada vacina
class VacinaInfo {
  final String nome;
  final int idadeMinimaMeses; // Idade para ficar "Pendente" (amarelo)
  final int idadeMaximaMeses; // Idade para ficar "Atrasado" (vermelho)

  const VacinaInfo({
    required this.nome,
    required this.idadeMinimaMeses,
    required this.idadeMaximaMeses,
  });
}

// A lista oficial de todas as vacinas do programa
const List<VacinaInfo> calendarioVacinal = [
  VacinaInfo(nome: "BCG", idadeMinimaMeses: 0, idadeMaximaMeses: 1),
  VacinaInfo(nome: "Hepatite B", idadeMinimaMeses: 0, idadeMaximaMeses: 1),
  VacinaInfo(nome: "Penta 2M", idadeMinimaMeses: 2, idadeMaximaMeses: 3),
  VacinaInfo(nome: "Pneumo 2M", idadeMinimaMeses: 2, idadeMaximaMeses: 3),
  VacinaInfo(nome: "VIP 2M", idadeMinimaMeses: 2, idadeMaximaMeses: 3),
  VacinaInfo(nome: "Rota 2M", idadeMinimaMeses: 2, idadeMaximaMeses: 3),
  VacinaInfo(nome: "MCC/ACWY 3M", idadeMinimaMeses: 3, idadeMaximaMeses: 4),
  VacinaInfo(nome: "Penta 4M", idadeMinimaMeses: 4, idadeMaximaMeses: 5),
  VacinaInfo(nome: "Pneumo 4M", idadeMinimaMeses: 4, idadeMaximaMeses: 5),
  VacinaInfo(nome: "VIP 4M", idadeMinimaMeses: 4, idadeMaximaMeses: 5),
  VacinaInfo(nome: "Rota 4M", idadeMinimaMeses: 4, idadeMaximaMeses: 5),
  VacinaInfo(nome: "MCC/ACWY 5M", idadeMinimaMeses: 5, idadeMaximaMeses: 6),
  VacinaInfo(nome: "Penta 6M", idadeMinimaMeses: 6, idadeMaximaMeses: 7),
  VacinaInfo(nome: "VIP 6M", idadeMinimaMeses: 6, idadeMaximaMeses: 7),
  VacinaInfo(nome: "1ª Influenza 6M", idadeMinimaMeses: 6, idadeMaximaMeses: 7),
  VacinaInfo(nome: "Febre Amarela 9M", idadeMinimaMeses: 9, idadeMaximaMeses: 10),
  VacinaInfo(nome: "Ref Pneumo 12M", idadeMinimaMeses: 12, idadeMaximaMeses: 13),
  VacinaInfo(nome: "ACWY 12M", idadeMinimaMeses: 12, idadeMaximaMeses: 13),
  VacinaInfo(nome: "1ª Tríplice Viral 12M", idadeMinimaMeses: 12, idadeMaximaMeses: 13),
  VacinaInfo(nome: "DTP 15M", idadeMinimaMeses: 15, idadeMaximaMeses: 16),
  VacinaInfo(nome: "Hep A 15M", idadeMinimaMeses: 15, idadeMaximaMeses: 16),
  VacinaInfo(nome: "Tetra/Varicela 15M", idadeMinimaMeses: 15, idadeMaximaMeses: 16),
  VacinaInfo(nome: "2ª Triviral 15M", idadeMinimaMeses: 15, idadeMaximaMeses: 16),
  VacinaInfo(nome: "Ref VIP 15M", idadeMinimaMeses: 15, idadeMaximaMeses: 16),
  VacinaInfo(nome: "Ref DTP 4A", idadeMinimaMeses: 48, idadeMaximaMeses: 49),
  VacinaInfo(nome: "Varicela/Tetra 4A", idadeMinimaMeses: 48, idadeMaximaMeses: 49),
  VacinaInfo(nome: "Febre Amarela 4A", idadeMinimaMeses: 48, idadeMaximaMeses: 49),
  VacinaInfo(nome: "VIP 4A", idadeMinimaMeses: 48, idadeMaximaMeses: 49),
];