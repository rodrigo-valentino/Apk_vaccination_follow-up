// lib/screens/details_page.dart - CÓDIGO ATUALIZADO (EDIÇÃO/REMOÇÃO/RESTRIÇÃO)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../helpers/database_helper.dart';
import '../models/crianca.dart';
import '../models/vacina_aplicada.dart';
import '../models/vacina_status.dart';
import '../models/status_vacina.dart';
import '../services/servico_vacinas.dart';
import '../models/dados_detalhados_crianca.dart'; // Importa o novo modelo

class DetailsPage extends StatefulWidget {
  final Crianca crianca;

  const DetailsPage({super.key, required this.crianca});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  final dbHelper = DatabaseHelper();
  final servicoVacinas = ServicoVacinas();

  // A Future agora carrega o nosso novo objeto
  late Future<DadosDetalhadosCrianca> _dadosProcessados;

  @override
  void initState() {
    super.initState();
    _carregarDadosDasVacinas();
  }

  void _carregarDadosDasVacinas() {
    setState(() {
      _dadosProcessados = _getVaccineStatusList();
    });
  }

  // A função agora retorna o nosso novo objeto
  Future<DadosDetalhadosCrianca> _getVaccineStatusList() async {
    final vacinasAplicadas = await dbHelper.getAppliedVaccines(widget.crianca.id!);
    
    // O serviço agora retorna o objeto com a lista E a idade
    return servicoVacinas.calcularStatusDeTodasAsVacinas(
      crianca: widget.crianca,
      vacinasAplicadas: vacinasAplicadas,
    );
  }

  // ▼▼▼ NOVA LÓGICA DE CLIQUE ▼▼▼
  void _onVaccineTapped(VacinaComStatus item, int idadeAtualEmMeses) {
    switch (item.status) {
      // 1. JÁ VACINADO (Verde): Mostrar opções de Edição/Remoção
      case StatusVacina.Vacinado:
        _mostrarOpcoesEdicao(item);
        break;
      
      // 2. AGUARDANDO IDADE (Cinza): Mostrar aviso
      case StatusVacina.ADia:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A criança ainda não tem idade para esta vacina.'),
            backgroundColor: Colors.blueGrey,
          ),
        );
        break;

      // 3. PENDENTE ou ATRASADO (Amarelo/Vermelho): Abrir calendário
      case StatusVacina.Pendente:
      case StatusVacina.Atrasado:
        _selecionarData(item);
        break;
    }
  }

  // Função para mostrar o seletor de data (abrir o calendário)
  Future<void> _selecionarData(VacinaComStatus vacinaComStatus) async {
    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(), // Impede datas futuras
      locale: const Locale('pt', 'BR'),
    );

    if (dataSelecionada != null) {
      final dataFormatada = DateFormat('dd/MM/yyyy').format(dataSelecionada);
      final vacinaParaSalvar = VacinaAplicada(
        criancaId: widget.crianca.id!,
        nomeVacina: vacinaComStatus.info.nome,
        dataAplicacao: dataFormatada,
      );
      await dbHelper.saveVaccine(vacinaParaSalvar);
      _carregarDadosDasVacinas();
    }
  }

  // ▼▼▼ NOVA FUNÇÃO ▼▼▼
  // Mostra o diálogo para Editar ou Remover
  Future<void> _mostrarOpcoesEdicao(VacinaComStatus item) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.info.nome),
        content: const Text('O que deseja fazer com esta vacina?'),
        actions: [
          TextButton(
            child: const Text('Remover Lançamento'),
            onPressed: () {
              Navigator.of(context).pop(); // Fecha o diálogo
              _removerVacina(item);
            },
          ),
          TextButton(
            child: const Text('Editar Data'),
            onPressed: () {
              Navigator.of(context).pop(); // Fecha o diálogo
              _selecionarData(item); // Abre o calendário
            },
          ),
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  // ▼▼▼ NOVA FUNÇÃO ▼▼▼
  // Remove a data da vacina do banco de dados
Future<void> _removerVacina(VacinaComStatus item) async {
  await dbHelper.deleteVaccine(widget.crianca.id!, item.info.nome);

  if (!mounted) return; // Garante que o widget ainda está ativo

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Data da vacina removida com sucesso!'),
      backgroundColor: Colors.red,
    ),
  );

  _carregarDadosDasVacinas();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.crianca.nome),
      ),
      // O FutureBuilder agora usa o nosso novo objeto
      body: FutureBuilder<DadosDetalhadosCrianca>(
        future: _dadosProcessados,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar vacinas: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.listaStatusVacinas.isEmpty) {
            return const Center(child: Text('Não foi possível calcular o status das vacinas.'));
          }

          // Obtemos a lista E a idade
          final listaDeStatus = snapshot.data!.listaStatusVacinas;
          final idadeAtualEmMeses = snapshot.data!.idadeEmMeses;

          return ListView.builder(
            itemCount: listaDeStatus.length,
            itemBuilder: (context, index) {
              final item = listaDeStatus[index];
              return _buildVacinaListTile(item, idadeAtualEmMeses); // Passa a idade
            },
          );
        },
      ),
    );
  }

  // O ListTile agora recebe a idade para a lógica de clique
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
      color: cor.withAlpha(38), // Fundo suave
      child: ListTile(
        leading: Icon(icone, color: cor, size: 30),
        title: Text(item.info.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitulo),
        onTap: () => _onVaccineTapped(item, idadeAtualEmMeses), // Chama a nova função de clique
      ),
    );
  }

  // Funções auxiliares (sem alteração)
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