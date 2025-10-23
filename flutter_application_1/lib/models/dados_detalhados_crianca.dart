// lib/models/dados_detalhados_crianca.dart

import 'vacina_status.dart';

class DadosDetalhadosCrianca {
  final List<VacinaComStatus> listaStatusVacinas;
  final int idadeEmMeses;

  DadosDetalhadosCrianca({
    required this.listaStatusVacinas,
    required this.idadeEmMeses,
  });
}