// lib/models/vacina_status.dart

import '../data/lista_vacinas.dart';
import 'status_vacina.dart';

class VacinaComStatus {
  final VacinaInfo info; // A informação estática da vacina
  final StatusVacina status; // O status calculado
  final String? dataAplicacao; // A data, se tiver sido aplicada

  VacinaComStatus({
    required this.info,
    required this.status,
    this.dataAplicacao,
  });
}