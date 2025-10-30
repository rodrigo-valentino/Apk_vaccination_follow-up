import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:flutter_application_1/models/vacina_status.dart'; 
import 'package:intl/intl.dart'; 
import '../helpers/database_helper.dart';
import '../models/crianca.dart';
import '../models/crianca_status_geral.dart';
import '../models/status_vacina.dart';
import '../services/servico_vacinas.dart';
import 'add_child_page.dart';
import 'details_page.dart';

enum OpcoesOrdenacao { alfabetica, status, idade }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final dbHelper = DatabaseHelper();
  final servicoVacinas = ServicoVacinas();

  bool _isLoading = true;
  OpcoesOrdenacao _ordenacaoAtual = OpcoesOrdenacao.alfabetica;
  final TextEditingController _searchController = TextEditingController();

  List<CriancaComStatus> _listaCompleta = [];
  List<CriancaComStatus> _listaFiltrada = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_aplicarFiltrosESort);
    _carregarDadosIniciais();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _carregarDadosIniciais() async {
    setState(() => _isLoading = true);

    final List<Crianca> criancas = await dbHelper.getChildren();
    final List<CriancaComStatus> listaProcessada = [];

    for (final crianca in criancas) {
      final vacinasAplicadas = await dbHelper.getAppliedVaccines(crianca.id!);

      final dadosProcessados = servicoVacinas.calcularStatusDeTodasAsVacinas(
        crianca: crianca,
        vacinasAplicadas: vacinasAplicadas,
      );
      final idadeDetalhada = servicoVacinas.calcularIdadeDetalhada(crianca.dataNascimento);
      final statusGeral = servicoVacinas.getStatusGeral(dadosProcessados.listaStatusVacinas);

      DateTime dataNascimento;
      try {
        dataNascimento = DateFormat('dd/MM/yyyy').parse(crianca.dataNascimento);
      } catch (e) {
        dataNascimento = DateTime(1900); 
      }

      listaProcessada.add(
        CriancaComStatus(
          crianca: crianca,
          idadeDetalhada: idadeDetalhada,
          statusGeral: statusGeral,
          dataNascimento: dataNascimento, 
        ),
      );
    }

    setState(() {
      _listaCompleta = listaProcessada;
      _isLoading = false;
      _aplicarFiltrosESort();
    });
  }

  void _aplicarFiltrosESort() {
    final String query = _searchController.text.toLowerCase();
    List<CriancaComStatus> listaTemp = [];

    if (query.isNotEmpty) {
      listaTemp = _listaCompleta
          .where((item) => item.crianca.nome.toLowerCase().contains(query))
          .toList();
    } else {
      listaTemp = _listaCompleta.toList(); 
    }

    switch (_ordenacaoAtual) {
      case OpcoesOrdenacao.alfabetica:
        listaTemp.sort((a, b) =>
            a.crianca.nome.toLowerCase().compareTo(b.crianca.nome.toLowerCase()));
        break;
      case OpcoesOrdenacao.status:
        listaTemp.sort((a, b) =>
            _getStatusWeight(a.statusGeral).compareTo(_getStatusWeight(b.statusGeral)));
        break;
      case OpcoesOrdenacao.idade:
        listaTemp.sort((a, b) => b.dataNascimento.compareTo(a.dataNascimento));
        break;
    }

    setState(() => _listaFiltrada = listaTemp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crianças Cadastradas'),
        actions: [
          PopupMenuButton<OpcoesOrdenacao>(
            icon: const Icon(Icons.sort),
            tooltip: 'Ordenar por',
            onSelected: (opcao) {
              setState(() {
                _ordenacaoAtual = opcao;
                _aplicarFiltrosESort();
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: OpcoesOrdenacao.alfabetica,
                child: Text('Ordem Alfabética'),
              ),
              const PopupMenuItem(
                value: OpcoesOrdenacao.status,
                child: Text('Status (Atrasados primeiro)'),
              ),
              const PopupMenuItem(
                value: OpcoesOrdenacao.idade,
                child: Text('Idade (Mais novos primeiro)'),
              ),
            ],
          )
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildChildrenList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateAndRefresh(const AddChildPage()),
        tooltip: 'Adicionar Criança',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: 'Pesquisar por nome...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildChildrenList() {
    if (_listaFiltrada.isEmpty) {
      return Center(
        child: Text(
          _isLoading ? 'A carregar...' : 'Nenhuma criança encontrada.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      itemCount: _listaFiltrada.length,
      itemBuilder: (context, index) {
        final item = _listaFiltrada[index];
        final child = item.crianca;
        final corStatus = _getCorDoStatus(item.statusGeral);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          color: corStatus.withAlpha(38), // 0.15 * 255 = 38
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            leading: Icon(Icons.child_care, size: 40, color: corStatus),
            title: Text(child.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              '${item.idadeDetalhada}\nStatus: ${_getStatusText(item.statusGeral)}',
              style: TextStyle(color: corStatus.withAlpha(230)), // 0.9 * 255 = 230
            ),
            isThreeLine: true,
            onTap: () => _navigateAndRefresh(DetailsPage(crianca: child)),
            trailing: PopupMenuButton(
              onSelected: (value) {
                if (value == 'edit') {
                  _navigateAndRefresh(AddChildPage(crianca: child));
                } else if (value == 'delete') {
                  _showDeleteConfirmationDialog(child);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Editar')),
                const PopupMenuItem(value: 'delete', child: Text('Excluir')),
              ],
            ),
          ),
        );
      },
    );
  }
  
  void _navigateAndRefresh(Widget page) async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    if (result == true) {
      _carregarDadosIniciais();
    }
  }

  void _showDeleteConfirmationDialog(Crianca child) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem a certeza de que deseja excluir ${child.nome}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              dbHelper.deleteChild(child.id!);
              Navigator.of(context).pop();
              _carregarDadosIniciais();
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  int _getStatusWeight(StatusVacina status) {
    switch (status) {
      case StatusVacina.Atrasado: return 0;
      case StatusVacina.Pendente: return 1;
      case StatusVacina.Vacinado: return 2;
      case StatusVacina.ADia: return 3;
    }
  }

  Color _getCorDoStatus(StatusVacina status) {
    switch (status) {
      case StatusVacina.Atrasado: return Colors.red;
      case StatusVacina.Pendente: return Colors.amber.shade700;
      default: return Colors.green;
    }
  }

  String _getStatusText(StatusVacina status) {
    switch (status) {
      case StatusVacina.Atrasado: return 'Atrasado';
      case StatusVacina.Pendente: return 'Pendente';
      default: return 'Em Dia';
    }
  }
}