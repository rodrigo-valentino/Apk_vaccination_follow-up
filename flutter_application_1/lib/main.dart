// lib/main.dart - CÓDIGO CORRIGIDO PARA DESKTOP E MOBILE

import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Importa o pacote FFI
import 'dart:io'; // Importa o pacote para verificar a plataforma (Desktop/Mobile)
import 'screens/home_page.dart';

Future<void> main() async {
  // === INÍCIO DA CORREÇÃO ===

  // Garante que o Flutter está inicializado antes de qualquer outra coisa
  WidgetsFlutterBinding.ensureInitialized();

  // Verifica se a plataforma NÃO é Android nem iOS
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Inicializa o sqflite para ambientes FFI (desktop)
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // === FIM DA CORREÇÃO ===

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle de Vacinas',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}