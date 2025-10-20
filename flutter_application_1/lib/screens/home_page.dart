// lib/screens/home_page.dart - CÓDIGO FINAL COM CRUD COMPLETO

import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../models/crianca.dart';
import 'add_child_page.dart';
import 'details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Crianca>> _childrenList;
  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _refreshChildrenList();
  }

  void _refreshChildrenList() {
    setState(() {
      _childrenList = dbHelper.getChildren();
    });
  }

  void _navigateAndRefresh(Widget page) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
    if (result == true) {
      _refreshChildrenList();
    }
  }

  void _deleteChild(int id) async {
    await dbHelper.deleteChild(id);
     if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Criança removida com sucesso!')),
        );
    }
    _refreshChildrenList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crianças Cadastradas'),
      ),
      body: FutureBuilder<List<Crianca>>(
        future: _childrenList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma criança cadastrada.\nClique no botão "+" para adicionar.',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          final children = snapshot.data!;
          return ListView.builder(
            itemCount: children.length,
            itemBuilder: (context, index) {
              final child = children[index];
              return ListTile(
                title: Text(child.nome),
                subtitle: Text('Nasc.: ${child.dataNascimento}'),
                leading: const Icon(Icons.child_care, size: 40),
                onTap: () {
                  // O toque normal continua a levar para a página de detalhes
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailsPage(crianca: child),
                    ),
                  );
                  // ▲▲▲ FIM DA ALTERAÇÃO ▲▲▲
                },
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Editar'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Excluir'),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      // Ação de Editar: Navega para a AddChildPage com os dados da criança
                      _navigateAndRefresh(AddChildPage(crianca: child));
                    } else if (value == 'delete') {
                      // Ação de Excluir: Mostra um diálogo de confirmação
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirmar Exclusão'),
                          content: Text('Tem a certeza de que deseja excluir ${child.nome}?'),
                          actions: [
                            TextButton(
                              child: const Text('Cancelar'),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            TextButton(
                              child: const Text('Excluir'),
                              onPressed: () {
                                _deleteChild(child.id!);
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateAndRefresh(const AddChildPage()),
        // ignore: sort_child_properties_last
        child: const Icon(Icons.add),
        tooltip: 'Adicionar Criança',
      ),
    );
  }
}
                  
