// lib/screens/details_page.dart - CÓDIGO FINAL

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../helpers/database_helper.dart';
import '../models/crianca.dart';
import '../models/vacina_aplicada.dart';
import '../models/vacina_status.dart';
import '../models/status_vacina.dart';
import '../services/servico_vacinas.dart';

class DetailsPage extends StatefulWidget {
  final Crianca crianca;

  const DetailsPage({super.key, required this.crianca});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  final dbHelper = DatabaseHelper();
  final servicoVacinas = ServicoVacinas();

  // Usaremos um Future para carregar a lista de vacinas de forma assíncrona
  late Future<List<VacinaComStatus>> _listaDeStatusVacinas;

  @override
  void initState() {
    super.initState();
    _carregarDadosDasVacinas();
  }

  void _carregarDadosDasVacinas() {
    setState(() {
      _listaDeStatusVacinas = _getVaccineStatusList();
    });
  }

  // Função principal que busca os dados e os processa
  Future<List<VacinaComStatus>> _getVaccineStatusList() async {
    // 1. Busca no banco de dados as vacinas já aplicadas para esta criança
    final vacinasAplicadas = await dbHelper.getAppliedVaccines(widget.crianca.id!);

    // 2. Usa o nosso serviço para calcular o status de todas as vacinas
    return servicoVacinas.calcularStatusDeTodasAsVacinas(
      crianca: widget.crianca,
      vacinasAplicadas: vacinasAplicadas,
    );
  }

  // Função para mostrar o seletor de data
  Future<void> _selecionarData(VacinaComStatus vacinaComStatus) async {
    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'), // Para ter o calendário em português
    );

    if (dataSelecionada != null) {
      final dataFormatada = DateFormat('dd/MM/yyyy').format(dataSelecionada);

      // Cria o objeto para salvar no banco de dados
      final vacinaParaSalvar = VacinaAplicada(
        criancaId: widget.crianca.id!,
        nomeVacina: vacinaComStatus.info.nome,
        dataAplicacao: dataFormatada,
      );

      // Salva no banco de dados
      await dbHelper.saveVaccine(vacinaParaSalvar);

      // Recarrega a lista para mostrar a atualização na tela
      _carregarDadosDasVacinas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.crianca.nome),
      ),
      body: FutureBuilder<List<VacinaComStatus>>(
        future: _listaDeStatusVacinas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar vacinas: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Não foi possível calcular o status das vacinas.'));
          }

          final listaDeStatus = snapshot.data!;

          return ListView.builder(
            itemCount: listaDeStatus.length,
            itemBuilder: (context, index) {
              final item = listaDeStatus[index];
              return _buildVacinaListTile(item);
            },
          );
        },
      ),
    );
  }

  // Widget auxiliar para construir cada item da lista
  Widget _buildVacinaListTile(VacinaComStatus item) {
    final cor = _getCorDoStatus(item.status);
    final icone = _getIconeDoStatus(item.status);
    String subtitulo;

    if (item.status == StatusVacina.Vacinado) {
      subtitulo = 'Aplicada em: ${item.dataAplicacao}';
    } else {
      subtitulo = 'Status: ${_getStatusText(item.status)}';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: cor.withOpacity(0.15), // Cor de fundo suave
      child: ListTile(
        leading: Icon(icone, color: cor, size: 30),
        title: Text(item.info.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitulo),
        onTap: () => _selecionarData(item),
      ),
    );
  }

  // Funções auxiliares para a UI
  Color _getCorDoStatus(StatusVacina status) {
    switch (status) {
      case StatusVacina.Vacinado:
        return Colors.green;
      case StatusVacina.Pendente:
        return Colors.amber.shade700;
      case StatusVacina.Atrasado:
        return Colors.red;
      case StatusVacina.ADia:
        return Colors.grey;
    }
  }

  IconData _getIconeDoStatus(StatusVacina status) {
    switch (status) {
      case StatusVacina.Vacinado:
        return Icons.check_circle;
      case StatusVacina.Pendente:
        return Icons.schedule;
      case StatusVacina.Atrasado:
        return Icons.warning;
      case StatusVacina.ADia:
        return Icons.hourglass_empty;
    }
  }

  String _getStatusText(StatusVacina status) {
    switch (status) {
      case StatusVacina.Pendente:
        return 'Pendente';
      case StatusVacina.Atrasado:
        return 'Atrasado';
      case StatusVacina.ADia:
        return 'Aguardando Idade';
      default:
        return '';
    }
  }
}