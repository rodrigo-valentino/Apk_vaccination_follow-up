// lib/screens/details_page.dart - CÓDIGO FINAL COM EDIÇÃO IN-PLACE

import 'package:flutter/material.dart';
// ignore: unnecessary_import
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../helpers/database_helper.dart';
import '../models/crianca.dart';
import '../models/vacina_aplicada.dart';
import '../models/vacina_status.dart';
import '../models/status_vacina.dart';
import '../services/servico_vacinas.dart';
import '../models/dados_detalhados_crianca.dart';

class DetailsPage extends StatefulWidget {
  final Crianca crianca; 
  const DetailsPage({super.key, required this.crianca});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  final dbHelper = DatabaseHelper();
  final servicoVacinas = ServicoVacinas();

  late Crianca _criancaAtual;
  late Future<DadosDetalhadosCrianca> _dadosProcessados;

  @override
  void initState() {
    super.initState();
    _criancaAtual = widget.crianca;
    _carregarDadosDasVacinas();
  }

  void _carregarDadosDasVacinas() {
    setState(() {
      _dadosProcessados = _getVaccineStatusList(_criancaAtual);
    });
  }

  Future<DadosDetalhadosCrianca> _getVaccineStatusList(Crianca crianca) async {
    final vacinasAplicadas = await dbHelper.getAppliedVaccines(crianca.id!);
    return servicoVacinas.calcularStatusDeTodasAsVacinas(
      crianca: crianca,
      vacinasAplicadas: vacinasAplicadas,
    );
  }

  void _onVaccineTapped(VacinaComStatus item, int idadeAtualEmMeses) {
    switch (item.status) {
      case StatusVacina.Vacinado:
        _mostrarOpcoesEdicao(item);
        break;
      case StatusVacina.ADia:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('A vacina "${item.info.nome}" ainda não está disponível para aplicação.')),
        );
        break;
      case StatusVacina.Pendente:
      case StatusVacina.Atrasado:
        _selecionarData(item);
        break;
    }
  }

  Future<void> _selecionarData(VacinaComStatus vacinaComStatus) async {
    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (dataSelecionada != null) {
      final dataFormatada = DateFormat('dd/MM/yyyy').format(dataSelecionada);
      final vacinaParaSalvar = VacinaAplicada(
        criancaId: _criancaAtual.id!,
        nomeVacina: vacinaComStatus.info.nome,
        dataAplicacao: dataFormatada,
      );
      await dbHelper.saveVaccine(vacinaParaSalvar);
      _carregarDadosDasVacinas();
    }
  }

  Future<void> _mostrarOpcoesEdicao(VacinaComStatus item) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Vacina "${item.info.nome}"'),
        content: const Text('O que deseja fazer?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Remover Registro'),
            onPressed: () {
              Navigator.of(context).pop();
              _removerVacina(item);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _removerVacina(VacinaComStatus item) async {
    await dbHelper.deleteVaccine(_criancaAtual.id!, item.info.nome); 
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Vacina "${item.info.nome}" removida com sucesso.')),
    );
    _carregarDadosDasVacinas();
  }

  Future<void> _mostrarDialogoEdicaoResponsavel() async {
    final controller = TextEditingController(text: _criancaAtual.nomeResponsavel ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Responsável'),
        content: TextField(
          controller: controller,
          maxLength: 80,
          maxLines: 1,
          autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Nome do Responsável',
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Salvar'),
            onPressed: () async {
              final updatedChild = Crianca(
                id: _criancaAtual.id,
                nome: _criancaAtual.nome,
                dataNascimento: _criancaAtual.dataNascimento,
                nomeResponsavel: controller.text,
                observacoes: _criancaAtual.observacoes,
              );
              await dbHelper.updateChild(updatedChild);
              if (!mounted) return;
              setState(() {
                _criancaAtual = updatedChild; 
              });
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _mostrarDialogoEdicaoObs() async {
    final controller = TextEditingController(text: _criancaAtual.observacoes ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Observações'),
        content: TextField(
          controller: controller,
          maxLength: 500,
          maxLines: 5,
          autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Observações',
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Salvar'),
            onPressed: () async {
              final updatedChild = Crianca(
                id: _criancaAtual.id,
                nome: _criancaAtual.nome,
                dataNascimento: _criancaAtual.dataNascimento,
                nomeResponsavel: _criancaAtual.nomeResponsavel,
                observacoes: controller.text,
              );
              await dbHelper.updateChild(updatedChild);
              if (!mounted) return;
              setState(() {
                _criancaAtual = updatedChild;
              });
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_criancaAtual.nome),
      ),
      body: FutureBuilder<DadosDetalhadosCrianca>(
        future: _dadosProcessados,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {  
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar dados'));
          }
          if (!snapshot.hasData || snapshot.data!.listaStatusVacinas.isEmpty) {
            return const Center(child: Text('Nenhum dado disponível'));
          }

          final listaDeStatus = snapshot.data!.listaStatusVacinas;
          final idadeAtualEmMeses = snapshot.data!.idadeEmMeses;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(_criancaAtual), 
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Caderneta de Vacinas',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: listaDeStatus.length,
                  itemBuilder: (context, index) {
                    final item = listaDeStatus[index];
                    return _buildVacinaListTile(item, idadeAtualEmMeses);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(Crianca crianca) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.supervisor_account, color: Colors.blueGrey, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Responsável: ${crianca.nomeResponsavel ?? 'Nenhum'}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20, color: Colors.blueGrey),
                  onPressed: _mostrarDialogoEdicaoResponsavel,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Editar Responsável',
                ),
              ],
            ),
            
            const Divider(height: 20),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.comment, color: Colors.blueGrey, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Observações: ${crianca.observacoes ?? 'Nenhuma'}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20, color: Colors.blueGrey),
                  onPressed: _mostrarDialogoEdicaoObs,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Editar Observações',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVacinaListTile(VacinaComStatus item, int idadeAtualEmMeses) {
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
      color: cor.withAlpha(38),
      child: ListTile(
        leading: Icon(icone, color: cor, size: 30),
        title: Text(item.info.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitulo),
        onTap: () => _onVaccineTapped(item, idadeAtualEmMeses),
      ),
    );
  }

  Color _getCorDoStatus(StatusVacina status) {
    switch (status) {
      case StatusVacina.Vacinado: return Colors.green;
      case StatusVacina.Pendente: return Colors.amber.shade700;
      case StatusVacina.Atrasado: return Colors.red;
      case StatusVacina.ADia: return Colors.grey;
    }
  }

  IconData _getIconeDoStatus(StatusVacina status) {
    switch (status) {
      case StatusVacina.Vacinado: return Icons.check_circle;
      case StatusVacina.Pendente: return Icons.schedule;
      case StatusVacina.Atrasado: return Icons.warning;
      case StatusVacina.ADia: return Icons.hourglass_empty;
    }
  }

  String _getStatusText(StatusVacina status) {
    switch (status) {
      case StatusVacina.Pendente: return 'Pendente';
      case StatusVacina.Atrasado: return 'Atrasado';
      case StatusVacina.ADia: return 'Aguardando Idade';
      default: return '';
    }
  }
}