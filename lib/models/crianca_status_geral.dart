import 'crianca.dart';
import 'status_vacina.dart';

class CriancaComStatus {
  final Crianca crianca;
  final String idadeDetalhada;
  final StatusVacina statusGeral;
  final DateTime dataNascimento;

  CriancaComStatus({
    required this.crianca,
    required this.idadeDetalhada,
    required this.statusGeral,
    required this.dataNascimento,
  });
}