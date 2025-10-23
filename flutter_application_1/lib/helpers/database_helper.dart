// lib/helpers/database_helper.dart - CÓDIGO COMPLETO E CORRIGIDO

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/crianca.dart';
import '../models/vacina_aplicada.dart'; // Import necessário

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'vacinacao.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE criancas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        dataNascimento TEXT NOT NULL
      )
    ''');
    await _createVacinasTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createVacinasTable(db);
    }
  }

  Future<void> _createVacinasTable(Database db) async {
    await db.execute('''
      CREATE TABLE vacinas_aplicadas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        criancaId INTEGER NOT NULL,
        nomeVacina TEXT NOT NULL,
        dataAplicacao TEXT NOT NULL,
        FOREIGN KEY (criancaId) REFERENCES criancas (id) ON DELETE CASCADE
      )
    ''');
  }

  // --- Métodos CRUD para Crianças ---

  Future<int> addChild(Crianca crianca) async {
    final db = await database;
    return await db.insert('criancas', crianca.toMap());
  }

  Future<List<Crianca>> getChildren() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('criancas', orderBy: 'nome ASC');
    return List.generate(maps.length, (i) => Crianca.fromMap(maps[i]));
  }

  Future<int> updateChild(Crianca crianca) async {
    final db = await database;
    return await db.update('criancas', crianca.toMap(), where: 'id = ?', whereArgs: [crianca.id]);
  }

  Future<int> deleteChild(int id) async {
    final db = await database;
    return await db.delete('criancas', where: 'id = ?', whereArgs: [id]);
  }

  // --- Métodos CRUD para Vacinas Aplicadas ---

  Future<void> saveVaccine(VacinaAplicada vacina) async {
    final db = await database;
    final existing = await db.query(
      'vacinas_aplicadas',
      where: 'criancaId = ? AND nomeVacina = ?',
      whereArgs: [vacina.criancaId, vacina.nomeVacina],
    );
    if (existing.isNotEmpty) {

      final dataUpdate = vacina.toMap();
      dataUpdate['id'] = existing.first['id'];

      await db.update('vacinas_aplicadas', dataUpdate, where: 'id = ?', whereArgs: [existing.first['id']]);
    } else {
      await db.insert('vacinas_aplicadas', vacina.toMap());
    }
  }

  Future<List<VacinaAplicada>> getAppliedVaccines(int criancaId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('vacinas_aplicadas', where: 'criancaId = ?', whereArgs: [criancaId]);
    return List.generate(maps.length, (i) => VacinaAplicada.fromMap(maps[i]));
  }

  Future<void> deleteVaccine(int criancaId, String nomeVacina) async {
    final db = await database;
    await db.delete('vacinas_aplicadas', where: 'criancaId = ? AND nomeVacina = ?', whereArgs: [criancaId, nomeVacina]);
  }

}