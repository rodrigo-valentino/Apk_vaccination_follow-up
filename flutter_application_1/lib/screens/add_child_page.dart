// lib/screens/add_child_page.dart - CÓDIGO ATUALIZADO

import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../models/crianca.dart';

class AddChildPage extends StatefulWidget {
  // Adicionamos uma variável opcional para receber a criança a ser editada
  final Crianca? crianca;

  const AddChildPage({super.key, this.crianca});

  @override
  State<AddChildPage> createState() => _AddChildPageState();
}

class _AddChildPageState extends State<AddChildPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final dbHelper = DatabaseHelper();

  // Variável para saber se estamos a editar ou a adicionar
  bool get _isEditing => widget.crianca != null;

  @override
  void initState() {
    super.initState();
    // Se estivermos a editar, preenchemos os campos com os dados existentes
    if (_isEditing) {
      _nameController.text = widget.crianca!.nome;
      _birthDateController.text = widget.crianca!.dataNascimento;
    }
  }

  void _saveChild() async {
    if (_formKey.currentState!.validate()) {
      if (_isEditing) {
        // Lógica de ATUALIZAÇÃO
        final updatedChild = Crianca(
          id: widget.crianca!.id, // Mantém o mesmo ID
          nome: _nameController.text,
          dataNascimento: _birthDateController.text,
        );
        await dbHelper.updateChild(updatedChild);
      } else {
        // Lógica de CRIAÇÃO (como antes)
        final newChild = Crianca(
          nome: _nameController.text,
          dataNascimento: _birthDateController.text,
        );
        await dbHelper.addChild(newChild);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Criança salva com sucesso!')),
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // O título da página muda se estivermos a adicionar ou a editar
        title: Text(_isEditing ? 'Editar Criança' : 'Adicionar Nova Criança'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome Completo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _birthDateController,
                decoration: const InputDecoration(
                  labelText: 'Data de Nascimento',
                  hintText: 'dd/mm/aaaa',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a data';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveChild,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}