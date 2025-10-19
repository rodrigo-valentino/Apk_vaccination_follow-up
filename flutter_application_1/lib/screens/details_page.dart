import 'package:flutter/material.dart';

class DetailsPage extends StatelessWidget {
  // Esta variável vai receber o nome da criança da HomePage
  final String childName;

  const DetailsPage({super.key, required this.childName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(childName), // O título da barra é o nome da criança
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informações da Criança (por enquanto, estático)
            const Text(
              'Idade Detalhada: 1 ano e 2 meses',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            const Text(
              'Status das Vacinas:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Aqui entrará a lista de vacinas no futuro.
            // Por agora, um exemplo estático:
            ListTile(
              title: const Text('Penta 2M'),
              subtitle: const Text('Status: Atrasado'),
              tileColor: Colors.red.shade100, // Fundo vermelho claro
              leading: const Icon(Icons.warning, color: Colors.red),
            ),
            ListTile(
              title: const Text('Febre Amarela 9M'),
              subtitle: const Text('Status: Pendente'),
              tileColor: Colors.yellow.shade100, // Fundo amarelo claro
              leading: const Icon(Icons.schedule, color: Colors.amber),
            ),
             ListTile(
              title: const Text('BCG'),
              subtitle: const Text('Aplicada em: 10/08/2024'),
              tileColor: Colors.green.shade100, // Fundo verde claro
              leading: const Icon(Icons.check_circle, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}