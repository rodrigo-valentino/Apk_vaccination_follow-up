// lib/services/servico_vacinas.dart

import 'package:intl/intl.dart';
import '../data/lista_vacinas.dart';
import '../models/crianca.dart';
import '../models/status_vacina.dart';
import '../models/vacina_aplicada.dart';
import '../models/vacina_status.dart';

class ServicoVacinas {

  // Calcula a idade da criança em meses completos
  int _calcularIdadeEmMeses(DateTime dataNascimento) {
    final hoje = DateTime.now();
    // Anos de diferença * 12 + meses de diferença
    int meses = (hoje.year - dataNascimento.year) * 12 + hoje.month - dataNascimento.month;

    // Se o dia de hoje for anterior ao dia do aniversário no mês corrente,
    // significa que o mês ainda não foi completado.
    if (hoje.day < dataNascimento.day) {
      meses--;
    }
    return meses;
  }

  // A função principal que processa a lista de vacinas
  List<VacinaComStatus> calcularStatusDeTodasAsVacinas({
    required Crianca crianca,
    required List<VacinaAplicada> vacinasAplicadas,
  }) {
    // Primeiro, parseamos a data de nascimento da criança que está como String
    // Usamos um try-catch para o caso de a data estar num formato inválido
    DateTime dataNascimento;
    try {
      dataNascimento = DateFormat('dd/MM/yyyy').parse(crianca.dataNascimento);
    } catch (e) {
      // Se o formato for inválido, não podemos calcular. Retornamos uma lista vazia.
      print("Erro ao parsear a data de nascimento: ${crianca.dataNascimento}");
      return [];
    }

    final int idadeEmMeses = _calcularIdadeEmMeses(dataNascimento);

    // Converte a lista de vacinas aplicadas num mapa para uma busca rápida e eficiente
    final mapaVacinasAplicadas = {
      for (var v in vacinasAplicadas) v.nomeVacina: v.dataAplicacao
    };

    // Lista final que será retornada
    List<VacinaComStatus> statusFinal = [];

    // Itera sobre a lista oficial de vacinas do calendário
    for (final vacinaInfo in calendarioVacinal) {
      StatusVacina status;
      String? dataAplicacao;

      // 1. Verifica se a vacina já foi aplicada
      if (mapaVacinasAplicadas.containsKey(vacinaInfo.nome)) {
        status = StatusVacina.Vacinado;
        dataAplicacao = mapaVacinasAplicadas[vacinaInfo.nome];
      }
      // 2. Se não foi aplicada, verifica a idade da criança
      else {
        if (idadeEmMeses >= vacinaInfo.idadeMaximaMeses) {
          status = StatusVacina.Atrasado;
        } else if (idadeEmMeses >= vacinaInfo.idadeMinimaMeses) {
          status = StatusVacina.Pendente;
        } else {
          status = StatusVacina.ADia;
        }
      }

      statusFinal.add(
        VacinaComStatus(
          info: vacinaInfo,
          status: status,
          dataAplicacao: dataAplicacao,
        ),
      );
    }

    return statusFinal;
  }
}