// lib/screens/add_child_page.dart - CÓDIGO ATUALIZADO

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import necessário para o maxLength
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart'; // Importa o pacote da máscara
import '../helpers/database_helper.dart';
import '../models/crianca.dart';

class AddChildPage extends StatefulWidget {
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

  // Cria a máscara para o formato de data dd/mm/aaaa
  final _dateMaskFormatter = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  bool get _isEditing => widget.crianca != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.crianca!.nome;
      _birthDateController.text = widget.crianca!.dataNascimento;
    }
  }

  void _saveChild() async {
    if (_formKey.currentState!.validate()) {
      // Lógica de salvar continua a mesma...
      if (_isEditing) {
        final updatedChild = Crianca(
          id: widget.crianca!.id,
          nome: _nameController.text,
          dataNascimento: _birthDateController.text,
        );
        await dbHelper.updateChild(updatedChild);
      } else {
        final newChild = Crianca(
          nome: _nameController.text,
          dataNascimento: _birthDateController.text,
        );
        await dbHelper.addChild(newChild);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Criança salva com sucesso!')),
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                // ▼▼▼ MELHORIA APLICADA ▼▼▼
                maxLength: 80, // Limita o nome a 80 caracteres
                inputFormatters: [
                  LengthLimitingTextInputFormatter(80),
                ],
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
                // ▼▼▼ MELHORIA APLICADA ▼▼▼
                inputFormatters: [_dateMaskFormatter], // Aplica a máscara
                keyboardType: TextInputType.datetime, // Mostra o teclado numérico
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a data';
                  }
                  if (value.length < 10) {
                    return 'Por favor, preencha a data completa';
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