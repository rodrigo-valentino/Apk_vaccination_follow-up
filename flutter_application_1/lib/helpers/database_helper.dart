// lib/helpers/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/crianca.dart';

class DatabaseHelper {
  // Padrão Singleton: garante que teremos apenas uma instância do nosso banco de dados
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Inicializa o banco de dados
  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'vacinacao.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Cria a tabela quando o banco de dados é criado pela primeira vez
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE criancas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        dataNascimento TEXT NOT NULL
      )
    ''');
  }

  // --- Métodos para interagir com a tabela 'criancas' ---

  // Inserir uma nova criança
  Future<int> addChild(Crianca crianca) async {
    final db = await database;
    return await db.insert('criancas', crianca.toMap());
  }

  // Obter a lista de todas as crianças
  Future<List<Crianca>> getChildren() async {
    final db = await database;
    // Ordena por nome em ordem alfabética
    final List<Map<String, dynamic>> maps = await db.query('criancas', orderBy: 'nome ASC');

    return List.generate(maps.length, (i) {
      return Crianca.fromMap(maps[i]);
    });
  }

// U - Update: Atualizar uma criança existente
  Future<int> updateChild(Crianca crianca) async {
    final db = await database;
    return await db.update(
      'criancas',
      crianca.toMap(),
      where: 'id = ?', // Usa o ID para encontrar o registo certo
      whereArgs: [crianca.id],
    );
  }

  // D - Delete: Apagar uma criança pelo ID
  Future<int> deleteChild(int id) async {
    final db = await database;
    return await db.delete(
      'criancas',
      where: 'id = ?', // Usa o ID para encontrar o registo certo
      whereArgs: [id],
    );
  }
}