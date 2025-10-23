// lib/services/servico_vacinas.dart - CÓDIGO ATUALIZADO

import 'package:intl/intl.dart';
import '../data/lista_vacinas.dart';
import '../models/crianca.dart';
import '../models/status_vacina.dart';
import '../models/vacina_aplicada.dart';
import '../models/vacina_status.dart';
import '../models/dados_detalhados_crianca.dart';

class ServicoVacinas {
  // --- Funções de Cálculo de Idade ---

  int _calcularIdadeEmMeses(DateTime dataNascimento) {
    final hoje = DateTime.now();
    int meses = (hoje.year - dataNascimento.year) * 12 + hoje.month - dataNascimento.month;
    if (hoje.day < dataNascimento.day) {
      meses--;
    }
    return meses;
  }

  // ▼▼▼ NOVA FUNÇÃO ▼▼▼
  // Calcula a idade detalhada para exibição (ex: "1 ano e 2 meses")
  String calcularIdadeDetalhada(String dataNascimentoStr) {
    try {
      final dataNascimento = DateFormat('dd/MM/yyyy').parse(dataNascimentoStr);
      final hoje = DateTime.now();

      final anos = hoje.year - dataNascimento.year;
      final meses = hoje.month - dataNascimento.month;
      final dias = hoje.day - dataNascimento.day;

      int anosFinal = anos;
      int mesesFinal = meses;

      if (dias < 0) {
        mesesFinal--;
      }
      if (mesesFinal < 0) {
        anosFinal--;
        mesesFinal += 12;
      }
      
      if (anosFinal > 0) {
        final pluralAnos = anosFinal == 1 ? "ano" : "anos";
        final pluralMeses = mesesFinal == 1 ? "mês" : "meses";
        return "$anosFinal $pluralAnos e $mesesFinal $pluralMeses";
      } else {
         final pluralMeses = mesesFinal == 1 ? "mês" : "meses";
        return "$mesesFinal $pluralMeses";
      }
    } catch (e) {
      return "Idade inválida";
    }
  }

  // --- Funções de Cálculo de Status ---

  // ▼▼▼ NOVA FUNÇÃO ▼▼▼
  // Determina o status geral da criança com base na lista de status de vacinas
  StatusVacina getStatusGeral(List<VacinaComStatus> listaStatus) {
    if (listaStatus.any((v) => v.status == StatusVacina.Atrasado)) {
      return StatusVacina.Atrasado;
    }
    if (listaStatus.any((v) => v.status == StatusVacina.Pendente)) {
      return StatusVacina.Pendente;
    }
    // Se não há atrasadas nem pendentes, consideramos "Vacinado" para o status geral
    return StatusVacina.Vacinado;
  }
  
  // A função principal que processa a lista de vacinas (continua igual)
  // Mude o tipo de retorno da função
  DadosDetalhadosCrianca calcularStatusDeTodasAsVacinas({
    required Crianca crianca,
    required List<VacinaAplicada> vacinasAplicadas,
  }) {
    DateTime dataNascimento;
    try {
      dataNascimento = DateFormat('dd/MM/yyyy').parse(crianca.dataNascimento);
    } catch (e) {
      // Se a data falhar, retorna um objeto vazio
      return DadosDetalhadosCrianca(listaStatusVacinas: [], idadeEmMeses: 0);
    }

    final int idadeEmMeses = _calcularIdadeEmMeses(dataNascimento); // Já calculamos isto!
    final mapaVacinasAplicadas = { for (var v in vacinasAplicadas) v.nomeVacina: v.dataAplicacao };
    List<VacinaComStatus> statusFinal = [];

    for (final vacinaInfo in calendarioVacinal) {
      StatusVacina status;
      String? dataAplicacao;
      if (mapaVacinasAplicadas.containsKey(vacinaInfo.nome)) {
        status = StatusVacina.Vacinado;
        dataAplicacao = mapaVacinasAplicadas[vacinaInfo.nome];
      } else {
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

    // Mude a linha final de 'return'
    return DadosDetalhadosCrianca(
      listaStatusVacinas: statusFinal,
      idadeEmMeses: idadeEmMeses,
    );
  }
}